; RUN: llc -mtriple armv7-unknown-linux-gnueabihf -verify-machineinstrs -stop-after=prolog-epilog < %s | FileCheck %s
; RUN: llc -mtriple thumbv7-unknown-linux-gnueabihf -verify-machineinstrs -stop-after=prolog-epilog < %s | FileCheck %s

; Check that STATEPOINT instruction has an early clobber implicit def for LR.
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-unknown-linux-gnueabihf"

define void @test() "frame-pointer"="all" gc "statepoint-example" {
entry:
  %safepoint_token = tail call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr elementtype(void ()) @return_i1, i32 0, i32 0, i32 0, i32 0) ["gc-live" ()]
; CHECK: STATEPOINT 0, 0, 0, @return_i1, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, csr_aapcs, implicit-def $sp, implicit-def dead early-clobber $lr
  ret void
}

declare void @return_i1()
declare token @llvm.experimental.gc.statepoint.p0(i64, i32, ptr, i32, i32, ...)
