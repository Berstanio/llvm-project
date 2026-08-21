; RUN: llc < %s -mtriple=armv7-unknown-linux-gnueabihf -mattr=+reserve-r9,+reserve-r10 -verify-machineinstrs | FileCheck %s
; RUN: not llc < %s -mtriple=armv7-unknown-linux-gnueabihf -mattr=+reserve-r10 -filetype=null 2>&1 | FileCheck %s --check-prefix=NO-RESERVE-R9

define i32 @read_r9() nounwind {
; CHECK-LABEL: read_r9:
; CHECK: mov r0, r9
; NO-RESERVE-R9: error: <unknown>:0:0: invalid register "r9" for llvm.read_register
entry:
  %r = call i32 @llvm.read_register.i32(metadata !0)
  ret i32 %r
}

define void @write_r9(i32 %v) nounwind {
; CHECK-LABEL: write_r9:
; CHECK: mov r9, r0
; NO-RESERVE-R9: error: <unknown>:0:0: invalid register "r9" for llvm.write_register
entry:
  call void @llvm.write_register.i32(metadata !0, i32 %v)
  ret void
}

define i32 @read_r10() nounwind {
; CHECK-LABEL: read_r10:
; CHECK: mov r0, r10
entry:
  %r = call i32 @llvm.read_register.i32(metadata !1)
  ret i32 %r
}

define void @write_r10(i32 %v) nounwind {
; CHECK-LABEL: write_r10:
; CHECK: mov r10, r0
entry:
  call void @llvm.write_register.i32(metadata !1, i32 %v)
  ret void
}

; The stack pointer is reserved on every subtarget
define i32 @read_sp() nounwind {
; CHECK-LABEL: read_sp:
; CHECK: mov r0, sp
entry:
  %r = call i32 @llvm.read_register.i32(metadata !2)
  ret i32 %r
}

; Writing a reserved register is a modification of a callee-saved register.
define void @callee_saved(i32 %v) nounwind {
; CHECK-LABEL: callee_saved:
; CHECK: push {r9, lr}
; CHECK: mov r9, r0
; CHECK: bl sink
; CHECK: pop {r9, pc}
entry:
  call void @llvm.write_register.i32(metadata !0, i32 %v)
  call void @sink()
  ret void
}

declare void @sink()

!0 = !{!"r9\00"}
!1 = !{!"r10\00"}
!2 = !{!"sp\00"}
