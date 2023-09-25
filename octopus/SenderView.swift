//
//  SenderView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import PhotosUI
import SwiftUI

struct SenderView: View {
    let fileType: Bool
    let restart: () -> Void
    
    @State var sender: Sender = Sender()
    @State var showCard: Bool = false
    
    @State var textToSend: String = ""
    @State var fileToSend: PhotosPickerItem? = nil
    
    init(fileType: Bool, restart: @escaping () -> Void) {
        self.fileType = fileType
        self.restart = restart
    }
    
    var body: some View {
        VStack {
            // Shouldn't do this but OK
            Button("Let's go!") {
                self.showCard = true
            }
        }
        .onAppear(perform: { self.showCard = true })
        .sheet(isPresented: $showCard, onDismiss: restart) {
            VStack {
                Text(fileType ? "Send a File" : "Send a Text")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                getConnectionStatus()
                    .frame(alignment: .leading)
                    .padding()
                
                if (!fileType) {
                    // Show text input field for text mode
                    ZStack(alignment: .leading) {
                        if (textToSend.isEmpty) {
                            VStack {
                                HStack {
                                    Text("Enter text")
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
                                Spacer()
                            }
                            .padding(.all)
                        }
                        
                        TextEditor(text: $textToSend)
                            .scrollContentBackground(.hidden)
                            .padding(.all)
                    }
                } else {
                    // Show document selector for file mode
                    VStack(spacing: 30) {
                        PhotosPicker(
                            selection: $fileToSend,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white, lineWidth: 2)
                                    .frame(maxWidth: .infinity)
                                
                                HStack(spacing: 0) {
                                    Image(systemName: "photo")
                                        .frame(minWidth: 50, alignment: .leading)
                                        .imageScale(.large)
                                    Text("Photo")
                                        .font(.title)
                                        .frame(alignment: .trailing)
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.borderless)
                        
                        DocumentPickerView() {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white, lineWidth: 2)
                                    .frame(maxWidth: .infinity)
                                
                                HStack(spacing: 0) {
                                    Image(systemName: "doc")
                                        .frame(minWidth: 50, alignment: .leading)
                                        .imageScale(.large)
                                    Text("File")
                                        .font(.title)
                                        .frame(alignment: .trailing)
                                }
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                Button("Test") {
                    sender.state.wsConnected = true
                    sender.state.remoteCode = "1234"
                }
                
                Button("Close") {
                    showCard = false
                }
            }
            .presentationDetents([.fraction(0.7)])
            .padding()
        }
    }
    
    @ViewBuilder private func getConnectionStatus() -> some View {
        if (!sender.state.wsConnected) {
            Text("Disconnected")
                .foregroundColor(.red)
        } else if (sender.state.wsConnected && !sender.state.remoteConnected) {
            VStack(spacing: 0) {
                Text("Waiting for remote connection")
                    .foregroundColor(.yellow)
                if (sender.state.remoteCode != "") {
                    Text(" on \(sender.state.remoteCode)")
                        .fontWeight(.bold)
                }
            }
        } else if (sender.state.wsConnected && sender.state.remoteConnected) {
            VStack(spacing: 0) {
                Text("Connected")
                    .foregroundColor(.yellow)
                if (sender.state.remoteCode != "") {
                    Text(" on \(sender.state.remoteCode)")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    VStack {
        SenderView(fileType: true, restart: {})
    }
    .frame(maxHeight: 800)
    .padding()
}