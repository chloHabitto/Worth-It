//
//  NumPadView.swift
//  Worth It?
//
//  Reusable number pad component
//

import SwiftUI

struct NumPadView: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    var deleteDisabled: Bool = false

    private let digits: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "del"]
    ]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<digits.count, id: \.self) { rowIndex in
                let row = digits[rowIndex]
                HStack(spacing: 24) {
                    ForEach(0..<row.count, id: \.self) { colIndex in
                        let digit = row[colIndex]
                        if digit.isEmpty {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 72, height: 72)
                        } else if digit == "del" {
                            Button {
                                onDelete()
                            } label: {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Image(systemName: "delete.left.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(
                                                deleteDisabled
                                                    ? AppColors.mutedForeground.opacity(0.3)
                                                    : AppColors.mutedForeground
                                            )
                                    )
                            }
                            .disabled(deleteDisabled)
                        } else {
                            Button {
                                onDigit(digit)
                            } label: {
                                Circle()
                                    .fill(AppColors.muted.opacity(0.001))
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Text(digit)
                                            .font(.system(size: 28, weight: .medium))
                                            .foregroundStyle(AppColors.foreground)
                                    )
                            }
                            .buttonStyle(NumPadButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

struct NumPadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(configuration.isPressed ? AppColors.muted : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
