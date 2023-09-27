//
//  DocumentPicker.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.24.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView<Content>: View where Content: View {
    let onSuccess: (String, Data) -> Void
    let children: () -> Content

    @State private var showDocPicker: Bool = false
    
    init(onSuccess: @escaping (String, Data) -> Void, @ViewBuilder children: @escaping () -> Content) {
        self.onSuccess = onSuccess
        self.children = children
    }
    
    var body: some View {
        children()
            .sheet(isPresented: $showDocPicker) {
                DocumentPicker(onSuccess: self.onSuccess)
            }
            .onTapGesture {
                self.showDocPicker = true
            }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onSuccess: (String, Data) -> Void
    
    func makeCoordinator() -> DocumentPicker.Coordinator {
        return DocumentPicker.Coordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.content])
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                print("Error loading document data: Could not access security scoped resource")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            var error: NSError? = nil
            NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (cleanURL) in
                print("File chosen: \(cleanURL.lastPathComponent)")
                
                do {
                    // Read from URL as Data type
                    let data = try Data(contentsOf: cleanURL)
                    self.parent.onSuccess(cleanURL.lastPathComponent, data)
                } catch {
                    print("Error loading document data: \(error)")
                }
            }
        }
    }
}
