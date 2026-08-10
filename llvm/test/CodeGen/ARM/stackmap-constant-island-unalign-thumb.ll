; RUN: llc -mtriple=thumbv7-unknown-linux-gnueabihf -filetype=obj -o /dev/null %s
; RUN: llc -mtriple=thumbv7-unknown-linux-gnueabihf -o - %s | FileCheck %s --check-prefix=THUMB

target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"

declare token @llvm.experimental.gc.statepoint.p0(i64, i32, ptr, i32, i32, ...)
declare void @llvm.experimental.stackmap(i64, i32, ...)
declare i32 @llvm.arm.space(i32, i32)

; A Thumb2 statepoint with a register call target and no patch bytes is
; lowered to a 2 byte tBLXr, but is reported as 4 bytes.

; THUMB-LABEL: test_statepoint_island_thumb:
; THUMB: blx
; THUMB: blx
; THUMB: blx
; THUMB: vldr {{d[0-9]+}}, [[T1_CP:.?LCPI[0-9]+_[0-9]+]]
; THUMB: b.w [[T1_PAST:.?LBB[0-9]+_[0-9]+]]
; THUMB: [[T1_CP]]:
; THUMB-NEXT: .long 1413754136
; THUMB-NEXT: .long 1074340347
; THUMB: [[T1_PAST]]:
; THUMB-NEXT: .zero 1006
define void @test_statepoint_island_thumb(ptr %p, ptr %fn, ptr %q) gc "statepoint-example" {
entry:
  %t0 = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr elementtype(void ()) %fn, i32 0, i32 0, i32 0, i32 0)
  %t1 = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr elementtype(void ()) %fn, i32 0, i32 0, i32 0, i32 0)
  %t2 = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr elementtype(void ()) %fn, i32 0, i32 0, i32 0, i32 0)
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %q
  call i32 @llvm.arm.space(i32 1006, i32 undef)
  ret void
}

; A stackmap, whose shadow is trimmed against the instructions that follow it:
; the 6 byte shadow is fully vldr and the vstr, so no nops are emitted, but it still reports as 6.

; THUMB-LABEL: test_stackmap_island_thumb:
; THUMB: vldr {{d[0-9]+}}, [[T2_CP:.?LCPI[0-9]+_[0-9]+]]
; THUMB: b.w [[T2_PAST:.?LBB[0-9]+_[0-9]+]]
; THUMB: [[T2_CP]]:
; THUMB-NEXT: .long 1413754136
; THUMB-NEXT: .long 1074340347
; THUMB: [[T2_PAST]]:
; THUMB-NEXT: .zero 1010
define void @test_stackmap_island_thumb(ptr %p) {
entry:
  %l0 = load volatile i32, ptr %p
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 0, i32 6)
  store volatile double 0x400921FB54442D18, ptr %p
  call i32 @llvm.arm.space(i32 1010, i32 undef)
  ret void
}
