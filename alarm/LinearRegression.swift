//
//  Linear Regression
//  alarm
//
//  Created by Michael Lewis on 3/21/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class LinearRegression {

  class func slope(x: Array<Double>, y: Array<Double>) -> Double {
    let n = Double(x.count)

    let meanX: Double = x.reduce(0.0, +) / n
    let meanY: Double = y.reduce(0.0, +) / n

    let numerator = reduce(Zip2(x, y), 0.0) {
      (acc, val) in
      return acc + (val.0 - meanX) * (val.1 - meanY)
    }

    let denominator = reduce(x, 0.0) {
      (acc, val) in
      return acc + (val - meanX) * (val - meanX)
    }

    return numerator / denominator
  }

}