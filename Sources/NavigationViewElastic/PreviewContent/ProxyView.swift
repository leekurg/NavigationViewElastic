//
//  ProxyView.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 30.10.2024.
//

import SwiftUI

#if DEBUG
struct ProxyView: View {
    @State var stopRefreshing = false

    var body: some View {
        NavigationViewElastic(
            content: {
                Color.clear.frame(height: 10)

                LazyVStack {
                    ForEach(1...20, id: \.self) { value in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray)
                            .frame(height: 150)
                            .overlay {
                                Text("\(value)")
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .nveTitle("Title")
                .nveTitleDisplayMode(.inline)
                .padding(.horizontal, 10)
            },
            subtitleContent: {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Product.allCases, id: \.self) { entry in
                            Button(action: { stopRefreshing = true }) {
                                Text(entry.rawValue)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.bottom, 10)
            },
            leadingBarItem: { NVE.BackButton() },
            trailingBarItem: {
                Button {
                } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.trailing, 10)
                }
            }
        )
        .refreshable(stopRefreshing: $stopRefreshing, onRefresh: {})
        .preferredColorScheme(.dark)
        .background(Color(white: 0.12))
        .nveConfig { config in
            config.largeTitle.topEdgeInset = 20
        }
    }
}

enum Product: String, CaseIterable {
    case all = "All"
    case cake = "Cake"
    case lemon = "Lemon"
    case broccoli = "Broccoli"
    case milk = "Milk"
    case sausages = "Sausages"
    case icecream = "Ice cream"
}

#Preview {
    ProxyView()
}

#endif
