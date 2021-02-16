//
//  AICameraDetection.swift
//  AICameraDetection
//
//  Created by Азиз on 30.01.2021.
//
import UIKit
import AVFoundation

public protocol AICameraDetectionManagerDelegate: class {
    func faceDatectedWith(faceRects: [CGRect], faceLayers: [CAShapeLayer])
    func brightness(value: Detection.Brightness)
    func detectionStateChanged(_ state: Detection.DetectionState)
}

/// Manage camera setup and access
open class AICameraDetectionManager {
    
    // MARK: - Open Variables
    /// use for setup camera view
    public var setupUI: (() -> Void)?
    
    /// detectionDelegate
    public weak var delegate: AICameraDetectionManagerDelegate?
    
    // MARK: - Private Variables
    let preview: UIView
    /// you should use it for error handling
    var errorHandler: ((AICameraAccessError) -> Void)?
    var sessionManager: AISessionManager!
    var detectionType: AIDetectionType
    var capturePhotoDelegate: AVCapturePhotoCaptureDelegate? = nil
    /// detectionTypes
    var faceDetection = AIFaceDetection()
    // MARK: - Init
    /// Default init for AICameraDetectionManager
    /// - Parameters:
    ///   - cameraView: UIView where you will show camera layer
    ///   - detectionType: detection type AIDetectionType
    ///   - errorHandler: this handler will triggered when camera access error
    ///   - capturePhoto: AVCapturePhotoCaptureDelegate implementation for take a  photo
    /// implement this func required for take a photo this calling takePhoto method:
    ///   photoOutput( _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    public required init(cameraView: UIView, detectionType:AIDetectionType, errorHandler: ((AICameraAccessError) -> Void)? = nil, capturePhoto:AVCapturePhotoCaptureDelegate? = nil) {
        self.preview = cameraView
        self.errorHandler = errorHandler
        self.detectionType = detectionType
        self.capturePhotoDelegate = capturePhoto
        setupManager()
        // setup detection delegates
        faceDetection.delegate = self
        setupMode()
    }
    
    // MARK: - Public methods
    /// Fist func wich yoy should use for open camera in specific view
    /// this method call errorHandler if error exist with camera permition
    /// error type AICameraAccessError
    public func openCamera() {
        sessionManager?.openCamera(callback: { error  in
            DispatchQueue.main.async {
                self.errorHandler?(error)
            }
        })
    }
    
    /// This func calls AISessionManager method witch calls photoOutput,capturePhoto(with:,delegate:)
    /// where delegate is class implements AVCapturePhotoCaptureDelegate
    /// call this gunc after implement func photoOutput( _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    public func takePhoto() {
        sessionManager.handleTakePhoto()
    }
    
    /// switch camera from front to back
    public func switchCamera() {
        switch sessionManager.cameraPosition {
            case .front:
                sessionManager.cameraPosition = .back
            case .back:
                sessionManager.cameraPosition = .front
            default:
                break
        }
    }
    
    /// Switch detection mode
    /// - Parameter detectionType: AIDetectionType enum types of detection .face, .document etc.
    /// for detect face uses front camera, for documents uses back camera
    private func setupMode() {
        switch detectionType {
            case .face:
                sessionManager.delegate = faceDetection
            case .document:
                sessionManager.delegate = nil
        }
    }
    
    // MARK: - Private methods
    private func setupManager() {
        if let capturePhotoDelegate =  capturePhotoDelegate {
            sessionManager = AISessionManager(cameraView: preview, capturePhotoDelegate: capturePhotoDelegate)
        } else {
            sessionManager = AISessionManager(cameraView: preview)
        }
        sessionManager?.setupUI = setupUI
        sessionManager.delegate = faceDetection
    }
}

extension AICameraDetectionManager: FaceDetectionProtocol {
    func detectionStateChanged(with state: Detection.DetectionState) {
        delegate?.detectionStateChanged(state)
    }
    
    func detectBrightness(brightness: Detection.Brightness) {
        delegate?.brightness(value: brightness)
    }
    
    func detectedFaces(faceBoxsLayer: [CAShapeLayer], faceRects: [CGRect]) {
        delegate?.faceDatectedWith(faceRects: faceRects, faceLayers: faceBoxsLayer)
    }
    
}
