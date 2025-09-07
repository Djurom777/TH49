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
    @State private var gameAreaSize: CGSize = .zero
    
    let gravity: CGFloat = 0.8
    let jumpPower: CGFloat = -15
    let monkeySize: CGFloat = 40  // Размер обезьяны
    var groundLevel: CGFloat {
        gameAreaSize.height > 0 ? gameAreaSize.height * 0.7 : 280
    }
    var monkeyGroundY: CGFloat {
        groundLevel - monkeySize / 2  // Обезьяна стоит НА земле
    }
    
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
                            Text("🐵 Monkey Jump 🐵")
                                .font(.system(size: min(geometry.size.width * 0.06, 24), weight: .bold))
                                .foregroundColor(BananaManiaColors.bananaYellow)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            Text("Level \(level)")
                                .font(.system(size: min(geometry.size.width * 0.035, 16)))
                                .foregroundColor(BananaManiaColors.secondaryText)
                                .minimumScaleFactor(0.7)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Score: \(score)")
                                .font(.system(size: min(geometry.size.width * 0.04, 18), weight: .bold))
                                .foregroundColor(BananaManiaColors.goldenYellow)
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
                        
                        // Scrolling background effect
                        HStack(spacing: geometry.size.width * 0.05) {
                            ForEach(0..<10, id: \.self) { _ in
                                Text("🌳")
                                    .font(.system(size: min(geometry.size.width * 0.08, 32)))
                                    .opacity(0.3)
                            }
                        }
                        .offset(x: scrollOffset)
                        
                        // Collectibles
                        ForEach(collectibles) { item in
                            Text(item.type == .banana ? "🍌" : "🪙")
                                .font(.system(size: min(geometry.size.width * 0.06, 24)))
                                .position(x: item.position.x, y: item.position.y)
                        }
                        
                        // Obstacles
                        ForEach(obstacles) { obstacle in
                            Text("🪨")
                                .font(.system(size: min(geometry.size.width * 0.08, 32)))
                                .position(x: obstacle.position.x, y: obstacle.position.y)
                        }
                        
                        // Monkey
                        Text(isJumping ? "🙈" : "🐵")
                            .font(.system(size: min(geometry.size.width * 0.1, monkeySize)))
                            .position(x: monkeyPosition.x, y: monkeyPosition.y)
                        
                        // Ground line
                        Rectangle()
                            .fill(BananaManiaColors.woodenBrown)
                            .frame(height: 5)
                            .position(x: gameAreaSize.width / 2, y: groundLevel + 2.5)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .onTapGesture {
                        if gameActive && monkeyPosition.y >= monkeyGroundY - 5 {
                            jump()
                        }
                    }
                
                    // Game controls
                    if !gameActive {
                        VStack(spacing: geometry.size.height * 0.02) {
                            Text("Tap to make the monkey jump!\nCollect bananas and coins, avoid rocks!")
                                .font(.system(size: min(geometry.size.width * 0.04, 16)))
                                .foregroundColor(BananaManiaColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, geometry.size.width * 0.1)
                            
                            Button(score == 0 ? "Start Jumping!" : "Jump Again!") {
                                startGame()
                            }
                            .buttonStyle(JungleButtonStyle())
                        }
                    } else {
                        Text("Tap screen to jump!")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .medium))
                            .foregroundColor(BananaManiaColors.secondaryText)
                            .minimumScaleFactor(0.7)
                    }
                    
                    Spacer()
                }
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
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        monkeyPosition = CGPoint(x: gameWidth * 0.2, y: monkeyGroundY)
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
        if monkeyPosition.y >= monkeyGroundY {
            monkeyPosition.y = monkeyGroundY
            monkeyVelocity = 0
            isJumping = false
        }
        
        // Update scroll effect
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        scrollOffset -= 2
        if scrollOffset < -gameWidth {
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
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        let gameHeight = gameAreaSize.height > 0 ? gameAreaSize.height : 500
        let x = CGFloat.random(in: gameWidth * 1.1...(gameWidth * 1.5))
        let y = CGFloat.random(in: gameHeight * 0.2...(gameHeight * 0.6))
        let type: CollectibleType = Bool.random() ? .banana : .coin
        
        collectibles.append(Collectible(
            id: UUID(),
            position: CGPoint(x: x, y: y),
            type: type
        ))
    }
    
    private func spawnObstacles() {
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        let x = CGFloat.random(in: gameWidth * 1.2...(gameWidth * 1.8))
        let obstacleSize: CGFloat = 32  // Размер препятствия
        let y = groundLevel - obstacleSize / 2  // Препятствие стоит НА земле
        
        obstacles.append(Obstacle(
            id: UUID(),
            position: CGPoint(x: x, y: y)
        ))
    }
    
    private func checkCollisions() {
        let gameWidth = gameAreaSize.width > 0 ? gameAreaSize.width : 400
        let collectThreshold = gameWidth * 0.08 // 8% of game width
        let obstacleThreshold = gameWidth * 0.09 // 9% of game width
        
        // Check collectible collisions
        for collectible in collectibles {
            let distance = sqrt(
                pow(monkeyPosition.x - collectible.position.x, 2) +
                pow(monkeyPosition.y - collectible.position.y, 2)
            )
            
            if distance < collectThreshold {
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
            
            if distance < obstacleThreshold {
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