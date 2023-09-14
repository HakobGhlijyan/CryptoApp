//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 01.08.2023.
//

import SwiftUI

@main
struct CryptoAppApp: App {
    
    @StateObject private var vm = HomeViewModel()
    
    @State private var showLaunchView:Bool = true
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(Color.theme.accent)]
        UINavigationBar.appearance().tintColor = UIColor(Color.theme.accent)
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                //0
                NavigationStack {
                    HomeView()
                        .navigationBarHidden(true)
                }
                .environmentObject(vm)
                .zIndex(0.0)
                
                //1
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(AnyTransition.move(edge: .leading))
                    }
                }
                .zIndex(1.0)
            }
        }
    }
}
