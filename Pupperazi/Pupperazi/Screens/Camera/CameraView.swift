import SwiftUI

struct CameraView: View {
    @Binding var showCreateView: Bool
    @Binding var capturedImage: UIImage?
    @Binding var showPhotoConfirmation: Bool
    var isActive: Bool = false
    @State private var camera = CameraManager()
    @State private var shutterAppeared = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Camera preview
                CameraPreview(session: camera.session)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                // Zoom control
                ZoomControl(
                    steps: camera.zoomSteps,
                    zoom: $camera.zoomLevel
                )
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .onChange(of: camera.zoomLevel) { _, newValue in
                    camera.setZoom(newValue)
                }

                // Controls row
                HStack(spacing: 8) {
                    FlashButton(mode: $camera.flashMode)
                        .frame(maxWidth: .infinity)

                    ShutterButton(
                        action: {
                            Task {
                                let image = await camera.capturePhoto()
                                if let image {
                                    capturedImage = image
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        showPhotoConfirmation = true
                                    }
                                }
                            }
                        },
                        appeared: shutterAppeared
                    )

                    CameraRotateButton {
                        camera.rotateCamera()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(EdgeInsets(top: 12, leading: 16, bottom: 32, trailing: 16))
            }
            .opacity(showPhotoConfirmation ? 0 : 1)

            // Photo confirmation overlay
            if showPhotoConfirmation, let image = capturedImage {
                PhotoConfirmationView(
                    image: image,
                    onConfirm: {
                        showCreateView = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPhotoConfirmation = false
                        }
                    },
                    onRetake: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showPhotoConfirmation = false
                        }
                        capturedImage = nil
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            camera.requestPermission()
            if isActive {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    shutterAppeared = true
                }
            }
        }
        .onDisappear {
            camera.stopSession()
            shutterAppeared = false
        }
        .onChange(of: isActive) { _, active in
            if active {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    shutterAppeared = true
                }
            } else {
                shutterAppeared = false
            }
        }
    }
}

// MARK: - Photo Confirmation

struct PhotoConfirmationView: View {
    let image: UIImage
    let onConfirm: () -> Void
    let onRetake: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Polaroid photo
            PolaroidFrame {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            }
            .padding(.horizontal, 40)
            .rotationEffect(.degrees(-2))

            Spacer()

            // Confirmation content
            VStack(spacing: 20) {
                Text("WANNA USE\nTHIS PAP?")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Label.inverse)
                    .multilineTextAlignment(.center)

                PrimaryButton(title: "Yeah, let's go!") {
                    onConfirm()
                }

                Button {
                    onRetake()
                } label: {
                    Text("No, I'll retake it")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.Label.inverse)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 40)
        }
    }
}
