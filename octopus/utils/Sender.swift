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

class Sender {
    public var state: SenderState = SenderState()
    public var fileName: String = ""
    public var fileSize: UInt64 = 0
    public var fileData: Data? = nil {
        didSet {
            // If non-nil, call sendData
            if let fileData {
                sendData(fileData)
            }
        }
    }
    
    private var socket: Starscream.WebSocket?
    
    init() {
        print("Initializing WS")
        
        // Start WS
        var request = URLRequest(url: URL(string: WS_URL)!)
        request.timeoutInterval = 10
        
        self.socket = Starscream.WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    private func sendData(_ data: Data) {
        print("New data detected, sending...")
        print("Data: \(data)")
    }
}

extension Sender: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
            self.state.wsConnected = .connected
            
            // Initialize connection and request code
            client.write(string: "INIT")
            
            print("WebSocket is connected")
        case .disconnected(let reason, let code):
            self.state.wsConnected = .disconnected
            print("WebSocket is disconnected: \(reason) with code \(code)")
        case .text(let text):
            // The first message is the remote code, entirely numbers
            if (text.contains(/^\d+$/)) {
                self.state.remoteCode = text
                print("Received remote code \(text)")
            }
            // Handle received text data if needed
            print("Received text data: \(text)")
        case .binary(let data):
            // Handle received binary data if needed
            print("Received binary data: \(data)")
        case .ping, .pong, .viabilityChanged, .reconnectSuggested:
            // Handle other WebSocket events as needed
            break
        case .error(let error):
            self.state.wsConnected = .disconnected
            print("Error occurred with WS: \(error)")
        case .cancelled:
            self.state.wsConnected = .disconnected
        case .peerClosed:
            self.state.wsConnected = .disconnected
        }
    }
}
