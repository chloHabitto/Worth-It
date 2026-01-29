//
//  ToastView.swift
//  Worth It?
//
//  Toast notification overlay component
//  Matches recall-resolve sonner toast styling
//

import SwiftUI

struct ToastView: View {
    let toast: ToastItem
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: toast.type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(toast.type.iconColor)

            // Message
            Text(toast.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.foreground)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.card)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    // Swipe up to dismiss
                    if value.translation.height < -20 {
                        onDismiss()
                    }
                }
        )
        .onTapGesture {
            onDismiss()
        }
    }
}

// MARK: - Toast Container Modifier

struct ToastContainerModifier: ViewModifier {
    // Use the singleton directly to avoid environment issues (e.g. sheets)
    private var toastManager: ToastManager { ToastManager.shared }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast) {
                        toastManager.dismiss()
                    }
                    .padding(.top, 8)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(1000)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.currentToast)
    }
}

extension View {
    func toastContainer() -> some View {
        modifier(ToastContainerModifier())
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Toast Preview")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColors.background)
    .overlay(alignment: .top) {
        ToastView(
            toast: ToastItem(type: .success, message: "Memory saved!", duration: 3)
        ) {}
        .padding(.top, 60)
    }
}
