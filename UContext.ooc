include ucontext

LibcFpState: cover from struct _libc_fpstate
StackT: cover from stack_t {
    ssSp: extern(ss_sp) Pointer
    ssSize: extern(ss_size) SizeT
    ssFlags: extern(ss_flags) Int
}

MContext: cover from mcontext_t
SigSet: cover from __sigset_t
UContext: cover from ucontext_t {
    ucFlags: extern(uc_flags) ULong
    ucLink: extern(uc_link) UContext
    ucStack: extern(uc_stack) StackT
    ucMContext: extern(uc_mcontext) MContext
    ucSigmask: extern(uc_sigmask) SigSet
    fpregsMem: extern(__fpregs_mem) LibcFpState
} 

getcontext: extern func (...)
makecontext: extern func (...)
swapcontext: extern func (...)

