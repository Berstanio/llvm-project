; RUN: llc -mtriple=armv7-unknown-linux-gnueabihf < %s | FileCheck %s --check-prefixes=CHECK,LE
; RUN: llc -mtriple=armebv7-unknown-linux-gnueabihf < %s | FileCheck %s --check-prefixes=CHECK,BE

define i32 @stackmap_frame_record(i32 %a) {
; CHECK-LABEL: stackmap_frame_record:
entry:
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 7, i32 0, i32 %a)
  ret i32 %a
}

; CHECK:      .section .llvm_stackmaps
; CHECK:      __LLVM_StackMaps:
; Header
; CHECK-NEXT: .byte 3
; CHECK-NEXT: .byte 0
; CHECK-NEXT: .short 0
; Num Functions
; CHECK-NEXT: .long 1
; Num LargeConstants
; CHECK-NEXT: .long 0
; Num Callsites
; CHECK-NEXT: .long 1

; Functions and stack size
; LE-NEXT: .long stackmap_frame_record
; LE-NEXT: .zero 4
; LE-NEXT: .long 8
; LE-NEXT: .long 0
; LE-NEXT: .long 1
; LE-NEXT: .long 0
; BE-NEXT: .zero 4
; BE-NEXT: .long stackmap_frame_record
; BE-NEXT: .long 0
; BE-NEXT: .long 8
; BE-NEXT: .long 0
; BE-NEXT: .long 1

declare void @llvm.experimental.stackmap(i64, i32, ...)
