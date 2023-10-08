//
//  Helpers.swift
//  octopus
//
//  Created by Minghao Chen on 2023.10.08.
//

import Foundation
import SwiftUI

class HelperFunctions {
    @ViewBuilder public static func getConnectionStatus(_ cs: ConnectionState) -> some View {
        if (cs.wsConnected != .connected) {
            Text("Disconnected")
                .foregroundColor(.red)
            if (cs.remoteCode != "") {
                Text(" on \(cs.remoteCode)")
                    .fontWeight(.bold)
            }
        } else if (cs.wsConnected == .connected && !cs.remoteConnected) {
            VStack(spacing: 0) {
                Text("Waiting for remote connection")
                    .foregroundColor(.yellow)
                if (cs.remoteCode != "") {
                    Text(" on \(cs.remoteCode)")
                        .fontWeight(.bold)
                }
            }
        } else if (cs.wsConnected == .connected && cs.remoteConnected) {
            VStack(spacing: 0) {
                Text("Connected")
                    .foregroundColor(.green)
                if (cs.remoteCode != "") {
                    Text(" on \(cs.remoteCode)")
                        .fontWeight(.bold)
                }
            }
        }
    }
}
