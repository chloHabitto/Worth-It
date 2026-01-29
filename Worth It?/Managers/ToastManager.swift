//
//  ToastManager.swift
//  Worth It?
//
//  Global toast notification manager
//

import SwiftUI

enum ToastType {
    case success
    case error
    case info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return AppColors.secondary
        case .error: return AppColors.destructive
        case .info: return AppColors.primary
        }
    }

    var iconColor: Color {
        switch self {
        case .success: return AppColors.ratingFine  // Green
        case .error: return AppColors.destructive   // Red
        case .info: return AppColors.primary        // Coral
        }
    }
}

struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    let type: ToastType
    let message: String
    let duration: TimeInterval

    init(type: ToastType, message: String, duration: TimeInterval) {
        self.type = type
        self.message = message
        self.duration = duration
    }

    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
final class ToastManager {
    static let shared = ToastManager()

    private(set) var currentToast: ToastItem?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    // MARK: - Public Methods

    func show(_ message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        // Cancel any pending dismiss
        dismissTask?.cancel()

        // Show new toast with animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentToast = ToastItem(type: type, message: message, duration: duration)
        }

        // Schedule auto-dismiss
        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    func success(_ message: String, duration: TimeInterval = 3.0) {
        show(message, type: .success, duration: duration)
    }

    func error(_ message: String, duration: TimeInterval = 4.0) {
        show(message, type: .error, duration: duration)
    }

    func info(_ message: String, duration: TimeInterval = 3.0) {
        show(message, type: .info, duration: duration)
    }

    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.25)) {
            currentToast = nil
        }
    }
}
