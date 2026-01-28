//
//  WorthItTheme.swift
//  Worth It?
//

import SwiftUI

// MARK: - AppColors (Converted from CSS HSL to RGB)
// CSS HSL uses Lightness; SwiftUI Color(hue:saturation:brightness:) uses HSB Brightness — they differ.
// Using RGB for exact, unambiguous colors.

struct AppColors {
    // --background: hsl(40, 33%, 98%) → rgb(253, 251, 247)
    static let background = Color(red: 253/255, green: 251/255, blue: 247/255)

    // --foreground: hsl(25, 30%, 15%) → rgb(50, 39, 27)
    static let foreground = Color(red: 50/255, green: 39/255, blue: 27/255)

    // --card: hsl(40, 40%, 99%) → rgb(254, 253, 250)
    static let card = Color(red: 254/255, green: 253/255, blue: 250/255)

    // --card-foreground: same as foreground
    static let cardForeground = foreground

    // --primary: hsl(12, 76%, 61%) → rgb(223, 115, 86) - Warm coral
    static let primary = Color(red: 223/255, green: 115/255, blue: 86/255)

    // --primary-foreground: hsl(40, 33%, 99%) → rgb(254, 253, 251)
    static let primaryForeground = Color(red: 254/255, green: 253/255, blue: 251/255)

    // --secondary: hsl(145, 20%, 92%) → rgb(227, 240, 232) - Soft sage green
    static let secondary = Color(red: 227/255, green: 240/255, blue: 232/255)

    // --secondary-foreground: hsl(145, 25%, 25%) → rgb(48, 80, 60)
    static let secondaryForeground = Color(red: 48/255, green: 80/255, blue: 60/255)

    // --muted: hsl(35, 20%, 93%) → rgb(242, 239, 233)
    static let muted = Color(red: 242/255, green: 239/255, blue: 233/255)

    // --muted-foreground: hsl(25, 15%, 45%) → rgb(132, 119, 98)
    static let mutedForeground = Color(red: 132/255, green: 119/255, blue: 98/255)

    // --accent: hsl(35, 90%, 55%) → rgb(244, 173, 41) - Warm amber
    static let accent = Color(red: 244/255, green: 173/255, blue: 41/255)

    // --accent-foreground: same as foreground
    static let accentForeground = foreground

    // --destructive: hsl(0, 72%, 51%) → rgb(223, 68, 37) - Red
    static let destructive = Color(red: 223/255, green: 68/255, blue: 37/255)

    // --destructive-foreground: same as primaryForeground
    static let destructiveForeground = primaryForeground

    // --border: hsl(35, 25%, 88%) → rgb(232, 225, 214)
    static let border = Color(red: 232/255, green: 225/255, blue: 214/255)

    // Rating colors
    // --rating-fine: hsl(145, 50%, 45%) → rgb(57, 172, 103)
    static let ratingFine = Color(red: 57/255, green: 172/255, blue: 103/255)

    // --rating-meh: hsl(45, 80%, 50%) → rgb(230, 196, 26)
    static let ratingMeh = Color(red: 230/255, green: 196/255, blue: 26/255)

    // --rating-bad: hsl(25, 80%, 55%) → rgb(229, 138, 56)
    static let ratingBad = Color(red: 229/255, green: 138/255, blue: 56/255)

    // --rating-awful: hsl(0, 70%, 50%) → rgb(217, 38, 38)
    static let ratingAwful = Color(red: 217/255, green: 38/255, blue: 38/255)

    // Worth colors
    static let worthYes = Color(red: 57/255, green: 172/255, blue: 103/255)
    static let worthMeh = Color(red: 230/255, green: 196/255, blue: 26/255)
    static let worthNo = Color(red: 217/255, green: 38/255, blue: 38/255)
}

// MARK: - Backward compatibility alias
typealias WorthItColors = AppColors

// MARK: - Shadows
struct AppShadows {
    static let soft = Color(red: 50/255, green: 39/255, blue: 27/255).opacity(0.08)
    static let softRadius: CGFloat = 20
    static let softY: CGFloat = 4

    static let medium = Color(red: 50/255, green: 39/255, blue: 27/255).opacity(0.12)
    static let mediumRadius: CGFloat = 30
    static let mediumY: CGFloat = 8

    static let glow = AppColors.primary.opacity(0.15)
    static let glowRadius: CGFloat = 40
}

// MARK: - Layout Constants
struct AppLayout {
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 8
    static let buttonCornerRadius: CGFloat = 12
    static let badgeCornerRadius: CGFloat = 9999

    static let horizontalPadding: CGFloat = 24
    static let cardPadding: CGFloat = 16
    static let compactCardPadding: CGFloat = 12
}

// MARK: - Card Style Modifier
struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius)
                    .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
            )
            .shadow(
                color: AppShadows.soft,
                radius: AppShadows.softRadius,
                x: 0,
                y: AppShadows.softY
            )
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardStyle())
    }

    /// Backward compatibility: same as appCard()
    func worthItCard() -> some View {
        modifier(AppCardStyle())
    }
}
