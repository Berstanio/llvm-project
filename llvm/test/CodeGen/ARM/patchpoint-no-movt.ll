; RUN: not llc -mtriple=armv5te-unknown-linux-gnueabi -verify-machineinstrs < %s 2>&1 | FileCheck %s

declare i32 @llvm.experimental.patchpoint.i32(i64, i32, ptr, i32, ...)

define i32 @patchpoint_immediate_target_needs_movt() {
entry:
  %target = inttoptr i32 305419896 to ptr
  %result = tail call i32 (i64, i32, ptr, i32, ...) @llvm.experimental.patchpoint.i32(i64 14, i32 20, ptr %target, i32 0)
  ret i32 %result
}

; CHECK: LLVM ERROR: Lowering patchpoint with an immediate call target requires movw/movt
