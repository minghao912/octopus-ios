//
//  SenderState.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import Foundation

struct SenderState {
    public var wsConnected: Bool
    public var remoteConnected: Bool
    public var fileSelected: Bool
    public var alreadySent: Bool
    public var remoteCode: String
    
    init() {
        self.wsConnected = false
        self.remoteConnected = false
        self.fileSelected = false
        self.alreadySent = false
        self.remoteCode = ""
    }
}
