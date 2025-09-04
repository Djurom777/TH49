//
//  BananaCatchGame.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct BananaCatchGame: View {
    @ObservedObject var gameState: GameState
    let onBack: () -> Void
    
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var gameActive = false
    @State private var fallingBananas: [FallingBanana] = []
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var basketPosition: CGFloat = 0
    @State private var showGameOver = false
    @State private var earnedCoins = 0
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("← Back") {
                        endGame()
                        onBack()
                    }
                    .buttonStyle(JungleButtonStyle())
                    
                    Spacer()
                    
                    VStack {
                        Text("🍌 Banana Catch 🍌")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Score: \(score)")
                            .font(.headline.bold())
                            .foregroundColor(BananaManiaColors.goldenYellow)
                        Text("Time: \(timeRemaining)s")
                            .font(.subheadline)
                            .foregroundColor(BananaManiaColors.secondaryText)
                    }
                }
                .padding(.horizontal, 20)
                
                // Game area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(BananaManiaColors.darkEmerald)
                        .frame(height: 500)
                    
                    // Falling bananas
                    ForEach(fallingBananas) { banana in
                        Text("🍌")
                            .font(.title)
                            .position(x: banana.x, y: banana.y)
                            .onTapGesture {
                                catchBanana(banana)
                            }
                    }
                    
                    // Basket (monkey)
                    VStack {
                        Spacer()
                        Text("🐵")
                            .font(.system(size: 60))
                            .offset(x: basketPosition)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        basketPosition = max(-150, min(150, value.translation.width))
                                    }
                            )
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                
                // Game controls
                if !gameActive {
                    Button(timeRemaining == 30 ? "Start Game!" : "Play Again!") {
                        startGame()
                    }
                    .buttonStyle(JungleButtonStyle())
                } else {
                    Text("Drag the monkey to catch bananas!")
                        .font(.headline)
                        .foregroundColor(BananaManiaColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .alert("Game Over! 🎉", isPresented: $showGameOver) {
            Button("Collect Coins!") {
                gameState.addCoins(earnedCoins)
                showGameOver = false
            }
        } message: {
            Text("Final Score: \(score)\nYou earned \(earnedCoins) coins!")
        }
    }
    
    private func startGame() {
        score = 0
        timeRemaining = 30
        gameActive = true
        fallingBananas.removeAll()
        basketPosition = 0
        
        // Game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endGame()
            }
        }
        
        // Spawn timer
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            spawnBanana()
        }
    }
    
    private func endGame() {
        gameActive = false
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
        
        // Calculate coins earned
        earnedCoins = max(5, score / 10)
        gameState.updateGameScore(game: "banana_catch", score: score)
        
        showGameOver = true
    }
    
    private func spawnBanana() {
        let banana = FallingBanana(
            id: UUID(),
            x: CGFloat.random(in: 50...350),
            y: -50,
            speed: Double.random(in: 2.0...4.0)
        )
        fallingBananas.append(banana)
        
        // Animate falling
        animateBanana(banana)
    }
    
    private func animateBanana(_ banana: FallingBanana) {
        withAnimation(.linear(duration: banana.speed)) {
            if let index = fallingBananas.firstIndex(where: { $0.id == banana.id }) {
                fallingBananas[index].y = 600
            }
        }
        
        // Remove banana after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + banana.speed) {
            fallingBananas.removeAll { $0.id == banana.id }
        }
    }
    
    private func catchBanana(_ banana: FallingBanana) {
        // Check if banana is near the monkey
        let monkeyX = basketPosition + 200 // Adjust for screen center
        let distance = abs(banana.x - monkeyX)
        
        if distance < 50 && banana.y > 400 {
            score += 10
            fallingBananas.removeAll { $0.id == banana.id }
            
            // Add visual feedback
            withAnimation(.easeOut(duration: 0.3)) {
                // Could add particle effect here
            }
        }
    }
}

struct FallingBanana: Identifiable {
    let id: UUID
    let x: CGFloat
    var y: CGFloat
    let speed: Double
}

#Preview {
    BananaCatchGame(gameState: GameState(), onBack: {})
}