//
//  ConnectionState.swift
//  octopus
//
//  Created by Minghao Chen on 2023.10.08.
//

import Foundation

protocol ConnectionState {
    var wsConnected: WSState { get set }
    var remoteConnected: Bool { get set }
    var remoteCode: String { get set }
}
