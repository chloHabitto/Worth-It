//
//  WorthItTheme.swift
//  Worth It?
//

import SwiftUI

// MARK: - Exact Color Translations from CSS HSL (Tailwind → SwiftUI)

struct AppColors {
    // --background: 40 33% 98%
    static let background = Color(hue: 40/360, saturation: 0.33, brightness: 0.98)

    // --foreground: 25 30% 15%
    static let foreground = Color(hue: 25/360, saturation: 0.30, brightness: 0.15)

    // --card: 40 40% 99%
    static let card = Color(hue: 40/360, saturation: 0.40, brightness: 0.99)

    // --primary: 12 76% 61% (Warm coral)
    static let primary = Color(hue: 12/360, saturation: 0.76, brightness: 0.61)

    // --primary-foreground: 40 33% 99%
    static let primaryForeground = Color(hue: 40/360, saturation: 0.33, brightness: 0.99)

    // --secondary: 145 20% 92% (Soft sage green for "yes")
    static let secondary = Color(hue: 145/360, saturation: 0.20, brightness: 0.92)

    // --secondary-foreground: 145 25% 25%
    static let secondaryForeground = Color(hue: 145/360, saturation: 0.25, brightness: 0.25)

    // --muted: 35 20% 93%
    static let muted = Color(hue: 35/360, saturation: 0.20, brightness: 0.93)

    // --muted-foreground: 25 15% 45%
    static let mutedForeground = Color(hue: 25/360, saturation: 0.15, brightness: 0.45)

    // --accent: 35 90% 55% (Warm amber for "meh")
    static let accent = Color(hue: 35/360, saturation: 0.90, brightness: 0.55)

    // --destructive: 0 72% 51% (Red for "no")
    static let destructive = Color(hue: 0/360, saturation: 0.72, brightness: 0.51)

    // --border: 35 25% 88%
    static let border = Color(hue: 35/360, saturation: 0.25, brightness: 0.88)

    // Card foreground (same as foreground)
    static let cardForeground = Color(hue: 25/360, saturation: 0.30, brightness: 0.15)

    // Rating colors (for PhysicalRating)
    static let ratingFine = Color(hue: 145/360, saturation: 0.50, brightness: 0.45)
    static let ratingMeh = Color(hue: 45/360, saturation: 0.80, brightness: 0.50)
    static let ratingBad = Color(hue: 25/360, saturation: 0.80, brightness: 0.55)
    static let ratingAwful = Color(hue: 0/360, saturation: 0.70, brightness: 0.50)

    // Worth colors (legacy; badge uses secondary/accent/destructive)
    static let worthYes = Color(hue: 145/360, saturation: 0.50, brightness: 0.45)
    static let worthMeh = Color(hue: 45/360, saturation: 0.80, brightness: 0.50)
    static let worthNo = Color(hue: 0/360, saturation: 0.70, brightness: 0.50)
}

// MARK: - Legacy aliases (WorthItColors / WorthItTheme for existing code)

typealias WorthItColors = AppColors

enum WorthItTheme {
    static let coral = AppColors.primary
    static let background = AppColors.background
    static let muted = AppColors.mutedForeground
    static let surface = AppColors.card
    static let coralTint = AppColors.primary.opacity(0.12)

    static let titleFont = Font.system(.title, design: .serif).weight(.medium)
    static let title2Font = Font.system(.title2, design: .serif).weight(.medium)
    static let headlineFont = Font.system(.headline, design: .serif)
    static let bodyFont = Font.body
    static let calloutFont = Font.callout
    static let subheadlineFont = Font.subheadline
    static let footnoteFont = Font.footnote

    static let cornerRadius: CGFloat = 12
    static let cardShadowRadius: CGFloat = 20
    static let cardShadowY: CGFloat = 4
    static let cardShadowOpacity: Double = 0.08
}

// MARK: - View modifiers

struct WorthItCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 4)
    }
}

extension View {
    func worthItCard() -> some View {
        modifier(WorthItCardStyle())
    }
}
