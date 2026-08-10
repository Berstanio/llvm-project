; RUN: llc -o - -verify-machineinstrs -mtriple=armv7-unknown-linux-gnueabihf -stop-after machine-sink %s | FileCheck %s --check-prefix=ISEL
; RUN: llc -o - -verify-machineinstrs -mtriple=armv7-unknown-linux-gnueabihf -fast-isel -fast-isel-abort=1 -stop-after machine-sink %s | FileCheck %s --check-prefix=FAST-ISEL
; RUN: llc -o - -verify-machineinstrs -mtriple=thumbv7-unknown-linux-gnueabihf -stop-after machine-sink %s | FileCheck %s --check-prefix=ISEL

define void @caller_meta_leaf() {
entry:
  %metadata = alloca i32, i32 3, align 4
  store i32 11, ptr %metadata
  store i32 12, ptr %metadata
  store i32 13, ptr %metadata
; ISEL:      ADJCALLSTACKDOWN 0, 0, 14 /* CC::al */, $noreg, implicit-def
; ISEL-NEXT: STACKMAP
; ISEL-NEXT: ADJCALLSTACKUP 0, 0, 14 /* CC::al */, $noreg, implicit-def
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 4, i32 0, ptr %metadata)
; FAST-ISEL:      ADJCALLSTACKDOWN 0, 0, 14 /* CC::al */, $noreg, implicit-def
; FAST-ISEL-NEXT: STACKMAP
; FAST-ISEL-NEXT: ADJCALLSTACKUP 0, 0, 14 /* CC::al */, $noreg, implicit-def
  ret void
}

declare void @llvm.experimental.stackmap(i64, i32, ...)
