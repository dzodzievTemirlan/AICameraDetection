//
//  Detection.swift
//  AICameraDetection
//
//  Created by Азиз on 31.01.2021.
//

import Foundation
import VisionKit
import VideoToolbox

open class Detection: NSObject {
    /// Detection State :
    public enum DetectionState {
        /// singleDetection  - only one face
        case singleDetection
        /// manyDetections - value equels faces detected in camera
        case manyDetections(Int)
        /// notDetected -  faces not detected
        case notDetected
    }
    
    /// Brightness state of image when detecting is started
    public enum Brightness {
        /// normal state for detection
        case normal
        /// is too dark state for detection
        case isTooDark
        /// is too bright for detection
        case isTooBright
        /// can not detect brightness
        case indefined
    }
    
}
