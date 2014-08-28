//
//  AsyncExample_iOSTests.swift
//  AsyncExample iOSTests
//
//  Created by Tobias DM on 15/07/14.
//  Copyright (c) 2014 Tobias Due Munk. All rights reserved.
//

import UIKit
import XCTest

// Just a mininally printing workload
func dumbFibonachi(n:Int)->Int {
    if n < 3 {
        return 1
    }
    return dumbFibonachi(n-1) + dumbFibonachi(n-2)
}

var fibonachiResult:[Int] = [] // Prevents optimiser removing fibonachi calls
var emptyString = ""
func heavyWork() {
    // Heavy work
    for i in 0...15 {
        fibonachiResult = [Int](count: 2000, repeatedValue: 15).map { return dumbFibonachi($0)}
        print(emptyString)
    }
}
let allowEarlyDispatchBy = 0.001

class AsyncExample_iOSTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	
	/* GCD */
	
//	func testGCD() {
//
//		let expectation = expectationWithDescription("Expected after time")
//
//		let qos = QOS_CLASS_BACKGROUND
//		let queue = dispatch_get_global_queue(+qos, 0)
//		dispatch_async(queue) {
//			let currentQos = qos_class_self()
//            //		XCTAssertEqual(+currentQos, +qos, "On \(currentQos.description) (expected \(qos.description))")
//			expectation.fulfill()
//		}
//		waitForExpectationsWithTimeout(1, handler: nil)
//	}
    
    
    
    func testWaitAccuracy() {
        // Not a pass fail test but an indication of the variation of the actual delay time of even high priority dispatches.
        var callTimes = [Double]()
        let runCount = 20
        let targetDelay:Double = 0.1
        for i in 0..<runCount {
            let time = CFAbsoluteTimeGetCurrent()
            Async.userInteractive(after: targetDelay) {
                let curTime = CFAbsoluteTimeGetCurrent()
                callTimes.append(curTime - time)
            }.wait()
        }
        let minMaxSum = reduce(callTimes, (Double.infinity, 0.0, 0.0, 0)) {
            (min($0.0, $1), max($0.1, $1), $0.2 + $1, $1 < targetDelay ? $0.3 + 1 : $0.3)
        }
        println("\(runCount) tests with a target delay of \(targetDelay)")
        println("Minimum wait: \(minMaxSum.0) Maximum wait: \(minMaxSum.1), Average wait: \(minMaxSum.2/Double(callTimes.count)) Early calls: \(minMaxSum.3)")
    }
	
	/* dispatch_async() */
    
    func testAsyncMain() {
		let expectation = expectationWithDescription("Expected on main queue")
		var calledStuffAfterSinceAsync = false
		Async.main {
            //		XCTAssertEqual(+qos_class_self(), +qos_class_main(), "On \(qos_class_self().description) (expexted \(qos_class_main().description))")
			XCTAssert(calledStuffAfterSinceAsync, "Should be async")
			expectation.fulfill()
		}
		calledStuffAfterSinceAsync = true
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testAsyncUserInteractive() {
        let expectation = expectationWithDescription("Expected On") //\(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
		Async.userInteractive {
            //		XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INTERACTIVE, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testAsyncUserInitiared() {
        let expectation = expectationWithDescription("Expected On")// \(qos_class_self().description) (expected \(QOS_CLASS_USER_INITIATED.description))")
		Async.userInitiated {
            //		XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INITIATED, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INITIATED.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	// Not expected to succeed (Apples wording: "Not intended as a work classification")
	func testAsyncDefault() {
        let expectation = expectationWithDescription("Expected On")// \(qos_class_self().description) (expected \(QOS_CLASS_DEFAULT.description))")
		Async.default_ {
            //		XCTAssertEqual(+qos_class_self(), +QOS_CLASS_DEFAULT, "On \(qos_class_self().description) (expected \(QOS_CLASS_DEFAULT.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testAsyncUtility() {
        let expectation = expectationWithDescription("Expected On")// \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
		Async.utility {
            //		XCTAssertEqual(+qos_class_self(), +QOS_CLASS_UTILITY, "On \(qos_class_self().description) (expected \(QOS_CLASS_UTILITY.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testAsyncBackground() {
        let expectation = expectationWithDescription("Expected On ")//\(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
		Async.background {
        //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_BACKGROUND, "On \(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testAsyncBackgroundToMain() {
		let expectation = expectationWithDescription("Expected on background to main queue")
		var wasInBackground = false
		Async.background {
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_BACKGROUND, "On \(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
			wasInBackground = true
		}.main {
            //	XCTAssertEqual(+qos_class_self(), +qos_class_main(), "On \(qos_class_self().description) (expected \(qos_class_main().description))")
			XCTAssert(wasInBackground, "Was in background first")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testChaining() {
        let expectation = expectationWithDescription("Expected On")// \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
		var id = 0
		Async.main {
            //	XCTAssertEqual(+qos_class_self(), +qos_class_main(), "On \(qos_class_self().description) (expexted \(qos_class_main().description))")
			XCTAssertEqual(++id, 1, "Count main queue")
		}.userInteractive {
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INTERACTIVE, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
			XCTAssertEqual(++id, 2, "Count user interactive queue")
		}.userInitiated {
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INITIATED, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INITIATED.description))")
			XCTAssertEqual(++id, 3, "Count user initiated queue")
		}.utility {
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_UTILITY, "On \(qos_class_self().description) (expected \(QOS_CLASS_UTILITY.description))")
			XCTAssertEqual(++id, 4, "Count utility queue")
		}.background {
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_BACKGROUND, "On \(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
			XCTAssertEqual(++id, 5, "Count background queue")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
    
    func testMultipleChainedOnSingleBlock() {
        let chainedItemCount = 3
        let expect0 = expectationWithDescription("First block should have run")
        let chainedExpectations = map(0..<chainedItemCount) { self.expectationWithDescription("Chained block \($0) should have run") }
        let firstBlock = Async.background() {
            expect0.fulfill()
        }
        for i in 0..<chainedItemCount {
            firstBlock.default_() { chainedExpectations[i].fulfill() }
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
	
	func testCustomQueue() {
		let expectation = expectationWithDescription("Expected custom queues")
		var id = 0
		let customQueue = dispatch_queue_create("CustomQueueLabel", DISPATCH_QUEUE_CONCURRENT)
		let otherCustomQueue = dispatch_queue_create("OtherCustomQueueLabel", DISPATCH_QUEUE_SERIAL)
		Async.customQueue(customQueue) {
			XCTAssertEqual(++id, 1, "Count custom queue")
		}.customQueue(otherCustomQueue) {
			XCTAssertEqual(++id, 2, "Count other custom queue")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	
	/* dispatch_after() */
	
	func testAfterGCD() {
		
		let expectation = expectationWithDescription("Expected after time")
		let date = CFAbsoluteTimeGetCurrent()
		let timeDelay = 1.0
		let upperTimeDelay = timeDelay + 0.2
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay * Double(NSEC_PER_SEC)))
		let queue = dispatch_get_global_queue(+QOS_CLASS_BACKGROUND, 0)
		dispatch_after(time, queue, {
			let timePassed = CFAbsoluteTimeGetCurrent() - date
			println("\(timePassed)")
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay - allowEarlyDispatchBy, "Should wait \(timeDelay) seconds before firing but only waited \(timePassed) seconds")
			XCTAssertLessThan(timePassed, upperTimeDelay, "Shouldn't wait \(upperTimeDelay) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_BACKGROUND, "On \(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
			expectation.fulfill()
		})
		waitForExpectationsWithTimeout(timeDelay*2, handler: nil)
	}
	
	func testAfterMain() {
		let expectation = expectationWithDescription("Expected after time")
		let date = CFAbsoluteTimeGetCurrent()
		let timeDelay = 1.0
		let upperTimeDelay = timeDelay + 0.2
		Async.main(after: timeDelay) {
			let timePassed = CFAbsoluteTimeGetCurrent() - date
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay - allowEarlyDispatchBy, "Should wait \(timeDelay) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay, "Shouldn't wait \(upperTimeDelay) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +qos_class_main(), "On main queue")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(timeDelay*2, handler: nil)
	}
	
	func testChainedAfter() {
		let expectation = expectationWithDescription("Expected after time")
		let date1 = CFAbsoluteTimeGetCurrent()
		var date2 = CFAbsoluteTimeGetCurrent()
		let timeDelay1 = 1.1
		let upperTimeDelay1 = timeDelay1 + 0.2
		let timeDelay2 = 1.2
		let upperTimeDelay2 = timeDelay2 + 0.2
		var id = 0
		Async.userInteractive(after: timeDelay1) {
			XCTAssertEqual(++id, 1, "First after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date1
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay1 - allowEarlyDispatchBy, "Should wait \(timeDelay1) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay1, "Shouldn't wait \(upperTimeDelay1) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INTERACTIVE, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
			
			date2 = CFAbsoluteTimeGetCurrent() // Update
		}.utility(after: timeDelay2) {
			XCTAssertEqual(++id, 2, "Second after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date2
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay2 - allowEarlyDispatchBy, "Should wait \(timeDelay2) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay2, "Shouldn't wait \(upperTimeDelay2) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_UTILITY, "On \(qos_class_self().description) (expected \(QOS_CLASS_UTILITY.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout((timeDelay1 + timeDelay2) * 2, handler: nil)
	}
	
	func testAfterUserInteractive() {
		let expectation = expectationWithDescription("Expected after time")
		let date1 = CFAbsoluteTimeGetCurrent()
		var date2 = date1
		let timeDelay1 = 1.1
		let upperTimeDelay1 = timeDelay1 + 0.2
		let timeDelay2 = 1.2
		let upperTimeDelay2 = timeDelay2 + 0.2
		var id = 0
		Async.userInteractive(after: timeDelay1) {
			XCTAssertEqual(++id, 1, "First after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date1
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay1 - allowEarlyDispatchBy, "Should wait \(timeDelay1) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay1, "Shouldn't wait \(upperTimeDelay1) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INTERACTIVE, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
			
			date2 = CFAbsoluteTimeGetCurrent() // Update
		}.userInteractive(after: timeDelay2) {
			XCTAssertEqual(++id, 2, "Second after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date2
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay2 - allowEarlyDispatchBy, "Should wait \(timeDelay2) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay2, "Shouldn't wait \(upperTimeDelay2) seconds before firing - did wait: \(timePassed)")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INTERACTIVE, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INTERACTIVE.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout((timeDelay1 + timeDelay2) * 2, handler: nil)
	}
	
	func testAfterUserInitiated() {
		let expectation = expectationWithDescription("Expected after time")
		let date1 = CFAbsoluteTimeGetCurrent()
		var date2 = CFAbsoluteTimeGetCurrent()
		let timeDelay1 = 1.1
		let upperTimeDelay1 = timeDelay1 + 0.2
		let timeDelay2 = 1.2
		let upperTimeDelay2 = timeDelay2 + 0.2
		var id = 0
		Async.userInitiated(after: timeDelay1) {
			XCTAssertEqual(++id, 1, "First after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date1
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay1 - allowEarlyDispatchBy, "Should wait \(timeDelay1) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay1, "Shouldn't wait \(upperTimeDelay1) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INITIATED, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INITIATED.description))")
			
			date2 = CFAbsoluteTimeGetCurrent() // Update
		}.userInitiated(after: timeDelay2) {
			XCTAssertEqual(++id, 2, "Second after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date2
            XCTAssertGreaterThanOrEqual(timePassed, timeDelay2 - allowEarlyDispatchBy, "Should wait \(timeDelay2) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay2, "Shouldn't wait \(upperTimeDelay2) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_USER_INITIATED, "On \(qos_class_self().description) (expected \(QOS_CLASS_USER_INITIATED.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout((timeDelay1 + timeDelay2) * 2, handler: nil)
	}
	
	// Not expected to succeed (Apples wording: "Not intended as a work classification")
	func testAfterUserDefault() {
		let expectation = expectationWithDescription("Expected after time")
		let date1 = CFAbsoluteTimeGetCurrent()
		var date2 = CFAbsoluteTimeGetCurrent()
		let timeDelay1 = 1.1
		let upperTimeDelay1 = timeDelay1 + 0.2
		let timeDelay2 = 1.2
		let upperTimeDelay2 = timeDelay2 + 0.2
		var id = 0
		Async.default_(after: timeDelay1) {
			XCTAssertEqual(++id, 1, "First after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date1
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay1 - allowEarlyDispatchBy, "Should wait \(timeDelay1) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay1, "Shouldn't wait \(upperTimeDelay1) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_DEFAULT, "On \(qos_class_self().description) (expected \(QOS_CLASS_DEFAULT.description))")
			
			date2 = CFAbsoluteTimeGetCurrent() // Update
		}.default_(after: timeDelay2) {
			XCTAssertEqual(++id, 2, "Second after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date2
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay2 - allowEarlyDispatchBy, "Should wait \(timeDelay2) seconds before firing - did wait \(timePassed) seconds")
			XCTAssertLessThan(timePassed, upperTimeDelay2, "Shouldn't wait \(upperTimeDelay2) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_DEFAULT, "On \(qos_class_self().description) (expected \(QOS_CLASS_DEFAULT.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout((timeDelay1 + timeDelay2) * 2, handler: nil)
	}
	
	func testAfterUtility() {
		let expectation = expectationWithDescription("Expected after time")
		let date1 = CFAbsoluteTimeGetCurrent()
		var date2 = CFAbsoluteTimeGetCurrent()
		let timeDelay1 = 1.1
		let upperTimeDelay1 = timeDelay1 + 0.2
		let timeDelay2 = 1.2
		let upperTimeDelay2 = timeDelay2 + 0.2
		var id = 0
		Async.utility(after: timeDelay1) {
			XCTAssertEqual(++id, 1, "First after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date1
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay1 - allowEarlyDispatchBy, "Should wait \(timeDelay1) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay1, "Shouldn't wait \(upperTimeDelay1) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_UTILITY, "On \(qos_class_self().description) (expected \(QOS_CLASS_UTILITY.description))")
			
			date2 = CFAbsoluteTimeGetCurrent() // Update
		}.utility(after: timeDelay2) {
			XCTAssertEqual(++id, 2, "Second after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date2
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay2 - allowEarlyDispatchBy, "Should wait \(timeDelay2) seconds before firing - did wait \(timePassed) seconds")
			XCTAssertLessThan(timePassed, upperTimeDelay2, "Shouldn't wait \(upperTimeDelay2) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_UTILITY, "On \(qos_class_self().description) (expected \(QOS_CLASS_UTILITY.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout((timeDelay1 + timeDelay2) * 2, handler: nil)
	}
	
	func testAfterBackground() {
		let expectation = expectationWithDescription("Expected after time")
		let date1 = CFAbsoluteTimeGetCurrent()
		var date2 = CFAbsoluteTimeGetCurrent()
		let timeDelay1 = 1.1
		let upperTimeDelay1 = timeDelay1 + 0.2
		let timeDelay2 = 1.2
		let upperTimeDelay2 = timeDelay2 + 0.2
		var id = 0
		Async.background(after: timeDelay1) {
			XCTAssertEqual(++id, 1, "First after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date1
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay1 - allowEarlyDispatchBy, "Should wait \(timeDelay1) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay1, "Shouldn't wait \(upperTimeDelay1) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_BACKGROUND, "On \(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
			
			date2 = CFAbsoluteTimeGetCurrent() // Update
		}.background(after: timeDelay2) {
			XCTAssertEqual(++id, 2, "Second after")
			
			let timePassed = CFAbsoluteTimeGetCurrent() - date2
			XCTAssertGreaterThanOrEqual(timePassed, timeDelay2 - allowEarlyDispatchBy, "Should wait \(timeDelay2) seconds before firing")
			XCTAssertLessThan(timePassed, upperTimeDelay2, "Shouldn't wait \(upperTimeDelay2) seconds before firing")
            //	XCTAssertEqual(+qos_class_self(), +QOS_CLASS_BACKGROUND, "On \(qos_class_self().description) (expected \(QOS_CLASS_BACKGROUND.description))")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout((timeDelay1 + timeDelay2) * 2, handler: nil)
	}


	/* dispatch_block_cancel() */

	func testCancel() {
		let expectation = expectationWithDescription("Block1 should run")

		let block1 = Async.background {
			heavyWork()
			expectation.fulfill()
		}
		var block2 = block1.background {
			println("B – shouldn't be reached, since cancelled")
            XCTFail("Shouldn't be reached, since cancelled") // This doesn't work on this thread.
		}
		
		Async.main(after: 0.01) {
			block1.cancel() // First block is _not_ cancelled
			block2.cancel() // Second block _is_ cancelled
            
		}
		
		waitForExpectationsWithTimeout(10, handler: nil)
        NSThread.sleepForTimeInterval(1.0)
	}

    func testChainedBlocksAfterCancel() {
        let expectation1 = expectationWithDescription("First block should run")
        let expectation2 = expectationWithDescription("Third and last block should run")
        let firstBlock = Async.main(after: 1.0) {
            // Something to delay
            expectation1.fulfill()
        }
        let secondBlock = firstBlock.background {
            // Something to cancel
            println("This should be cancelled")
            XCTFail("This should be cancelled")
        }
        secondBlock.background {
            expectation2.fulfill()
        }
        secondBlock.cancel()
        waitForExpectationsWithTimeout(3, handler: nil)
    }

	/* dispatch_wait() */
	
	func testWait() {
		var id = 0
		let block = Async.background {
			// Medium light work
			println("Fib 12 = \(dumbFibonachi(12))")
			XCTAssertEqual(++id, 1, "")
		}
		XCTAssertEqual(id, 0, "")
		
		block.wait()
		XCTAssertEqual(++id, 2, "")
	}

	func testWaitMax() {
		var id = 0
		let block = Async.background {
			XCTAssertEqual(++id, 1, "") // A
			heavyWork()
			XCTAssertEqual(++id, 3, "") // C
		}
		XCTAssertEqual(id, 0, "")
		
		let date = CFAbsoluteTimeGetCurrent()
		let timeDelay = 0.3
		let upperTimeDelay = timeDelay + 0.2
		
		block.wait(seconds: timeDelay)
		
		XCTAssertEqual(++id, 2, "") // B
		let timePassed = CFAbsoluteTimeGetCurrent() - date
		XCTAssertLessThan(timePassed, upperTimeDelay, "Shouldn't wait \(upperTimeDelay) seconds before firing")
	}
}
