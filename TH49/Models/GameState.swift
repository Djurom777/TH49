//
//  GameState.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Game State Management
class GameState: ObservableObject {
    @Published var totalCoins: Int = 0
    @Published var totalBananas: Int = 0
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentScreen: AppScreen = .onboarding
    @Published var unlockedRewards: Set<String> = []
    @Published var gameScores: [String: Int] = [:]
    @Published var settings: UserSettings = UserSettings()
    
    // Daily bonus tracking
    @Published var lastBonusDate: Date?
    @Published var dailyBonusStreak: Int = 0
    
    init() {
        loadGameData()
    }
    
    func addCoins(_ amount: Int) {
        totalCoins += amount
        saveGameData()
    }
    
    func addBananas(_ amount: Int) {
        totalBananas += amount
        saveGameData()
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if totalCoins >= amount {
            totalCoins -= amount
            saveGameData()
            return true
        }
        return false
    }
    
    func updateGameScore(game: String, score: Int) {
        if gameScores[game] == nil || score > gameScores[game]! {
            gameScores[game] = score
            saveGameData()
        }
    }
    
    func unlockReward(_ rewardId: String) {
        unlockedRewards.insert(rewardId)
        saveGameData()
    }
    
    func checkDailyBonus() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastBonus = lastBonusDate {
            let lastBonusDay = Calendar.current.startOfDay(for: lastBonus)
            
            if Calendar.current.isDate(today, inSameDayAs: lastBonusDay) {
                return false // Already collected today
            }
            
            let daysBetween = Calendar.current.dateComponents([.day], from: lastBonusDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                dailyBonusStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                dailyBonusStreak = 1
            }
        } else {
            // First time
            dailyBonusStreak = 1
        }
        
        lastBonusDate = Date()
        let bonusAmount = min(dailyBonusStreak * 10, 100) // Max 100 coins
        addCoins(bonusAmount)
        return true
    }
    
    private func saveGameData() {
        // Save to UserDefaults
        UserDefaults.standard.set(totalCoins, forKey: "totalCoins")
        UserDefaults.standard.set(totalBananas, forKey: "totalBananas")
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(Array(unlockedRewards), forKey: "unlockedRewards")
        UserDefaults.standard.set(gameScores, forKey: "gameScores")
        UserDefaults.standard.set(dailyBonusStreak, forKey: "dailyBonusStreak")
        
        if let lastBonus = lastBonusDate {
            UserDefaults.standard.set(lastBonus, forKey: "lastBonusDate")
        }
        
        // Save settings
        if let settingsData = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(settingsData, forKey: "userSettings")
        }
    }
    
    private func loadGameData() {
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        totalBananas = UserDefaults.standard.integer(forKey: "totalBananas")
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        dailyBonusStreak = UserDefaults.standard.integer(forKey: "dailyBonusStreak")
        lastBonusDate = UserDefaults.standard.object(forKey: "lastBonusDate") as? Date
        
        let rewardsArray = UserDefaults.standard.array(forKey: "unlockedRewards") as? [String] ?? []
        unlockedRewards = Set(rewardsArray)
        
        gameScores = UserDefaults.standard.dictionary(forKey: "gameScores") as? [String: Int] ?? [:]
        
        // Load settings
        if let settingsData = UserDefaults.standard.data(forKey: "userSettings"),
           let loadedSettings = try? JSONDecoder().decode(UserSettings.self, from: settingsData) {
            settings = loadedSettings
        }
        
        currentScreen = hasCompletedOnboarding ? .home : .onboarding
    }
}

// MARK: - App Screens
enum AppScreen {
    case onboarding
    case home
    case miniGames
    case coinBank
    case rewards
    case settings
}

// MARK: - User Settings
struct UserSettings: Codable {
    var soundEnabled: Bool = true
    var vibrationEnabled: Bool = true
    var notificationsEnabled: Bool = true
}

// MARK: - Reward System
struct Reward: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let iconName: String
    let unlockMessage: String
}

extension GameState {
    static let availableRewards: [Reward] = [
        Reward(id: "golden_banana", name: "Golden Banana", description: "A shiny golden banana!", cost: 100, iconName: "star.fill", unlockMessage: "You found the legendary Golden Banana!"),
        Reward(id: "monkey_dance", name: "Monkey Dance", description: "Watch monkeys celebrate!", cost: 250, iconName: "figure.dance", unlockMessage: "The monkeys are dancing for you!"),
        Reward(id: "banana_crown", name: "Banana Crown", description: "Royal banana headpiece", cost: 500, iconName: "crown.fill", unlockMessage: "You are now the Banana Royalty!"),
        Reward(id: "jungle_throne", name: "Jungle Throne", description: "A majestic monkey throne", cost: 1000, iconName: "chair.fill", unlockMessage: "Behold your jungle kingdom!"),
        Reward(id: "diamond_banana", name: "Diamond Banana", description: "The ultimate treasure!", cost: 2000, iconName: "diamond.fill", unlockMessage: "You've achieved banana perfection!")
    ]
}