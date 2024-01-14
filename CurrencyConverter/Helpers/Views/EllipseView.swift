//
//  EllipseView.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

final class EllipseView: UIView {
    private var bottomSublayer = CAShapeLayer()
    private var middleSublayer = CAShapeLayer()
    private var topSublayer = CAShapeLayer()
    
    private var bottomSublayersPath: CGPath {
        CGPath(ellipseIn: CGRect(x: -100,
                                 y: -bounds.height * 0.4,
                                 width: bounds.width * 1.4,
                                 height: bounds.height * 1.6), transform: nil)
    }
    private var middleSublayersPath: CGPath {
        CGPath(ellipseIn: CGRect(x: -120,
                                 y: -bounds.height * 0.5,
                                 width: bounds.width * 1.35,
                                 height: bounds.height * 1.45), transform: nil)
    }
    private var topSublayersPath: CGPath {
        CGPath(ellipseIn: CGRect(x: -140,
                                 y: -bounds.height * 0.5,
                                 width: bounds.width + 110,
                                 height: bounds.height * 1.4),transform: nil)
    }
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        bottomSublayer = layoutEllipseShapeLayer(
            path: bottomSublayersPath,
            color: UIColor.dodgerBlue.cgColor)
        middleSublayer = layoutEllipseShapeLayer(
            path: middleSublayersPath,
            color: UIColor.skyBlue.cgColor)
        topSublayer = layoutEllipseShapeLayer(
            path: topSublayersPath,
            color: UIColor.steelBlue.cgColor)
        [bottomSublayer, middleSublayer, topSublayer].forEach { shapeLayer in
            layer.addSublayer(shapeLayer)
        }
        accessibilityIdentifier = "topViewWithThreeLayers"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Overridden Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomSublayer.path = bottomSublayersPath
        middleSublayer.path = middleSublayersPath
        topSublayer.path = topSublayersPath
    }
    
    // MARK: - Layers setup
    private func layoutEllipseShapeLayer(path: CGPath, color: CGColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = color
        return shapeLayer
    }
}
