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
                                                                                                                                       
              
; 时间片轮转调度、就绪队列和调度可视化。

; ------------------------------------------------------------
; Proc: DrawSchedule
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 调度面板矩形
; Output:
;   无；绘制当前运行订单、就绪队列前三项，以及示意性时间轴色块
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   读取 CurrentOrder/ReadyQueue/QueueHead/QueueCount；临时创建画刷。
; Notes:
;   时间轴色块是固定比例演示，不是根据真实历史日志动态生成。
; ------------------------------------------------------------
DrawSchedule PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL gridL:DWORD
    LOCAL gridT:DWORD
    LOCAL gridR:DWORD
    LOCAL gridB:DWORD
    LOCAL rowH:DWORD
    LOCAL hBrush:HBRUSH
    LOCAL rc:RECT
    LOCAL x1:DWORD
    LOCAL x2:DWORD
    LOCAL y1:DWORD
    LOCAL y2:DWORD
    LOCAL textL:DWORD
    LOCAL textR:DWORD

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR SchedText
    mov eax, lft
    add eax, 12
    mov textL, eax
    mov eax, rgt
    sub eax, 12
    mov textR, eax
    mov eax, tp
    add eax, 30
    mov y1, eax
    add eax, 18
    mov y2, eax
    invoke DrawCellW, hdc, ADDR AlgoText, textL, y1, textR, y2
    mov eax, tp
    add eax, 50
    mov y1, eax
    add eax, 18
    mov y2, eax
    invoke DrawCellW, hdc, ADDR SliceText, textL, y1, textR, y2

    mov eax, lft
    add eax, 80
    mov gridL, eax
    mov eax, tp
    add eax, 82
    mov gridT, eax
    mov eax, rgt
    sub eax, 14
    mov gridR, eax
    mov eax, btm
    sub eax, 18
    mov gridB, eax
    invoke DrawGrid, hdc, gridL, gridT, gridR, gridB, 6, 4
    mov eax, gridB
    sub eax, gridT
    xor edx, edx
    mov ebx, 4
    div ebx
    mov rowH, eax

    mov eax, lft
    add eax, 12
    mov textL, eax
    mov eax, gridL
    sub eax, 6
    mov textR, eax
    m2m y1, gridT
    mov eax, y1
    add eax, rowH
    mov y2, eax
    invoke GetSchedRowText, 0
    invoke DrawCellA, hdc, eax, textL, y1, textR, y2
    m2m y1, y2
    mov eax, y1
    add eax, rowH
    mov y2, eax
    invoke GetSchedRowText, 1
    invoke DrawCellA, hdc, eax, textL, y1, textR, y2
    m2m y1, y2
    mov eax, y1
    add eax, rowH
    mov y2, eax
    invoke GetSchedRowText, 2
    invoke DrawCellA, hdc, eax, textL, y1, textR, y2
    m2m y1, y2
    mov eax, gridB
    mov y2, eax
    invoke GetSchedRowText, 3
    invoke DrawCellA, hdc, eax, textL, y1, textR, y2

    invoke CreateSolidBrush, 00608048h
    mov hBrush, eax

    mov eax, gridT
    add eax, 5
    mov y1, eax
    mov eax, gridT
    add eax, rowH
    sub eax, 5
    mov y2, eax
    m2m x1, gridL
    mov eax, gridR
    sub eax, gridL
    mov ebx, 8
    mul ebx
    mov ebx, 30
    div ebx
    add eax, gridL
    mov x2, eax
    invoke SetRect, ADDR rc, x1, y1, x2, y2
    invoke FillRect, hdc, ADDR rc, hBrush

    mov eax, gridT
    add eax, rowH
    add eax, 5
    mov y1, eax
    mov eax, gridT
    mov ebx, rowH
    shl ebx, 1
    add eax, ebx
    sub eax, 5
    mov y2, eax
    m2m x1, gridL
    mov eax, gridR
    sub eax, gridL
    mov ebx, 8
    mul ebx
    mov ebx, 30
    div ebx
    add eax, gridL
    mov x2, eax
    invoke SetRect, ADDR rc, x1, y1, x2, y2
    invoke FillRect, hdc, ADDR rc, hBrush

    mov eax, gridR
    sub eax, gridL
    mov ebx, 2
    mul ebx
    mov ebx, 30
    div ebx
    add eax, gridL
    mov x1, eax
    mov eax, gridR
    sub eax, gridL
    mov ebx, 12
    mul ebx
    mov ebx, 30
    div ebx
    add eax, gridL
    mov x2, eax
    mov eax, gridT
    mov ebx, rowH
    shl ebx, 1
    add eax, ebx
    add eax, 5
    mov y1, eax
    mov eax, gridT
    mov ebx, rowH
    mov ecx, 3
    imul ebx, ecx
    add eax, ebx
    sub eax, 5
    mov y2, eax
    invoke SetRect, ADDR rc, x1, y1, x2, y2
    invoke FillRect, hdc, ADDR rc, hBrush

    mov eax, gridR
    sub eax, gridL
    mov ebx, 5
    mul ebx
    mov ebx, 30
    div ebx
    add eax, gridL
    mov x1, eax
    mov eax, gridR
    sub eax, gridL
    mov ebx, 20
    mul ebx
    mov ebx, 30
    div ebx
    add eax, gridL
    mov x2, eax
    mov eax, gridT
    mov ebx, rowH
    mov ecx, 3
    imul ebx, ecx
    add eax, ebx
    add eax, 5
    mov y1, eax
    mov eax, gridB
    sub eax, 5
    mov y2, eax
    invoke SetRect, ADDR rc, x1, y1, x2, y2
    invoke FillRect, hdc, ADDR rc, hBrush
    invoke DeleteObject, hBrush

    ret
DrawSchedule ENDP

; ------------------------------------------------------------
; Proc: InitSimulation
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   重置订单状态、剩余时间、资源可用量、就绪队列、页面缓存和统计计数。
; Notes:
;   这是全局硬重置；以后增加新的仿真状态时，必须在这里补初始化。
; ------------------------------------------------------------
InitSimulation PROC USES ebx esi edi
    mov esi, 0
init_orders:
    cmp esi, ORDER_COUNT
    jae init_orders_done
    mov BYTE PTR [OrderState+esi], STATE_NEW
    mov eax, [OrderTotalTime+esi*4]
    mov [OrderRemain+esi*4], eax
    mov DWORD PTR [OrderRunTime+esi*4], 0
    mov ebx, esi
    lea ebx, [ebx+ebx*2]
    mov BYTE PTR [OrderAlloc+ebx], 0
    mov BYTE PTR [OrderAlloc+ebx+1], 0
    mov BYTE PTR [OrderAlloc+ebx+2], 0
    inc esi
    jmp init_orders
init_orders_done:
    mov al, [ResTotal]
    mov [ResAvail], al
    mov al, [ResTotal+1]
    mov [ResAvail+1], al
    mov al, [ResTotal+2]
    mov [ResAvail+2], al

    mov BYTE PTR [ResMaxDemand], 0
    mov BYTE PTR [ResMaxDemand+1], 0
    mov BYTE PTR [ResMaxDemand+2], 0
    mov esi, 0
max_order_loop:
    cmp esi, ORDER_COUNT
    jae max_done
    mov ebx, esi
    lea ebx, [ebx+ebx*2]
    mov al, [OrderNeed+ebx]
    add BYTE PTR [ResMaxDemand], al
    mov al, [OrderNeed+ebx+1]
    add BYTE PTR [ResMaxDemand+1], al
    mov al, [OrderNeed+ebx+2]
    add BYTE PTR [ResMaxDemand+2], al
    inc esi
    jmp max_order_loop
max_done:
    mov QueueHead, 0
    mov QueueTail, 0
    mov QueueCount, 0
    mov CurrentOrder, INVALID_ORDER
    mov SliceLeft, 0
    mov ParallelLimit, 1
    mov esi, 0
init_running_slots:
    cmp esi, MAX_PARALLEL
    jae init_running_done
    mov DWORD PTR [RunningOrders+esi*4], INVALID_ORDER
    mov DWORD PTR [RunningSliceLeft+esi*4], 0
    inc esi
    jmp init_running_slots
init_running_done:
    mov NextAdmission, 0
    mov SimClock, 0
    mov FifoCursor, 0
    mov FifoHits, 0
    mov FifoFaults, 0
    mov LruClock, 0
    mov LruHits, 0
    mov LruFaults, 0
    mov LogHead, 0
    mov LogCount, 0

    mov esi, 0
init_queue_cache:
    cmp esi, CACHE_SIZE
    jae init_cache_done
    mov BYTE PTR [FifoFrames+esi], 0FFh
    mov BYTE PTR [LruFrames+esi], 0FFh
    mov DWORD PTR [LruAge+esi*4], 0
    cmp esi, QUEUE_SIZE
    jae skip_queue_init
    mov BYTE PTR [ReadyQueue+esi], 0FFh
skip_queue_init:
    inc esi
    jmp init_queue_cache
init_cache_done:
    invoke AddLogEvent, ADDR LogInitA, INVALID_ORDER
    ret
InitSimulation ENDP

; ------------------------------------------------------------
; Proc: SimTick
; Input:
;   无；由 WM_TIMER 每秒调用一次
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   推进 SimClock；尝试接纳所有可接纳订单；运行每个运行槽 1 秒；
;   更新订单暂存、资源分配、订单状态和就绪队列。
; Notes:
;   时间片长度写死为 2 秒；并行槽位数量由 ParallelLimit 控制，
;   等待订单的公平性仍依赖 NextAdmission 轮转扫描。
; ------------------------------------------------------------
SimTick PROC USES ebx esi edi
    inc SimClock

    invoke AdmitRunnableOrders
    invoke FillRunningSlots

    mov esi, 0
run_slot_loop:
    cmp esi, MAX_PARALLEL
    jae run_slots_done
    mov eax, esi
    cmp eax, ParallelLimit
    jae next_run_slot
    mov edi, [RunningOrders+esi*4]
    cmp edi, INVALID_ORDER
    je next_run_slot

    dec DWORD PTR [OrderRemain+edi*4]
    inc DWORD PTR [OrderRunTime+edi*4]
    dec DWORD PTR [RunningSliceLeft+esi*4]
    cmp DWORD PTR [OrderRemain+edi*4], 0
    jg slot_not_finished
    invoke ReleaseOrder, edi
    mov DWORD PTR [RunningOrders+esi*4], INVALID_ORDER
    mov DWORD PTR [RunningSliceLeft+esi*4], 0
    jmp next_run_slot
slot_not_finished:
    cmp DWORD PTR [RunningSliceLeft+esi*4], 0
    jg next_run_slot
    mov BYTE PTR [OrderState+edi], STATE_READY
    invoke EnqueueOrder, edi
    invoke AddLogEvent, ADDR LogRotateA, edi
    mov DWORD PTR [RunningOrders+esi*4], INVALID_ORDER
    mov DWORD PTR [RunningSliceLeft+esi*4], 0
next_run_slot:
    inc esi
    jmp run_slot_loop
run_slots_done:
    invoke AdmitRunnableOrders
    invoke FillRunningSlots
    invoke RefreshCurrentOrder
    cmp CurrentOrder, INVALID_ORDER
    jne tick_done
    cmp QueueCount, 0
    jne tick_done
    invoke AddLogEvent, ADDR LogIdleA, INVALID_ORDER
tick_done:
    ret
SimTick ENDP

; ------------------------------------------------------------
; Proc: AdmitRunnableOrders
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   扫描 NEW/WAIT 订单，资源和安全性满足时接纳进入就绪队列。
; Notes:
;   一轮 tick 会尝试所有候选订单，不再限制为最多接纳一个。
; ------------------------------------------------------------
AdmitRunnableOrders PROC USES ebx esi edi
    LOCAL scanBase:DWORD

    mov eax, NextAdmission
    mov scanBase, eax
    mov esi, 0
admit_scan:
    cmp esi, ORDER_COUNT
    jae admit_done
    mov eax, scanBase
    add eax, esi
    xor edx, edx
    mov ebx, ORDER_COUNT
    div ebx
    mov edi, edx
    movzx eax, BYTE PTR [OrderState+edi]
    .if eax == STATE_NEW || eax == STATE_WAIT
        invoke TryAdmitOrder, edi
        cmp eax, 1
        jne no_admit
        mov eax, edi
        inc eax
        xor edx, edx
        mov ebx, ORDER_COUNT
        div ebx
        mov NextAdmission, edx
    .endif
no_admit:
    inc esi
    jmp admit_scan
admit_done:
    ret
AdmitRunnableOrders ENDP

; ------------------------------------------------------------
; Proc: FillRunningSlots
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   从就绪队列取订单填充空运行槽，最多到 ParallelLimit。
; ------------------------------------------------------------
FillRunningSlots PROC USES esi
    mov esi, 0
fill_slot_loop:
    cmp esi, MAX_PARALLEL
    jae fill_done
    mov eax, esi
    cmp eax, ParallelLimit
    jae fill_done
    cmp DWORD PTR [RunningOrders+esi*4], INVALID_ORDER
    jne next_fill_slot
    invoke DequeueOrder
    cmp eax, INVALID_ORDER
    je fill_done
    mov [RunningOrders+esi*4], eax
    mov DWORD PTR [RunningSliceLeft+esi*4], 2
    mov BYTE PTR [OrderState+eax], STATE_RUN
    invoke AddLogEvent, ADDR LogRunA, eax
next_fill_slot:
    inc esi
    jmp fill_slot_loop
fill_done:
    invoke RefreshCurrentOrder
    ret
FillRunningSlots ENDP

; ------------------------------------------------------------
; Proc: ClampRunningSlots
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   并行度调小时，把超出槽位的运行订单放回就绪队列。
; ------------------------------------------------------------
ClampRunningSlots PROC USES esi edi
    mov esi, ParallelLimit
clamp_loop:
    cmp esi, MAX_PARALLEL
    jae clamp_done
    mov edi, [RunningOrders+esi*4]
    cmp edi, INVALID_ORDER
    je next_clamp_slot
    mov BYTE PTR [OrderState+edi], STATE_READY
    invoke EnqueueOrder, edi
    invoke AddLogEvent, ADDR LogRotateA, edi
    mov DWORD PTR [RunningOrders+esi*4], INVALID_ORDER
    mov DWORD PTR [RunningSliceLeft+esi*4], 0
next_clamp_slot:
    inc esi
    jmp clamp_loop
clamp_done:
    ret
ClampRunningSlots ENDP

; ------------------------------------------------------------
; Proc: RefreshCurrentOrder
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   用第一个运行槽刷新旧 UI 使用的 CurrentOrder/SliceLeft 镜像。
; ------------------------------------------------------------
RefreshCurrentOrder PROC USES esi
    mov CurrentOrder, INVALID_ORDER
    mov SliceLeft, 0
    mov esi, 0
refresh_loop:
    cmp esi, MAX_PARALLEL
    jae refresh_done
    mov eax, [RunningOrders+esi*4]
    cmp eax, INVALID_ORDER
    je next_refresh_slot
    mov CurrentOrder, eax
    mov eax, [RunningSliceLeft+esi*4]
    mov SliceLeft, eax
    ret
next_refresh_slot:
    inc esi
    jmp refresh_loop
refresh_done:
    ret
RefreshCurrentOrder ENDP

; ------------------------------------------------------------
; Proc: EnqueueOrder
; Input:
;   orderIndex = 要加入就绪队列的订单下标
; Output:
;   无
; Clobbers:
;   EAX
; Preserves:
;   EBX
; Side effects:
;   写 ReadyQueue/QueueTail/QueueCount。
; Notes:
;   队列满时静默丢弃；QUEUE_SIZE 必须为 2 的幂，因为用 and 做环形取模。
; ------------------------------------------------------------
EnqueueOrder PROC USES ebx orderIndex:DWORD
    cmp QueueCount, QUEUE_SIZE
    jae enqueue_done
    mov ebx, QueueTail
    mov eax, orderIndex
    mov [ReadyQueue+ebx], al
    inc ebx
    and ebx, QUEUE_SIZE - 1
    mov QueueTail, ebx
    inc QueueCount
enqueue_done:
    ret
EnqueueOrder ENDP

; ------------------------------------------------------------
; Proc: DequeueOrder
; Input:
;   无
; Output:
;   EAX = 出队订单下标；队列为空时为 INVALID_ORDER
; Clobbers:
;   EAX
; Preserves:
;   EBX
; Side effects:
;   写 ReadyQueue/QueueHead/QueueCount。
; Notes:
;   只维护队列结构，不修改订单状态；调用者要负责把订单标记为 RUN。
; ------------------------------------------------------------
DequeueOrder PROC USES ebx
    cmp QueueCount, 0
    jne can_dequeue
    mov eax, INVALID_ORDER
    ret
can_dequeue:
    mov ebx, QueueHead
    movzx eax, BYTE PTR [ReadyQueue+ebx]
    mov BYTE PTR [ReadyQueue+ebx], 0FFh
    inc ebx
    and ebx, QUEUE_SIZE - 1
    mov QueueHead, ebx
    dec QueueCount
    ret
DequeueOrder ENDP

; ------------------------------------------------------------
; Proc: GetSchedRowText
; Input:
;   rowIndex = 0 表示当前运行行，1..3 表示就绪队列显示行
; Output:
;   EAX = 订单号字符串地址；没有可显示订单时为 DashTextA
; Clobbers:
;   EAX, ECX
; Preserves:
;   EBX
; Side effects:
;   无；只读调度全局状态。
; Notes:
;   只显示就绪队列前三项；更多订单仍在队列里但不会出现在该面板。
; ------------------------------------------------------------
GetSchedRowText PROC USES ebx rowIndex:DWORD
    mov eax, rowIndex
    cmp eax, 0
    jne queued_row
    mov eax, CurrentOrder
    cmp eax, INVALID_ORDER
    je sched_dash
    mov eax, [OrderIdPtrs+eax*4]
    ret
queued_row:
    dec eax
    cmp eax, QueueCount
    jae sched_dash
    mov ebx, QueueHead
    add ebx, eax
    and ebx, QUEUE_SIZE - 1
    movzx eax, BYTE PTR [ReadyQueue+ebx]
    cmp eax, 0FFh
    je sched_dash
    mov eax, [OrderIdPtrs+eax*4]
    ret
sched_dash:
    mov eax, OFFSET DashTextA
    ret
GetSchedRowText ENDP
