//
//  SampleCard.swift
//  NavigationViewElasticExample
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

struct SampleCard: View {
    let title: String
    var loadingDuration: TimeInterval = 1

    @State var isAppearAnimationDone = false
    @State var color = Color.random

    var body: some View {
        ZStack {
            if isAppearAnimationDone {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            } else {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + loadingDuration) {
                isAppearAnimationDone = true
            }
        }
    }
}

struct SampleCard_Previews: PreviewProvider {
    static var previews: some View {
        SampleCard(title: "Title")
    }
}
