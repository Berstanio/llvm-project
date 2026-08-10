; RUN: llc < %s -mtriple=armv7-unknown-linux-gnueabihf | FileCheck %s --check-prefix=ARM
; RUN: llc < %s -mtriple=thumbv7-unknown-linux-gnueabihf | FileCheck %s --check-prefix=THUMB

; The size of an inline asm block is only an upper bound, so it cannot be
; counted for trimming the shadow.
define void @test_shadow_inline_asm() {
entry:
; ARM-LABEL: test_shadow_inline_asm:
; ARM:            .Ltmp{{[0-9]+}}:
; ARM-COUNT-2:      nop
; ARM-NEXT:       @APP
; THUMB-LABEL: test_shadow_inline_asm:
; THUMB:          .Ltmp{{[0-9]+}}:
; THUMB-COUNT-4:    nop
; THUMB-NEXT:     @APP
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 0, i32 8)
  call void asm sideeffect "nop", ""()
  ret void
}

declare void @llvm.experimental.stackmap(i64, i32, ...)
