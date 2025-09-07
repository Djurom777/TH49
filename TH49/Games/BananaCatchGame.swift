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
    @State private var gameAreaSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: min(geometry.size.height * 0.02, 20)) {
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
                                .font(.system(size: min(geometry.size.width * 0.06, 24), weight: .bold))
                                .foregroundColor(BananaManiaColors.bananaYellow)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Score: \(score)")
                                .font(.system(size: min(geometry.size.width * 0.04, 18), weight: .bold))
                                .foregroundColor(BananaManiaColors.goldenYellow)
                                .minimumScaleFactor(0.7)
                            Text("Time: \(timeRemaining)s")
                                .font(.system(size: min(geometry.size.width * 0.035, 16)))
                                .foregroundColor(BananaManiaColors.secondaryText)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                
                    // Game area
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(BananaManiaColors.darkEmerald)
                            .frame(height: geometry.size.height * 0.6)
                            .background(
                                GeometryReader { gameGeo in
                                    Color.clear
                                        .onAppear {
                                            gameAreaSize = gameGeo.size
                                        }
                                        .onChange(of: gameGeo.size) { newSize in
                                            gameAreaSize = newSize
                                        }
                                }
                            )
                        
                        // Falling bananas
                        ForEach(fallingBananas) { banana in
                            Text("🍌")
                                .font(.system(size: min(geometry.size.width * 0.08, 32)))
                                .position(x: banana.x, y: banana.y)
                                .onTapGesture {
                                    catchBanana(banana)
                                }
                        }
                        
                        // Basket (monkey)
                        VStack {
                            Spacer()
                            Text("🐵")
                                .font(.system(size: min(geometry.size.width * 0.15, 60)))
                                .offset(x: basketPosition)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let maxOffset = (gameAreaSize.width - 60) / 2
                                            basketPosition = max(-maxOffset, min(maxOffset, value.translation.width))
                                        }
                                )
                        }
                        .padding(.bottom, geometry.size.height * 0.02)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                
                    // Game controls
                    if !gameActive {
                        Button(timeRemaining == 30 ? "Start Game!" : "Play Again!") {
                            startGame()
                        }
                        .buttonStyle(JungleButtonStyle())
                    } else {
                        Text("Drag the monkey to catch bananas!")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .medium))
                            .foregroundColor(BananaManiaColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, geometry.size.width * 0.1)
                    }
                    
                    Spacer()
                }
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
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        let minX = gameWidth * 0.1
        let maxX = gameWidth * 0.9
        
        let banana = FallingBanana(
            id: UUID(),
            x: CGFloat.random(in: minX...maxX),
            y: -50,
            speed: Double.random(in: 2.0...4.0)
        )
        fallingBananas.append(banana)
        
        // Animate falling
        animateBanana(banana)
    }
    
    private func animateBanana(_ banana: FallingBanana) {
        let gameHeight = gameAreaSize.height > 0 ? gameAreaSize.height : 500
        
        withAnimation(.linear(duration: banana.speed)) {
            if let index = fallingBananas.firstIndex(where: { $0.id == banana.id }) {
                fallingBananas[index].y = gameHeight + 50
            }
        }
        
        // Remove banana after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + banana.speed) {
            fallingBananas.removeAll { $0.id == banana.id }
        }
    }
    
    private func catchBanana(_ banana: FallingBanana) {
        // Check if banana is near the monkey
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        let gameHeight = gameAreaSize.height > 0 ? gameAreaSize.height : 500
        let monkeyX = basketPosition + gameWidth / 2 // Adjust for screen center
        let distance = abs(banana.x - monkeyX)
        let catchThreshold = gameWidth * 0.12 // 12% of game width
        let bottomThreshold = gameHeight * 0.75 // 75% down the game area
        
        if distance < catchThreshold && banana.y > bottomThreshold {
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