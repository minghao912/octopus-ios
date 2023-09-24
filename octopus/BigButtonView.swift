//
//  BigButtonView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.22.
//

import SwiftUI

struct BigButtonView: View {
    var buttonAction: (() -> Void)?
    var buttonIcon: String
    var buttonText: String
    
    let config: Config = Config()
    
    var body: some View {
        Button(action: buttonAction ?? {}) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(config.buttonColor, lineWidth: 2)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    Image(systemName: buttonIcon)
                        .foregroundColor(config.textColor)
                        .frame(minWidth: 50, alignment: .leading)
                        .imageScale(.large)
                    Text(buttonText)
                        .foregroundColor(config.textColor)
                        .font(.title)
                        .frame(alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    public func setButtonColor(color: Color) -> Self {
        config.buttonColor = color
        return self
    }
    
    public func setTextColor(color: Color) -> Self {
        config.textColor = color
        return self
    }
}

public class Config: ObservableObject {
    @Published var buttonColor: Color = Color.black
    @Published var textColor: Color = Color.black
}

#Preview {
    BigButtonView(
        buttonAction: {},
        buttonIcon: "paperplane",
        buttonText: "Example"
    )
    .frame(maxWidth: 200, maxHeight: 100)
}
