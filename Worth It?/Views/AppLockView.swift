//
//  AppLockView.swift
//  Worth It?
//
//  Translated from src/components/AppLockSettings.tsx
//

import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppLockManager.self) private var lockManager
    private var toast: ToastManager { ToastManager.shared }

    @State private var showPinSetup = false
    @State private var showPinChange = false
    @State private var showDisableConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                lockStatusCard
                    .pageEntrance(delay: 0.05, offsetY: 10)

                if lockManager.settings.isEnabled {
                    biometricsCard
                        .pageEntrance(delay: 0.1, offsetY: 10)

                    lockTriggerCard
                        .pageEntrance(delay: 0.15, offsetY: 10)
                }

                Text("Note: If you forget your PIN, you'll need to reinstall the app to regain access.")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.mutedForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .fadeIn(delay: 0.2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("App Lock")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.foreground)
            }
        }
        .sheet(isPresented: $showPinSetup) {
            PinSetupSheet(mode: .setup) { pin in
                lockManager.enableLock(pin: pin)
                toast.success("PIN enabled")
            }
        }
        .sheet(isPresented: $showPinChange) {
            PinSetupSheet(mode: .change, verifyCurrentPin: lockManager.verifyPin) { pin in
                lockManager.changePin(newPin: pin)
                toast.success("PIN updated")
            }
        }
        .sheet(isPresented: $showDisableConfirm) {
            PinSetupSheet(mode: .disable, verifyCurrentPin: lockManager.verifyPin) { _ in
                lockManager.disableLock()
                toast.success("PIN disabled")
            }
        }
    }

    private var lockStatusCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Circle()
                    .fill(lockManager.settings.isEnabled ? Color.green.opacity(0.1) : AppColors.muted)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                lockManager.settings.isEnabled ? Color.green : AppColors.mutedForeground
                            )
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(lockManager.settings.isEnabled ? "App Lock Enabled" : "App Lock Disabled")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)

                    Text(lockManager.settings.isEnabled
                         ? "Your app is protected with a PIN"
                         : "Protect your app with a PIN or Face ID")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                Spacer()
            }

            if !lockManager.settings.isEnabled {
                Button {
                    showPinSetup = true
                } label: {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                        Text("Set Up App Lock")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(AppColors.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 16)
            } else {
                VStack(spacing: 8) {
                    Divider()
                        .background(AppColors.border.opacity(0.5))
                        .padding(.top, 16)

                    Button {
                        showPinChange = true
                    } label: {
                        Text("Change PIN")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.foreground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    }

                    Button {
                        showDisableConfirm = true
                    } label: {
                        Text("Disable App Lock")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.destructive)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }

    private var biometricsCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: lockManager.biometricType == .faceID ? "faceid" : "touchid")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.primary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(lockManager.biometricType == .faceID ? "Face ID" : "Touch ID")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.foreground)

                Text("Use biometrics to unlock")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.mutedForeground)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { lockManager.settings.biometricsEnabled },
                set: { lockManager.toggleBiometrics(enabled: $0) }
            ))
            .labelsHidden()
            .tint(AppColors.primary)
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
        .opacity(lockManager.isBiometricsAvailable ? 1 : 0.5)
        .disabled(!lockManager.isBiometricsAvailable)
    }

    private var lockTriggerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Lock Trigger")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.foreground)

                    Text("When should the app lock?")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                Spacer()
            }

            Picker("Lock Trigger", selection: Binding(
                get: { lockManager.settings.lockTrigger },
                set: { lockManager.setLockTrigger($0) }
            )) {
                ForEach(LockTrigger.allCases, id: \.self) { trigger in
                    Text(trigger.displayName).tag(trigger)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.muted.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if lockManager.settings.lockTrigger == .afterInactivity {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lock after")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)

                    Picker("Timeout", selection: Binding(
                        get: { lockManager.settings.inactivityTimeout },
                        set: { lockManager.setInactivityTimeout($0) }
                    )) {
                        ForEach(InactivityTimeout.allCases, id: \.rawValue) { timeout in
                            Text(timeout.displayName).tag(timeout.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.foreground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.muted.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }
}

// MARK: - PIN Setup Sheet

enum PinSetupMode {
    case setup
    case change
    case disable
}

struct PinSetupSheet: View {
    let mode: PinSetupMode
    var verifyCurrentPin: ((String) -> Bool)? = nil
    let onComplete: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: SetupStep = .enterCurrent
    @State private var currentPin = ""
    @State private var newPin = ""
    @State private var confirmPin = ""
    @State private var error = ""

    private enum SetupStep {
        case enterCurrent, enterNew, confirmNew
    }

    private var currentStep: SetupStep {
        switch mode {
        case .setup:
            return step == .enterCurrent ? .enterNew : step
        case .change, .disable:
            return step
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)

                    Text(descriptionText)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                }
                .padding(.top, 24)

                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(currentPinValue.count > index ? AppColors.primary : .clear)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(
                                        currentPinValue.count > index
                                            ? AppColors.primary
                                            : AppColors.mutedForeground.opacity(0.3),
                                        lineWidth: 2
                                    )
                            )
                    }
                }

                if !error.isEmpty {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.destructive)
                }

                NumPadView(
                    onDigit: handleDigit,
                    onDelete: handleDelete,
                    deleteDisabled: currentPinValue.isEmpty
                )

                Button {
                    handleContinue()
                } label: {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            AppColors.primary.opacity(currentPinValue.count == 4 ? 1 : 0.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(currentPinValue.count < 4)
                .padding(.horizontal, 24)

                Spacer()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.mutedForeground)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var currentPinValue: String {
        switch currentStep {
        case .enterCurrent: return currentPin
        case .enterNew: return newPin
        case .confirmNew: return confirmPin
        }
    }

    private var titleText: String {
        switch mode {
        case .setup:
            return step == .confirmNew ? "Confirm PIN" : "Create PIN"
        case .change:
            if currentStep == .enterCurrent { return "Enter Current PIN" }
            return step == .confirmNew ? "Confirm New PIN" : "Enter New PIN"
        case .disable:
            return "Enter PIN to Disable"
        }
    }

    private var descriptionText: String {
        switch mode {
        case .setup:
            return step == .confirmNew
                ? "Enter the same PIN again to confirm"
                : "Enter a 4-digit PIN to secure your app"
        case .change:
            if currentStep == .enterCurrent { return "Verify your identity first" }
            return step == .confirmNew
                ? "Enter the new PIN again to confirm"
                : "Choose a new 4-digit PIN"
        case .disable:
            return "Enter your PIN to disable app lock"
        }
    }

    private var buttonText: String {
        switch mode {
        case .setup:
            return step == .confirmNew ? "Enable App Lock" : "Continue"
        case .change:
            if currentStep == .enterCurrent { return "Verify" }
            return step == .confirmNew ? "Change PIN" : "Continue"
        case .disable:
            return "Disable App Lock"
        }
    }

    private func handleDigit(_ digit: String) {
        error = ""
        switch currentStep {
        case .enterCurrent:
            if currentPin.count < 4 { currentPin += digit }
        case .enterNew:
            if newPin.count < 4 { newPin += digit }
        case .confirmNew:
            if confirmPin.count < 4 { confirmPin += digit }
        }
    }

    private func handleDelete() {
        error = ""
        switch currentStep {
        case .enterCurrent:
            if !currentPin.isEmpty { currentPin.removeLast() }
        case .enterNew:
            if !newPin.isEmpty { newPin.removeLast() }
        case .confirmNew:
            if !confirmPin.isEmpty { confirmPin.removeLast() }
        }
    }

    private func handleContinue() {
        switch mode {
        case .setup:
            if step == .enterNew || step == .enterCurrent {
                step = .confirmNew
            } else if step == .confirmNew {
                if newPin == confirmPin {
                    onComplete(newPin)
                    dismiss()
                } else {
                    error = "PINs do not match"
                    confirmPin = ""
                }
            }

        case .change:
            if currentStep == .enterCurrent {
                if verifyCurrentPin?(currentPin) == true {
                    step = .enterNew
                    currentPin = ""
                } else {
                    error = "Incorrect PIN"
                    currentPin = ""
                }
            } else if step == .enterNew {
                step = .confirmNew
            } else if step == .confirmNew {
                if newPin == confirmPin {
                    onComplete(newPin)
                    dismiss()
                } else {
                    error = "PINs do not match"
                    confirmPin = ""
                }
            }

        case .disable:
            if verifyCurrentPin?(currentPin) == true {
                onComplete("")
                dismiss()
            } else {
                error = "Incorrect PIN"
                currentPin = ""
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AppLockView()
            .environment(AppLockManager.shared)
    }
}
