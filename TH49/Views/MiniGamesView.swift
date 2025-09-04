//
//  MiniGamesView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct MiniGamesView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedGame: MiniGame? = nil
    
    let miniGames = [
        MiniGame(
            id: "banana_catch",
            name: "Banana Catch",
            description: "Catch falling bananas as fast as you can!",
            icon: "🍌",
            difficulty: "Easy",
            reward: "5-15 coins per game"
        ),
        MiniGame(
            id: "monkey_jump",
            name: "Monkey Jump",
            description: "Help the monkey jump and collect treasures!",
            icon: "🐵",
            difficulty: "Medium",
            reward: "10-25 coins per game"
        ),
        MiniGame(
            id: "banana_match",
            name: "Banana Match",
            description: "Match bananas and gems in this puzzle game!",
            icon: "🧩",
            difficulty: "Hard",
            reward: "15-30 coins per game"
        )
    ]
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            if let game = selectedGame {
                GameViewContainer(game: game, gameState: gameState, onBack: {
                    selectedGame = nil
                })
            } else {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button(action: {
                            gameState.currentScreen = .home
                        }) {
                            HStack {
                                Text("🏠")
                                Text("Home")
                                    .font(.headline)
                                    .foregroundColor(BananaManiaColors.mainText)
                            }
                        }
                        .buttonStyle(JungleButtonStyle())
                        
                        Spacer()
                        
                        VStack {
                            Text("🎮 Mini-Games 🎮")
                                .font(.title.bold())
                                .foregroundColor(BananaManiaColors.bananaYellow)
                        }
                        
                        Spacer()
                        
                        // Balance display
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack {
                                Text("🪙")
                                Text("\(gameState.totalCoins)")
                                    .font(.headline.bold())
                                    .foregroundColor(BananaManiaColors.goldenYellow)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Games grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(miniGames) { game in
                            GameCard(game: game, gameState: gameState) {
                                selectedGame = game
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

struct MiniGame: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let difficulty: String
    let reward: String
}

struct GameCard: View {
    let game: MiniGame
    let gameState: GameState
    let onTap: () -> Void
    
    var highScore: Int {
        gameState.gameScores[game.id] ?? 0
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Game icon
                Text(game.icon)
                    .font(.system(size: 50))
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(BananaManiaColors.tropicalGreen.opacity(0.3))
                    )
                
                // Game info
                VStack(alignment: .leading, spacing: 8) {
                    Text(game.name)
                        .font(.title2.bold())
                        .foregroundColor(BananaManiaColors.mainText)
                    
                    Text(game.description)
                        .font(.subheadline)
                        .foregroundColor(BananaManiaColors.secondaryText)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("Difficulty: \(game.difficulty)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(difficultyColor.opacity(0.3))
                            )
                            .foregroundColor(difficultyColor)
                        
                        Spacer()
                        
                        if highScore > 0 {
                            Text("Best: \(highScore)")
                                .font(.caption.bold())
                                .foregroundColor(BananaManiaColors.goldenYellow)
                        }
                    }
                    
                    Text(game.reward)
                        .font(.caption)
                        .foregroundColor(BananaManiaColors.tropicalGreen)
                }
                
                Spacer()
                
                // Play arrow
                Text("▶️")
                    .font(.title)
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
        .woodenPanel()
    }
    
    private var difficultyColor: Color {
        switch game.difficulty {
        case "Easy": return BananaManiaColors.tropicalGreen
        case "Medium": return BananaManiaColors.bananaYellow
        case "Hard": return BananaManiaColors.tropicalRed
        default: return BananaManiaColors.secondaryText
        }
    }
}

struct GameViewContainer: View {
    let game: MiniGame
    @ObservedObject var gameState: GameState
    let onBack: () -> Void
    
    var body: some View {
        Group {
            switch game.id {
            case "banana_catch":
                BananaCatchGame(gameState: gameState, onBack: onBack)
            case "monkey_jump":
                MonkeyJumpGame(gameState: gameState, onBack: onBack)
            case "banana_match":
                BananaMatchGame(gameState: gameState, onBack: onBack)
            default:
                Text("Game not implemented")
                    .foregroundColor(BananaManiaColors.mainText)
            }
        }
    }
}

#Preview {
    MiniGamesView(gameState: GameState())
}