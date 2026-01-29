//
//  ProfileView.swift
//  Worth It?
//
//  Translated from ProfilePage.tsx (recall-resolve)
//

import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - Profile View

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EntryStore.self) private var store
    private var toast: ToastManager { ToastManager.shared }

    // User preferences - synced via @AppStorage
    @AppStorage("displayName") private var displayName: String = ""
    // Store profile image as base64 string (AppStorage doesn't support Data)
    @AppStorage("profileImageData") private var profileImageBase64: String = ""

    // Local state
    @State private var isEditingName = false
    @State private var tempName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var showPhotoSheet = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    // MARK: - Computed Properties

    private var profileImageData: Data? {
        Data(base64Encoded: profileImageBase64)
    }

    private var profileImage: Image? {
        guard let data = profileImageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    private var entryCount: Int {
        store.entries.count
    }

    private var firstEntryDate: Date? {
        store.entries.min(by: { $0.createdAt < $1.createdAt })?.createdAt
    }

    private var hasExistingPhoto: Bool {
        !profileImageBase64.isEmpty
    }

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    private var sheetHeight: CGFloat {
        var height: CGFloat = 180
        if isCameraAvailable { height += 80 }
        height += 80
        if hasExistingPhoto { height += 80 }
        return height
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                avatarNameCard
                    .pageEntrance(delay: 0.05, offsetY: 10)

                syncStatusCard
                    .pageEntrance(delay: 0.1, offsetY: 10)

                statsCard
                    .pageEntrance(delay: 0.15, offsetY: 10)

                appleSignInCard
                    .pageEntrance(delay: 0.2, offsetY: 10)
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
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(AppColors.foreground)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.foreground)
            }
        }
        .sheet(isPresented: $showPhotoSheet) {
            PhotoSelectionSheet(
                hasExistingPhoto: hasExistingPhoto,
                isCameraAvailable: isCameraAvailable,
                onTakePhoto: {
                    showPhotoSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCamera = true
                    }
                },
                onChooseFromLibrary: {
                    showPhotoSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showImagePicker = true
                    }
                },
                onRemovePhoto: {
                    withAnimation {
                        profileImageBase64 = ""
                    }
                    toast.success("Profile photo removed")
                    showPhotoSheet = false
                }
            )
            .presentationDetents([.height(sheetHeight)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(24)
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        let fiveMB = 5 * 1024 * 1024
                        if data.count > fiveMB {
                            toast.error("Image too large. Please choose an image under 5MB.")
                            return
                        }
                        if let uiImage = UIImage(data: data),
                           let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                            withAnimation {
                                profileImageBase64 = compressed.base64EncodedString()
                            }
                            toast.success("Profile photo updated")
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraFullScreenWrapper { image in
                if let data = image.jpegData(compressionQuality: 0.7) {
                    withAnimation {
                        profileImageBase64 = data.base64EncodedString()
                    }
                    toast.success("Profile photo updated")
                }
            }
        }
    }

    // MARK: - Avatar & Name Card
    // React: bg-card rounded-2xl p-6 shadow-soft border border-border/50

    private var avatarNameCard: some View {
        VStack(spacing: 16) {
            // Editable Avatar
            Button {
                showPhotoSheet = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                    } else {
                        // React: bg-gradient-to-br from-primary/20 to-accent/20
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.primary.opacity(0.2),
                                        AppColors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppColors.primary)
                            )
                    }

                    // Camera badge
                    // React: w-8 h-8 rounded-full bg-primary shadow-md border-2 border-background
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.primaryForeground)
                        )
                        .overlay(
                            Circle()
                                .stroke(AppColors.background, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
            }
            .buttonStyle(.plain)

            // Editable Name
            if isEditingName {
                VStack(spacing: 12) {
                    TextField("Enter your name", text: $tempName)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .inputFocusStyle(isFocused: isNameFieldFocused, cornerRadius: 8)
                        .focused($isNameFieldFocused)
                        .onSubmit { saveName() }

                    HStack(spacing: 12) {
                        Button {
                            isEditingName = false
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.foreground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppColors.muted)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Button {
                            saveName()
                        } label: {
                            Text("Save")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.primaryForeground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .frame(maxWidth: 200)
            } else {
                Button {
                    tempName = displayName
                    isEditingName = true
                } label: {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text(displayName.isEmpty ? "Tap to set name" : displayName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(displayName.isEmpty ? AppColors.mutedForeground : AppColors.foreground)
                        }

                        Text("Tap to edit")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }

    // MARK: - Sync Status Card
    // React: bg-emerald-500/10, text-emerald-600 dark:text-emerald-400

    private var syncStatusCard: some View {
        HStack(spacing: 16) {
            // React: w-12 h-12 rounded-full bg-emerald-500/10
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.green)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("iCloud Sync")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)

                    // React: w-4 h-4 rounded-full bg-emerald-500
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        )
                }

                Text("Syncing across your devices")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.mutedForeground)
            }

            Spacer()
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

    // MARK: - Stats Card
    // React: SectionCard style with "Your Stats" header

    private var statsCard: some View {
        VStack(spacing: 0) {
            // Header: px-5 py-3 bg-muted/30 border-b
            HStack {
                Text("Your Stats")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.mutedForeground)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppColors.muted.opacity(0.3))

            Divider()
                .background(AppColors.border.opacity(0.5))

            // Total Memories row
            // React: w-10 h-10 rounded-full bg-primary/10
            HStack(spacing: 16) {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Memories")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                    Text("\(entryCount)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)
                }

                Spacer()
            }
            .padding(16)

            Divider()
                .background(AppColors.border.opacity(0.5))

            // First Entry row
            // React: w-10 h-10 rounded-full bg-accent/10
            HStack(spacing: 16) {
                Circle()
                    .fill(AppColors.accent.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("First Entry")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                    Text(firstEntryDate != nil ? formatDate(firstEntryDate!) : "No entries yet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)
                }

                Spacer()
            }
            .padding(16)
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }

    // MARK: - Apple Sign In Card (Coming Soon)
    // React: opacity-60

    private var appleSignInCard: some View {
        HStack(spacing: 16) {
            // React: w-12 h-12 rounded-full bg-muted
            Circle()
                .fill(AppColors.muted)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "apple.logo")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.mutedForeground)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Sign in with Apple")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.mutedForeground)

                Text("Coming Soon")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.mutedForeground)
            }

            Spacer()

            // React: text-xs font-medium px-2 py-1 rounded-full bg-muted
            Text("Soon")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.mutedForeground)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.muted)
                .clipShape(Capsule())
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
        .opacity(0.6)
    }

    // MARK: - Helpers

    private func saveName() {
        let trimmed = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            displayName = trimmed
            toast.success("Display name updated")
        }
        isEditingName = false
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Photo Selection Sheet
// Translated from ProfilePage.tsx custom bottom sheet

struct PhotoSelectionSheet: View {
    let hasExistingPhoto: Bool
    let isCameraAvailable: Bool
    let onTakePhoto: () -> Void
    let onChooseFromLibrary: () -> Void
    let onRemovePhoto: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Change Profile Photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.foreground)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.mutedForeground)
                        .frame(width: 32, height: 32)
                        .background(AppColors.muted)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)

            // Options
            VStack(spacing: 12) {
                if isCameraAvailable {
                    PhotoOptionButton(
                        icon: "camera.fill",
                        iconBackgroundColor: AppColors.primary.opacity(0.1),
                        iconColor: AppColors.primary,
                        title: "Take Photo",
                        subtitle: "Use your camera",
                        action: onTakePhoto
                    )
                }

                PhotoOptionButton(
                    icon: "photo.fill",
                    iconBackgroundColor: AppColors.accent.opacity(0.1),
                    iconColor: AppColors.accent,
                    title: "Choose from Album",
                    subtitle: "Select an existing photo",
                    action: onChooseFromLibrary
                )

                if hasExistingPhoto {
                    PhotoOptionButton(
                        icon: "trash.fill",
                        iconBackgroundColor: AppColors.destructive.opacity(0.1),
                        iconColor: AppColors.destructive,
                        title: "Remove Photo",
                        subtitle: "Delete current photo",
                        action: onRemovePhoto
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Extra padding for home indicator

            Spacer()
        }
        .background(AppColors.card.ignoresSafeArea())
    }
}

// MARK: - Photo Option Button

struct PhotoOptionButton: View {
    let icon: String
    let iconBackgroundColor: Color
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // React: w-12 h-12 rounded-full bg-primary/10
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundStyle(iconColor)
                    )

                // React: text-left
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.foreground)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                Spacer()
            }
            .padding(16)
            .background(AppColors.muted.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Camera Full Screen Wrapper
// Ensures camera truly fills the entire screen

struct CameraFullScreenWrapper: View {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)

            CameraPickerViewControllerWrapper(
                onImageCaptured: { image in
                    onImageCaptured(image)
                    dismiss()
                },
                onCancel: {
                    dismiss()
                }
            )
            .ignoresSafeArea(.all)
        }
        .statusBarHidden(true)
    }
}

struct CameraPickerViewControllerWrapper: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        picker.modalPresentationStyle = .overFullScreen
        picker.cameraDevice = .rear
        picker.cameraCaptureMode = .photo

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerViewControllerWrapper

        init(_ parent: CameraPickerViewControllerWrapper) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
            .environment(EntryStore.preview)
    }
}
