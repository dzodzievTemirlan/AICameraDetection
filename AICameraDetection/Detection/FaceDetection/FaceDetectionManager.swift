//
//  AIFaceDetection.swift
//  AICameraDetection
//
//  Created by Азиз on 31.01.2021.
//

import UIKit
import Vision
import AVFoundation
import VideoToolbox

protocol FaceDetectionProtocol: class {
    func detectedFaces(faceBoxsLayer: [CAShapeLayer], faceRects: [CGRect])
    func detectBrightness(brightness: Detection.Brightness)
    func detectionStateChanged(with state: Detection.DetectionState)
}

open class AIFaceDetection: Detection {
    
    weak var delegate: FaceDetectionProtocol?
    public var detectionState: DetectionState = .notDetected
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var drawings: [CAShapeLayer] = []
    
    func detectFace(in imageBuffer: CVPixelBuffer, previewLayer: AVCaptureVideoPreviewLayer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, _: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    print("Did detect \(results.count) face(s)")
                    switch results.count {
                        case 1:
                            self.detectionState = .singleDetection
                            self.handleDetection(results, previewLayer: previewLayer)
                        case 2...:
                            self.detectionState = .manyDetections(results.count)
                            self.handleDetection(results, previewLayer: previewLayer)
                        default:
                            self.detectionState = .notDetected
                    }
                    self.delegate?.detectionStateChanged(with: self.detectionState)
                    
                } else {
                    print("did not detect any face")
                    self.detectionState = .notDetected
                    self.delegate?.detectionStateChanged(with: .notDetected)
                    self.clearDrawings()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .downMirrored, options: [:])
        let imageBrightness = detectBrightness(imageBuffer)
        delegate?.detectBrightness(brightness: imageBrightness)
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    /// Brightness value goes from 0 to 255.
    /// If the image's brightness is  < 34 , the image is too dark, if is >  227 is too bright.
    /// - Parameter value: range of bright
    func detectBrightness(_ imageBuffer: CVPixelBuffer) -> Brightness {
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let averageColor = ciImage.averageColor
        let light = averageColor?.light()
        if let light = light {
            switch light {
                case ...0.4:
                    return .isTooDark
                case 0.5...0.75:
                    return .normal
                case 0.75...:
                    return .isTooBright
                default:
                    return.indefined
            }
        }
        return .indefined
    }
    
    func handleDetection(_ observedFaces: [VNFaceObservation], previewLayer: AVCaptureVideoPreviewLayer) {
        self.clearDrawings()
        var faceRects = [CGRect]()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
            
            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            faceRects.append(faceBoundingBoxOnScreen)
            let faceBoundingBoxPath = CGPath(roundedRect: faceBoundingBoxOnScreen, cornerWidth: 10, cornerHeight: 10, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            return faceBoundingBoxShape
        })
        drawings = facesBoundingBoxes
        
        delegate?.detectedFaces(faceBoxsLayer: facesBoundingBoxes, faceRects: faceRects)
    }
    
    /// Clean superLayer befor add new subLayer
    func clearDrawings() {
        drawings.forEach({$0.removeFromSuperlayer()})
    }
}

extension AIFaceDetection: AISessionProtocol {
    
    public func captureOutput(sampleBuffer: CMSampleBuffer, previewLayer: AVCaptureVideoPreviewLayer) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        detectFace(in: frame, previewLayer: previewLayer)
    }
}
