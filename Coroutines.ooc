import UContext

CORO_DEFAULT_STACK_SIZE := static 128*1024
CORO_STACK_SIZE_MIN := static 8192

CallbackBlock: cover {
    context: Pointer
    function: Func (...)
    init: func@ (=context, =function) {}
}


Coro: cover {
    requestedStackSize: SizeT
    allocatedStackSize: SizeT
    stack: Pointer
    env: UContext
    isMain: Bool
    
    init: func@ () {
        requestedStackSize = CORO_DEFAULT_STACK_SIZE
        allocatedStackSize = 0
        stack = null
    }

    initMainCoro: func@ {
        isMain = true
    }

    startCoro: func (other: Coro, context: Pointer, callback: Func (...)) {
        block := CallbackBlock new(context, callback)
        other allocStackIfNeeded()
        other setup(block)
        switchTo(other)
    } 
    
    allocStackIfNeeded: func@ {
        printf("Allocating stack if needed. stack = %p, requestedStackSize = %d, allocatedStackSize = %d\n", stack, requestedStackSize, allocatedStackSize)
        
        if (stack != null && (requestedStackSize < allocatedStackSize)) {
            stack = null
            requestedStackSize = 0
        }
        
        if (!stack) {
            stack = gc_malloc(requestedStackSize + 16)
            allocatedStackSize = requestedStackSize
        }
    }
    
    startWithArg: func(block: CallbackBlock*) {
        block function (block@ context)
    }

    setup: func@ (arg: CallbackBlock) {
        ucp: UContext*
        ucp = env&
        getcontext(ucp)
        printf("stack = %p, requested stack size = %d\n", stack, requestedStackSize)
        ucp@ ucStack ssSp    = stack
        ucp@ ucStack ssSize  = requestedStackSize
        ucp@ ucStack ssFlags = 0
        ucp@ ucLink = null
        makecontext(ucp, This startWithArg as Func, 1, arg)
    }

    switchTo: func(next: Coro) {
        swapcontext(env&, next env&)
    }

        
}

        

