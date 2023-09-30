//
//  Sender.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import Foundation
import Starscream

let WS_URL = "wss://octopus-server.chenminghao.co/server-ws/send"
// let WS_URL = "ws://localhost:8089"

class Sender: ObservableObject {
    @Published public var state: SenderState = SenderState()
    
    public var fileName: String = ""
    public var fileData: Data? = nil {
        didSet {
            // If non-nil, call sendData
            if let fileData {
                DispatchQueue.main.async { [weak self] in
                    self?.sendData(fileData)
                }
            }
        }
    }
    
    private var socket: Starscream.WebSocket?
    private var sendQueue: [String] = []
    
    init() {
        print("Initializing WS")
        
        // Start WS
        var request = URLRequest(url: URL(string: WS_URL)!)
        request.timeoutInterval = 10
        
        self.socket = Starscream.WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    deinit {
        print("Disconnecting WS for \(self.state.remoteCode)")
        self.socket?.disconnect()
    }
    
    private func sendData(_ data: Data) {
        print("New data of size \(data) detected")
        
        let connectionReady = (self.state.wsConnected == .connected) && self.state.remoteConnected
        
        // Text only
        if fileName.isEmpty {
            let toSend = "\(self.state.remoteCode): \(String(data: data, encoding: .utf8) ?? "")"
            
            if (connectionReady) {
                print("Sending message")
                self.socket?.write(string: toSend)
            } else {
                print("Connection not yet ready, queueing item")
                self.sendQueue.append(toSend)
            }
        }
        // File
        else {
            // First split file into chunks
            print("Splitting file into chunks")
            let chunks = chunkifyData_(fileData: data, chunkSize: 1024 * 1 /* 1KB */)
            
            // Send "handshake" message telling server that we are sending file
            // Also includes filename, filesize, chunk count
            let metadata = "\(self.state.remoteCode): FILE,\(self.fileName.replacingOccurrences(of: ",", with: "-")),\(data.count),\(chunks.count)"
            if (connectionReady) {
                self.socket?.write(string: metadata)
                print("Sent file metadata")
            } else {
                self.sendQueue.append(metadata)
                print("Connection not ready, adding file metadata to queue")
            }
            
            // Add metadata to chunks then send to remote
            for (i, c) in chunks.enumerated() {
                print("Processing new chunk #\(i)")
                
                // Get binary data from Data (1024 B)
                let fileBinaryData = Array(c)
                
                // Create metadata
                var segmentNumber = Int32(i)
                var segmentSize = Int16(fileBinaryData.count)
                
                // Combine into one Data object, with padding
                var finalBinaryData = Data()
                finalBinaryData.append(Data(bytes: &segmentNumber, count: MemoryLayout<Int32>.size))
                finalBinaryData.append(Data(bytes: &segmentSize, count: MemoryLayout<Int16>.size))
                finalBinaryData.append(contentsOf: fileBinaryData)
                
                // Send to remote
                let finalData = finalBinaryData.base64EncodedString()
                
                if (connectionReady) {
                    print("Sending message")
                    self.socket?.write(string: "\(self.state.remoteCode): \(finalData)")
                } else {
                    print("Connection not yet ready, queueing item")
                    self.sendQueue.append("\(self.state.remoteCode): \(finalData)")
                }
                
            }
        }
    }
    
    private func chunkifyData_(fileData: Data, chunkSize: Int) -> [Data] {
        var chunks: [Data] = []
        var currentIndex = 0
        
        while currentIndex < fileData.count {
            let remainingCount = fileData.count - currentIndex
            let chunkLength = min(chunkSize, remainingCount)
            let chunkRange = currentIndex..<currentIndex + chunkLength
            let chunkData = fileData.subdata(in: chunkRange)
            chunks.append(chunkData)
            currentIndex += chunkLength
        }
        
        return chunks
    }
}

extension Sender: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            onConnect_(event: event, client: client, headers: headers)
        case .disconnected(let reason, let code):
            self.state.wsConnected = .disconnected
            print("WebSocket is disconnected: \(reason) with code \(code)")
        case .text(let text):
            onText_(event: event, client: client, text: text)
        case .binary(let data):
            onData_(event: event, client: client, data: data)
        case .error(let error):
            self.state.wsConnected = .disconnected
            print("Error occurred with WS: \(String(describing: error))")
        case .cancelled:
            self.state.wsConnected = .disconnected
        case .peerClosed:
            self.state.wsConnected = .disconnected
        case .ping, .pong, .viabilityChanged, .reconnectSuggested:
            // Handle other WebSocket events as needed
            break
        }
    }
    
    private func onConnect_(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient, headers: [String: String]) {
        print("WebSocket is connected")
        
        // Initialize connection and request code
        self.state.wsConnected = .connected
        client.write(string: "INIT")
    }
    
    private func onText_(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient, text: String) {
        print("Received text data: \(text)")
        
        // The first message is the remote code, entirely numbers
        if (text.contains(/^\d+$/)) {
            self.state.remoteCode = text
            print("Received remote code \(text)")
        }
        
        // The second message should be "Connection Received" indicating remote connection OK
        else if (text == "Connection received") {
            self.state.remoteConnected = true
            print("Remote connection established")
            
            // If user already queued something to send, send it now
            if (!self.sendQueue.isEmpty) {
                print("Queue detected, sending...")
                for e in self.sendQueue {
                    client.write(string: e)
                }
            }
        }
    }
    
    private func onData_(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient, data: Data) {
        print("Received binary data: \(data)")
    }
}
