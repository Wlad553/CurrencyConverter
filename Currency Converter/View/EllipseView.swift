//
//  EllipseView.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

final class EllipseView: UIView {
    private var bottomSublayer: CAShapeLayer!
    private var middleSublayer: CAShapeLayer!
    private var topSublayer: CAShapeLayer!
    
    private var bottomSublayersPath: CGPath {
        CGPath(ellipseIn: CGRect(x: -100, y: -bounds.height * 0.4, width: bounds.width * 1.4, height: bounds.height * 1.6), transform: nil)
    }
    private var middleSublayersPath: CGPath {
        CGPath(ellipseIn: CGRect(x: -120, y: -bounds.height * 0.5, width: bounds.width * 1.35, height: bounds.height * 1.45), transform: nil)
    }
    private var topSublayersPath: CGPath {
        CGPath(ellipseIn: CGRect(x: -140, y: -bounds.height * 0.5, width: bounds.width + 110, height: bounds.height * 1.4), transform: nil)
    }
    
    override init(frame: CGRect = CGRect()) {
        super.init(frame: frame)
        bottomSublayer = layoutEllipseShapeLayer(
            path: bottomSublayersPath,
            color: UIColor.bottomEllipseLayer.cgColor)
        middleSublayer = layoutEllipseShapeLayer(
            path: middleSublayersPath,
            color: UIColor.middleEllipseLayer.cgColor)
        topSublayer = layoutEllipseShapeLayer(
            path: topSublayersPath,
            color: UIColor.topEllipseLayer.cgColor)
        [bottomSublayer, middleSublayer, topSublayer].forEach { shapeLayer in
            layer.addSublayer(shapeLayer)
        }
        self.accessibilityIdentifier = "topViewWithThreeLayers"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomSublayer.path = bottomSublayersPath
        middleSublayer.path = middleSublayersPath
        topSublayer.path = topSublayersPath
    }
    
    func layoutViewIn(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(self, at: 0)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
    }

    private func layoutEllipseShapeLayer(path: CGPath, color: CGColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = color
        return shapeLayer
    }
}
