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
    @State var showFileSelectorCard: Bool = false
    @State var showFilePreviewCard: Bool = false
    
    @State var textToSend: String = ""
    @State var photoToSendPre: PhotosPickerItem? = nil
    @State var photoToSendImg: UIImage? = nil
    @State var fileToSendName: String = ""
    
    init(fileType: Bool, restart: @escaping () -> Void) {
        self.fileType = fileType
        self.restart = restart
    }
    
    var body: some View {
        VStack {
            // Shouldn't do this but OK
            Button("Let's go!") {
                self.showFileSelectorCard = true
            }
        }
        .onAppear(perform: { self.showFileSelectorCard = true })
        .sheet(isPresented: $showFileSelectorCard, onDismiss: restart) {
            VStack {
                Text(fileType ? "Send a File" : "Send a Text")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
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
                    
                    // Turn text into raw data
                    Button(
                        action: {
                            sender.fileData = textToSend.data(using: .utf8)
                            
                            self.showFileSelectorCard = false
                            self.showFilePreviewCard = true
                        }
                    ) {
                        HStack(spacing: 0) {
                            Image(systemName: "paperplane")
                                .foregroundColor(.white)
                                .frame(minWidth: 50, alignment: .leading)
                                .imageScale(.medium)
                            Text("Send")
                                .foregroundColor(.white)
                                .frame(alignment: .trailing)
                        }
                    }
                } else {
                    // Show document selector for file mode
                    VStack(spacing: 30) {
                        PhotosPicker(
                            selection: $photoToSendPre,
                            matching: .any(of: [.images, .videos]),
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
                        .onChange(of: photoToSendPre) { newPhoto in
                            // When photo is chosen, load it in as Data type
                            Task {
                                if let newPhoto {
                                    // This loads the photo as raw data, for sending
                                    newPhoto.loadTransferable(type: Data.self) { result in
                                        DispatchQueue.main.async {
                                            guard newPhoto == self.photoToSendPre else {
                                                print("Failed to get selected photo")
                                                return
                                            }
                                            
                                            switch result {
                                            case .success(let data):
                                                print("Success loading photo")
                                                
                                                // Set sender data
                                                sender.fileData = data
                                                self.photoToSendImg = UIImage(data: data!)
                                                
                                                // Show preview card
                                                self.showFileSelectorCard = false
                                                self.showFilePreviewCard = true
                                            case .failure(let error):
                                                print("Failed loading photo: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        DocumentPickerView(
                            onSuccess: { filename, data in
                                // Set sender data
                                self.fileToSendName = filename
                                sender.fileData = data
                                
                                // Show preview card
                                self.showFileSelectorCard = false
                                self.showFilePreviewCard = true
                            }
                        ) {
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
            }
            .presentationDetents([.fraction(0.7)])
            .padding()
        }
        .sheet(isPresented: $showFilePreviewCard, onDismiss: restart) {
            FilePreviewView(
                connectionStatusView: AnyView(self.getConnectionStatus()),
                textToSend: $textToSend,
                photoToSendImg: $photoToSendImg,
                fileToSendName: $fileToSendName
            )
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

struct FilePreviewView: View {
    let connectionStatusView: AnyView
    
    @Binding var textToSend: String
    @Binding var photoToSendImg: UIImage?
    @Binding var fileToSendName: String
    
    var body: some View {
        VStack {
            connectionStatusView
                .frame(alignment: .leading)
                .padding()
            
            Divider()
            Spacer()
            
            // Show text preview
            if (!textToSend.isEmpty) {
                TextEditor(text: $textToSend)
                    .scrollContentBackground(.hidden)
                    .padding(.all)
                    .disabled(true)
                    .scrollIndicators(.visible)
            }
            // Show photo preview
            else if self.photoToSendImg != nil {
                Image(uiImage: self.photoToSendImg!)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            // Show file preview
            else if (!fileToSendName.isEmpty) {
                VStack {
                    Image(systemName: "doc")
                        .font(.system(size: 144))
                        .fontWeight(.light)
                        .padding(.bottom)
                    
                    Text(fileToSendName)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            // Show error
            else {
                Text("File preview not available")
            }
            
            Spacer()
        }
        .presentationDetents([.fraction(0.7)])
        .padding()
    }
}

#Preview {
    VStack {
        SenderView(fileType: true, restart: {})
    }
    .frame(maxHeight: 800)
    .padding()
}
