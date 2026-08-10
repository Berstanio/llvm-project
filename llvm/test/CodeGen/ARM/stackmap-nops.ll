; RUN: llc < %s -mtriple=armv7-unknown-linux-gnueabihf | FileCheck %s
; RUN: llc < %s -mtriple=thumbv7-unknown-linux-gnueabihf | FileCheck %s --check-prefix=THUMB

; A 16-byte shadow is four ARM instructions, one of which the return covers.
; The Thumb NOP is only two bytes wide, so the same shadow takes eight of them.
define void @test_shadow_trimmed() {
entry:
; CHECK-LABEL: test_shadow_trimmed:
; CHECK:      .Ltmp{{[0-9]+}}:
; CHECK-NEXT:   nop
; CHECK-NEXT:   nop
; CHECK-NEXT:   nop
; CHECK-NEXT:   pop
; CHECK-NOT:    nop
; THUMB-LABEL: test_shadow_trimmed:
; THUMB:          .Ltmp{{[0-9]+}}:
; THUMB-COUNT-7:    nop
; THUMB-NEXT:       pop
; THUMB-NOT:        nop
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 0, i32 16)
  ret void
}

; A zero-byte shadow emits nothing at all.
define void @test_no_shadow() {
entry:
; CHECK-LABEL: test_no_shadow:
; CHECK:      .Ltmp{{[0-9]+}}:
; CHECK-NEXT:   pop
; CHECK-NOT:    nop
; THUMB-LABEL: test_no_shadow:
; THUMB:      .Ltmp{{[0-9]+}}:
; THUMB-NEXT:   pop
; THUMB-NOT:    nop
  tail call void (i64, i32, ...) @llvm.experimental.stackmap(i64 1, i32 0)
  ret void
}

; A instruction on ARM can be variable size, the space consumes the whole shadow here
define void @test_shadow_variable_size() {
entry:
; CHECK-LABEL: test_shadow_variable_size:
; CHECK:      .Ltmp{{[0-9]+}}:
; CHECK-NEXT:   .zero 800
; CHECK-NOT:    nop
; THUMB-LABEL: test_shadow_variable_size:
; THUMB:      .Ltmp{{[0-9]+}}:
; THUMB-NEXT:   .zero 800
; THUMB-NOT:    nop
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 2, i32 48)
  call i32 @llvm.arm.space(i32 800, i32 undef)
  ret void
}

; A SPACE is not strictly required to be a multiple of four bytes
define void @test_shadow_partial_word() {
entry:
; CHECK-LABEL: test_shadow_partial_word:
; CHECK:          .Ltmp{{[0-9]+}}:
; CHECK-COUNT-10:   nop
; CHECK-NEXT:       .zero 5
; CHECK-NEXT:       pop
; THUMB-LABEL: test_shadow_partial_word:
; THUMB:          .Ltmp{{[0-9]+}}:
; THUMB-COUNT-21:   nop
; THUMB-NEXT:       .zero 5
; THUMB-NEXT:       pop
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 3, i32 48)
  call i32 @llvm.arm.space(i32 5, i32 undef)
  ret void
}

; A statepoint can have a patch region, which must not overlap with the stackmap shadow
declare void @foo()
define void @test_shadow_stops_at_statepoint() gc "statepoint-example" {
entry:
; CHECK-LABEL: test_shadow_stops_at_statepoint:
; CHECK:          .Ltmp{{[0-9]+}}:
; CHECK-COUNT-24:   nop
; CHECK-NEXT:     .Ltmp{{[0-9]+}}:
; THUMB-LABEL: test_shadow_stops_at_statepoint:
; THUMB:          .Ltmp{{[0-9]+}}:
; THUMB-COUNT-48:   nop
; THUMB-NEXT:     .Ltmp{{[0-9]+}}:
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 4, i32 48)
  %tok = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 48, ptr elementtype(void ()) @foo, i32 0, i32 0, i32 0, i32 0)
  ret void
}

declare i32 @llvm.arm.space(i32, i32)
declare token @llvm.experimental.gc.statepoint.p0(i64, i32, ptr, i32, i32, ...)
declare void @llvm.experimental.stackmap(i64, i32, ...)
