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

  private var _labelText = ""
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
    self.backgroundColor = UIColor.clearColor()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func drawRect(rect: CGRect) {
    // Get the Graphics Context
    var context = UIGraphicsGetCurrentContext()

    // Set the fill color
    circleColor.setFill()

    // Fill in the circle
    CGContextFillEllipseInRect(context, rect)

    // Set the circle outerline-width
    CGContextSetLineWidth(context, borderWidth)

    // Set the circle outerline-colour
    color.colorWithAlphaComponent(0.9).setStroke()

    // Create circle
    CGContextAddArc(
      context,
      frame.size.width / 2,
      frame.size.height / 2,
      (frame.size.width - borderWidth) / 2,
      0.0,
      CGFloat(M_PI * 2.0),
      1
    )

    // Draw the circle stroke
    CGContextStrokePath(context)

    // Set up our label
    setupLabel(rect)
  }

  // Set up our sublabel
  private func setupLabel(rect: CGRect) {
    if label == nil {
      label = UILabel(frame: rect)
      label?.textAlignment = NSTextAlignment.Center
      self.addSubview(label!)
    }

    refreshLabel()
  }

  // Refresh the label's title
  private func refreshLabel() {
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
