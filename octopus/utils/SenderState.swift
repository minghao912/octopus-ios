//
//  SenderState.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import Foundation

enum WSState {
    case disconnected
    case connecting
    case connected
}

struct SenderState {
    public var wsConnected: WSState
    public var remoteConnected: Bool
    public var fileSelected: Bool
    public var alreadySent: Bool
    public var remoteCode: String
    
    init() {
        self.wsConnected = .disconnected
        self.remoteConnected = false
        self.fileSelected = false
        self.alreadySent = false
        self.remoteCode = ""
    }
}
