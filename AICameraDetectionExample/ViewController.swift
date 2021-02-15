//
//  ViewController.swift
//  AICameraDetectionExample
//
//  Created by Азиз on 30.01.2021.
//

import UIKit
import AICameraDetection

/// Camera ViewController
// MARK: - Do NOT foget add an NSCameraUsageDescription key with a string value explaining to the user how the app uses this data to Info.plist or you will get runtime error! -

class ViewController: UIViewController {
    
    var cameraManager: AICameraDetectionManager!
    
    let setupViewHander: () -> Void = {
        // setup buttons for take a photo or video or what eve you what to setup with UI
    }
    
    let cameraErrorHandler: (AICameraAccessError) -> Void = { (error) in
        switch error {
            case .denied:
                print(error.rawValue)
            // you also can use method for open setting for change permition for camera usage
            // openSetting()
            default:
                print(error.rawValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cameraCaptureSetup()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func cameraCaptureSetup() {
        cameraManager = AICameraDetectionManager(cameraView: self.view, detectionType: .face, errorHandler: cameraErrorHandler)
        cameraManager.openCamera()
        cameraManager.setupUI = setupViewHander
        cameraManager.delegate = self
    }
    
    @IBAction func switchCamera(_ sender: UIButton) {
        cameraManager.switchCamera()
    }

    /// you can open settings and show alert to user why you need to use camera and open setings by call this func
    @objc
    func openSettings() {
        // open the app permission in Settings app
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                  options: [:], completionHandler: nil)
    }
}

extension ViewController: AICameraDetectionManagerDelegate {
    func brightness(value: Detection.Brightness) {
        switch value {
            case .isTooBright:
                NSLog("TO Bright", "Detection.Brightness")
            case .isTooDark:
                NSLog("TO Dark", "Detection.Brightness")
            case .normal:
                NSLog("It's OK", "Detection.Brightness")
            case .indefined:
                NSLog("Indefined", "Detection.Brightness")
        }
    }
    
    func faceDatectedWith(faceRects: [CGRect], faceLayers: [CAShapeLayer]) {
        for face in faceLayers {
            view.layer.addSublayer(face)
        }
    }
}
