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
            content:
                LazyVStack {
                    ForEach(1...100, id: \.self) { value in
                        SampleCard(title: "\(value)")
                            .paddingWhen(.top, 10) { value == 1 }
                    }
                }
                .padding(.horizontal, 10)
                .eraseToAnyView()
            ,
            subtitleContent:
                HStack {
                    Button("Stop") {
                        stopRefreshing = true
                    }

                    Button("Reset") {
                        stopRefreshing = false
                    }

                    Text("value: \(stopRefreshing ? 1 : 0)")
                }
                .frame(height: 70)
//                filterFeed
                .eraseToAnyView()
                ,
            primaryActionLabel:
                Button(action: {

                }, label: {
                    Image(systemName: "heart")
                        .font(.system(size: 20, weight: .bold))
                })
                .eraseToAnyView(),
            stopRefreshing: $stopRefreshing,
            onRefresh: {
                print("Refresh requested!")
            }
        )
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

    var filterFeed: some View {
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
