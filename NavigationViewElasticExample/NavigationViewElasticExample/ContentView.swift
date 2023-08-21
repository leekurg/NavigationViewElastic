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
                            Button(action: {}) {
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
        .refreshable(stopRefreshing: .constant(false), onRefresh: {})
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
                Text("Go to")
            }
            .onAppear {
                isLinkActivated.toggle()
            }
        }
    }

    var destination: some View {
        VStack {
            BackButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

    }
}

struct BackButton: View {
    var action: (() -> Void)? = nil
    var title: String? = nil

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.accentColor)
                    .font(.system(size: 22, weight: .medium))

                Text(title ?? "Back")
            }
            .padding(.init(top: 5, leading: 8, bottom: 5, trailing: 5))

            .foregroundColor(Color.accentColor)
        }
    }

    private func onTap() {
        if let _ = action {
            action?()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

        SystemNavBar().previewDisplayName("System")

        SystemNavBarBackButton().previewDisplayName("Back")
    }
}
