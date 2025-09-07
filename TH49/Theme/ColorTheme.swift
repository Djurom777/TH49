//
//  ColorTheme.swift
//  TH49
//
//  Created by IGOR on 01/09/2025.
//

import SwiftUI

// MARK: - Color Theme System
struct BananaManiaColors {
    // Backgrounds
    static let deepJungleGreen = Color(red: 0.11, green: 0.23, blue: 0.10) // #1b3a1a
    static let darkEmerald = Color(red: 0.05, green: 0.18, blue: 0.05) // #0e2f0e
    
    // Buttons
    static let goldenYellow = Color(red: 0.97, green: 0.77, blue: 0.19) // #f7c531
    static let orangeGlow = Color(red: 0.95, green: 0.56, blue: 0.11) // #f28f1c
    static let darkerAmber = Color(red: 0.79, green: 0.48, blue: 0.08) // #c97a15
    
    // Accents
    static let bananaYellow = Color(red: 1.0, green: 0.88, blue: 0.36) // #ffe15c
    static let tropicalRed = Color(red: 0.91, green: 0.30, blue: 0.24) // #e74c3c
    static let gemPurple = Color(red: 0.61, green: 0.35, blue: 0.71) // #9b59b6
    
    // Panels
    static let woodenBrown = Color(red: 0.56, green: 0.35, blue: 0.16) // #8e5a2a
    
    // Highlights
    static let tropicalGreen = Color(red: 0.18, green: 0.80, blue: 0.44) // #2ecc71
    
    // Text
    static let mainText = Color.white // #ffffff
    static let secondaryText = Color(red: 0.98, green: 0.96, blue: 0.89) // #f9f5e3
    
    // Gradients
    static let jungleGradient = LinearGradient(
        colors: [deepJungleGreen, darkEmerald],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let buttonGradient = LinearGradient(
        colors: [goldenYellow, orangeGlow],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let pressedButtonGradient = LinearGradient(
        colors: [darkerAmber, Color(red: 0.65, green: 0.35, blue: 0.05)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Custom Button Style
struct JungleButtonStyle: ButtonStyle {
    let isPressed: Bool
    
    init(isPressed: Bool = false) {
        self.isPressed = isPressed
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(BananaManiaColors.mainText)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed || isPressed ? 
                          BananaManiaColors.pressedButtonGradient : 
                          BananaManiaColors.buttonGradient)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Wooden Panel Style
struct WoodenPanelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(BananaManiaColors.woodenBrown)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(BananaManiaColors.goldenYellow.opacity(0.3), lineWidth: 2)
                    )
            )
    }
}

extension View {
    func woodenPanel() -> some View {
        modifier(WoodenPanelStyle())
    }
}