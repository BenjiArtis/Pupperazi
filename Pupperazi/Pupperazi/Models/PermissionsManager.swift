import AVFoundation
import CoreLocation
import Photos

/// Handles requesting system permissions during onboarding.
final class PermissionsManager: NSObject, CLLocationManagerDelegate {

    enum PermissionResult {
        case granted
        case denied
    }

    // MARK: - Camera

    func requestCamera() async -> PermissionResult {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return .granted
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted ? .granted : .denied
        default:
            return .denied
        }
    }

    // MARK: - Location

    private var locationContinuation: CheckedContinuation<PermissionResult, Never>?
    private var locationManager: CLLocationManager?

    func requestLocation() async -> PermissionResult {
        if locationManager == nil {
            let manager = CLLocationManager()
            manager.delegate = self
            locationManager = manager
        }

        let status = locationManager!.authorizationStatus

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                locationContinuation = continuation
                locationManager!.requestWhenInUseAuthorization()
            }
        default:
            return .denied
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            continuation.resume(returning: .granted)
        case .notDetermined:
            break // Still waiting
        default:
            continuation.resume(returning: .denied)
        }
    }

    // MARK: - Photo Library

    func requestPhotoLibrary() async -> PermissionResult {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            return .granted
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return (newStatus == .authorized || newStatus == .limited) ? .granted : .denied
        default:
            return .denied
        }
    }
}
