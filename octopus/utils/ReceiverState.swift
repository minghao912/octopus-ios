//
//  ReceiverState.swift
//  octopus
//
//  Created by Minghao Chen on 2023.10.08.
//

import Foundation

class ReceiverState: ObservableObject, ConnectionState {
    @Published public var wsConnected: WSState
    @Published public var remoteConnected: Bool
    @Published public var remoteCode: String
    @Published public var fileType: Bool
    
    init() {
        self.wsConnected = .disconnected
        self.remoteConnected = false
        self.remoteCode = ""
        self.fileType = false
    }
}
