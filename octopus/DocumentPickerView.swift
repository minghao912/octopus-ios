//
//  DocumentPicker.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.24.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView<Content>: View where Content: View {
    let children: () -> Content

    @State private var showDocPicker: Bool = false
    
    init(@ViewBuilder children: @escaping () -> Content) {
        self.children = children
    }
    
    var body: some View {
        children()
            .sheet(isPresented: $showDocPicker) {
                DocumentPicker()
            }
            .onTapGesture {
                self.showDocPicker = true
            }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.content], asCopy: true)
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        
    }
}
