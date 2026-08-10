; RUN: llc -mtriple=armv7 -o - %s | FileCheck %s
; RUN: llc -mtriple=thumbv7 -o - %s | FileCheck %s --check-prefix=THUMB

define void @test_stackmap_island(ptr %p) {
; CHECK-LABEL: test_stackmap_island:
; CHECK: vldr {{d[0-9]+}}, [[CPENTRY:.?LCPI[0-9]+_[0-9]+]]
; CHECK: b [[PAST_CP:.?LBB[0-9]+_[0-9]+]]

; CHECK: [[CPENTRY]]:
; CHECK-NEXT: .long 1413754136
; CHECK-NEXT: .long 1074340347

; CHECK: [[PAST_CP]]:
; CHECK: nop

; THUMB-LABEL: test_stackmap_island:
; THUMB: vldr {{d[0-9]+}}, [[T_CPENTRY:.?LCPI[0-9]+_[0-9]+]]
; THUMB: b.w [[T_PAST_CP:.?LBB[0-9]+_[0-9]+]]

; THUMB: [[T_CPENTRY]]:
; THUMB-NEXT: .long 1413754136
; THUMB-NEXT: .long 1074340347

; THUMB: [[T_PAST_CP]]:
; THUMB: nop
  store volatile double 0x400921FB54442D18, ptr %p
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 0, i32 2048)
  ret void
}

declare void @llvm.experimental.stackmap(i64, i32, ...)
