//
//  InformationView.swift
//  LetSwift
//
//  Created by BumMo Koo on 7/13/24.
//

import SwiftUI

struct InformationView: View {
    
    init() {
        UINavigationBar.appearance().backgroundColor = .black
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(.white)]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(.white)]
        coloredAppearance.backgroundColor = .black
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blackBackground
                    .ignoresSafeArea(edges: .all)
                ScrollView {
                    VStack(spacing: 36) {
                        // Banner
                        Image("banner1")
                            .frame(height: 160)
                        sloganView
                        LocationAndDateView()
                        buttonStack
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Let'Swift 2024")
                        .font(.semiBold(size: 22))
                        .foregroundStyle(Color.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem {
            Label("information.title", image: "ic_home")
        }
        .toolbarBackground(.blackBackground, for: .tabBar)
    }
    
    var sloganView: some View {
        Text("One more step!\n한 걸음 넘어선 곳에는 무엇이 있을까요?")
            .padding(.bottom, 0)
            .multilineTextAlignment(.center)
            .font(.semiBold(size: 16))
            .foregroundStyle(Color.white)
            .padding(.bottom, 90)
    }
    
    var buttonStack: some View {
        HStack(spacing: 16) {
            LinkButton(title: "뉴스레터 구독", link: "")
            LinkButton(title: "홈페이지", link: "")
            LinkButton(title: "페스타", link: "")
        }
        
    }
}

#Preview {
    TabView {
        InformationView()
    }
    .environment(\.locale, .init(identifier: "ko"))
}
