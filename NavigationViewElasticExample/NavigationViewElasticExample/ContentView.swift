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
            title: "Products",
            blurStyle: .systemChromeMaterial,
            content: content,
            subtitleContent: subtitleContent,
            primaryActionLabel: primaryActionLabel,
            stopRefreshing: $stopRefreshing,
            onRefresh: {
                stopRefreshing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    stopRefreshing = true
                }
            }
        )
    }

    private var content: AnyView {
        LazyVStack {
            ForEach(1...2, id: \.self) { value in
                SampleCard(title: "\(value)")
                    .paddingWhen(.top, 10) { value == 1 }
            }
        }
        .padding(.horizontal, 10)
        .eraseToAnyView()
    }

    private var subtitleContent: AnyView {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(Product.allCases, id: \.self) { entry in
                    Text(entry.rawValue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(BlurEffect(style: .systemMaterial))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        .eraseToAnyView()
    }

    private var primaryActionLabel: AnyView {
        Button(
            action: {},
            label: {
                Image(systemName: "heart")
                    .font(.system(size: 20, weight: .bold))
            }
        )
        .eraseToAnyView()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

        SystemNavBar().previewDisplayName("System")
    }
}
