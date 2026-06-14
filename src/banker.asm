;oooooo   oooooo     oooo           o8o      .       .                               .o8                   
; `888.    `888.     .8'            `"'    .o8     .o8                              "888                   
;  `888.   .8888.   .8'   oooo d8b oooo  .o888oo .o888oo  .ooooo.  ooo. .oo.         888oooo.  oooo    ooo 
;   `888  .8'`888. .8'    `888""8P `888    888     888   d88' `88b `888P"Y88b        d88' `88b  `88.  .8'  
;    `888.8'  `888.8'      888      888    888     888   888ooo888  888   888        888   888   `88..8'   
;     `888'    `888'       888      888    888 .   888 . 888    .o  888   888        888   888    `888'    
;      `8'      `8'       d888b    o888o   "888"   "888" `Y8bod8P' o888o o888o       `Y8bod8P'     .8'     
;                                                                                              .o..P'      
;                                                                                              `Y8P'       
;                                                                                                          
;oooooooooooo                                           o8o                oooooo     oooo                           .o        .oooo.   
;`888'     `8                                           `"'                 `888.     .8'                          o888       d8P'`Y8b  
; 888         oooo d8b  .oooo.   ooo. .oo.    .ooooo.  oooo   .oooo.o        `888.   .8'    .ooooo.  oooo d8b       888      888    888 
; 888oooo8    `888""8P `P  )88b  `888P"Y88b  d88' `"Y8 `888  d88(  "8         `888. .8'    d88' `88b `888""8P       888      888    888 
; 888    "     888      .oP"888   888   888  888        888  `"Y88b.           `888.8'     888ooo888  888           888      888    888 
; 888          888     d8(  888   888   888  888   .o8  888  o.  )88b           `888'      888    .o  888           888  .o. `88b  d88' 
;o888o        d888b    `Y888""8o o888o o888o `Y8bod8P' o888o 8""888P'            `8'       `Y8bod8P' d888b         o888o Y8P  `Y8bd8P'  
                                                                                                                                                                                                                                                                                                                                                                                                               
; 银行家算法：订单接纳检查和资源释放。

; ------------------------------------------------------------
; Proc: TryAdmitOrder
; Input:
;   orderIndex = 候选订单下标，通常来自 NEW 或 WAIT 状态
; Output:
;   EAX = 1 表示接纳成功并加入就绪队列；0 表示资源不足或安全性检查失败
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   可能扣减 ResAvail、写 OrderAlloc/OrderState，并在安全时调用 EnqueueOrder。
; Notes:
;   采用“先试分配，再 BankerSafe 验证，不安全则回滚”的流程。
;   RES_COUNT 改变时，这里三类资源的手写代码必须同步扩展。
; ------------------------------------------------------------
TryAdmitOrder PROC USES ebx esi edi orderIndex:DWORD
    LOCAL prevState:DWORD

    mov esi, orderIndex
    movzx eax, BYTE PTR [OrderState+esi]
    mov prevState, eax
    mov ebx, esi
    lea ebx, [ebx+ebx*2]

    mov al, [OrderNeed+ebx]
    cmp al, [ResAvail]
    ja deny_admit
    mov al, [OrderNeed+ebx+1]
    cmp al, [ResAvail+1]
    ja deny_admit
    mov al, [OrderNeed+ebx+2]
    cmp al, [ResAvail+2]
    ja deny_admit

    mov al, [OrderNeed+ebx]
    sub [ResAvail], al
    mov [OrderAlloc+ebx], al
    mov al, [OrderNeed+ebx+1]
    sub [ResAvail+1], al
    mov [OrderAlloc+ebx+1], al
    mov al, [OrderNeed+ebx+2]
    sub [ResAvail+2], al
    mov [OrderAlloc+ebx+2], al

    mov BYTE PTR [OrderState+esi], STATE_READY
    invoke BankerSafe
    cmp eax, 1
    je safe_admit

    mov al, [OrderAlloc+ebx]
    add [ResAvail], al
    mov BYTE PTR [OrderAlloc+ebx], 0
    mov al, [OrderAlloc+ebx+1]
    add [ResAvail+1], al
    mov BYTE PTR [OrderAlloc+ebx+1], 0
    mov al, [OrderAlloc+ebx+2]
    add [ResAvail+2], al
    mov BYTE PTR [OrderAlloc+ebx+2], 0
    mov BYTE PTR [OrderState+esi], STATE_WAIT
    cmp prevState, STATE_WAIT
    je unsafe_log_done
    invoke AddLogEvent, ADDR LogWaitSafeA, esi
unsafe_log_done:
    xor eax, eax
    ret
safe_admit:
    invoke EnqueueOrder, esi
    invoke AddLogEvent, ADDR LogAdmitA, esi
    mov eax, 1
    ret
deny_admit:
    mov BYTE PTR [OrderState+esi], STATE_WAIT
    cmp prevState, STATE_WAIT
    je deny_log_done
    invoke AddLogEvent, ADDR LogWaitResA, esi
deny_log_done:
    xor eax, eax
    ret
TryAdmitOrder ENDP

; ------------------------------------------------------------
; Proc: BankerSafe
; Input:
;   当前全局资源分配快照：ResAvail、OrderNeed、OrderAlloc、OrderState
; Output:
;   EAX = 1 表示存在安全序列；0 表示当前分配不安全
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   无全局写入；只用局部 work/finishMask 模拟资源回收。
; Notes:
;   DONE/NEW/WAIT 被视为已完成或不参与竞争；这符合本仿真接纳逻辑，
;   但不是可以直接复制到任意场景的通用银行家算法模板。
; ------------------------------------------------------------
BankerSafe PROC USES ebx esi edi
    LOCAL work0:DWORD
    LOCAL work1:DWORD
    LOCAL work2:DWORD
    LOCAL progress:DWORD
    LOCAL doneCount:DWORD

    movzx eax, BYTE PTR [ResAvail]
    mov work0, eax
    movzx eax, BYTE PTR [ResAvail+1]
    mov work1, eax
    movzx eax, BYTE PTR [ResAvail+2]
    mov work2, eax
    mov esi, 0
clear_safe_finish:
    cmp esi, OrderCount
    jae clear_safe_done
    mov BYTE PTR [SafeFinish+esi], 0
    inc esi
    jmp clear_safe_finish
clear_safe_done:

safe_outer:
    mov progress, 0
    mov doneCount, 0
    mov esi, 0
safe_each:
    cmp esi, OrderCount
    jae safe_pass_done
    cmp BYTE PTR [SafeFinish+esi], 0
    jne already_finish

    movzx eax, BYTE PTR [OrderState+esi]
    .if eax == STATE_DONE || eax == STATE_NEW || eax == STATE_WAIT
        mov BYTE PTR [SafeFinish+esi], 1
        inc progress
        jmp already_finish
    .endif

    mov ebx, esi
    lea ebx, [ebx+ebx*2]
    movzx eax, BYTE PTR [OrderNeed+ebx]
    movzx edx, BYTE PTR [OrderAlloc+ebx]
    sub eax, edx
    cmp eax, work0
    ja cannot_finish
    movzx eax, BYTE PTR [OrderNeed+ebx+1]
    movzx edx, BYTE PTR [OrderAlloc+ebx+1]
    sub eax, edx
    cmp eax, work1
    ja cannot_finish
    movzx eax, BYTE PTR [OrderNeed+ebx+2]
    movzx edx, BYTE PTR [OrderAlloc+ebx+2]
    sub eax, edx
    cmp eax, work2
    ja cannot_finish

    movzx eax, BYTE PTR [OrderAlloc+ebx]
    add work0, eax
    movzx eax, BYTE PTR [OrderAlloc+ebx+1]
    add work1, eax
    movzx eax, BYTE PTR [OrderAlloc+ebx+2]
    add work2, eax
    mov BYTE PTR [SafeFinish+esi], 1
    inc progress
    jmp already_finish
cannot_finish:
already_finish:
    inc esi
    jmp safe_each
safe_pass_done:
    mov esi, 0
count_finish:
    cmp esi, OrderCount
    jae counted
    cmp BYTE PTR [SafeFinish+esi], 0
    jz not_counted
    inc doneCount
not_counted:
    inc esi
    jmp count_finish
counted:
    mov eax, OrderCount
    cmp doneCount, eax
    je safe_yes
    cmp progress, 0
    jne safe_outer
    xor eax, eax
    ret
safe_yes:
    mov eax, 1
    ret
BankerSafe ENDP

; ------------------------------------------------------------
; Proc: ReleaseOrder
; Input:
;   orderIndex = 已运行完毕的订单下标
; Output:
;   无
; Clobbers:
;   EAX
; Preserves:
;   EBX, ESI
; Side effects:
;   把该订单已分配资源加回 ResAvail，清零 OrderAlloc，并把状态设为 STATE_DONE。
; Notes:
;   调用者应确保订单确实完成；重复调用不会多归还资源，因为 OrderAlloc 已被清零。
; ------------------------------------------------------------
ReleaseOrder PROC USES ebx esi orderIndex:DWORD
    mov esi, orderIndex
    mov ebx, esi
    lea ebx, [ebx+ebx*2]
    mov al, [OrderAlloc+ebx]
    add [ResAvail], al
    mov BYTE PTR [OrderAlloc+ebx], 0
    mov al, [OrderAlloc+ebx+1]
    add [ResAvail+1], al
    mov BYTE PTR [OrderAlloc+ebx+1], 0
    mov al, [OrderAlloc+ebx+2]
    add [ResAvail+2], al
    mov BYTE PTR [OrderAlloc+ebx+2], 0
    mov BYTE PTR [OrderState+esi], STATE_DONE
    invoke AddLogEvent, ADDR LogDoneA, esi
    ret
ReleaseOrder ENDP
