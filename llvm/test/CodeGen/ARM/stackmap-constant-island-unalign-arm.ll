; RUN: llc -mtriple=armv7-unknown-linux-gnueabihf -filetype=obj -o /dev/null %s
; RUN: llc -mtriple=armv7-unknown-linux-gnueabihf -o - %s | FileCheck %s --check-prefix=ARM

target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"

declare void @llvm.experimental.stackmap(i64, i32, ...)
declare i32 @llvm.arm.space(i32, i32)

; A stackmap, whose shadow is trimmed against the instructions that follow it:
; the 4 byte shadow is fully covered by the far ldr itself, so no nops are
; emitted, but it still reports as 4.

; ARM-LABEL: test_stackmap_island_arm:
; ARM: ldr {{r[0-9]+}}, [[A_CP:.?LCPI[0-9]+_[0-9]+]]
; ARM: .zero 4028
; ARM: [[A_CP]]:
; ARM-NEXT: .long 12345678
; ARM: .long 1413754136
; ARM-NEXT: .long 1074340347
define i32 @test_stackmap_island_arm(ptr %p, i32 %c) minsize {
entry:
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 0, i32 4)
  %addr = inttoptr i32 12345678 to ptr
  %val = load volatile i32, ptr %addr
  call i32 @llvm.arm.space(i32 4028, i32 undef)
  %t = icmp eq i32 %c, 0
  br i1 %t, label %tail, label %out

tail:
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  store volatile double 0x400921FB54442D18, ptr %p
  br label %out

out:
  ret i32 %val
}
