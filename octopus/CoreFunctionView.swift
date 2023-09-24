//
//  CoreFunctionView.swift
//  octopus
//
//  Created by Minghao Chen on 2023.09.23.
//

import SwiftUI

struct CoreFunctionView: View {
    let sendMode: Bool
    let fileType: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("hello")
            }
        }
    }
}

#Preview {
    VStack {
        CoreFunctionView(sendMode: true, fileType: true)
    }
    .frame(maxHeight: 800)
}
