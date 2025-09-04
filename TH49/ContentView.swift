//
//  ContentView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        ZStack {
            // Background that persists across all screens
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            // Main navigation
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
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Initialize any app-level setup
            setupNotifications()
        }
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
