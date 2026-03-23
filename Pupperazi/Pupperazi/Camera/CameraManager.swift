import AVFoundation
import SwiftUI
import Photos

@Observable
final class CameraManager: NSObject {
    // MARK: - Published state

    var isSessionRunning = false
    var flashMode: FlashMode = .auto
    var zoomLevel: Double = 1.0
    var capturedImage: UIImage?
    var permissionGranted = false
    var isFrontCamera = false

    /// Available zoom steps for the current device.
    var zoomSteps: [Double] {
        guard let device = currentCamera else { return [0.5, 1, 2] }
        var steps: [Double] = []

        // Ultra-wide (0.5x)
        if device.minAvailableVideoZoomFactor <= 1.0 {
            steps.append(0.5)
        }
        steps.append(1.0)
        steps.append(2.0)

        let maxZoom = min(Double(device.activeFormat.videoMaxZoomFactor), 15)
        if maxZoom >= 5 { steps.append(5) }
        if maxZoom >= 10 { steps.append(10) }

        return steps
    }

    // MARK: - Internals

    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

    private var currentCamera: AVCaptureDevice? {
        videoInput?.device
    }

    // MARK: - Setup

    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if granted { self?.setupSession() }
                }
            }
        default:
            permissionGranted = false
        }
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Default to back camera
        guard let camera = bestBackCamera(),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
            videoInput = input
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
        startSession()
    }

    // MARK: - Session lifecycle

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            Task { @MainActor in
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            Task { @MainActor in
                self?.isSessionRunning = false
            }
        }
    }

    // MARK: - Zoom

    func setZoom(_ level: Double) {
        guard let device = currentCamera else { return }
        let clamped = min(max(level, Double(device.minAvailableVideoZoomFactor)),
                         Double(device.activeFormat.videoMaxZoomFactor))
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = CGFloat(clamped)
            device.unlockForConfiguration()
            zoomLevel = level
        } catch {}
    }

    // MARK: - Flash

    var avFlashMode: AVCaptureDevice.FlashMode {
        switch flashMode {
        case .on: .on
        case .auto: .auto
        case .off: .off
        }
    }

    // MARK: - Camera rotation

    func rotateCamera() {
        session.beginConfiguration()

        // Remove current input
        if let input = videoInput {
            session.removeInput(input)
        }

        isFrontCamera.toggle()

        let camera: AVCaptureDevice?
        if isFrontCamera {
            camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        } else {
            camera = bestBackCamera()
        }

        guard let cam = camera,
              let newInput = try? AVCaptureDeviceInput(device: cam) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(newInput) {
            session.addInput(newInput)
            videoInput = newInput
        }

        session.commitConfiguration()

        // Reset zoom for the new camera
        setZoom(1.0)
    }

    // MARK: - Capture

    func capturePhoto() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            if photoOutput.supportedFlashModes.contains(avFlashMode) {
                settings.flashMode = avFlashMode
            }

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Helpers

    private func bestBackCamera() -> AVCaptureDevice? {
        // Prefer triple, then dual, then wide angle
        if let triple = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            return triple
        }
        if let dual = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
            return dual
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image: UIImage?
        if let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }

        Task { @MainActor in
            self.capturedImage = image
            self.photoContinuation?.resume(returning: image)
            self.photoContinuation = nil
        }
    }
}
