; RUN: llc -mtriple=armv7-unknown-linux-gnueabihf -verify-machineinstrs < %s | FileCheck %s

; Test that scratch registers are spilled around patchpoints
; CHECK-LABEL: clobberScratch:
; CHECK:      @NO_APP
; CHECK-NEXT: mov r{{[0-9]+}}, lr
; CHECK-NEXT: mov r{{[0-9]+}}, r12
; CHECK-NEXT: .Ltmp
; CHECK-NEXT: nop
define void @clobberScratch(ptr %p) {
  %v = load i32, ptr %p
  tail call void asm sideeffect "nop", "~{r0},~{r1},~{r2},~{r3},~{r4},~{r5},~{r6},~{r7},~{r8},~{r9},~{r10}"() nounwind
  tail call void (i64, i32, ptr, i32, ...) @llvm.experimental.patchpoint.void(i64 5, i32 20, ptr null, i32 0, ptr %p, i32 %v)
  store i32 %v, ptr %p
  ret void
}

declare void @llvm.experimental.patchpoint.void(i64, i32, ptr, i32, ...)
