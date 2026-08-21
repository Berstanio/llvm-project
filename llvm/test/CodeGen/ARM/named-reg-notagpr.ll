; RUN: not llc < %s -mtriple=armv7-unknown-linux-gnueabihf -filetype=null 2>&1 | FileCheck %s

; ZR is reserved, but not a GPR.
define i32 @get_zr() nounwind {
entry:
; CHECK: error: <unknown>:0:0: invalid register "zr" for llvm.read_register
  %r = call i32 @llvm.read_register.i32(metadata !0)
  ret i32 %r
}

declare i32 @llvm.read_register.i32(metadata) nounwind

!0 = !{!"zr"}

