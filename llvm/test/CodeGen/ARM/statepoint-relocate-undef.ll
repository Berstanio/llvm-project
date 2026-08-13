; RUN: llc -mtriple=armv7-unknown-linux-gnueabihf -stop-before=finalize-isel < %s | FileCheck %s

declare i32 @f()
declare token @llvm.experimental.gc.statepoint.p0(i64, i32, ptr, i32, i32, ...)
declare ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token, i32, i32)
declare i32 @llvm.experimental.gc.result.i32(token)

define i32 @test_gcrelocate_undef_store(ptr %slot) gc "statepoint-example" {
; CHECK-LABEL: name: test_gcrelocate_undef_store
; CHECK:      STATEPOINT 0, 0, 0, @f
; CHECK-NOT:  STRi12
; CHECK:      %{{[0-9]+}}:gpr = MOVi32imm -16843010
; CHECK-NEXT: STRi12 killed %{{[0-9]+}}, %{{[0-9]+}}, 0, {{.*}} :: (store (s32) into %ir.slot)
; CHECK-NOT:  STRi12
  %tok = call token (i64, i32, ptr, i32, i32, ...)
      @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr elementtype(i32 ()) @f, i32 0, i32 0, i32 0, i32 0) ["gc-live" (ptr addrspace(1) undef)]
  %rel = call ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token %tok, i32 0, i32 0)
  %res = call i32 @llvm.experimental.gc.result.i32(token %tok)
  store ptr addrspace(1) %rel, ptr %slot, align 4
  ret i32 %res
}
