//
//  AlarmViewController.swift
//  alarm
//
//  Created by Michael Lewis on 3/8/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

protocol TimePickerDelegate {
  func timeSelected(time: TimePresenter)
}


class AlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

  @IBOutlet weak var timePicker: UIPickerView!

  let pickerNaturalWidth = CGFloat(160.0)
  let pickerNaturalHeight = CGFloat(216.0)
  var pickerWidthScaleRatio = CGFloat(1.0)
  var pickerHeightScaleRatio = CGFloat(1.0)

  // Vertically stretch up the picker element text
  let pickerElementHeightScaleRatio = CGFloat(1.3)

  var pickerData: Array<TimePresenter>?

  var delegate: TimePickerDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up our visual elements
    self.view.backgroundColor = UIColor.clearColor()
    timePicker.backgroundColor = UIColor.clearColor()
    timePicker.alpha = 1.0
    timePicker.tintColor = UIColor.greenColor()

    // Do any additional setup after loading the view.
    timePicker.dataSource = self
    timePicker.delegate = self

    // Generate our picker data
    pickerData = TimePresenter.generateAllElements()
  }

  override func viewWillAppear(animated: Bool) {
    fixTimePickerDimensions()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    // Run up the number by a factor of 100 in order to provide fake
    // circular selection. This has been profiled and does not materially
    // hurt memory usage.
    return (pickerData?.count ?? 0) * 100
  }

  // For each picker element,
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
    var label = UILabel()

    if let activeElement = getElementAtRow(row) {
      let displayString = activeElement.wheelDisplayStr() ?? ""

      // Create the label with our attributed text
      label.attributedText = NSAttributedString(
        string: displayString,
        attributes: [
          NSFontAttributeName: UIFont(name: "Avenir-Light", size: 32.0)!,
          NSForegroundColorAttributeName: UIColor(white: 0.8, alpha: 1.0),
        ]
      )
      label.textAlignment = .Center
      // Finally, transform the text. This essentially performs two transforms.
      // The first one is an inverse of the transform run on the picker
      // as a whole. This makes sure that while the picker itself is
      // stretched, the individual elements themselves are not.
      // The second one is an individual scale of the element for
      // aesthetics.
      label.transform = CGAffineTransformMakeScale(
        1.0 / pickerWidthScaleRatio,
        pickerElementHeightScaleRatio / pickerHeightScaleRatio
      )
    }

    return label
  }

  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // pickerData[row]
  }

  func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return 20.0
  }


  // The accept button was selected
  @IBAction func acceptTapped(sender: UITapGestureRecognizer) {
    let selectedRow = timePicker.selectedRowInComponent(0)
    if let activeElement = getElementAtRow(selectedRow) {
      delegate?.timeSelected(activeElement)
    }
  }


  // Get the element at a given row
  // This is helpful because of our circular data
  private func getElementAtRow(row: Int) -> TimePresenter? {
    if let data = pickerData {
      // Because we're duplicating elements in order to simulate
      // a circular effect, we need to use modulus when accessing
      // the data by row number.
      let numRows = data.count
      return data[row % numRows]
    } else {
      NSLog("Shouldn't return nil here")
      return nil
    }
  }


  // Horizontally stretch the time picker to the full height of the
  // surrounding view. This introduces some weird stretching effects that
  // need to be dealt with, but it's the only way to get a picker to display
  // with a height greater than 216.
  private func fixTimePickerDimensions() {
    pickerWidthScaleRatio = (self.view.frame.width / 2.0) / pickerNaturalWidth
    pickerHeightScaleRatio = self.view.frame.height / pickerNaturalHeight
    timePicker.transform = CGAffineTransformMakeScale(pickerWidthScaleRatio, pickerHeightScaleRatio)
  }
}
