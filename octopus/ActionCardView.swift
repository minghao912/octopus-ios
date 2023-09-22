//
//  ActionCardView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.22.
//

import Steps
import SwiftUI

struct StepItem {
    var title: String
    var image: Image?
}

let baseSteps: [StepItem] = [
    StepItem(title: "Mode", image: Image(systemName: "antenna.radiowaves.left.and.right")),
    StepItem(title: "Type", image: Image(systemName: "paperclip")),
    StepItem(title: "Item", image: Image(systemName: "arrow.up.arrow.down"))
]

struct ActionCardView: View {
    @State @ObservedObject private var stepsState: StepsState<StepItem>
    @State private var currentStepDetails: [StepItem]
    
    init() {
        currentStepDetails = baseSteps
        stepsState = StepsState(data: baseSteps)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(Color(red: 6/255, green: 2/255, blue: 38/255))
            .shadow(color: .black, radius: 8, x: 4, y: 4) // Apply shadow to the wrapper view
            .overlay(
                VStack {
                    VStack {
                        Steps(
                            state: stepsState,
                            onCreateStep: { item in
                                return Step(title: item.title, image: item.image)
                            }
                        )
                        .itemSpacing(10)
                        .primaryColor(.white)
                        .secondaryColor(.black)
                        .font(.caption)
                        .padding()
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 30) {
                        BigButtonView(buttonAction: { updateMode(sendMode: true) }, buttonIcon: "paperplane", buttonText: "Send")
                            .setButtonColor(color: .white)
                            .setTextColor(color: .white)
                        BigButtonView(buttonAction: { updateMode(sendMode: false) }, buttonIcon: "arrow.down.to.line", buttonText: "Receive")
                            .setButtonColor(color: .white)
                            .setTextColor(color: .white)
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        self.stepsState = StepsState(data: baseSteps)
                        self.stepsState.setStep(0)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "house")
                                .foregroundColor(.white)
                            Text("Restart")
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                }
            )
    }
    
    private func updateMode(sendMode: Bool) -> Void {
        currentStepDetails[0] = StepItem(
            title: sendMode ? "Send" : "Receive",
            image: Image(systemName: "antenna.radiowaves.left.and.right")
        )
        
        self.stepsState = StepsState(data: currentStepDetails)
        self.stepsState.setStep(1)
    }
}

#Preview {
    ActionCardView()
}
