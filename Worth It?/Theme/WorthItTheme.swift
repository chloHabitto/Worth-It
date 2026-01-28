//
//  WorthItTheme.swift
//  Worth It?
//

import SwiftUI

// MARK: - WorthItColors (Exact translations from recall-resolve CSS)

struct WorthItColors {
    // --background: 40 33% 98%
    static let background = Color(hue: 40/360, saturation: 0.33, brightness: 0.98)

    // --foreground: 25 30% 15%
    static let foreground = Color(hue: 25/360, saturation: 0.30, brightness: 0.15)

    // --card: 40 40% 99%
    static let card = Color(hue: 40/360, saturation: 0.40, brightness: 0.99)

    // --card-foreground: 25 30% 15%
    static let cardForeground = Color(hue: 25/360, saturation: 0.30, brightness: 0.15)

    // --primary: 12 76% 61% (Warm coral)
    static let primary = Color(hue: 12/360, saturation: 0.76, brightness: 0.61)

    // --primary-foreground: 40 33% 99%
    static let primaryForeground = Color(hue: 40/360, saturation: 0.33, brightness: 0.99)

    // --secondary: 145 20% 92% (Soft sage)
    static let secondary = Color(hue: 145/360, saturation: 0.20, brightness: 0.92)

    // --secondary-foreground: 145 25% 25%
    static let secondaryForeground = Color(hue: 145/360, saturation: 0.25, brightness: 0.25)

    // --muted: 35 20% 93%
    static let muted = Color(hue: 35/360, saturation: 0.20, brightness: 0.93)

    // --muted-foreground: 25 15% 45%
    static let mutedForeground = Color(hue: 25/360, saturation: 0.15, brightness: 0.45)

    // --accent: 35 90% 55% (Warm amber)
    static let accent = Color(hue: 35/360, saturation: 0.90, brightness: 0.55)

    // --destructive: 0 72% 51%
    static let destructive = Color(hue: 0/360, saturation: 0.72, brightness: 0.51)

    // --border: 35 25% 88%
    static let border = Color(hue: 35/360, saturation: 0.25, brightness: 0.88)

    // Rating colors
    static let ratingFine = Color(hue: 145/360, saturation: 0.50, brightness: 0.45)
    static let ratingMeh = Color(hue: 45/360, saturation: 0.80, brightness: 0.50)
    static let ratingBad = Color(hue: 25/360, saturation: 0.80, brightness: 0.55)
    static let ratingAwful = Color(hue: 0/360, saturation: 0.70, brightness: 0.50)

    // Worth colors
    static let worthYes = Color(hue: 145/360, saturation: 0.50, brightness: 0.45)
    static let worthMeh = Color(hue: 45/360, saturation: 0.80, brightness: 0.50)
    static let worthNo = Color(hue: 0/360, saturation: 0.70, brightness: 0.50)
}

// MARK: - Shadows (from CSS)

struct WorthItShadows {
    static let soft = Color(hue: 25/360, saturation: 0.30, brightness: 0.15).opacity(0.08)
    static let softRadius: CGFloat = 20
    static let softY: CGFloat = 4

    static let medium = Color(hue: 25/360, saturation: 0.30, brightness: 0.15).opacity(0.12)
    static let mediumRadius: CGFloat = 30
    static let mediumY: CGFloat = 8

    static let glow = WorthItColors.primary.opacity(0.15)
    static let glowRadius: CGFloat = 40
}

// MARK: - Layout Constants

struct WorthItLayout {
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    static let badgeCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 16

    static let horizontalPadding: CGFloat = 24
    static let cardPadding: CGFloat = 16
    static let spacing: CGFloat = 12
}

// MARK: - Legacy WorthItTheme (for minimal migration; prefer WorthItColors/WorthItLayout)

enum WorthItTheme {
    static let coral = WorthItColors.primary
    static let background = WorthItColors.background
    static let muted = WorthItColors.mutedForeground
    static let surface = WorthItColors.card
    static let coralTint = WorthItColors.primary.opacity(0.12)

    static let titleFont = Font.system(.title, design: .serif).weight(.medium)
    static let title2Font = Font.system(.title2, design: .serif).weight(.medium)
    static let headlineFont = Font.system(.headline, design: .serif)
    static let bodyFont = Font.body
    static let calloutFont = Font.callout
    static let subheadlineFont = Font.subheadline
    static let footnoteFont = Font.footnote

    static let cornerRadius: CGFloat = WorthItLayout.cornerRadius
    static let cardShadowRadius: CGFloat = WorthItShadows.softRadius
    static let cardShadowY: CGFloat = WorthItShadows.softY
    static let cardShadowOpacity: Double = 0.08
}

// MARK: - View modifiers

struct WorthItCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WorthItColors.card)
            .clipShape(RoundedRectangle(cornerRadius: WorthItLayout.cardCornerRadius))
            .shadow(
                color: WorthItShadows.soft,
                radius: WorthItShadows.softRadius,
                x: 0,
                y: WorthItShadows.softY
            )
    }
}

extension View {
    func worthItCard() -> some View {
        modifier(WorthItCardStyle())
    }
}
