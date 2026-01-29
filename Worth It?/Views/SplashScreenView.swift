//
//  SplashScreenView.swift
//  Worth It?
//
//  Launch splash screen with Vector logo and app name.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoVisible = false
    @State private var titleVisible = false

    private let logoAnimation = Animation.spring(response: 0.6, dampingFraction: 0.75)
    private let titleAnimation = Animation.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)

    var body: some View {
        ZStack {
            Color(hex: "FDD2B2")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("Vector")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .scaleEffect(logoVisible ? 1 : 0.6)
                    .opacity(logoVisible ? 1 : 0)

                Text("Worth It?")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.foreground)
                    .offset(y: titleVisible ? 0 : 16)
                    .opacity(titleVisible ? 1 : 0)
            }
            .onAppear {
                withAnimation(logoAnimation) {
                    logoVisible = true
                }
                withAnimation(titleAnimation) {
                    titleVisible = true
                }
            }
        }
    }
}

// Hex color helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SplashScreenView()
}
