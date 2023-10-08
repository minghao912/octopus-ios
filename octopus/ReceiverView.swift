//
//  ReceiverView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.10.08.
//

import Combine
import SwiftUI

struct ReceiverView: View {
    let fileType: Bool
    let restart: () -> Void
    
    @StateObject var receiver = Receiver()
    @State var showReceiverCard = false
    @State var showCodeInputField = true
    @State var receiverCode: String = ""
    
    init(fileType: Bool, restart: @escaping () -> Void) {
        self.fileType = fileType
        self.restart = restart
    }
    
    var body: some View {
        VStack {
            // Shouldn't do this but OK
            Button("Let's go!") {
                self.showReceiverCard = true
            }
        }
        .onAppear(perform: { self.showReceiverCard = true })
        .sheet(isPresented: self.$showReceiverCard, onDismiss: self.restart) {
            VStack {
                // Show text input for connection
                if (self.showCodeInputField) {
                    HStack {
                        TextField(
                            "Enter your 6-digit code",
                            text: $receiverCode
                        )
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.decimalPad)
                        .onReceive(Just(receiverCode)) { newVal in
                            // Numeric only
                            var filtered = newVal.filter { "0123456789".contains($0) }
                            
                            // Max 6 digits
                            if filtered.count > 6 {
                                filtered = String(filtered[filtered.startIndex..<filtered.index(filtered.startIndex, offsetBy: 6)])
                            }
                            
                            if filtered != newVal {
                                self.receiverCode = filtered
                            }
                        }
                        .padding()
                        
                        Button("Connect") {
                            self.receiver.setRemoteCode(code: receiverCode)
                            self.showCodeInputField = false
                            self.receiver.startReceiving()
                        }
                        .padding()
                    }
                } else {
                    // TODO: Isn't updating properly
                    HelperFunctions.getConnectionStatus(self.receiver.state)
                }
                
                
                Divider()
                Spacer()
                
                DownloadingSubview(receiver: self.receiver)
                    .padding()
            }
            .presentationDetents([.fraction(0.7)])
            .padding()
        }
    }
}

struct DownloadingSubview : View {
    @ObservedObject var receiver: Receiver
    
    var body: some View {
        Button("Hi") {
            
        }
    }
}

#Preview {
    VStack {
        ReceiverView(fileType: false, restart: {})
    }
    .frame(maxHeight: 800)
    .padding()
}
