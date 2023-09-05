//
//  ContentView.swift
//  NavigationViewElasticExample
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI
import NavigationViewElastic

struct ContentView: View {
    @State var stopRefreshing = false

    var body: some View {
        NavigationViewElastic(
            content: {
                LazyVStack {
                    ForEach(1...20, id: \.self) { value in
                        SampleCard(title: "\(value)")
                            .paddingWhen(.top, 10) { value == 1 }
                    }
                }
                .padding(.horizontal, 10)
            },
            subtitleContent: {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Product.allCases, id: \.self) { entry in
                            Button(action: { stopRefreshing = true }) {
                                Text(entry.rawValue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .paddingWhen(.leading, 10) {
                                entry == Product.allCases.first
                            }
                            .paddingWhen(.trailing, 10) {
                                entry == Product.allCases.last
                            }
                        }
                    }
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
        .navigationTitle("Title")
        .refreshable(stopRefreshing: $stopRefreshing, onRefresh: {})
    }
}

extension ContentView {
    enum Product: String, CaseIterable {
        case all = "All"
        case cake = "Cake"
        case lemon = "Lemon"
        case broccoli = "Broccoli"
        case milk = "Milk"
        case sausages = "Sausages"
        case icecream = "Ice cream"
    }
}

struct SystemNavBar: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(1...100, id: \.self) { value in
                        SampleCard(title: "\(value)")
                            .paddingWhen(.top, 10) { value == 1 }
                    }
                }
                .padding(.horizontal, 10)
            }
            .navigationTitle("Title")
            .refreshable {
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            }
        }
    }
}

struct SystemNavBarBackButton: View {
    @State var isLinkActivated = false

    var body: some View {
        NavigationView {
            NavigationLink(
                isActive: $isLinkActivated,
                destination: { destination }
            ) {
                Text("Go to NVE")
            }
            .onAppear {
                isLinkActivated.toggle()
            }
        }
    }

    var destination: some View {
        NavigationViewElastic(
            title: "Cards",
            content: {
                LazyVStack {
                    ForEach(1...20, id: \.self) { value in
                        SampleCard(title: "\(value)")
                            .paddingWhen(.top, 10) { value == 1 }
                    }
                }
                .padding(.horizontal, 10)
            },
            leadingBarItem: { NVE.BackButton() }
        )
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

        SystemNavBar().previewDisplayName("System")

        SystemNavBarBackButton().previewDisplayName("Back button")
    }
}
