//
//  FadingTextView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.21.
//

import Combine
import SwiftUI

struct FadingTextView: View {
    
    @Binding var source: String
    var transitionTime: Double
    
    @State private var currentText: String? = nil
    @State private var visible: Bool = false
    private var publisher: AnyPublisher<[String.Element], Never> {
        source
            .publisher
            .collect()
            .eraseToAnyPublisher()
    }
    
    init(text: Binding<String>, totalTransitionTime: Double) {
        self._source = text
        self.transitionTime = totalTransitionTime / 3
    }
    
    private func update(_: Any) {
        guard currentText != nil else {
            currentText = source
            DispatchQueue.main.asyncAfter(deadline: .now() + (transitionTime)) {
                self.visible = true
            }
            return
        }
        guard source != currentText else { return }
        self.visible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + (transitionTime)) {
            self.currentText = source
            DispatchQueue.main.asyncAfter(deadline: .now() + (transitionTime)) {
                self.visible = true
            }
        }
    }
    
    var body: some View {
        Text(currentText ?? "")
            .opacity(visible ? 1 : 0)
            .animation(.linear(duration: transitionTime), value: visible)
            .onReceive(publisher, perform: update(_:))
    }
    
}
