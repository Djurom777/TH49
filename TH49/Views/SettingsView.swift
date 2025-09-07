//
//  SettingsView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameState: GameState
    @State private var showResetAlert = false
    @State private var showAboutSheet = false
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                HStack {
                    Button("← Home") {
                        gameState.currentScreen = .home
                    }
                    .buttonStyle(JungleButtonStyle())
                    
                    Spacer()
                    
                    Text("⚙️ Settings ⚙️")
                        .font(.title.bold())
                        .foregroundColor(BananaManiaColors.bananaYellow)
                    
                    Spacer()
                    
                    Button("ℹ️") {
                        showAboutSheet = true
                    }
                    .buttonStyle(JungleButtonStyle())
                }
                .padding(.horizontal, 20)
                
                // Settings sections
                ScrollView {
                    VStack(spacing: 20) {
                        // Game Stats
                        SettingsSection(title: "📊 Your Stats", icon: "📈") {
                            VStack(spacing: 15) {
                                StatRow(label: "Total Coins Earned", value: "\(gameState.totalCoins)", icon: "🪙")
                                StatRow(label: "Total Bananas", value: "\(gameState.totalBananas)", icon: "🍌")
                                StatRow(label: "Games Played", value: "\(gameState.gameScores.count)", icon: "🎮")
                                StatRow(label: "Rewards Unlocked", value: "\(gameState.unlockedRewards.count)/\(GameState.availableRewards.count)", icon: "🏆")
                                StatRow(label: "Daily Streak", value: "\(gameState.dailyBonusStreak) days", icon: "🔥")
                            }
                        }
                        
                        // Game Management
                        SettingsSection(title: "🎮 Game Management", icon: "🔧") {
                            VStack(spacing: 15) {
                                Button(action: {
                                    showResetAlert = true
                                }) {
                                    HStack {
                                        Text("🗑️")
                                        Text("Reset Game Progress")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    .foregroundColor(BananaManiaColors.tropicalRed)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(BananaManiaColors.darkEmerald.opacity(0.5))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // App Info
                        VStack(spacing: 10) {
                            Text("🐵 Banana Mania 🐵")
                                .font(.title2.bold())
                                .foregroundColor(BananaManiaColors.bananaYellow)
                            
                            Text("Made with 🍌 and ❤️")
                                .font(.caption)
                                .foregroundColor(BananaManiaColors.secondaryText)
                        }
                        .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Reset Game Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {
                showResetAlert = false
            }
            Button("Reset", role: .destructive) {
                resetGameProgress()
            }
        } message: {
            Text("This will delete all your progress, coins, and unlocked rewards. This cannot be undone!")
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
    }
    
    private func resetGameProgress() {
        // Clear all UserDefaults
        let keys = ["totalCoins", "totalBananas", "hasCompletedOnboarding", "unlockedRewards", "gameScores", "dailyBonusStreak", "lastBonusDate", "userSettings"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Reset game state
        gameState.totalCoins = 0
        gameState.totalBananas = 0
        gameState.hasCompletedOnboarding = false
        gameState.unlockedRewards.removeAll()
        gameState.gameScores.removeAll()
        gameState.dailyBonusStreak = 0
        gameState.lastBonusDate = nil
        gameState.settings = UserSettings()
        gameState.currentScreen = .onboarding
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(BananaManiaColors.bananaYellow)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .woodenPanel()
    }
}



struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title3)
                .frame(width: 30)
            
            Text(label)
                .font(.headline)
                .foregroundColor(BananaManiaColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(BananaManiaColors.goldenYellow)
        }
    }
}



struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button("✕") {
                        dismiss()
                    }
                    .font(.title2)
                    .foregroundColor(BananaManiaColors.secondaryText)
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 20) {
                    Text("🐵")
                        .font(.system(size: 100))
                    
                    Text("About Banana Mania")
                        .font(.title.bold())
                        .foregroundColor(BananaManiaColors.bananaYellow)
                    
                    VStack(spacing: 15) {
                        Text("Welcome to the ultimate jungle adventure!")
                        Text("Play exciting mini-games, save your coins in the Banana Bank, and unlock amazing rewards.")
                        Text("Join our monkey friends in this tropical paradise and become the ultimate banana collector!")
                    }
                    .font(.headline)
                    .foregroundColor(BananaManiaColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 10) {
                        Text("🌟 Features 🌟")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.tropicalGreen)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "🎮", text: "3 Unique Mini-Games")
                            FeatureRow(icon: "🏦", text: "Savings & Goal Tracking")
                            FeatureRow(icon: "🏆", text: "Unlockable Rewards")
                            FeatureRow(icon: "🎁", text: "Daily Bonus System")
                            FeatureRow(icon: "📱", text: "Beautiful Animations")
                        }
                    }
                }
                .woodenPanel()
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title3)
            Text(text)
                .font(.headline)
                .foregroundColor(BananaManiaColors.secondaryText)
            Spacer()
        }
    }
}

#Preview {
    SettingsView(gameState: GameState())
}