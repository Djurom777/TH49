//
//  OnboardingView.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var gameState: GameState
    @State private var currentPage = 0
    @State private var animationPhase = 0
    @State private var bananaOffset: CGFloat = -100
    @State private var monkeyScale: CGFloat = 0.5
    @State private var chestRotation: Double = 0
    
    let onboardingPages = [
        OnboardingPage(
            title: "Welcome to Banana Mania!",
            description: "Join our monkey friends in the ultimate jungle adventure!",
            iconName: "🐵"
        ),
        OnboardingPage(
            title: "Play Mini-Games",
            description: "Catch bananas, help monkeys jump, and solve puzzles!",
            iconName: "🎮"
        ),
        OnboardingPage(
            title: "Save Your Rewards",
            description: "Store your bananas and coins in the magical Banana Bank!",
            iconName: "🏦"
        ),
        OnboardingPage(
            title: "Unlock Fun Prizes",
            description: "Collect treasures and watch monkeys celebrate your success!",
            iconName: "🏆"
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated jungle background
            BananaManiaColors.jungleGradient
                .ignoresSafeArea()
            
            // Floating banana particles
            ForEach(0..<8, id: \.self) { index in
                Text("🍌")
                    .font(.title)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .opacity(0.3)
                    .animation(
                        .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animationPhase
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Animated mascot area
                VStack(spacing: 20) {
                    Text("🐵")
                        .font(.system(size: 80))
                        .scaleEffect(monkeyScale)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: monkeyScale)
                    
                    Text("🍌")
                        .font(.system(size: 40))
                        .offset(y: bananaOffset)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: bananaOffset)
                    
                    Text("📦")
                        .font(.system(size: 60))
                        .rotationEffect(.degrees(chestRotation))
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: chestRotation)
                }
                
                // Content area
                VStack(spacing: 30) {
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            OnboardingPageView(page: onboardingPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 300)
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("Previous") {
                                withAnimation(.easeInOut) {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(JungleButtonStyle())
                        }
                        
                        Spacer()
                        
                        if currentPage < onboardingPages.count - 1 {
                            Button("Next") {
                                withAnimation(.easeInOut) {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(JungleButtonStyle())
                        } else {
                            Button("Start Adventure!") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    gameState.hasCompletedOnboarding = true
                                    gameState.currentScreen = .home
                                }
                            }
                            .buttonStyle(JungleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .woodenPanel()
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            monkeyScale = 1.0
            animationPhase = 1
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
            bananaOffset = 20
        }
        
        withAnimation(.easeInOut(duration: 2.0).delay(1.0)) {
            chestRotation = 10
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let iconName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 25) {
            Text(page.iconName)
                .font(.system(size: 80))
                .padding(.bottom, 10)
            
            Text(page.title)
                .font(.title.bold())
                .foregroundColor(BananaManiaColors.bananaYellow)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.title3)
                .foregroundColor(BananaManiaColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 30)
    }
}

#Preview {
    OnboardingView(gameState: GameState())
}