//
//  TimePickerViewController.swift
//  alarm
//
//  Created by Michael Lewis on 3/8/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

protocol TimePickerDelegate {
  func timeSelected(_ time: TimePresenter)
}


class TimePickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

  @IBOutlet weak var timePicker: UIPickerView!

  // We're turning a linear picker into a circular one by
  // massively duplicating the number of rows, and starting
  // off in the middle.
  let circularPickerExplosionFactor = 50

  let pickerNaturalWidth = CGFloat(160.0)
  let pickerNaturalHeight = CGFloat(216.0)
  var pickerWidthScaleRatio = CGFloat(1.0)
  var pickerHeightScaleRatio = CGFloat(1.0)

  // Vertically stretch up the picker element text
  let pickerElementHeightScaleRatio = CGFloat(1.3)

  var pickerData: Array<TimePresenter>?
  var startingTimePresenter: TimePresenter?

  var delegate: TimePickerDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up our visual elements
    self.view.backgroundColor = UIColor.clear
    timePicker.backgroundColor = UIColor.clear
    timePicker.alpha = 1.0

    // Do any additional setup after loading the view.
    timePicker.dataSource = self
    timePicker.delegate = self

    // Generate our picker data
    pickerData = TimePresenter.generateAllElements()

    // If we were given a TimePresenter to start with,
    // try to select it.
    if let timePresenter = startingTimePresenter {
      selectTimePresenterRow(timePresenter)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    fixTimePickerDimensions()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    // Run up the number by a factor of 100 in order to provide fake
    // circular selection. This has been profiled and does not materially
    // hurt memory usage.
    return (pickerData?.count ?? 0) * circularPickerExplosionFactor * 2
  }

  // For each picker element, set up the view
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    let timeView = UIView()
    timeView.frame = CGRect(
        x: 0,
        y: 0,
        width: pickerView.rowSize(forComponent: component).width,
        height: pickerView.rowSize(forComponent: component).height
    )
    
    let timeLabel = UILabel()
    let amPmLabel = UILabel()

    if let activeElement = getTimePickerAtRow(row) {
        let displayString = activeElement.stringForWheelDisplay()
        
        var amPmString: String
        
        if displayString.contains("noon") || displayString.contains("midnight") {
            amPmString = ""
        } else {
            amPmString = activeElement.stringForAmPm()
        }
        
        let transformation = CGAffineTransform(
            scaleX: 1.0 / pickerWidthScaleRatio,
            y: pickerElementHeightScaleRatio / pickerHeightScaleRatio
        )

      // Create the labels with our attributed text
      timeLabel.attributedText = NSAttributedString(
        string: displayString,
        attributes: [
          NSFontAttributeName: UIFont(name: "Avenir-Light", size: 32.0)!,
          NSForegroundColorAttributeName: UIColor(white: 0.8, alpha: 1.0),
        ]
      )
      timeLabel.textAlignment = .center
      
      amPmLabel.attributedText = NSAttributedString(
        string: amPmString,
        attributes: [
          NSFontAttributeName: UIFont(name: "Avenir-Light", size: 18.0)!,
          NSForegroundColorAttributeName: UIColor(white: 0.8, alpha: 1.0),
        ]
      )
      amPmLabel.textAlignment = .center
      // Finally, transform the text. This essentially performs two transforms.
      // The first one is an inverse of the transform run on the picker
      // as a whole. This makes sure that while the picker itself is
      // stretched, the individual elements themselves are not.
      // The second one is an individual scale of the element for
      // aesthetics.
      timeLabel.transform = transformation
      amPmLabel.transform = transformation
    }
    
    timeLabel.sizeToFit()
    timeLabel.center = timeView.center
    
    amPmLabel.sizeToFit()
    amPmLabel.center = CGPoint(x: (timeLabel.center.x + timeLabel.frame.width / 2) + (amPmLabel.frame.width / 2) + 10, y: timeLabel.center.y + amPmLabel.frame.height / 6)
    
    timeView.addSubview(timeLabel)
    timeView.addSubview(amPmLabel)

    return timeView
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // pickerData[row]
  }

  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return 20.0
  }

  // The accept button was selected
  @IBAction func acceptTapped(_ sender: UITapGestureRecognizer) {
    let selectedRow = timePicker.selectedRow(inComponent: 0)
    if let activeElement = getTimePickerAtRow(selectedRow) {
      delegate?.timeSelected(activeElement)
    }
  }

  /* Private */

  // Given a time presenter, select the row in the picker view
  // that is equal.
  fileprivate func selectTimePresenterRow(_ timePresenter: TimePresenter, animated: Bool = false) {
    if let data = pickerData {
      if let index = data.index(of: timePresenter) {
        let newRowIndex = data.count * circularPickerExplosionFactor + index
        timePicker.selectRow(newRowIndex, inComponent: 0, animated: animated)
      }
    }
  }

  // Get the element at a given row
  // This is helpful because of our circular data
  fileprivate func getTimePickerAtRow(_ row: Int) -> TimePresenter? {
    if let data = pickerData {
      // Because we're duplicating elements in order to simulate
      // a circular effect, we need to use modulus when accessing
      // the data by row number.
      let numRows = data.count
      return data[row % numRows]
    } else {
      NSLog("Should never nil here")
      return nil
    }
  }

  // Horizontally stretch the time picker to the full height of the
  // surrounding view. This introduces some weird stretching effects that
  // need to be dealt with, but it's the only way to get a picker to display
  // with a height greater than 216.
  fileprivate func fixTimePickerDimensions() {
    pickerWidthScaleRatio = (self.view.frame.width / 2.0) / pickerNaturalWidth
    pickerHeightScaleRatio = self.view.frame.height / pickerNaturalHeight
    timePicker.transform = CGAffineTransform(scaleX: pickerWidthScaleRatio, y: pickerHeightScaleRatio)
  }
}
