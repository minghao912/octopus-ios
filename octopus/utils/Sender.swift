//
//  Sender.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import Foundation

struct Sender {
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
    
    init() {
        // Start WS
    }
    
    private func sendData(_ data: Data) {
        print("New data detected, sending...")
        print("Data: \(data)")
    }
}
