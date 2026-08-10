; RUN: llc -mtriple=armv7-unknown-linux-gnueabihf < %s | FileCheck %s
;
; Note: Print verbose stackmaps using -debug-only=stackmaps.

; CHECK-LABEL:  .section  .llvm_stackmaps
; CHECK-NEXT:  __LLVM_StackMaps:
; Header
; CHECK-NEXT:   .byte 3
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 0
; Num Functions
; CHECK-NEXT:   .long 5
; Num LargeConstants
; CHECK-NEXT:   .long 2
; Num Callsites
; CHECK-NEXT:   .long 7

; Functions and stack size.
; CHECK-NEXT:   .long constantargs
; CHECK-NEXT:   .zero 4
; CHECK-NEXT:   .long 8
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long 1
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long liveArgs
; CHECK-NEXT:   .zero 4
; CHECK-NEXT:   .long 8
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long 1
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long directFrameIdx
; CHECK-NEXT:   .zero 4
; CHECK-NEXT:   .long 24
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long 1
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long spilledValue
; CHECK-NEXT:   .zero 4
; CHECK-NEXT:   .long 40
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long 1
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long longid
; CHECK-NEXT:   .zero 4
; CHECK-NEXT:   .long 8
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long 3
; CHECK-NEXT:   .long 0

; Large Constants
; 4294967295
; CHECK-NEXT:   .long 4294967295
; CHECK-NEXT:   .long 0
; 4294967296
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long 1

; Constant arguments
;
; CHECK-NEXT:   .long 1
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long .L{{.*}}-constantargs
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 4
; SmallConstant
; CHECK-NEXT:   .byte 4
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 8
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 65535
; SmallConstant
; CHECK-NEXT:   .byte 4
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 8
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 65536
; LargeConstant at index 0
; CHECK-NEXT:   .byte 5
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 8
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 0
; LargeConstant at index 1
; CHECK-NEXT:   .byte 5
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 8
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 1

define void @constantargs() {
entry:
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 1, i32 0, i32 65535, i32 65536, i64 4294967295, i64 4294967296)
  ret void
}

; Live values in registers.
;
; CHECK-LABEL:  .long .L{{.*}}-liveArgs
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 3
; Loc 0: Register r0
; CHECK-NEXT:   .byte 1
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 4
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 0
; Loc 1: Register r1
; CHECK-NEXT:   .byte 1
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 4
; CHECK-NEXT:   .short 1
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 0
; Loc 2: Register r2
; CHECK-NEXT:   .byte 1
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 4
; CHECK-NEXT:   .short 2
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 0

define void @liveArgs(i32 %a, i32 %b, i32 %c) {
entry:
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 2, i32 0, i32 %a, i32 %b, i32 %c)
  ret void
}

; Directly map an alloca's address.
;
; CHECK-LABEL:  .long .L{{.*}}-directFrameIdx
; CHECK-NEXT:   .short 0
; 1 location
; CHECK-NEXT:   .short 1
; Loc 0: Direct SP (r13) + ofs
; CHECK-NEXT:   .byte 2
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 4
; CHECK-NEXT:   .short 13
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long 4

define void @directFrameIdx() {
entry:
  %metadata = alloca i32, i32 3, align 4
  store i32 11, ptr %metadata
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 3, i32 0, ptr %metadata)
  ret void
}

; Spilled stack map values.
;
; CHECK-LABEL:  .long .L{{.*}}-spilledValue
; CHECK-NEXT:   .short 0
; 1 location
; CHECK-NEXT:   .short 1
; Loc 0: Indirect SP (r13) + ofs
; CHECK-NEXT:   .byte 3
; CHECK-NEXT:   .byte 0
; CHECK-NEXT:   .short 4
; CHECK-NEXT:   .short 13
; CHECK-NEXT:   .short 0
; CHECK-NEXT:   .long {{[0-9]+}}

define void @spilledValue(i32 %a) {
entry:
  tail call void asm sideeffect "nop", "~{r0},~{r1},~{r2},~{r3},~{r4},~{r5},~{r6},~{r7},~{r8},~{r9},~{r10},~{r12},~{lr}"() nounwind
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 4, i32 0, i32 %a)
  ret void
}

; Test a 64-bit ID, which also splits into a low and a high .long.
;
; 4294967295
; CHECK:        .long 4294967295
; CHECK-NEXT:   .long 0
; CHECK-NEXT:   .long .L{{.*}}-longid
; 4294967296
; CHECK:        .long 0
; CHECK-NEXT:   .long 1
; CHECK-NEXT:   .long .L{{.*}}-longid
; 9223372036854775807
; CHECK:        .long 4294967295
; CHECK-NEXT:   .long 2147483647
; CHECK-NEXT:   .long .L{{.*}}-longid

define void @longid() {
entry:
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 4294967295, i32 0)
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 4294967296, i32 0)
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 9223372036854775807, i32 0)
  ret void
}

declare void @llvm.experimental.stackmap(i64, i32, ...)
