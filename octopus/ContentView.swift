//
//  ContentView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HeaderView()

            Spacer()
            
            ActionCardView()
                .padding()
            
            Spacer()
            
            Text("Preview Build")
        }
        .padding()
        .foregroundColor(.white)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(red: 05/255, green: 05/255, blue: 35/255),
                        Color(red: 15/255, green: 10/255, blue: 20/255)
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    ContentView()
}
