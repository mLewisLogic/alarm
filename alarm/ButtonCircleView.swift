//
//  CircleView.swift
//  alarm
//
//  Created by Michael Lewis on 3/24/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class ButtonCircleView: UIView {

  var borderWidth = CGFloat(3.0)
  var color = UIColor(white: 0.9, alpha: 1.0)
  var circleColor = UIColor(white: 0.0, alpha: 0.5)
  var fontSize = CGFloat(24.0)

  fileprivate var _labelText = ""
  var labelText: String {
    get { return _labelText }
    set {
      _labelText = newValue
      refreshLabel()
    }
  }
  var label: UILabel?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }

  override func draw(_ rect: CGRect) {
    // Get the Graphics Context
    let context = UIGraphicsGetCurrentContext()

    // Set the fill color
    circleColor.setFill()

    // Fill in the circle
    context!.fillEllipse(in: rect)

    // Set the circle outerline-width
    context!.setLineWidth(borderWidth)

    // Set the circle outerline-colour
    color.withAlphaComponent(0.9).setStroke()

    // Create circle
    context?.addArc(center: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: frame.size.height / 2, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
    
    // Draw the circle stroke
    context!.strokePath()

    // Set up our label
    setupLabel(rect)
  }

  // Set up our sublabel
  fileprivate func setupLabel(_ rect: CGRect) {
    if label == nil {
      label = UILabel(frame: rect)
      label?.textAlignment = NSTextAlignment.center
      self.addSubview(label!)
    }

    refreshLabel()
  }

  // Refresh the label's title
  fileprivate func refreshLabel() {
    if label != nil {
      //label!.text = self.labelText
      label!.attributedText = NSAttributedString(
        string: self.labelText,
        attributes: [
          NSFontAttributeName: UIFont(
            name: "Avenir-Medium",
            size: self.fontSize)!,
          NSForegroundColorAttributeName: self.color,
        ]
      )
    }
  }

}
