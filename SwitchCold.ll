; ModuleID = './example.ll'
source_filename = "./example.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"


define dso_local void @cold_foo() cold{
entry:
    %cold_cond = icmp eq i64 100,120
    br i1 %cold_cond, label %expect, label %noexpect
expect:
    br label %end
noexpect:
    br label %end
end:
ret void
}

define dso_local void @noncold(){
entry:
ret void
}
; branch to BB with unreachable is less likely
; both are unreachable - 50/50
define dso_local i32 @bar(i32 %arg1) {
entry:
    ; yield true if not equal
    %cond = icmp sgt i32 1,0
    
    %bare_assign = alloca i32 
    store  i32 3, i32* %bare_assign
    %val = load i32, i32* %bare_assign
    
    ;br i1 %cond, label %bbwithunreachable, label %bbreachable

    switch i32 %val, label %defaultcase [ i32 1, label %onone
                                    i32 2, label %ontwo
                                    i32 3, label %onthree ]

; no probs set to these 
; entry to onone - unreachable edge
; remainings are reachable

; entry to ontwo - cold edge
onone:
    call void @noncold()
    ret i32 1
ontwo:
    call void @cold_foo()
    ret i32 4
onthree:
    call void @noncold()
    ret i32 10
defaultcase:
    call void @cold_foo()
    ret i32 10
}
