//
//  CoinBankView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct CoinBankView: View {
    @ObservedObject var gameState: GameState
    @State private var chestScale: CGFloat = 1.0
    @State private var showingCoins = false
    @State private var coinAnimations: [CoinAnimation] = []
    @State private var nextGoal = 500
    @State private var showGoalReached = false
    
    var progressToNextGoal: Double {
        Double(gameState.totalCoins) / Double(nextGoal)
    }
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            // Animated coin effects
            ForEach(coinAnimations, id: \.id) { coin in
                Text("🪙")
                    .font(.title)
                    .position(x: coin.position.x, y: coin.position.y)
                    .opacity(coin.opacity)
                    .scaleEffect(coin.scale)
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button("← Home") {
                            gameState.currentScreen = .home
                        }
                        .buttonStyle(JungleButtonStyle())
                        
                        Spacer()
                        
                        Text("🏦 Banana Bank 🏦")
                            .font(.title.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                        
                        Spacer()
                        
                        Button("💰 Deposit") {
                            depositCoins()
                        }
                        .buttonStyle(JungleButtonStyle())
                    }
                    .padding(.horizontal, 20)
                
                    // Main treasure chest
                    VStack(spacing: 20) {
                        Text("📦")
                            .font(.system(size: 120))
                            .scaleEffect(chestScale)
                            .onTapGesture {
                                animateChest()
                            }
                        
                        Text("Your Treasure Chest")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.goldenYellow)
                    }
                
                    // Balance display
                    VStack(spacing: 15) {
                        HStack(spacing: 30) {
                            BalanceItem(icon: "🪙", label: "Coins", amount: gameState.totalCoins, color: BananaManiaColors.goldenYellow)
                            BalanceItem(icon: "🍌", label: "Bananas", amount: gameState.totalBananas, color: BananaManiaColors.bananaYellow)
                        }
                        
                        // Goal progress
                        VStack(spacing: 10) {
                            HStack {
                                Text("Next Goal: \(nextGoal) coins")
                                    .font(.headline)
                                    .foregroundColor(BananaManiaColors.secondaryText)
                                
                                Spacer()
                                
                                Text("\(Int(progressToNextGoal * 100))%")
                                    .font(.headline.bold())
                                    .foregroundColor(BananaManiaColors.tropicalGreen)
                            }
                            
                            ProgressView(value: min(progressToNextGoal, 1.0))
                                .progressViewStyle(JungleProgressStyle())
                            
                            if progressToNextGoal >= 1.0 {
                                Button("🎉 Claim Goal Reward! 🎉") {
                                    claimGoalReward()
                                }
                                .buttonStyle(JungleButtonStyle())
                            }
                        }
                    }
                    .woodenPanel()
                
                    // Savings stats
                    VStack(spacing: 15) {
                        Text("💰 Savings Stats 💰")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                        
                        HStack(spacing: 30) {
                            StatItem(label: "Daily Streak", value: "\(gameState.dailyBonusStreak)", icon: "🔥")
                            StatItem(label: "Total Earned", value: "\(gameState.totalCoins + gameState.totalBananas * 5)", icon: "📈")
                        }
                        
                        HStack(spacing: 30) {
                            StatItem(label: "Games Played", value: "\(gameState.gameScores.count)", icon: "🎮")
                            StatItem(label: "Rewards Unlocked", value: "\(gameState.unlockedRewards.count)", icon: "🏆")
                        }
                    }
                    .woodenPanel()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            updateNextGoal()
        }
        .alert("Goal Achieved! 🎊", isPresented: $showGoalReached) {
            Button("Amazing!") {
                showGoalReached = false
            }
        } message: {
            Text("You reached your savings goal!\nBonus: 100 coins awarded!")
        }
    }
    
    private func animateChest() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            chestScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                chestScale = 1.0
            }
        }
        
        // Show coins flying out
        showCoinsAnimation()
    }
    
    private func depositCoins() {
        animateChest()
        
        // Add some bonus coins for depositing
        let bonus = max(1, gameState.totalCoins / 100)
        gameState.addCoins(bonus)
    }
    
    private func showCoinsAnimation() {
        for i in 0..<5 {
            let coin = CoinAnimation(
                id: UUID(),
                position: CGPoint(x: 200, y: 300),
                opacity: 1.0,
                scale: 1.0
            )
            coinAnimations.append(coin)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                if let index = coinAnimations.firstIndex(where: { $0.id == coin.id }) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        coinAnimations[index].position = CGPoint(
                            x: CGFloat.random(in: 100...300),
                            y: CGFloat.random(in: 150...250)
                        )
                        coinAnimations[index].opacity = 0.0
                        coinAnimations[index].scale = 0.5
                    }
                }
            }
        }
        
        // Clean up animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            coinAnimations.removeAll()
        }
    }
    
    private func updateNextGoal() {
        let goals = [500, 1000, 2500, 5000, 10000]
        nextGoal = goals.first { $0 > gameState.totalCoins } ?? 10000
    }
    
    private func claimGoalReward() {
        gameState.addCoins(100)
        updateNextGoal()
        showGoalReached = true
    }
}

struct BalanceItem: View {
    let icon: String
    let label: String
    let amount: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title)
            
            Text("\(amount)")
                .font(.title.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(BananaManiaColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(icon)
                .font(.title2)
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(BananaManiaColors.goldenYellow)
            
            Text(label)
                .font(.caption)
                .foregroundColor(BananaManiaColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct JungleProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(BananaManiaColors.darkEmerald)
                .frame(height: 20)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(BananaManiaColors.tropicalGreen)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 300, height: 20)
                .animation(.easeInOut, value: configuration.fractionCompleted)
        }
        .frame(width: 300)
    }
}

struct CoinAnimation: Identifiable {
    let id: UUID
    var position: CGPoint
    var opacity: Double
    var scale: CGFloat
}

#Preview {
    CoinBankView(gameState: GameState())
}