; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes='attributor' -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=6 < %s | FileCheck %s
target datalayout = "E-p:64:64:64-a0:0:8-f32:32:32-f64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-v64:64:64-v128:128:128"

define internal i32 @test(i32* %X, i32* %Y) {
; CHECK-LABEL: define {{[^@]+}}@test
; CHECK-SAME: (i32* noalias nocapture nofree nonnull readonly align 4 dereferenceable(4) [[X:%.*]], i32* noalias nocapture nofree nonnull readonly align 4 dereferenceable(4) [[Y:%.*]])
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[X]], align 4
; CHECK-NEXT:    [[B:%.*]] = load i32, i32* [[Y]], align 4
; CHECK-NEXT:    [[C:%.*]] = add i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[C]]
;
  %A = load i32, i32* %X
  %B = load i32, i32* %Y
  %C = add i32 %A, %B
  ret i32 %C
}

define internal i32 @caller(i32* %B) {
; CHECK-LABEL: define {{[^@]+}}@caller
; CHECK-SAME: (i32* noalias nocapture nofree nonnull readonly align 4 dereferenceable(4) [[B:%.*]])
; CHECK-NEXT:    [[A:%.*]] = alloca i32
; CHECK-NEXT:    store i32 1, i32* [[A]], align 4
; CHECK-NEXT:    [[C:%.*]] = call i32 @test(i32* noalias nocapture nofree nonnull align 4 dereferenceable(4) [[A]], i32* noalias nocapture nofree nonnull readonly align 4 dereferenceable(4) [[B]])
; CHECK-NEXT:    ret i32 [[C]]
;
  %A = alloca i32
  store i32 1, i32* %A
  %C = call i32 @test(i32* %A, i32* %B)
  ret i32 %C
}

define i32 @callercaller() {
; CHECK-LABEL: define {{[^@]+}}@callercaller()
; CHECK-NEXT:    [[B:%.*]] = alloca i32
; CHECK-NEXT:    store i32 2, i32* [[B]], align 4
; CHECK-NEXT:    [[X:%.*]] = call i32 @caller(i32* noalias nocapture nofree nonnull align 4 dereferenceable(4) [[B]])
; CHECK-NEXT:    ret i32 [[X]]
;
  %B = alloca i32
  store i32 2, i32* %B
  %X = call i32 @caller(i32* %B)
  ret i32 %X
}

