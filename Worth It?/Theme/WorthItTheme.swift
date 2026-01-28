//
//  WorthItTheme.swift
//  Worth It?
//
//  Translated from recall-resolve src/index.css
//  Supports both Light and Dark modes
//

import SwiftUI

// MARK: - AppColors (Adaptive Light/Dark Mode)
// Converted from CSS HSL to RGB for both :root (light) and .dark modes

struct AppColors {

    // MARK: - Core Colors

    /// --background: light hsl(40, 33%, 98%) / dark hsl(25, 25%, 8%)
    static var background: Color {
        Color(
            light: Color(red: 253/255, green: 251/255, blue: 247/255),
            dark: Color(red: 26/255, green: 21/255, blue: 15/255)
        )
    }

    /// --foreground: light hsl(25, 30%, 15%) / dark hsl(40, 20%, 95%)
    static var foreground: Color {
        Color(
            light: Color(red: 50/255, green: 39/255, blue: 27/255),
            dark: Color(red: 246/255, green: 244/255, blue: 240/255)
        )
    }

    /// --card: light hsl(40, 40%, 99%) / dark hsl(25, 20%, 12%)
    static var card: Color {
        Color(
            light: Color(red: 254/255, green: 253/255, blue: 250/255),
            dark: Color(red: 37/255, green: 31/255, blue: 24/255)
        )
    }

    /// --card-foreground: same as foreground
    static var cardForeground: Color { foreground }

    // MARK: - Primary Colors (Warm Coral - same in both modes)

    /// --primary: hsl(12, 76%, 61%)
    static let primary = Color(red: 223/255, green: 115/255, blue: 86/255)

    /// --primary-foreground: hsl(40, 33%, 99%)
    static let primaryForeground = Color(red: 254/255, green: 253/255, blue: 251/255)

    // MARK: - Secondary Colors (Sage Green)

    /// --secondary: light hsl(145, 20%, 92%) / dark hsl(145, 15%, 20%)
    static var secondary: Color {
        Color(
            light: Color(red: 227/255, green: 240/255, blue: 232/255),
            dark: Color(red: 43/255, green: 59/255, blue: 49/255)
        )
    }

    /// --secondary-foreground: light hsl(145, 25%, 25%) / dark hsl(145, 20%, 85%)
    static var secondaryForeground: Color {
        Color(
            light: Color(red: 48/255, green: 80/255, blue: 60/255),
            dark: Color(red: 207/255, green: 225/255, blue: 213/255)
        )
    }

    // MARK: - Muted Colors

    /// --muted: light hsl(35, 20%, 93%) / dark hsl(25, 15%, 18%)
    static var muted: Color {
        Color(
            light: Color(red: 242/255, green: 239/255, blue: 233/255),
            dark: Color(red: 53/255, green: 46/255, blue: 39/255)
        )
    }

    /// --muted-foreground: light hsl(25, 15%, 45%) / dark hsl(35, 15%, 60%)
    static var mutedForeground: Color {
        Color(
            light: Color(red: 132/255, green: 119/255, blue: 98/255),
            dark: Color(red: 166/255, green: 156/255, blue: 140/255)
        )
    }

    // MARK: - Accent Colors (Warm Amber)

    /// --accent: light hsl(35, 90%, 55%) / dark hsl(35, 80%, 50%)
    static var accent: Color {
        Color(
            light: Color(red: 244/255, green: 173/255, blue: 41/255),
            dark: Color(red: 230/255, green: 166/255, blue: 26/255)
        )
    }

    /// --accent-foreground
    static var accentForeground: Color {
        Color(
            light: Color(red: 50/255, green: 39/255, blue: 27/255),
            dark: Color(red: 33/255, green: 25/255, blue: 18/255)
        )
    }

    // MARK: - Destructive Colors

    /// --destructive: light hsl(0, 72%, 51%) / dark hsl(0, 62%, 45%)
    static var destructive: Color {
        Color(
            light: Color(red: 223/255, green: 68/255, blue: 37/255),
            dark: Color(red: 185/255, green: 44/255, blue: 44/255)
        )
    }

    /// --destructive-foreground
    static let destructiveForeground = Color(red: 254/255, green: 253/255, blue: 251/255)

    // MARK: - Border Colors

    /// --border: light hsl(35, 25%, 88%) / dark hsl(25, 15%, 20%)
    static var border: Color {
        Color(
            light: Color(red: 232/255, green: 225/255, blue: 214/255),
            dark: Color(red: 59/255, green: 50/255, blue: 43/255)
        )
    }

    /// --input: same as border
    static var input: Color { border }

    /// --ring: same as primary
    static let ring = primary

    // MARK: - Rating Colors (consistent across modes)

    static let ratingFine = Color(red: 57/255, green: 172/255, blue: 103/255)
    static let ratingMeh = Color(red: 230/255, green: 196/255, blue: 26/255)
    static let ratingBad = Color(red: 229/255, green: 138/255, blue: 56/255)
    static let ratingAwful = Color(red: 217/255, green: 38/255, blue: 38/255)

    // MARK: - Worth Colors (consistent across modes)

    static let worthYes = Color(red: 57/255, green: 172/255, blue: 103/255)
    static let worthMeh = Color(red: 230/255, green: 196/255, blue: 26/255)
    static let worthNo = Color(red: 217/255, green: 38/255, blue: 38/255)

    // MARK: - Popover Colors

    static var popover: Color { card }
    static var popoverForeground: Color { cardForeground }
}

// MARK: - Backward compatibility alias
typealias WorthItColors = AppColors

// MARK: - Color Extension for Light/Dark Mode Support

extension Color {
    /// Creates an adaptive color that responds to the current color scheme
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Shadows (Adaptive)

struct AppShadows {
    static var soft: Color {
        Color(
            light: Color(red: 50/255, green: 39/255, blue: 27/255).opacity(0.08),
            dark: Color.black.opacity(0.3)
        )
    }
    static let softRadius: CGFloat = 20
    static let softY: CGFloat = 4

    static var medium: Color {
        Color(
            light: Color(red: 50/255, green: 39/255, blue: 27/255).opacity(0.12),
            dark: Color.black.opacity(0.4)
        )
    }
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

    func worthItCard() -> some View {
        modifier(AppCardStyle())
    }
}
