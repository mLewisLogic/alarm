//
//  GradientView.swift
//  alarm
//
//  Created by Michael Lewis on 3/25/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class VerticalGradientView: UIView {

  override func drawRect(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()

    CGContextSaveGState(context);

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    let colors: CFArray = [
      UIColor(white: 0.0, alpha: 0.7).CGColor,
      UIColor.clearColor().CGColor,
    ]

    var locations: [CGFloat] = [0.0, 1.0]

    var gradient = CGGradientCreateWithColors(colorSpace, colors, &locations)

    let startPoint = CGPointMake(0, 0)
    let endPoint = CGPointMake(0, self.bounds.height)

    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)

    CGContextRestoreGState(context)
  }

}
