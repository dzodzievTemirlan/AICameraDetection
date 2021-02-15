//
//  FaceMaskView.swift
//  AICameraDetection
//
//  Created by Азиз on 10.02.2021.
//
import UIKit

class FaceView: UIView {
    
    var path = UIBezierPath()
    
    var width: CGFloat = 200
    var height: CGFloat = 300
    
    override func draw(_ rect: CGRect) {
        // create oval centered at (0, 0)
        let path = UIBezierPath(ovalIn: CGRect(x: -width/2, y: -height/2, width: width , height: height))

//        // rotate it 30 degrees
//        path.apply(CGAffineTransform(rotationAngle: .pi / 2))

        // translate it to where you want it
        path.apply(CGAffineTransform(translationX: self.bounds.width / 2, y: self.bounds.height / 2))
        
        // set stroke color
        UIColor.blue.setStroke()
        // stroke the path
        path.stroke()
      
        let blurEffect = UIBlurEffect(style: .dark)
        let blur = UIVisualEffectView(effect: blurEffect)
        
        blur.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blur, at: 0)
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blur.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blur.isUserInteractionEnabled = false
        blur.clipsToBounds = true
        
        let superPath = UIBezierPath(rect: CGRect(origin: .zero, size: bounds.size))
//        superPath.apply(CGAffineTransform(translationX: bounds.width / 2, y: bounds.height / 2))
        superPath.append(path)
        superPath.usesEvenOddFillRule = true
        
        let testLayer = CAShapeLayer()
        testLayer.path = superPath.cgPath
        testLayer.fillRule = .evenOdd
        layer.addSublayer(testLayer)
        blur.layer.mask = testLayer
        
    }
}
