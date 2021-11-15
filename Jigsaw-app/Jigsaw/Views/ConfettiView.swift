//
//  ConfettiView.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/18/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

private let kAnimationLayerKey = "com.nshipster.animationLayer"

/// A view that emits confetti.
final class ConfettiView: UIView, CAAnimationDelegate {
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = false
    }
    
    /// Emits the provided confetti content for a specified duration.
    /// - Parameters:
    ///   - contents: The contents to be emitted as confetti.
    ///   - duration: The amount of time in seconds to emit confetti before fading out; 3.0 seconds by default.
    func emit(_ contents: [Content], for duration: TimeInterval = 3.0) {
        guard duration.isFinite else { return }
        
        let layer = Layer()
        layer.configure(with: contents)
        layer.frame = bounds
        layer.needsDisplayOnBoundsChange = true
        self.layer.addSublayer(layer)
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = #keyPath(Layer.birthRate)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fillMode = convertToCAMediaTimingFillMode("forwards")
        animation.values = [1, 0, 0]
        animation.keyTimes = [0, 0.5, 1]
        animation.isRemovedOnCompletion = false
        
//        layer.beginTime = CACurrentMediaTime()
        layer.birthRate = 1.0
        layer.add(animation, forKey: kAnimationLayerKey)  // nil if fade out transition.
        
        // Note: there are some issue with the code below that causes
        // the animation not to stop.
//        CATransaction.begin()
//        CATransaction.setCompletionBlock { [unowned self, unowned layer] in
//            let transition = CATransition()
//            transition.delegate = self
//            transition.type = .fade
//            transition.duration = 1
//            transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
//            transition.setValue(layer, forKey: kAnimationLayerKey)
//            transition.isRemovedOnCompletion = false
//
//            layer.add(transition, forKey: nil)
//
//            layer.opacity = 0
//        }
//        CATransaction.commit()
    }
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if let layer = animation.value(forKey: kAnimationLayerKey) as? Layer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
    }
    
    // MARK: UIView
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let superview = newSuperview else { return }
        frame = superview.bounds
        isUserInteractionEnabled = false
    }
    
    // swiftlint:disable nesting
    
    /// Content to be emitted as confetti
    enum Content {
        /// Confetti shapes
        enum Shape {
            case circle
            case triangle
            case square
            
            // A custom shape.
            case custom(CGPath)
        }
        
        /// A shape with a particular color.
        case shape(Shape, UIColor)
        /// An image with an optional tint color.
        case image(UIImage, UIColor?)
        /// A string of characters.
        case text(String)
    }
    // swiftlint:enable nesting
    
    private final class Layer: CAEmitterLayer {
        func configure(with contents: [Content]) {
            emitterCells = contents.map { content in
                let cell = CAEmitterCell()
                
                cell.birthRate = 50.0
                cell.lifetime = 10.0
                cell.velocity = CGFloat(cell.birthRate * cell.lifetime)
                cell.velocityRange = cell.velocity / 2
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.spinRange = .pi * 8
                cell.scaleRange = 0.25
                cell.scale = 1.0 - cell.scaleRange
                cell.contents = content.image.cgImage
                
                if let color = content.color {
                    cell.color = color.cgColor
                }
                
                return cell
            }
        }
        
        // MARK: CALayer
        
        override func layoutSublayers() {
            super.layoutSublayers()
            
            emitterMode = convertToCAEmitterLayerEmitterMode("outline")
            emitterShape = convertToCAEmitterLayerEmitterShape("line")
            emitterSize = CGSize(width: frame.size.width, height: 1.0)
            emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        }
    }
}

// MARK: -

private extension ConfettiView.Content.Shape {
    func path(in rect: CGRect) -> CGPath {
        switch self {
        case .circle:
            return CGPath(ellipseIn: rect, transform: nil)
        case .triangle:
            let path = CGMutablePath()
            path.addLines(between: [
                CGPoint(x: rect.midX, y: 0),
                CGPoint(x: rect.maxX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.maxY),
                CGPoint(x: rect.midX, y: 0)
            ])
            
            return path
        case .square:
            return CGPath(rect: rect, transform: nil)
        case .custom(let path):
            return path
        }
    }
    
    func image(with color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 12.0, height: 12.0))
        return UIGraphicsImageRenderer(size: rect.size).image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.addPath(path(in: rect))
            context.cgContext.fillPath()
        }
    }
}

private extension ConfettiView.Content {
    var color: UIColor? {
        switch self {
        case let .image(_, color?),
             let .shape(_, color):
            return color
        default:
            return nil
        }
    }
    
    var image: UIImage {
        switch self {
        case let .shape(shape, _):
            return shape.image(with: .white)
        case let .image(image, _):
            return image
        case let .text(string):
            let defaultAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16.0)
            ]
            
            return NSAttributedString(string: "\(string)", attributes: defaultAttributes).image
        }
    }
}

private extension NSAttributedString {
    var image: UIImage {
        return UIGraphicsImageRenderer(size: size()).image { _ in
            self.draw(at: .zero)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFillMode(_ input: String) -> CAMediaTimingFillMode {
	return CAMediaTimingFillMode(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAEmitterLayerEmitterMode(_ input: String) -> CAEmitterLayerEmitterMode {
	return CAEmitterLayerEmitterMode(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAEmitterLayerEmitterShape(_ input: String) -> CAEmitterLayerEmitterShape {
	return CAEmitterLayerEmitterShape(rawValue: input)
}
