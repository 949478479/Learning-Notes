//
//  FirstViewController.swift
//  CustomSegue
//
//  Created by 从今以后 on 15/12/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    deinit { print("delloc - \(self)") }

    @IBAction private func unwindForSegue(CustomUnwindSegue: UIStoryboardSegue) { }
}

class SecondViewController: FirstViewController { }
