//
//  PhotoButtonView.swift
//  CAAnimation
//
//  Created by 홍창남 on 2018. 7. 23..
//  Copyright © 2018년 홍창남. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoButtonDelegate: class {
    func didTapButton()
}

class PhotoButtonView: UIView {

    // MARK: Property
    weak var delegate: PhotoButtonDelegate?

    let blackLineLayer = CAShapeLayer()
    let progressLayer = CAShapeLayer()
    let pulseLayer = CAShapeLayer()
    var gradientLayer: CAGradientLayer?

    let animationDuration: CFTimeInterval = 2.0
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(takePhoto))

    private var layerPath: CGPath {
        let boundCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        return UIBezierPath(arcCenter: boundCenter,
                            radius: self.bounds.width / 2,
                            startAngle: -CGFloat.pi / 2,
                            endAngle: CGFloat.pi * 2,
                            clockwise: true).cgPath
    }

    // MARK: -
    // MARK: Layer Setup

    /// 사진 촬영 진행 progress를 보여주는 Layer 설정
    private func setupProgressLayer(lineWidth: CGFloat) {
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeColor = #colorLiteral(red: 1, green: 0.1975799089, blue: 0.6812156217, alpha: 1).cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = kCALineCapRound

        let boundCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        progressLayer.path = UIBezierPath(arcCenter: boundCenter,
                                          radius: self.bounds.width / 2,
                                          startAngle: -CGFloat.pi / 2,
                                          endAngle: CGFloat.pi * 2,
                                          clockwise: true).cgPath

        self.layer.addSublayer(progressLayer)
    }

    /// 버튼 내부의 검은색 Layer 설정
    private func setupLineLayer(lineWidth: CGFloat) {
        blackLineLayer.strokeColor = UIColor.black.cgColor
        blackLineLayer.lineWidth = lineWidth
        blackLineLayer.fillColor = UIColor.clear.cgColor

        let rect = CGRect(origin: CGPoint(x: self.bounds.minX + lineWidth, y: self.bounds.minY + lineWidth),
                          size: CGSize(width: self.bounds.width - (lineWidth * 2),
                                       height: self.bounds.height - (lineWidth * 2)))

        blackLineLayer.path = UIBezierPath(ovalIn: rect).cgPath
        self.layer.addSublayer(blackLineLayer)
    }

    /// pulse 효과를 위한 Layer 설정
    private func setupPulseLayer(lineWidth: CGFloat) {

        pulseLayer.strokeColor = #colorLiteral(red: 1, green: 0.1975799089, blue: 0.6812156217, alpha: 0.5).cgColor
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.lineWidth = lineWidth
        pulseLayer.frame = self.bounds
        pulseLayer.path = self.layerPath

        self.layer.insertSublayer(pulseLayer, above: self.layer)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupPulseLayer(lineWidth: 4)
        setupLineLayer(lineWidth: 5)
        setupProgressLayer(lineWidth: 6)

        self.addGestureRecognizer(tapGesture)

        pulseLayer.isHidden = true
    }

    // MARK: -
    // MARK: Layer Animation

    /// 사진 촬영 진행 Progress 애니메이션
    private func progressAnimation() {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.duration = animationDuration
        progressAnimation.fillMode = kCAFillModeForwards
        progressAnimation.isRemovedOnCompletion = false
        progressAnimation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        progressAnimation.toValue = 1
        progressLayer.add(progressAnimation, forKey: "layer.progress")

    }

    /// Progress Animation을 gradient Layer로 masking
    private func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = self.bounds
        gradientLayer?.cornerRadius = self.bounds.width / 2
        gradientLayer?.colors = [#colorLiteral(red: 1, green: 0.1975799089, blue: 0.6812156217, alpha: 1).cgColor, #colorLiteral(red: 0.9176470588, green: 0.1529411765, blue: 0.3843137255, alpha: 1).cgColor, #colorLiteral(red: 0.9882352941, green: 0.1058823529, blue: 0.3490196078, alpha: 1).cgColor]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        self.layer.addSublayer(gradientLayer!)
        gradientLayer?.mask = progressLayer
    }

    /// pulse 효과 애니메이션
    private func pulseAnimation() {
        pulseLayer.isHidden = false

        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.5
        pulseAnimation.toValue = 1.08
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        pulseAnimation.repeatCount = Float(animationDuration * pulseAnimation.duration * 2)
        pulseLayer.add(pulseAnimation, forKey: "layer.pulsing")
    }

    /// 애니메이션 종료 후 제거
    private func removeAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            guard let `self` = self else { return }

            self.progressLayer.removeAllAnimations()
            self.pulseLayer.removeAllAnimations()
            self.pulseLayer.isHidden = true
            self.gradientLayer?.removeFromSuperlayer()
            self.tapGesture.isEnabled = true
        }
    }

    /// tapGesture를 통해 호출
    @objc func takePhoto() {
        self.tapGesture.isEnabled = false

        pulseAnimation()
        progressAnimation()
        setupGradientLayer()
        removeAnimations()

        delegate?.didTapButton()
    }
}
