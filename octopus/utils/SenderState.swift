//
//  SenderState.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import Foundation

class SenderState: ObservableObject, ConnectionState {
    @Published public var wsConnected: WSState
    @Published public var remoteConnected: Bool
    @Published public var fileSelected: Bool
    @Published public var alreadySent: Bool
    @Published public var remoteCode: String
    
    init() {
        self.wsConnected = .disconnected
        self.remoteConnected = false
        self.fileSelected = false
        self.alreadySent = false
        self.remoteCode = ""
    }
}
