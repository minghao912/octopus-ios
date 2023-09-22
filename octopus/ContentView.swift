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
                .foregroundColor(Color.white)

            Spacer()
            
            ActionCardView()
                .padding()
            
            Spacer()
            
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(red: 14/255, green: 06/255, blue: 72/255),
                        Color(red: 32/255, green: 22/255, blue: 42/255)
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
