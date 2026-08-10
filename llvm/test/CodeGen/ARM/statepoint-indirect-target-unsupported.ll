; RUN: not llc -mtriple=armv4t-unknown-linux-gnueabi -verify-machineinstrs < %s 2>&1 | FileCheck %s

declare token @llvm.experimental.gc.statepoint.p0(i64, i32, ptr, i32, i32, ...)

define void @statepoint_indirect_target(ptr %fn) gc "statepoint-example" {
  %tok = call token (i64, i32, ptr, i32, i32, ...)
      @llvm.experimental.gc.statepoint.p0(i64 0, i32 0,
          ptr elementtype(void ()) %fn, i32 0, i32 0, i32 0, i32 0)
  ret void
}

; CHECK: LLVM ERROR: Lowering statepoint with an indirect call target requires blx
