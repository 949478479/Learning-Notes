//
//  ViewController.swift
//  NSProgressDemo
//
//  Created by 从今以后 on 16/2/2.
//  Copyright © 2016年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var progressView: UIProgressView!

	var contextForKVO = 0
	let progress = NSProgress(totalUnitCount: 5) // 指定任务数量为 5 份

	override func viewDidLoad() {
		super.viewDidLoad()
		progress.addObserver(self, forKeyPath: "fractionCompleted", options: [], context: &contextForKVO)
	}

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
		change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

		guard context == &contextForKVO else {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
			return
		}

		dispatch_async(dispatch_get_main_queue()) {
			self.progressView.progress = Float(self.progress.fractionCompleted)
			print(self.progress.localizedDescription, self.progress.localizedAdditionalDescription)
		}
	}

	@IBAction func start() {
		guard progress.fractionCompleted == 0 else { return }

		let foo = Foo()

		// 指定任务 A 占 3 份，即任务 A 全部完成时，总任务进度为 3/5
		self.progress.becomeCurrentWithPendingUnitCount(3)
		foo.doSomeThingAWithCompletion {

			// 异步任务 A 完成后开始异步任务 B，指定任务 B 占 1 份
			self.progress.becomeCurrentWithPendingUnitCount(1)
			foo.doSomeThingBWithCompletion {

				// 此时总任务进度为 4/5，模拟主任务自己搞些事情，然后标记完成
				let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
				dispatch_after(when, dispatch_get_main_queue()) {
					// 这将导致任务进度跳跃，而非平滑增长
					self.progress.completedUnitCount = 5
				}
			}
			self.progress.resignCurrent()
		}
		self.progress.resignCurrent()
	}

	@IBAction func pauseOrResume(sender: UIButton) {
		if sender.selected {
			progress.resume()
			sender.setTitle("暂停", forState: .Normal)
		} else {
			progress.pause()
			sender.setTitle("恢复", forState: .Normal)
		}
		sender.selected = !sender.selected
	}

	@IBAction func reset() {
		guard progress.fractionCompleted == 1 else { return }
		progress.completedUnitCount = 0
		progressView.progress = 0
	}
}

class Foo {

	private let queue = dispatch_queue_create("com.cjyh.NSProgressDemo", DISPATCH_QUEUE_SERIAL)

	func doSomeThingAWithCompletion(completion: ()->()) {
		print(__FUNCTION__)

		let totalUnitCount: Int64 = 50
		let progress = NSProgress(totalUnitCount: totalUnitCount)

		// 使用定时器来模拟长时任务
		let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
		dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, UInt64(0.1 * Double(NSEC_PER_SEC)), 0)
		dispatch_source_set_event_handler(timer) {

			if progress.completedUnitCount + 1 >= totalUnitCount {

				progress.completedUnitCount = totalUnitCount
				dispatch_source_cancel(timer)

				dispatch_async(dispatch_get_main_queue(), completion)

			} else {
				progress.completedUnitCount += 1
			}
		}

		// 响应暂停和恢复
		progress.pausingHandler = {
			dispatch_suspend(timer)
		}
		progress.resumingHandler = {
			dispatch_resume(timer)
		}

		dispatch_resume(timer)
	}

	func doSomeThingBWithCompletion(completion: ()->()) {
		print(__FUNCTION__)

		// 有些任务无法确定任务进度，这种情况下可以指定为负数
		let progress = NSProgress(totalUnitCount: -1)

		// 延迟，模拟任务执行，任务完毕后将 totalUnitCount 和 completedUnitCount 随便设置为相同的数即可，
		// 这样它们的比值为 1，以此表示任务完成，这种情况下任务进度会直接从 0 跳至 1
		let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
		dispatch_after(when, dispatch_get_main_queue()) {
			progress.totalUnitCount = 1
			progress.completedUnitCount = 1
			completion()
		}
	}
}
