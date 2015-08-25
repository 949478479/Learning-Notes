//
//  ViewController.swift
//  SlotMachine
//
//  Created by 从今以后 on 15/8/25.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let images =
        ["🐵", "🐶", "🐱", "🐭", "🐰", "🐻", "🐼", "🐷", "🐮", "🐔", "🐨", "🐯", "🐹", "🐵", "🐶"]

    @IBOutlet private weak var pickerView: UIPickerView!

    @IBAction private func startButton(sender: UIButton) {

        var lastRow = 0
        var isWin   = true

        for component in 0..<3 {

            var row = 0
            var selectedRow = 0

            do {
                // 避免选中首尾行,这样有种图片循环的感觉.
                row = Int(arc4random_uniform(UInt32(images.count - 2))) + 1

                selectedRow = pickerView.selectedRowInComponent(component)

            } while selectedRow == row

            if abs(selectedRow - row) < 3 { // 确保滚动幅度大于3格.
                row = (row + 3) % (images.count - 2) + 1
            }

            if component > 0 && isWin {
                isWin = (lastRow == row)
            } else {
                lastRow = row
            }

            pickerView.selectRow(row, inComponent: component, animated: true)
        }

        if isWin {

            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()) {

                let alert = UIAlertController(title: "碉堡了", message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "一般一般...", style: .Cancel, handler: nil))

                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for component in 0..<3 {
            pickerView.selectRow(1, inComponent: component, animated: false)
        }
    }
}

// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return images.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
        reusingView view: UIView!) -> UIView {

        var pickerLabel = view as? UILabel

        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel!.font = UIFont.systemFontOfSize(100)
        }

        pickerLabel!.text = images[row % images.count]

        return pickerLabel!
    }
}