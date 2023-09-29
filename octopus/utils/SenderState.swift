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

class SenderState: ObservableObject {
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
