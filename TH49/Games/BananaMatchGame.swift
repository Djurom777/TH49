//
//  BananaMatchGame.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct BananaMatchGame: View {
    @ObservedObject var gameState: GameState
    let onBack: () -> Void
    
    @State private var score = 0
    @State private var moves = 20
    @State private var gameActive = false
    @State private var grid: [[GameTile]] = []
    @State private var selectedTile: GridPosition? = nil
    @State private var showGameOver = false
    @State private var earnedCoins = 0
    @State private var matchingTiles: Set<GridPosition> = []
    @State private var animatingMatches = false
    
    let gridSize = 6
    let tileTypes = ["🍌", "🥥", "🍊", "🍇", "💎"]
    
    var body: some View {
        ZStack {
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("← Back") {
                        onBack()
                    }
                    .buttonStyle(JungleButtonStyle())
                    
                    Spacer()
                    
                    VStack {
                        Text("🧩 Banana Match 🧩")
                            .font(.title2.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Score: \(score)")
                            .font(.headline.bold())
                            .foregroundColor(BananaManiaColors.goldenYellow)
                        Text("Moves: \(moves)")
                            .font(.subheadline)
                            .foregroundColor(moves > 5 ? BananaManiaColors.secondaryText : BananaManiaColors.tropicalRed)
                    }
                }
                .padding(.horizontal, 20)
                
                // Game grid
                if gameActive {
                    VStack(spacing: 4) {
                        ForEach(0..<gridSize, id: \.self) { row in
                            HStack(spacing: 4) {
                                ForEach(0..<gridSize, id: \.self) { col in
                                    GameTileView(
                                        tile: grid[row][col],
                                        isSelected: selectedTile == GridPosition(row: row, col: col),
                                        isMatching: matchingTiles.contains(GridPosition(row: row, col: col))
                                    ) {
                                        handleTileTap(row: row, col: col)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .woodenPanel()
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 20) {
                        Text("🎯 Match 3 or more identical items!")
                            .font(.title3.bold())
                            .foregroundColor(BananaManiaColors.bananaYellow)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 10) {
                            Text("🍌 Bananas = 10 points")
                            Text("🥥 Coconuts = 15 points")
                            Text("🍊 Oranges = 20 points")
                            Text("🍇 Grapes = 25 points")
                            Text("💎 Gems = 50 points")
                        }
                        .font(.subheadline)
                        .foregroundColor(BananaManiaColors.secondaryText)
                        
                        Button(score == 0 ? "Start Matching!" : "Play Again!") {
                            startGame()
                        }
                        .buttonStyle(JungleButtonStyle())
                    }
                    .woodenPanel()
                    .padding(.horizontal, 30)
                }
                
                Spacer()
            }
        }
        .alert("Game Over! 🎊", isPresented: $showGameOver) {
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
        moves = 20
        gameActive = true
        selectedTile = nil
        matchingTiles.removeAll()
        initializeGrid()
    }
    
    private func endGame() {
        gameActive = false
        earnedCoins = max(15, score / 15)
        gameState.updateGameScore(game: "banana_match", score: score)
        showGameOver = true
    }
    
    private func initializeGrid() {
        grid = []
        for row in 0..<gridSize {
            var rowTiles: [GameTile] = []
            for col in 0..<gridSize {
                let tileType = tileTypes.randomElement()!
                rowTiles.append(GameTile(
                    id: UUID(),
                    type: tileType,
                    position: GridPosition(row: row, col: col)
                ))
            }
            grid.append(rowTiles)
        }
        
        // Ensure no initial matches
        removeInitialMatches()
    }
    
    private func removeInitialMatches() {
        var hasMatches = true
        while hasMatches {
            hasMatches = false
            
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if findMatches(at: GridPosition(row: row, col: col)).count >= 3 {
                        grid[row][col].type = tileTypes.randomElement()!
                        hasMatches = true
                    }
                }
            }
        }
    }
    
    private func handleTileTap(row: Int, col: Int) {
        guard gameActive && !animatingMatches else { return }
        
        let position = GridPosition(row: row, col: col)
        
        if let selected = selectedTile {
            if selected == position {
                // Deselect
                selectedTile = nil
            } else if areAdjacent(selected, position) {
                // Attempt swap
                swapTiles(selected, position)
                selectedTile = nil
            } else {
                // Select new tile
                selectedTile = position
            }
        } else {
            selectedTile = position
        }
    }
    
    private func swapTiles(_ pos1: GridPosition, _ pos2: GridPosition) {
        let temp = grid[pos1.row][pos1.col]
        grid[pos1.row][pos1.col] = grid[pos2.row][pos2.col]
        grid[pos2.row][pos2.col] = temp
        
        // Update positions
        grid[pos1.row][pos1.col].position = pos1
        grid[pos2.row][pos2.col].position = pos2
        
        // Check for matches
        let matches1 = findMatches(at: pos1)
        let matches2 = findMatches(at: pos2)
        
        if matches1.count >= 3 || matches2.count >= 3 {
            moves -= 1
            processMatches()
        } else {
            // Swap back if no matches
            let temp2 = grid[pos1.row][pos1.col]
            grid[pos1.row][pos1.col] = grid[pos2.row][pos2.col]
            grid[pos2.row][pos2.col] = temp2
            
            grid[pos1.row][pos1.col].position = pos1
            grid[pos2.row][pos2.col].position = pos2
        }
        
        if moves <= 0 {
            endGame()
        }
    }
    
    private func processMatches() {
        animatingMatches = true
        var allMatches: Set<GridPosition> = []
        
        // Find all matches
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let matches = findMatches(at: GridPosition(row: row, col: col))
                if matches.count >= 3 {
                    allMatches.formUnion(matches)
                }
            }
        }
        
        if !allMatches.isEmpty {
            matchingTiles = allMatches
            
            // Calculate score
            for position in allMatches {
                let tile = grid[position.row][position.col]
                score += getPointsForTile(tile.type)
            }
            
            // Remove matched tiles after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                removeMatchedTiles(allMatches)
                dropTiles()
                fillEmptySpaces()
                matchingTiles.removeAll()
                animatingMatches = false
                
                // Check for cascade matches
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    processMatches()
                }
            }
        } else {
            animatingMatches = false
        }
    }
    
    private func findMatches(at position: GridPosition) -> Set<GridPosition> {
        let tile = grid[position.row][position.col]
        var matches: Set<GridPosition> = [position]
        
        // Check horizontal matches
        var left = position.col - 1
        while left >= 0 && grid[position.row][left].type == tile.type {
            matches.insert(GridPosition(row: position.row, col: left))
            left -= 1
        }
        
        var right = position.col + 1
        while right < gridSize && grid[position.row][right].type == tile.type {
            matches.insert(GridPosition(row: position.row, col: right))
            right += 1
        }
        
        // Check vertical matches
        var up = position.row - 1
        while up >= 0 && grid[up][position.col].type == tile.type {
            matches.insert(GridPosition(row: up, col: position.col))
            up -= 1
        }
        
        var down = position.row + 1
        while down < gridSize && grid[down][position.col].type == tile.type {
            matches.insert(GridPosition(row: down, col: position.col))
            down += 1
        }
        
        return matches
    }
    
    private func removeMatchedTiles(_ matches: Set<GridPosition>) {
        for position in matches {
            grid[position.row][position.col].type = ""
        }
    }
    
    private func dropTiles() {
        for col in 0..<gridSize {
            var writeIndex = gridSize - 1
            
            for row in stride(from: gridSize - 1, through: 0, by: -1) {
                if !grid[row][col].type.isEmpty {
                    if writeIndex != row {
                        grid[writeIndex][col] = grid[row][col]
                        grid[writeIndex][col].position = GridPosition(row: writeIndex, col: col)
                        grid[row][col].type = ""
                    }
                    writeIndex -= 1
                }
            }
        }
    }
    
    private func fillEmptySpaces() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col].type.isEmpty {
                    grid[row][col] = GameTile(
                        id: UUID(),
                        type: tileTypes.randomElement()!,
                        position: GridPosition(row: row, col: col)
                    )
                }
            }
        }
    }
    
    private func areAdjacent(_ pos1: GridPosition, _ pos2: GridPosition) -> Bool {
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.col - pos2.col)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func getPointsForTile(_ type: String) -> Int {
        switch type {
        case "🍌": return 10
        case "🥥": return 15
        case "🍊": return 20
        case "🍇": return 25
        case "💎": return 50
        default: return 10
        }
    }
}

struct GameTile: Identifiable {
    let id: UUID
    var type: String
    var position: GridPosition
}

struct GridPosition: Hashable {
    let row: Int
    let col: Int
}

struct GameTileView: View {
    let tile: GameTile
    let isSelected: Bool
    let isMatching: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(tile.type)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
                        )
                )
                .scaleEffect(isMatching ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isMatching)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isMatching {
            return BananaManiaColors.tropicalGreen.opacity(0.8)
        } else if isSelected {
            return BananaManiaColors.bananaYellow.opacity(0.6)
        } else {
            return BananaManiaColors.woodenBrown.opacity(0.8)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return BananaManiaColors.goldenYellow
        } else {
            return BananaManiaColors.secondaryText.opacity(0.3)
        }
    }
}

#Preview {
    BananaMatchGame(gameState: GameState(), onBack: {})
}