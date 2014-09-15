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
	class final func mainQueue() -> dispatch_queue_t {
		return dispatch_get_main_queue()
		// Could use return dispatch_get_global_queue(+qos_class_main(), 0)
	}
	class final func userInteractiveQueue() -> dispatch_queue_t {
        //return dispatch_get_global_queue(+QOS_CLASS_USER_INTERACTIVE, 0)
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
	}
	class final func userInitiatedQueue() -> dispatch_queue_t {
        //return dispatch_get_global_queue(+QOS_CLASS_USER_INITIATED, 0)
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
	}
	class final func defaultQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
	}
	class final func utilityQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
	}
	class final func backgroundQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
	}
}

public class Async {
//    public class final func main<R>(block: ()->R) -> AsyncInternal<(),R> {
//		return AsyncInternal<(),R>.async(block, inQueue: GCD.mainQueue(), withArgs:())
//    }
    class final func main(block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: GCD.mainQueue(), withArgs:())
	}
	class final func userInteractive(block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: GCD.userInteractiveQueue(), withArgs:())
	}
	class final func userInitiated(block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: GCD.userInitiatedQueue(), withArgs:())
	}
	class final func default_(block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: GCD.defaultQueue(), withArgs:())
	}
	class final func utility(block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: GCD.utilityQueue(), withArgs:())
	}
	class final func background(block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: GCD.backgroundQueue(), withArgs:())
	}
	class final func customQueue(queue: dispatch_queue_t, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.async(block, inQueue: queue, withArgs:())
	}

	class final func main(#after: Double, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: GCD.mainQueue(), withArg:())
	}
	class final func userInteractive(#after: Double, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: GCD.userInteractiveQueue(), withArg:())
	}
	class final func userInitiated(#after: Double, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: GCD.userInitiatedQueue(), withArg:())
	}
	class final func default_(#after: Double, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: GCD.defaultQueue(), withArg:())
	}
	class final func utility(#after: Double, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: GCD.utilityQueue(), withArg:())
	}
	class final func background(#after: Double, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: GCD.backgroundQueue(), withArg:())
	}
	class final func customQueue(#after: Double, queue: dispatch_queue_t, block: ()->()) -> AsyncInternal<(),()> {
		return AsyncInternal.after(after, block: block, inQueue: queue, withArg:())
	}
}

public class AsyncPlus : Async {
    public class final func main<A,R>(withArg:A, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal<A,R>.async(block, inQueue: GCD.mainQueue(), withArgs:withArg)
	}
	class final func userInteractive<A,R>(withArg:A, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal.async(block, inQueue: GCD.userInteractiveQueue(), withArgs:withArg)
	}
	class final func userInitiated<A,R>(withArg:A, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal.async(block, inQueue: GCD.userInitiatedQueue(), withArgs:withArg)
	}
	class final func default_<A,R>(withArg:A, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal.async(block, inQueue: GCD.defaultQueue(), withArgs:withArg)
	}
	class final func utility<A,R>(withArg:A, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal.async(block, inQueue: GCD.utilityQueue(), withArgs:withArg)
	}
	class final func background<A,R>(withArg:A, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal.async(block, inQueue: GCD.backgroundQueue(), withArgs:withArg)
	}
	class final func customQueue<A,R>(withArg:A, queue: dispatch_queue_t, block: A->R) -> AsyncInternal<A,R> {
		return AsyncInternal.async(block, inQueue: queue, withArgs:withArg)
	}
    
}

public class AsyncInternal<A,R> {
    
    //The block to be executed does not need to be retained in present code
    //only the dispatch_group is needed in order to cancel it.
    //private let block: dispatch_block_t
    private let dgroup: dispatch_group_t = dispatch_group_create()
    private var isCancelled = false
    private let argument:ArgumentType!
    private let chained:Bool
    private var returnedValueOpt:ReturnType?
    private init(argument:ArgumentType) {
        self.argument = argument
        self.chained = false
    }
    // This initialiser has arguments to help me remember it is only for use in an explictly chained scenario.
    private init(chained: Bool) {
        assert(chained == true)
        self.chained = true
    }
    typealias ReturnType = R
    typealias ArgumentType = A
    // Static methods
}

extension AsyncInternal
{
    
    /* dispatch_async() */

	private class final func async(block: A->R, inQueue queue: dispatch_queue_t, withArgs:A) -> AsyncInternal<A,R> {
        // Wrap block in a struct since dispatch_block_t can't be extended and to give it a group
		let asyncBlock =  AsyncInternal<A,R>(argument:withArgs)

        // Add block to queue
		dispatch_group_async(asyncBlock.dgroup, queue, asyncBlock.cancellable(block, withArg:withArgs))

        return asyncBlock
		
	}


	/* dispatch_after() */

	private class final func after(seconds: Double, block: A->R, inQueue queue: dispatch_queue_t, withArg:A) -> AsyncInternal<A,R> {
		let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
		let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
		return at(time, block: block, inQueue: queue, withArg:withArg)
	}
	private class final func at(time: dispatch_time_t, block: A->R, inQueue queue: dispatch_queue_t, withArg:A) -> AsyncInternal<A,R> {
		// See Async.async() for comments
        let asyncBlock = AsyncInternal<A,R>(argument: withArg)
        dispatch_group_enter(asyncBlock.dgroup)
        dispatch_after(time, queue){
            let cancellableBlock = asyncBlock.cancellable(block, withArg:withArg)
            cancellableBlock() // Compiler crashed in Beta6 when I just did asyncBlock.cancellable(block) directly.
            dispatch_group_leave(asyncBlock.dgroup)
        }
		return asyncBlock
	}

}


extension AsyncInternal { // Regualar methods matching static once
	
	private final func chain<X>(block chainingBlock: ReturnType->X, runInQueue queue: dispatch_queue_t) -> AsyncInternal<ReturnType,X> {
		// See AsyncInternal.async() for comments
        let asyncBlock = AsyncInternal<ReturnType,X>(chained: true)
        dispatch_group_enter(asyncBlock.dgroup)
        dispatch_group_notify(self.dgroup, queue) {
            let cancellableChainingBlock = self.cancellable(chainingBlock, nextBlock:asyncBlock)
            cancellableChainingBlock()
            dispatch_group_leave(asyncBlock.dgroup)
        }
		return asyncBlock
	}

    private final func cancellable(blockToWrap:ArgumentType->ReturnType, withArg:ArgumentType) -> ()->() {
        // Retains self in case it is cancelled and then released.
        return {
            if !self.isCancelled {
                self.returnedValueOpt = blockToWrap(withArg)
            }
        }
    }

    private final func cancellable<X>(blockToWrap:ReturnType->X, nextBlock:AsyncInternal<ReturnType, X>) -> ()->() {
        // Retains self in case it is cancelled and then released.
        return {
            if !nextBlock.isCancelled {
                nextBlock.returnedValueOpt = blockToWrap(self.returnedValueOpt!)
            }
        }
    }
	
    final func main(chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: GCD.mainQueue())
	}
    final func userInteractive(chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: GCD.userInteractiveQueue())
	}
	final func userInitiated(chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: GCD.userInitiatedQueue())
	}
	final func default_(chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: GCD.defaultQueue())
	}
	final func utility(chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: GCD.utilityQueue())
	}
	final func background(chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: GCD.backgroundQueue())
	}
	final func customQueue(queue: dispatch_queue_t, chainingBlock: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return chain(block: chainingBlock, runInQueue: queue)
	}

	final func main<X>(chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: GCD.mainQueue())
	}
	final func userInteractive<X>(chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: GCD.userInteractiveQueue())
	}
	final func userInitiated<X>(chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: GCD.userInitiatedQueue())
	}
	final func default_<X>(chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: GCD.defaultQueue())
	}
	final func utility<X>(chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: GCD.utilityQueue())
	}
	final func background<X>(chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: GCD.backgroundQueue())
	}
	final func customQueue<X>(queue: dispatch_queue_t, chainingBlock: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return chain(block: chainingBlock, runInQueue: queue)
	}

	
	/* dispatch_after() */

	private final func after<X>(seconds: Double, block chainingBlock: ReturnType->X, runInQueue queue: dispatch_queue_t) -> AsyncInternal<ReturnType,X> {
        
        var asyncBlock = AsyncInternal<ReturnType,X>(chained: true)
        
        dispatch_group_notify(self.dgroup, queue)
        {
            dispatch_group_enter(asyncBlock.dgroup)
            let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
            let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            dispatch_after(time, queue) {
                let cancellableChainingBlock = self.cancellable(chainingBlock, nextBlock: asyncBlock)
                cancellableChainingBlock()
                dispatch_group_leave(asyncBlock.dgroup)
            }
            
        }

		// Wrap block in a struct since dispatch_block_t can't be extended
		return asyncBlock
	}

	final func mainAfter(#after: Double, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: GCD.mainQueue())
	}
	final func userInteractive(#after: Double, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: GCD.userInteractiveQueue())
	}
	final func userInitiated(#after: Double, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: GCD.userInitiatedQueue())
	}
	final func default_(#after: Double, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: GCD.defaultQueue())
	}
	final func utility(#after: Double, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: GCD.utilityQueue())
	}
	final func background(#after: Double, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: GCD.backgroundQueue())
	}
	final func customQueue(#after: Double, queue: dispatch_queue_t, block: ReturnType->()) -> AsyncInternal<ReturnType,()> {
		return self.after(after, block: block, runInQueue: queue)
	}

	final func mainAfter<X>(#after: Double, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: GCD.mainQueue())
	}
	final func userInteractive<X>(#after: Double, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: GCD.userInteractiveQueue())
	}
	final func userInitiated<X>(#after: Double, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: GCD.userInitiatedQueue())
	}
	final func default_<X>(#after: Double, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: GCD.defaultQueue())
	}
	final func utility<X>(#after: Double, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: GCD.utilityQueue())
	}
	final func background<X>(#after: Double, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: GCD.backgroundQueue())
	}
	final func customQueue<X>(#after: Double, queue: dispatch_queue_t, block: ReturnType->X) -> AsyncInternal<ReturnType,X> {
		return self.after(after, block: block, runInQueue: queue)
	}


	/* cancel */

     final func cancel(withValue:ReturnType) {
        isCancelled = true
        // Don't replace proper return value if already set.
        // TODO: This must be syncronised with the returnedValue being set...ick
        if returnedValueOpt == nil {
            returnedValueOpt = withValue
        }
    }

	/* wait */

	/// If optional parameter forSeconds is not provided, use DISPATCH_TIME_FOREVER
	final func wait(seconds: Double = 0.0) {
		if seconds != 0.0 {
			let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
			let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            dispatch_group_wait(dgroup, time)
		} else {
			dispatch_group_wait(dgroup, DISPATCH_TIME_FOREVER)
		}
	}
    
    // Waiting for result with timeout must accept an optional to be returned as
    // nil if the timeout occurred. If the ReturnType is optional it may be an
    // Optional Optional (??)
    /*    final func waitResult(seconds: Double = 0.0)->ReturnType? {
        
    }*/
    final func waitResult()->ReturnType {
        dispatch_group_wait(dgroup,DISPATCH_TIME_FOREVER)
        return returnedValueOpt! // Must be set in the return or cancel
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

