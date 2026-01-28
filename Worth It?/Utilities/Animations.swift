//
//  Animations.swift
//  Worth It?
//

import SwiftUI

// MARK: - Animation Constants (matching recall-resolve timing)

struct AppAnimations {
    // Duration presets matching Framer Motion defaults
    static let fast = Animation.easeInOut(duration: 0.15)
    static let normal = Animation.easeOut(duration: 0.25)
    static let slow = Animation.easeOut(duration: 0.35)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)

    // Staggered animation for lists (delay: index * 0.05)
    static func staggered(index: Int, baseDelay: Double = 0) -> Animation {
        .easeOut(duration: 0.25).delay(baseDelay + Double(index) * 0.05)
    }

    // For search results (delay: index * 0.03)
    static func fastStagger(index: Int, baseDelay: Double = 0) -> Animation {
        .easeOut(duration: 0.2).delay(baseDelay + Double(index) * 0.03)
    }
}

// MARK: - Custom Transitions (matching recall-resolve AnimatePresence)

extension AnyTransition {
    // initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 10)),
            removal: .opacity.combined(with: .offset(y: -5))
        )
    }

    // initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }}
    static var slideDown: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: -10)),
            removal: .opacity.combined(with: .offset(y: 5))
        )
    }

    // exit={{ opacity: 0, scale: 0.95 }}
    static var scaleOut: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 0.95))
        )
    }

    // For step transitions: initial={{ opacity: 0, x: 20 }} exit={{ opacity: 0, x: -20 }}
    static var slideFromRight: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(x: 20)),
            removal: .opacity.combined(with: .offset(x: -20))
        )
    }

    static var slideFromLeft: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(x: -20)),
            removal: .opacity.combined(with: .offset(x: 20))
        )
    }

    // For clear button: initial={{ opacity: 0, scale: 0.8 }}
    static var scaleIn: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.8))
    }
}

// MARK: - Page Entrance Modifier
// Replicates: initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }}

struct PageEntranceModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    let offsetY: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offsetY)
            .onAppear {
                withAnimation(AppAnimations.normal.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Staggered List Item Modifier
// Replicates: initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: index * 0.05 }}

struct StaggeredItemModifier: ViewModifier {
    @State private var isVisible = false
    let index: Int
    let baseDelay: Double
    /// Delay added per item index (default 0.05 for lists, 0.03 for faster stagger)
    let delayPerItem: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                let totalDelay = baseDelay + Double(index) * delayPerItem
                withAnimation(.easeOut(duration: 0.25).delay(totalDelay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Interactive Scale Modifier
// Replicates: whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}

struct InteractiveScaleModifier: ViewModifier {
    @State private var isPressed = false
    let pressedScale: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? pressedScale : 1.0)
            .animation(AppAnimations.fast, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: 10, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Fade In Modifier (simple opacity animation)

struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(AppAnimations.normal.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Page entrance animation (fade + slide from top)
    /// - Parameters:
    ///   - delay: Animation delay in seconds
    ///   - offsetY: Starting Y offset (negative = from top, positive = from bottom)
    func pageEntrance(delay: Double = 0, offsetY: CGFloat = -10) -> some View {
        modifier(PageEntranceModifier(delay: delay, offsetY: offsetY))
    }

    /// Staggered list item animation
    /// - Parameters:
    ///   - index: Item index in the list
    ///   - baseDelay: Base delay before stagger starts
    ///   - delayPerItem: Delay per index (default 0.05; use 0.03 for faster stagger)
    func staggeredAppear(index: Int, baseDelay: Double = 0.1, delayPerItem: Double = 0.05) -> some View {
        modifier(StaggeredItemModifier(index: index, baseDelay: baseDelay, delayPerItem: delayPerItem))
    }

    /// Interactive press scale feedback
    /// - Parameter scale: Scale when pressed (default 0.98)
    func interactiveScale(_ scale: CGFloat = 0.98) -> some View {
        modifier(InteractiveScaleModifier(pressedScale: scale))
    }

    /// Simple fade in animation
    /// - Parameter delay: Animation delay
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}
