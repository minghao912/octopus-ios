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
    StepItem(title: "Choose Mode", image: Image(systemName: "antenna.radiowaves.left.and.right")),
    StepItem(title: "Choose Type", image: Image(systemName: "paperclip")),
    StepItem(title: "Transmit Item", image: Image(systemName: "arrow.up.arrow.down"))
]

struct ActionCardView: View {
    @State @ObservedObject private var stepsState: StepsState<StepItem>
    @State private var currentStepDetails: [StepItem]
    @State private var currentStepNumber: Int = 0
    
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
                    
                    getCardContent(currentStepNumber)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        self.stepsState = StepsState(data: baseSteps)
                        self.stepsState.setStep(0)
                        self.currentStepDetails = baseSteps
                        self.currentStepNumber = 0
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.gray)
                            Text("Restart")
                        }
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
            )
    }
    
    @ViewBuilder private func getCardContent(_ step: Int) -> some View {
        switch step {
        case 0:
            VStack(spacing: 30) {
                BigButtonView(buttonAction: { updateMode(sendMode: true) }, buttonIcon: "paperplane", buttonText: "Send")
                    .setButtonColor(color: .white)
                    .setTextColor(color: .white)
                BigButtonView(buttonAction: { updateMode(sendMode: false) }, buttonIcon: "arrow.down.to.line", buttonText: "Receive")
                    .setButtonColor(color: .white)
                    .setTextColor(color: .white)
            }
        case 1:
            VStack(spacing: 30) {
                BigButtonView(buttonAction: { updateType(fileType: true) }, buttonIcon: "doc", buttonText: "File")
                    .setButtonColor(color: .white)
                    .setTextColor(color: .white)
                BigButtonView(buttonAction: { updateType(fileType: false) }, buttonIcon: "textformat", buttonText: "Text")
                    .setButtonColor(color: .white)
                    .setTextColor(color: .white)
            }
        case 2:
            VStack(spacing: 30) {
            }
        default:
            exit(1)
        }
    }
    
    private func updateMode(sendMode: Bool) -> Void {
        currentStepDetails[0] = StepItem(
            title: sendMode ? "Send" : "Receive",
            image: Image(systemName: "antenna.radiowaves.left.and.right")
        )
        currentStepDetails[2] = StepItem(
            title: sendMode ? "Send Item" : "Receive Item",
            image: Image(systemName: sendMode ? "arrow.up" : "arrow.down")
        )
        
        self.stepsState = StepsState(data: currentStepDetails)
        self.stepsState.setStep(1)
        self.currentStepNumber = 1
    }
    
    private func updateType(fileType: Bool) -> Void {
        currentStepDetails[1] = StepItem(
            title: fileType ? "File" : "Text",
            image: Image(systemName: "paperclip")
        )
        currentStepDetails[2] = StepItem(
            title: currentStepDetails[2].title.replacingOccurrences(of: "Item", with: fileType ? "File" : "Text"),
            image: currentStepDetails[2].image
        )
        
        self.stepsState = StepsState(data: currentStepDetails)
        self.stepsState.setStep(2)
        self.currentStepNumber = 2
    }
}

#Preview {
    ActionCardView()
}
