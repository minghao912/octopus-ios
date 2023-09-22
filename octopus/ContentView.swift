//
//  ContentView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.18.
//

import SwiftUI

struct ContentView: View {
    // Dynamic fading text
    let SENDABLE_NOUNS: [String] = ["photos", "videos", "bills", "homework", "drawings", "letters", "blueprints"]
    let SENDABLE_NOUNS_TRANSITION_TIME_MS: Int = 1500
    @State private var currentSendableNounIndex: Int = 0
    @State private var currentSendableNoun: String = "photos"
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Octopus")
                    .font(.largeTitle)
                HStack(spacing: 0) {
                    Text("Send ")
                    FadingTextView(text: $currentSendableNoun, totalTransitionTime: Double(SENDABLE_NOUNS_TRANSITION_TIME_MS) / 1000)
        
                    Text(" to anyone, anywhere.")
                }
                .onAppear() {
                    // Hold the current text for a little bit, then change to next
                    Timer.scheduledTimer(
                        withTimeInterval: Double(SENDABLE_NOUNS_TRANSITION_TIME_MS * 2) / 1000,
                        repeats: true,
                        block: { _ in
                            currentSendableNounIndex += 1
                            currentSendableNoun = SENDABLE_NOUNS[currentSendableNounIndex % SENDABLE_NOUNS.count]
                        }
                    )
                }
                
            }
            .padding()
            
            Spacer()
            
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
