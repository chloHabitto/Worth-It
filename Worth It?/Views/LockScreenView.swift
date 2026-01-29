//
//  LockScreenView.swift
//  Worth It?
//
//  Translated from src/components/LockScreen.tsx
//

import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    let onUnlock: () -> Void
    let verifyPin: (String) -> Bool
    let biometricsEnabled: Bool
    let biometricType: LABiometryType
    let onBiometricAuth: () async -> Bool

    @State private var pin: String = ""
    @State private var error: Bool = false
    @State private var success: Bool = false
    @State private var shakeOffset: CGFloat = 0
    @State private var hasAttemptedBiometric: Bool = false
    @State private var showHelpAlert: Bool = false

    private let pinLength = 4

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "lock.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppColors.primary)
                        )

                    Text("Worth It?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)

                    Text("Enter your PIN to unlock")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                HStack(spacing: 16) {
                    ForEach(0..<pinLength, id: \.self) { index in
                        Circle()
                            .fill(dotColor(for: index))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(dotBorderColor(for: index), lineWidth: 2)
                            )
                            .scaleEffect(pin.count > index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.2), value: pin.count)
                    }
                }
                .offset(x: shakeOffset)

                if error {
                    Text("Incorrect PIN. Try again.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.destructive)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if success {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(Color.green)
                        Text("Unlocked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                NumPadView(
                    onDigit: handleDigit,
                    onDelete: handleDelete,
                    deleteDisabled: pin.isEmpty
                )

                if biometricsEnabled {
                    Button {
                        Task {
                            await handleBiometric()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                                .font(.system(size: 20))
                            Text(biometricType == .faceID ? "Use Face ID" : "Use Touch ID")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(AppColors.foreground)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .padding(.top, 16)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showHelpAlert = true
            } label: {
                Text("Need help?")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.mutedForeground)
            }
            .padding(.top, 16)
            .padding(.trailing, 24)
        }
        .alert("Forgot your PIN?", isPresented: $showHelpAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("If you've forgotten your PIN, you'll need to delete and reinstall the app. Don't worry - your data is safely stored in iCloud. Once you reinstall and sign in with the same iCloud account, all your entries will sync back automatically.")
        }
        .animation(.easeInOut(duration: 0.2), value: error)
        .animation(.easeInOut(duration: 0.2), value: success)
        .onAppear {
            if biometricsEnabled && !hasAttemptedBiometric {
                hasAttemptedBiometric = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Task {
                        await handleBiometric()
                    }
                }
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        guard pin.count > index else { return .clear }
        if success { return Color.green }
        if error { return AppColors.destructive }
        return AppColors.primary
    }

    private func dotBorderColor(for index: Int) -> Color {
        guard pin.count > index else { return AppColors.mutedForeground.opacity(0.3) }
        if success { return Color.green }
        if error { return AppColors.destructive }
        return AppColors.primary
    }

    private func handleDigit(_ digit: String) {
        guard pin.count < pinLength else { return }

        pin += digit
        error = false

        if pin.count == pinLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if verifyPin(pin) {
                    success = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onUnlock()
                    }
                } else {
                    error = true
                    shakeAnimation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        pin = ""
                        error = false
                    }
                }
            }
        }
    }

    private func handleDelete() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
        error = false
    }

    @MainActor
    private func handleBiometric() async {
        let result = await onBiometricAuth()
        if result {
            success = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onUnlock()
            }
        }
    }

    private func shakeAnimation() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
            shakeOffset = -10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                shakeOffset = 10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                shakeOffset = -10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                shakeOffset = 0
            }
        }
    }
}
