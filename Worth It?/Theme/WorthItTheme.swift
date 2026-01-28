//
//  WorthItTheme.swift
//  Worth It?
//

import SwiftUI

// MARK: - Colors

enum WorthItTheme {
    /// Primary: coral — Color(hue: 0.03, saturation: 0.76, brightness: 0.61)
    static let coral = Color(hue: 0.03, saturation: 0.76, brightness: 0.61)

    /// Background: warm cream
    static let background = Color(hue: 0.12, saturation: 0.08, brightness: 0.98)

    /// Secondary text / muted
    static let muted = Color(hue: 0.08, saturation: 0.06, brightness: 0.55)

    /// Card/surface
    static let surface = Color.white

    /// Coral with opacity for backgrounds
    static let coralTint = coral.opacity(0.12)
}

// MARK: - Typography

extension WorthItTheme {
    /// Headers — serif
    static let titleFont = Font.system(.title, design: .serif).weight(.medium)
    static let title2Font = Font.system(.title2, design: .serif).weight(.medium)
    static let title3Font = Font.system(.title3, design: .serif).weight(.medium)
    static let headlineFont = Font.system(.headline, design: .serif)

    /// Body — sans-serif (system default)
    static let bodyFont = Font.body
    static let calloutFont = Font.callout
    static let subheadlineFont = Font.subheadline
    static let footnoteFont = Font.footnote
}

// MARK: - Layout & Shape

extension WorthItTheme {
    static let cornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 2
    static let cardShadowOpacity: Double = 0.06
}

// MARK: - View modifiers

struct WorthItCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WorthItTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: WorthItTheme.cornerRadius))
            .shadow(
                color: .black.opacity(WorthItTheme.cardShadowOpacity),
                radius: WorthItTheme.cardShadowRadius,
                x: 0,
                y: WorthItTheme.cardShadowY
            )
    }
}

extension View {
    func worthItCard() -> some View {
        modifier(WorthItCardStyle())
    }
}
