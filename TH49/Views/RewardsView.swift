//
//  RewardsView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct RewardsView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedReward: Reward? = nil
    @State private var showUnlockAnimation = false
    @State private var celebrationMonkeys: [CelebrationMonkey] = []
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            // Celebration monkeys animation
            ForEach(celebrationMonkeys, id: \.id) { monkey in
                Text("🐵")
                    .font(.title)
                    .position(x: monkey.position.x, y: monkey.position.y)
                    .scaleEffect(monkey.scale)
                    .opacity(monkey.opacity)
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Button("← Home") {
                            gameState.currentScreen = .home
                        }
                        .buttonStyle(JungleButtonStyle())
                        
                        Spacer()
                        
                        VStack {
                            Text("🏆 Jungle Gallery 🏆")
                                .font(.title.bold())
                                .foregroundColor(BananaManiaColors.bananaYellow)
                            Text("Unlock amazing treasures!")
                                .font(.subheadline)
                                .foregroundColor(BananaManiaColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                Text("🪙")
                                Text("\(gameState.totalCoins)")
                                    .font(.headline.bold())
                                    .foregroundColor(BananaManiaColors.goldenYellow)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Rewards grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(GameState.availableRewards) { reward in
                            RewardCard(
                                reward: reward,
                                isUnlocked: gameState.unlockedRewards.contains(reward.id),
                                canAfford: gameState.totalCoins >= reward.cost
                            ) {
                                selectedReward = reward
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Progress summary
                    VStack(spacing: 10) {
                        Text("🌟 Collection Progress 🌟")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.tropicalGreen)
                        
                        Text("\(gameState.unlockedRewards.count) / \(GameState.availableRewards.count) rewards unlocked")
                            .font(.headline)
                            .foregroundColor(BananaManiaColors.secondaryText)
                        
                        ProgressView(value: Double(gameState.unlockedRewards.count) / Double(GameState.availableRewards.count))
                            .progressViewStyle(JungleProgressStyle())
                    }
                    .woodenPanel()
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .sheet(item: $selectedReward) { reward in
            RewardDetailView(
                reward: reward,
                gameState: gameState,
                isUnlocked: gameState.unlockedRewards.contains(reward.id),
                canAfford: gameState.totalCoins >= reward.cost,
                onPurchase: {
                    purchaseReward(reward)
                },
                onDismiss: {
                    selectedReward = nil
                }
            )
        }
        .alert("Reward Status", isPresented: $showPurchaseAlert) {
            Button("OK") {
                showPurchaseAlert = false
            }
        } message: {
            Text(purchaseMessage)
        }
    }
    
    private func purchaseReward(_ reward: Reward) {
        if gameState.unlockedRewards.contains(reward.id) {
            purchaseMessage = "You already own this reward!"
            showPurchaseAlert = true
        } else if gameState.totalCoins >= reward.cost {
            let _ = gameState.spendCoins(reward.cost)
            gameState.unlockReward(reward.id)
            
            purchaseMessage = reward.unlockMessage
            showPurchaseAlert = true
            
            // Trigger celebration animation
            startCelebrationAnimation()
            selectedReward = nil
        } else {
            purchaseMessage = "Not enough coins! You need \(reward.cost - gameState.totalCoins) more coins."
            showPurchaseAlert = true
        }
    }
    
    private func startCelebrationAnimation() {
        // Create celebrating monkeys
        for i in 0..<6 {
            let monkey = CelebrationMonkey(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...400)
                ),
                scale: 0.5,
                opacity: 1.0
            )
            celebrationMonkeys.append(monkey)
            
            // Animate monkey celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                if let index = celebrationMonkeys.firstIndex(where: { $0.id == monkey.id }) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        celebrationMonkeys[index].scale = 1.5
                    }
                    
                    withAnimation(.easeOut(duration: 2.0).delay(1.0)) {
                        celebrationMonkeys[index].opacity = 0.0
                        celebrationMonkeys[index].position.y -= 100
                    }
                }
            }
        }
        
        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            celebrationMonkeys.removeAll()
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let isUnlocked: Bool
    let canAfford: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Reward icon
                ZStack {
                    Circle()
                        .fill(isUnlocked ? BananaManiaColors.tropicalGreen : BananaManiaColors.darkEmerald)
                        .frame(width: 80, height: 80)
                    
                    if isUnlocked {
                        Image(systemName: reward.iconName)
                            .font(.system(size: 30))
                            .foregroundColor(BananaManiaColors.goldenYellow)
                    } else {
                        Text("🔒")
                            .font(.title)
                    }
                }
                
                // Reward info
                VStack(spacing: 6) {
                    Text(reward.name)
                        .font(.headline.bold())
                        .foregroundColor(isUnlocked ? BananaManiaColors.goldenYellow : BananaManiaColors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    if !isUnlocked {
                        HStack {
                            Text("🪙")
                            Text("\(reward.cost)")
                                .font(.subheadline.bold())
                                .foregroundColor(canAfford ? BananaManiaColors.tropicalGreen : BananaManiaColors.tropicalRed)
                        }
                    } else {
                        Text("✅ Unlocked")
                            .font(.subheadline.bold())
                            .foregroundColor(BananaManiaColors.tropicalGreen)
                    }
                }
            }
            .padding(20)
            .frame(height: 180)
        }
        .buttonStyle(PlainButtonStyle())
        .woodenPanel()
        .opacity(isUnlocked ? 1.0 : (canAfford ? 0.9 : 0.6))
    }
}

struct RewardDetailView: View {
    let reward: Reward
    @ObservedObject var gameState: GameState
    let isUnlocked: Bool
    let canAfford: Bool
    let onPurchase: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button("✕") {
                        onDismiss()
                    }
                    .font(.title2)
                    .foregroundColor(BananaManiaColors.secondaryText)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Reward showcase
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(BananaManiaColors.goldenYellow.opacity(0.3))
                            .frame(width: 150, height: 150)
                        
                        if isUnlocked {
                            Image(systemName: reward.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(BananaManiaColors.goldenYellow)
                        } else {
                            Text("🔒")
                                .font(.system(size: 60))
                        }
                    }
                    
                    Text(reward.name)
                        .font(.title.bold())
                        .foregroundColor(BananaManiaColors.bananaYellow)
                    
                    Text(reward.description)
                        .font(.title3)
                        .foregroundColor(BananaManiaColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Purchase section
                VStack(spacing: 15) {
                    if isUnlocked {
                        VStack(spacing: 10) {
                            Text("🎉 Congratulations! 🎉")
                                .font(.title2.bold())
                                .foregroundColor(BananaManiaColors.tropicalGreen)
                            
                            Text("You own this amazing reward!")
                                .font(.headline)
                                .foregroundColor(BananaManiaColors.secondaryText)
                        }
                    } else {
                        VStack(spacing: 15) {
                            HStack {
                                Text("Cost:")
                                    .font(.title2)
                                    .foregroundColor(BananaManiaColors.secondaryText)
                                
                                HStack {
                                    Text("🪙")
                                    Text("\(reward.cost)")
                                        .font(.title.bold())
                                        .foregroundColor(canAfford ? BananaManiaColors.tropicalGreen : BananaManiaColors.tropicalRed)
                                }
                            }
                            
                            HStack {
                                Text("Your balance:")
                                    .font(.headline)
                                    .foregroundColor(BananaManiaColors.secondaryText)
                                
                                HStack {
                                    Text("🪙")
                                    Text("\(gameState.totalCoins)")
                                        .font(.headline.bold())
                                        .foregroundColor(BananaManiaColors.goldenYellow)
                                }
                            }
                            
                            if canAfford {
                                Button("🛒 Purchase Reward") {
                                    onPurchase()
                                }
                                .buttonStyle(JungleButtonStyle())
                            } else {
                                VStack(spacing: 10) {
                                    Text("Need \(reward.cost - gameState.totalCoins) more coins")
                                        .font(.headline)
                                        .foregroundColor(BananaManiaColors.tropicalRed)
                                    
                                    Text("Play more games to earn coins!")
                                        .font(.subheadline)
                                        .foregroundColor(BananaManiaColors.secondaryText)
                                }
                            }
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

struct CelebrationMonkey: Identifiable {
    let id: UUID
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
}

#Preview {
    RewardsView(gameState: GameState())
}