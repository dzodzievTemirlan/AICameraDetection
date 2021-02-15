//
//  AISessionManager.swift
//  AICameraDetection
//
//  Created by Азиз on 30.01.2021.
//

import UIKit
import AVFoundation

public protocol AISessionProtocol: class {
    func captureOutput(sampleBuffer: CMSampleBuffer, previewLayer: AVCaptureVideoPreviewLayer)
}

public class AISessionManager: NSObject {

    public weak var delegate: AISessionProtocol?

    var setupUI: VoidHandler?
    var cameraPosition: AVCaptureDevice.Position {
        didSet {
            reloadCamera()
        }
    }

    var captureDevice: AVCaptureDevice?
    var previewLayer = AVCaptureVideoPreviewLayer()
    var photoOutput = AVCapturePhotoOutput()
    var session = AVCaptureSession()
    let cameraView: UIView
    let sessionQueue = DispatchQueue(label: "session queue")
    let videoDataOutput = AVCaptureVideoDataOutput()

    init(cameraView: UIView) {
        self.cameraView = cameraView
        cameraPosition = .front
    }

    func openCamera(callback: @escaping CameraAccessErrorHandler) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // user has already authorized to access the camera
                sessionQueue.async {
                    self.reloadCamera()
                }
                NSLog("✅ user has already authorized to access the camera")
            case .notDetermined: // the user has not yet asked for camera access
                AVCaptureDevice.requestAccess(for: .video) {[weak self] (granded) in
                    guard let self = self else { return }
                    if granded {
                        NSLog("✅ the user has granded to access the camera")
                        self.sessionQueue.async {
                            self.reloadCamera()
                        }
                    } else {
                        NSLog(AICameraAccessError.notGranded.description)
                        callback(.notGranded)
                    }
                }
            case .denied:
                NSLog(AICameraAccessError.denied.description)
                callback(.denied)
            case .restricted:
                NSLog(AICameraAccessError.restricted.description)
                callback(.restricted)
            default:
                NSLog(AICameraAccessError.unrecognizedError.description)
                callback(.unrecognizedError)
        }

    }

    func reloadCamera() {
        session.stopRunning()
        previewLayer.removeFromSuperlayer()
        // camera loading code
        session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo

        var captureDevice: AVCaptureDevice! = nil
        
        switch cameraPosition {
            case .front:
                captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                                                                 mediaType: .video, position: .front).devices.first
            case .back:
                captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                                                                 mediaType: .video, position: .back).devices.first
            default:
                break
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch let error {
            NSLog("Failed to set input device with error: \(error)")
        }
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
        session.startRunning()

        DispatchQueue.main.async {
            self.setupUI?()
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.previewLayer.frame = self.cameraView.frame
            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.connection?.videoOrientation = .portrait
            self.cameraView.layer.insertSublayer(self.previewLayer, at: 0)

            self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
            self.session.addOutput(self.videoDataOutput)

        }
    }

    @objc
    public func openSettings() {
        // open the app permission in Settings app
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate -
/// capture image every time when camera has updated
extension AISessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(sampleBuffer: sampleBuffer, previewLayer: previewLayer)
    }
}
