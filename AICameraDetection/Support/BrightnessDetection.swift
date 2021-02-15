//
//  BrightnessDetection.swift
//  AICameraDetection
//
//  Created by Азиз on 08.02.2021.
//

import UIKit

extension CIImage {
    
    var averageColor: UIColor? {
        let extentVector = CIVector(x: self.extent.origin.x, y: self.extent.origin.y, z: self.extent.size.width, w: self.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
        
    }
}

extension UIColor {
    func light() -> Float {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        var brightness: Float = 0.0
        if let components = self.cgColor.components {
            let red = (components[0] * 0.299)
            let green = (components[1] * 0.587)
            let blue = (components[2] * 0.114)
            brightness = Float((red + green + blue))
            
        }
        return brightness
    }
}
  
