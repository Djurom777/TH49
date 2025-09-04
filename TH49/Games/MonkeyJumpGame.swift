//
//  MonkeyJumpGame.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct MonkeyJumpGame: View {
    @ObservedObject var gameState: GameState
    let onBack: () -> Void
    
    @State private var score = 0
    @State private var level = 1
    @State private var gameActive = false
    @State private var monkeyPosition: CGPoint = CGPoint(x: 200, y: 400)
    @State private var monkeyVelocity: CGFloat = 0
    @State private var isJumping = false
    @State private var collectibles: [Collectible] = []
    @State private var obstacles: [Obstacle] = []
    @State private var gameTimer: Timer?
    @State private var showGameOver = false
    @State private var earnedCoins = 0
    @State private var scrollOffset: CGFloat = 0
    
    let gravity: CGFloat = 0.8
    let jumpPower: CGFloat = -15
    let groundLevel: CGFloat = 400
    
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
                        Text("🐵 Monkey Jump 🐵")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                        Text("Level \(level)")
                            .font(.subheadline)
                            .foregroundColor(BananaManiaColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Score: \(score)")
                            .font(.headline.bold())
                            .foregroundColor(BananaManiaColors.goldenYellow)
                    }
                }
                .padding(.horizontal, 20)
                
                // Game area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(BananaManiaColors.darkEmerald)
                        .frame(height: 500)
                    
                    // Scrolling background effect
                    HStack(spacing: 20) {
                        ForEach(0..<10, id: \.self) { _ in
                            Text("🌳")
                                .font(.title)
                                .opacity(0.3)
                        }
                    }
                    .offset(x: scrollOffset)
                    
                    // Collectibles
                    ForEach(collectibles) { item in
                        Text(item.type == .banana ? "🍌" : "🪙")
                            .font(.title2)
                            .position(x: item.position.x, y: item.position.y)
                    }
                    
                    // Obstacles
                    ForEach(obstacles) { obstacle in
                        Text("🪨")
                            .font(.title)
                            .position(x: obstacle.position.x, y: obstacle.position.y)
                    }
                    
                    // Monkey
                    Text(isJumping ? "🙈" : "🐵")
                        .font(.system(size: 40))
                        .position(x: monkeyPosition.x, y: monkeyPosition.y)
                    
                    // Ground line
                    Rectangle()
                        .fill(BananaManiaColors.woodenBrown)
                        .frame(height: 5)
                        .position(x: 200, y: groundLevel + 10)
                }
                .padding(.horizontal, 20)
                .onTapGesture {
                    if gameActive && monkeyPosition.y >= groundLevel - 5 {
                        jump()
                    }
                }
                
                // Game controls
                if !gameActive {
                    VStack(spacing: 15) {
                        Text("Tap to make the monkey jump!\nCollect bananas and coins, avoid rocks!")
                            .font(.subheadline)
                            .foregroundColor(BananaManiaColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        Button(score == 0 ? "Start Jumping!" : "Jump Again!") {
                            startGame()
                        }
                        .buttonStyle(JungleButtonStyle())
                    }
                } else {
                    Text("Tap screen to jump!")
                        .font(.headline)
                        .foregroundColor(BananaManiaColors.secondaryText)
                }
                
                Spacer()
            }
        }
        .alert("Level Complete! 🎉", isPresented: $showGameOver) {
            Button("Collect Coins!") {
                gameState.addCoins(earnedCoins)
                showGameOver = false
            }
            Button("Next Level") {
                level += 1
                startGame()
            }
        } message: {
            Text("Score: \(score)\nYou earned \(earnedCoins) coins!")
        }
    }
    
    private func startGame() {
        score = 0
        gameActive = true
        monkeyPosition = CGPoint(x: 200, y: groundLevel)
        monkeyVelocity = 0
        isJumping = false
        collectibles.removeAll()
        obstacles.removeAll()
        scrollOffset = 0
        
        // Spawn initial items
        spawnCollectibles()
        spawnObstacles()
        
        // Game loop
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateGame()
        }
    }
    
    private func endGame() {
        gameActive = false
        gameTimer?.invalidate()
        gameTimer = nil
        
        earnedCoins = max(10, score / 20)
        gameState.updateGameScore(game: "monkey_jump", score: score)
        showGameOver = true
    }
    
    private func updateGame() {
        // Update monkey physics
        monkeyVelocity += gravity
        monkeyPosition.y += monkeyVelocity
        
        // Keep monkey on ground
        if monkeyPosition.y >= groundLevel {
            monkeyPosition.y = groundLevel
            monkeyVelocity = 0
            isJumping = false
        }
        
        // Update scroll effect
        scrollOffset -= 2
        if scrollOffset < -400 {
            scrollOffset = 0
        }
        
        // Move collectibles and obstacles
        for i in collectibles.indices {
            collectibles[i].position.x -= CGFloat(2 + level)
        }
        
        for i in obstacles.indices {
            obstacles[i].position.x -= CGFloat(2 + level)
        }
        
        // Remove off-screen items
        collectibles.removeAll { $0.position.x < -50 }
        obstacles.removeAll { $0.position.x < -50 }
        
        // Check collisions
        checkCollisions()
        
        // Spawn new items
        if collectibles.count < 3 {
            spawnCollectibles()
        }
        if obstacles.count < 2 {
            spawnObstacles()
        }
        
        // Level progression
        if score > level * 100 {
            level += 1
        }
    }
    
    private func jump() {
        if !isJumping {
            monkeyVelocity = jumpPower
            isJumping = true
        }
    }
    
    private func spawnCollectibles() {
        let x = CGFloat.random(in: 450...600)
        let y = CGFloat.random(in: 200...350)
        let type: CollectibleType = Bool.random() ? .banana : .coin
        
        collectibles.append(Collectible(
            id: UUID(),
            position: CGPoint(x: x, y: y),
            type: type
        ))
    }
    
    private func spawnObstacles() {
        let x = CGFloat.random(in: 500...700)
        let y = groundLevel
        
        obstacles.append(Obstacle(
            id: UUID(),
            position: CGPoint(x: x, y: y)
        ))
    }
    
    private func checkCollisions() {
        // Check collectible collisions
        for collectible in collectibles {
            let distance = sqrt(
                pow(monkeyPosition.x - collectible.position.x, 2) +
                pow(monkeyPosition.y - collectible.position.y, 2)
            )
            
            if distance < 30 {
                score += collectible.type == .banana ? 20 : 30
                collectibles.removeAll { $0.id == collectible.id }
            }
        }
        
        // Check obstacle collisions
        for obstacle in obstacles {
            let distance = sqrt(
                pow(monkeyPosition.x - obstacle.position.x, 2) +
                pow(monkeyPosition.y - obstacle.position.y, 2)
            )
            
            if distance < 35 {
                endGame()
                return
            }
        }
    }
}

struct Collectible: Identifiable {
    let id: UUID
    var position: CGPoint
    let type: CollectibleType
}

enum CollectibleType {
    case banana, coin
}

struct Obstacle: Identifiable {
    let id: UUID
    var position: CGPoint
}

#Preview {
    MonkeyJumpGame(gameState: GameState(), onBack: {})
}