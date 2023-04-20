//
//  OvalView.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

class EllipseView: UIView {
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
            color: CGColor(red: 10/255, green: 95/255, blue: 255/255, alpha: 1))
        middleSublayer = layoutEllipseShapeLayer(
            path: middleSublayersPath,
            color: CGColor(red: 24/255, green: 110/255, blue: 247/255, alpha: 1))
        topSublayer = layoutEllipseShapeLayer(
            path: topSublayersPath,
            color: CGColor(red: 41/255, green: 126/255, blue: 255/255, alpha: 1))
        [bottomSublayer, middleSublayer, topSublayer].forEach { shapeLayer in
            layer.addSublayer(shapeLayer)
        }
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
