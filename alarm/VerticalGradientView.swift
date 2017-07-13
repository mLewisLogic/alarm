//
//  GradientView.swift
//  alarm
//
//  Created by Michael Lewis on 3/25/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class VerticalGradientView: UIView {

  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()

    context!.saveGState();

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    let colors = [
      UIColor(white: 0.0, alpha: 0.7).cgColor,
      UIColor.clear.cgColor
    ]

    var locations: [CGFloat] = [0.0, 1.0]

    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &locations)

    let startPoint = CGPoint(x: 0, y: 0)
    let endPoint = CGPoint(x: 0, y: self.bounds.height)

    context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))

    context!.restoreGState()
  }

}
