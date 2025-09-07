//
//  HomeView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var gameState: GameState
    @State private var swingingBananas: [SwingingBanana] = []
    @State private var animationTimer: Timer?
    @State private var showDailyBonus = false
    @State private var bonusAmount = 0
    
    var body: some View {
        ZStack {
            // Jungle background
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            // Animated background elements
            ForEach(swingingBananas) { banana in
                Text("🍌")
                    .font(.title2)
                    .offset(x: banana.xPosition, y: banana.yPosition)
                    .opacity(banana.opacity)
                    .animation(.easeInOut(duration: banana.duration), value: banana.xPosition)
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header with balance
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("🪙")
                                Text("\(gameState.totalCoins)")
                                    .font(.title2.bold())
                                    .foregroundColor(BananaManiaColors.goldenYellow)
                            }
                            
                            HStack {
                                Text("🍌")
                                Text("\(gameState.totalBananas)")
                                    .font(.title2.bold())
                                    .foregroundColor(BananaManiaColors.bananaYellow)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if gameState.checkDailyBonus() {
                                bonusAmount = min(gameState.dailyBonusStreak * 10, 100)
                                showDailyBonus = true
                            }
                        }) {
                            VStack {
                                Text("🎁")
                                    .font(.title)
                                Text("Daily")
                                    .font(.caption)
                                    .foregroundColor(BananaManiaColors.secondaryText)
                            }
                        }
                        .buttonStyle(JungleButtonStyle())
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                
                    // Welcome message
                    VStack(spacing: 10) {
                        Text("🐵 Welcome to Banana Mania! 🐵")
                            .font(.title.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                            .multilineTextAlignment(.center)
                        
                        Text("Choose your jungle adventure!")
                            .font(.title3)
                            .foregroundColor(BananaManiaColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                
                    // Main navigation buttons
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            NavigationButton(
                                title: "Mini-Games",
                                icon: "🎮",
                                description: "Play & Earn",
                                action: { gameState.currentScreen = .miniGames }
                            )
                            
                            NavigationButton(
                                title: "My Bank",
                                icon: "🏦",
                                description: "Save Coins",
                                action: { gameState.currentScreen = .coinBank }
                            )
                        }
                        
                        HStack(spacing: 20) {
                            NavigationButton(
                                title: "Rewards",
                                icon: "🏆",
                                description: "Unlock Prizes",
                                action: { gameState.currentScreen = .rewards }
                            )
                            
                            NavigationButton(
                                title: "Settings",
                                icon: "⚙️",
                                description: "Preferences",
                                action: { gameState.currentScreen = .settings }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                
                    // Fun facts or tips
                    VStack(spacing: 10) {
                        Text("🌟 Jungle Tip 🌟")
                            .font(.headline.bold())
                            .foregroundColor(BananaManiaColors.tropicalGreen)
                        
                        Text("Play daily to increase your bonus streak!")
                            .font(.subheadline)
                            .foregroundColor(BananaManiaColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .woodenPanel()
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            startSwingingBananas()
        }
        .onDisappear {
            stopSwingingBananas()
        }
        .alert("Daily Bonus! 🎉", isPresented: $showDailyBonus) {
            Button("Collect!") {
                showDailyBonus = false
            }
        } message: {
            Text("You earned \(bonusAmount) coins!\nStreak: \(gameState.dailyBonusStreak) days")
        }
    }
    
    private func startSwingingBananas() {
        // Create initial bananas
        for _ in 0..<3 {
            addSwingingBanana()
        }
        
        // Timer to add more bananas periodically
        animationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            addSwingingBanana()
            cleanupBananas()
        }
    }
    
    private func stopSwingingBananas() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func addSwingingBanana() {
        let banana = SwingingBanana(
            id: UUID(),
            xPosition: -200,
            yPosition: CGFloat.random(in: -200...(-50)),
            opacity: 1.0,
            duration: Double.random(in: 3.0...5.0)
        )
        
        swingingBananas.append(banana)
        
        // Animate across screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = swingingBananas.firstIndex(where: { $0.id == banana.id }) {
                swingingBananas[index].xPosition = 200
                swingingBananas[index].opacity = 0.0
            }
        }
    }
    
    private func cleanupBananas() {
        swingingBananas.removeAll { $0.opacity <= 0.1 }
    }
}

struct SwingingBanana: Identifiable {
    let id: UUID
    var xPosition: CGFloat
    let yPosition: CGFloat
    var opacity: Double
    let duration: Double
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 40))
                
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(BananaManiaColors.mainText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(BananaManiaColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(BananaManiaColors.buttonGradient)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(gameState: GameState())
}