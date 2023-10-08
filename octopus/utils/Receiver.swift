//
//  Receiver.swift
//  octopus
//
//  Created by Minghao Chen on 2023.10.08.
//

import Foundation
import Starscream

class Receiver: ObservableObject {
    let WS_URL = "wss://octopus-server.chenminghao.co/server-ws/receive"
    // let WS_URL = "ws://localhost:8089"
    
    @Published public var state: ReceiverState = ReceiverState()
    @Published public var fileMetadata: FileMetadata? = nil
    @Published public var totalReceivedBytes: UInt64 = 0
    
    private var socket: Starscream.WebSocket?
    
    deinit {
        print("Disconnecting WS for \(self.state.remoteCode)")
        self.socket?.disconnect()
    }
    
    public func setRemoteCode(code: String) {
        self.state.remoteCode = code
    }
    
    public func startReceiving() {
        print("Initializing Receiver WS")
        
        // Start WS
        var request = URLRequest(url: URL(string: self.WS_URL)!)
        request.timeoutInterval = 10
        
        self.socket = Starscream.WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    private func handleNewFileContents_(_ b64: String) {
        print(b64)
    }
}

extension Receiver: WebSocketDelegate {
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
        client.write(string: "\(self.state.remoteCode): INIT")
    }
    
    private func onText_(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient, text: String) {
        print("Received text data: \(text)")
        
        // The first message may be file metadata (indicates FILE type)
        if (text.starts(with: "FILE")) {
            self.state.fileType = true
            
            // Split metadata
            let parts = text.split(separator: ",")
            let filename = String(parts[1])
            
            guard let filesize = UInt64(parts[2]), let chunks = UInt64(parts[3]) else {
                print("Error parsing filesize or chunksize in message: \(text)")
                return
            }
            
            self.fileMetadata = FileMetadata(
                filename: filename,
                filesize: filesize,
                chunks: chunks
            )
        } else if (text.starts(with: "ERROR")) {
            print("Error from WS server\n\(text)");
            self.state.wsConnected = .disconnected
        } else if (text.starts(with: "OK")) {
            print(text);
        } else {
            print("Message data received");
            
            // This is the contents of the file
            self.handleNewFileContents_(text);
        }
    }
    
    private func onData_(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient, data: Data) {
        print("Received binary data: \(data)")
    }
}

class FileMetadata {
    var filename: String
    var filesize: UInt64
    var chunks: UInt64
    
    init (filename: String, filesize: UInt64, chunks: UInt64) {
        self.filename = filename
        self.filesize = filesize
        self.chunks = chunks
    }
}
