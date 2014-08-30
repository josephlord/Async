//
//  AsyncLegacy.swift
//
//  Created by Tobias DM on 15/07/14.
//  Modifed by Joseph Lord
//  Copyright (c) 2014 Human Friendly Ltd.
//
//	OS X 10.9+ and iOS 7.0+
//	Only use with ARC
//
//	The MIT License (MIT)
//	Copyright (c) 2014 Tobias Due Munk
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation

// HACK: For Beta 5, 6
prefix func +(v: qos_class_t) -> Int {
	return Int(v.value)
}

private class GCD {
	
	/* dispatch_get_queue() */
	class func mainQueue() -> dispatch_queue_t {
		return dispatch_get_main_queue()
		// Could use return dispatch_get_global_queue(+qos_class_main(), 0)
	}
	class func userInteractiveQueue() -> dispatch_queue_t {
        //return dispatch_get_global_queue(+QOS_CLASS_USER_INTERACTIVE, 0)
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
	}
	class func userInitiatedQueue() -> dispatch_queue_t {
        //return dispatch_get_global_queue(+QOS_CLASS_USER_INITIATED, 0)
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
	}
	class func defaultQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
	}
	class func utilityQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
	}
	class func backgroundQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
	}
}

public class Async<S,T> {
    
    //The block to be executed does not need to be retained in present code
    //only the dispatch_group is needed in order to cancel it.
    //private let block: dispatch_block_t
    private typealias ReturnType = T
    private typealias ArgumentType = S
    private let dgroup: dispatch_group_t = dispatch_group_create()
    private var isCancelled = false
    private var return_value:ReturnType? = nil
    private let argument_value:ArgumentType?
    private init(argument: ArgumentType) {
        argument_value = argument
    }
    private init(chainedFromBlock:Bool) {
        assert(chainedFromBlock)
        argument_value = nil
    }
    
}

extension Async { // Static methods

	
	/* dispatch_async() */

	private class func async<A,R>(block: A->R , inQueue queue: dispatch_queue_t, withArgs:A) -> Async<A,R> {
        // Wrap block in a struct since dispatch_block_t can't be extended and to give it a group
		let asyncBlock =  Async<A,R>(argument: withArgs)

        // Add block to queue
        let return_block = {
            asyncBlock.return_value = block(withArgs)
        }
		dispatch_group_async(asyncBlock.dgroup, queue, asyncBlock.cancellable(return_block))

        return asyncBlock
		
	}
	class func main<A,R>(block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: GCD.mainQueue(), withArgs:withArgs)
	}
	class func userInteractive<A,R>(block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: GCD.userInteractiveQueue(), withArgs:withArgs)
	}
	class func userInitiated<A,R>(block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: GCD.userInitiatedQueue(), withArgs:withArgs)
	}
	class func default_<A,R>(block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: GCD.defaultQueue(), withArgs:withArgs)
	}
	class func utility<A,R>(block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: GCD.utilityQueue(), withArgs:withArgs)
	}
	class func background<A,R>(block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: GCD.backgroundQueue(), withArgs: withArgs)
	}
	class func customQueue<A,R>(queue: dispatch_queue_t, block: (A->R), withArgs:A) -> Async<A,R> {
		return Async.async(block, inQueue: queue, withArgs: withArgs)
	}

    class func main<R>(block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: GCD.mainQueue(), withArgs:())
	}
	class func userInteractive<R>(block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: GCD.userInteractiveQueue(), withArgs: ())
	}
	class func userInitiated<R>(block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: GCD.userInitiatedQueue(), withArgs:())
	}
	class func default_<R>(block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: GCD.defaultQueue(), withArgs:())
	}
	class func utility<R>(block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: GCD.utilityQueue(), withArgs:())
	}
	class func background<R>(block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: GCD.backgroundQueue(), withArgs:())
	}
	class func customQueue<R>(queue: dispatch_queue_t, block: ()->R) -> Async<(),R> {
		return Async.async(block, inQueue: queue, withArgs:())
	}


	/* dispatch_after() */

	private class func after<A,R>(seconds: Double, block: A->R, inQueue queue: dispatch_queue_t, withArgs:A) -> Async<A,R> {
		let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
		let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
		return at(time, block: block, inQueue: queue, withArgs:withArgs)
	}
	private class func at<A,R>(time: dispatch_time_t, block: A->R, inQueue queue: dispatch_queue_t, withArgs:A) -> Async<A,R> {
		// See Async.async() for comments
        let asyncBlock = Async<A,R>(argument: withArgs)
        dispatch_group_enter(asyncBlock.dgroup)
        dispatch_after(time, queue){
            let return_block = {
                asyncBlock.return_value = block(withArgs)
            }
            let cancellableBlock = asyncBlock.cancellable(return_block)
            cancellableBlock() // Compiler crashed in Beta6 when I just did asyncBlock.cancellable(block) directly.
            dispatch_group_leave(asyncBlock.dgroup)
        }
		return asyncBlock
	}
	class func main<A,R>(#after: Double, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: GCD.mainQueue(), withArgs:withArgs)
	}
	class func userInteractive<A,R>(#after: Double, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: GCD.userInteractiveQueue(), withArgs:withArgs)
	}
	class func userInitiated<A,R>(#after: Double, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: GCD.userInitiatedQueue(), withArgs:withArgs)
	}
	class func default_<A,R>(#after: Double, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: GCD.defaultQueue(), withArgs:withArgs)
	}
	class func utility<A,R>(#after: Double, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: GCD.utilityQueue(), withArgs:withArgs)
	}
	class func background<A,R>(#after: Double, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: GCD.backgroundQueue(), withArgs:withArgs)
	}
	class func customQueue<A,R>(#after: Double, queue: dispatch_queue_t, withArgs:A, block: A->R) -> Async<A,R> {
		return Async.after(after, block: block, inQueue: queue, withArgs:withArgs)
	}

	class func main<R>(#after: Double, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: GCD.mainQueue(), withArgs:())
	}
	class func userInteractive<R>(#after: Double, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: GCD.userInteractiveQueue(), withArgs:())
	}
	class func userInitiated<R>(#after: Double, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: GCD.userInitiatedQueue(), withArgs:())
	}
	class func default_<R>(#after: Double, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: GCD.defaultQueue(), withArgs:())
	}
	class func utility<R>(#after: Double, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: GCD.utilityQueue(), withArgs:())
	}
	class func background<R>(#after: Double, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: GCD.backgroundQueue(), withArgs:())
	}
	class func customQueue<R>(#after: Double, queue: dispatch_queue_t, block: ()->R) -> Async<(),R> {
		return Async.after(after, block: block, inQueue: queue, withArgs:())
	}
}


extension Async { // Regualar methods matching static once
	
	private func chain<R>(block chainingBlock: (ReturnType->R), runInQueue queue: dispatch_queue_t) -> Async<ReturnType,R> {
		// See Async.async() for comments
        let asyncBlock = Async<ReturnType,R>(chainedFromBlock: true)
        dispatch_group_enter(asyncBlock.dgroup)
        dispatch_group_notify(self.dgroup, queue) {
            let return_block = {
                asyncBlock.return_value = chainingBlock(self.return_value!)
            }
            let cancellableChainingBlock = asyncBlock.cancellable(return_block)
            cancellableChainingBlock()
            dispatch_group_leave(asyncBlock.dgroup)
        }
		return asyncBlock
	}
    
    private func cancellable(blockToWrap: dispatch_block_t) -> dispatch_block_t {
        // Retains self in case it is cancelled and then released.
        return {
            if !self.isCancelled {
                blockToWrap()
            }
        }
    }
	
	func main<R>(chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: GCD.mainQueue())
	}
	func userInteractive<R>(chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: GCD.userInteractiveQueue())
	}
	func userInitiated<R>(chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: GCD.userInitiatedQueue())
	}
	func default_<R>(chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: GCD.defaultQueue())
	}
	func utility<R>(chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: GCD.utilityQueue())
	}
	func background<R>(chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: GCD.backgroundQueue())
	}
	func customQueue<R>(queue: dispatch_queue_t, chainingBlock: ReturnType->R) -> Async<ReturnType,R> {
		return chain(block: chainingBlock, runInQueue: queue)
	}

	
	/* dispatch_after() */

	private func after<R>(seconds: Double, block chainingBlock: ReturnType->R, runInQueue queue: dispatch_queue_t) -> Async<ReturnType,R> {
        
        var asyncBlock = Async<ReturnType,R>(chainedFromBlock: true)
        
        dispatch_group_notify(self.dgroup, queue)
        {
            dispatch_group_enter(asyncBlock.dgroup)
            let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
            let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            dispatch_after(time, queue) {
                let return_block = {
                    asyncBlock.return_value = chainingBlock(self.return_value!)
                }
                let cancellableChainingBlock = self.cancellable(return_block)
                cancellableChainingBlock()
                dispatch_group_leave(asyncBlock.dgroup)
            }
            
        }
		return asyncBlock
	}
	func main<R>(#after: Double, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: GCD.mainQueue())
	}
	func userInteractive<R>(#after: Double, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: GCD.userInteractiveQueue())
	}
	func userInitiated<R>(#after: Double, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: GCD.userInitiatedQueue())
	}
	func default_<R>(#after: Double, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: GCD.defaultQueue())
	}
	func utility<R>(#after: Double, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: GCD.utilityQueue())
	}
	func background<R>(#after: Double, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: GCD.backgroundQueue())
	}
	func customQueue<R>(#after: Double, queue: dispatch_queue_t, block: ReturnType->R) -> Async<ReturnType,R> {
		return self.after(after, block: block, runInQueue: queue)
	}


	/* cancel */

     func cancel() {
        // I don't think that syncronisation is necessary. Any combination of multiple access
        // should result in some boolean value and the cancel will only cancel
        // if the execution has not yet started.
        isCancelled = true
    }

	/* wait */

	/// If optional parameter forSeconds is not provided, use DISPATCH_TIME_FOREVER
	func wait(seconds: Double = 0.0) {
		if seconds != 0.0 {
			let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
			let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            dispatch_group_wait(dgroup, time)
		} else {
			dispatch_group_wait(dgroup, DISPATCH_TIME_FOREVER)
		}
	}
}


// Convenience

// extension qos_class_t {
//
//	// Calculated property
//	var description: String {
//		get {
//			switch +self {
//				case +qos_class_main(): return "Main"
//				case +QOS_CLASS_USER_INTERACTIVE: return "User Interactive"
//				case +QOS_CLASS_USER_INITIATED: return "User Initiated"
//				case +QOS_CLASS_DEFAULT: return "Default"
//				case +QOS_CLASS_UTILITY: return "Utility"
//				case +QOS_CLASS_BACKGROUND: return "Background"
//				case +QOS_CLASS_UNSPECIFIED: return "Unspecified"
//				default: return "Unknown"
//			}
//		}
//	}
//}

