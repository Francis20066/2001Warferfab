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
;   无；绘制最近 60 秒内各订单的 READY/RUN 时间轴
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   读取 SchedHistory/OrderIdPtrs/OrderCount；临时创建画刷。
; Notes:
;   横轴固定为最近 60 秒，越靠右越接近当前 tick；纵轴为订单号。
; ------------------------------------------------------------
DrawSchedule PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL gridL:DWORD
    LOCAL gridT:DWORD
    LOCAL gridR:DWORD
    LOCAL gridB:DWORD
    LOCAL gridW:DWORD
    LOCAL rowH:DWORD
    LOCAL hReadyBrush:HBRUSH
    LOCAL hRunBrush:HBRUSH
    LOCAL rc:RECT
    LOCAL x1:DWORD
    LOCAL x2:DWORD
    LOCAL y1:DWORD
    LOCAL y2:DWORD
    LOCAL textL:DWORD
    LOCAL textR:DWORD
    LOCAL slot:DWORD
    LOCAL age:DWORD
    LOCAL base:DWORD

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
    add eax, 86
    mov gridL, eax
    mov eax, tp
    add eax, 74
    mov gridT, eax
    mov eax, rgt
    sub eax, 14
    mov gridR, eax
    mov eax, btm
    sub eax, 30
    mov gridB, eax
    cmp OrderCount, 0
    je draw_schedule_done
    invoke DrawGrid, hdc, gridL, gridT, gridR, gridB, 6, OrderCount
    mov eax, gridR
    sub eax, gridL
    mov gridW, eax
    mov eax, gridB
    sub eax, gridT
    xor edx, edx
    mov ebx, OrderCount
    div ebx
    cmp eax, 1
    jae have_sched_row_h
    mov eax, 1
have_sched_row_h:
    mov rowH, eax

    mov eax, lft
    add eax, 12
    mov textL, eax
    mov eax, gridL
    sub eax, 6
    mov textR, eax

    mov esi, 0
sched_label_loop:
    cmp esi, OrderCount
    jae sched_labels_done
    mov eax, esi
    mul rowH
    add eax, gridT
    mov y1, eax
    add eax, rowH
    mov y2, eax
    mov eax, y2
    cmp eax, gridB
    jbe sched_label_y_ok
    mov eax, gridB
    mov y2, eax
sched_label_y_ok:
    mov eax, [OrderIdPtrs+esi*4]
    invoke DrawCellA, hdc, eax, textL, y1, textR, y2
    inc esi
    jmp sched_label_loop
sched_labels_done:

    invoke CreateSolidBrush, 00D9A55Ch
    mov hReadyBrush, eax
    invoke CreateSolidBrush, 00608048h
    mov hRunBrush, eax

    mov eax, SchedHistoryHead
    cmp eax, 0
    jne sched_have_prev_slot
    mov eax, SCHED_HISTORY_SECONDS
sched_have_prev_slot:
    dec eax
    mov slot, eax
    mov age, 0
sched_age_loop:
    mov eax, age
    cmp eax, SchedHistoryCount
    jae sched_fill_done

    mov eax, age
    mul gridW
    mov ebx, SCHED_HISTORY_SECONDS
    div ebx
    mov ebx, gridR
    sub ebx, eax
    mov x2, ebx
    mov eax, age
    inc eax
    mul gridW
    mov ebx, SCHED_HISTORY_SECONDS
    div ebx
    mov ebx, gridR
    sub ebx, eax
    mov x1, ebx
    cmp ebx, gridL
    jae sched_x1_ok
    mov eax, gridL
    mov x1, eax
sched_x1_ok:
    mov eax, x2
    cmp eax, x1
    ja sched_x_ok
    mov eax, x1
    inc eax
    mov x2, eax
sched_x_ok:
    mov eax, slot
    mov ebx, ORDER_COUNT
    mul ebx
    mov base, eax

    mov esi, 0
sched_order_loop:
    cmp esi, OrderCount
    jae sched_order_done
    mov ebx, base
    mov al, BYTE PTR [SchedHistory+ebx+esi]
    cmp al, STATE_READY
    je sched_fill_ready
    cmp al, STATE_RUN
    je sched_fill_run
    jmp sched_next_order
sched_fill_ready:
    mov edi, hReadyBrush
    jmp sched_have_brush
sched_fill_run:
    mov edi, hRunBrush
sched_have_brush:
    mov eax, esi
    mul rowH
    add eax, gridT
    inc eax
    mov y1, eax
    add eax, rowH
    sub eax, 2
    mov y2, eax
    mov eax, y2
    cmp eax, y1
    ja sched_y_height_ok
    mov eax, y1
    inc eax
    mov y2, eax
sched_y_height_ok:
    mov eax, y2
    cmp eax, gridB
    jbe sched_y_ok
    mov eax, gridB
    mov y2, eax
sched_y_ok:
    invoke SetRect, ADDR rc, x1, y1, x2, y2
    invoke FillRect, hdc, ADDR rc, edi
sched_next_order:
    inc esi
    jmp sched_order_loop
sched_order_done:
    mov eax, slot
    cmp eax, 0
    jne sched_dec_slot
    mov eax, SCHED_HISTORY_SECONDS
sched_dec_slot:
    dec eax
    mov slot, eax
    inc age
    jmp sched_age_loop
sched_fill_done:
    invoke DeleteObject, hReadyBrush
    invoke DeleteObject, hRunBrush

    mov eax, gridB
    add eax, 4
    mov y1, eax
    add eax, 18
    mov y2, eax
    mov eax, gridL
    sub eax, 12
    mov x1, eax
    mov eax, gridL
    add eax, 36
    mov x2, eax
    invoke DrawCellA, hdc, ADDR AxisStartA, x1, y1, x2, y2
    mov eax, gridW
    shr eax, 1
    add eax, gridL
    sub eax, 20
    mov x1, eax
    add eax, 48
    mov x2, eax
    invoke DrawCellA, hdc, ADDR AxisMidA, x1, y1, x2, y2
    mov eax, gridR
    sub eax, 36
    mov x1, eax
    mov eax, gridR
    add eax, 12
    mov x2, eax
    invoke DrawCellA, hdc, ADDR AxisNowA, x1, y1, x2, y2

draw_schedule_done:
    ret
DrawSchedule ENDP

; ------------------------------------------------------------
; Proc: RecordScheduleHistory
; Input:
;   无
; Output:
;   无；把当前 READY/RUN 状态写入 60 秒环形历史
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   写 SchedHistory/SchedHistoryHead/SchedHistoryCount。
; ------------------------------------------------------------
RecordScheduleHistory PROC USES ebx esi edi
    mov eax, SchedHistoryHead
    mov ebx, ORDER_COUNT
    mul ebx
    mov edi, OFFSET SchedHistory
    add edi, eax

    mov esi, 0
sched_hist_clear:
    cmp esi, ORDER_COUNT
    jae sched_hist_scan_begin
    mov BYTE PTR [edi+esi], 0
    inc esi
    jmp sched_hist_clear

sched_hist_scan_begin:
    mov esi, 0
sched_hist_scan:
    cmp esi, OrderCount
    jae sched_hist_advance
    mov al, BYTE PTR [OrderState+esi]
    cmp al, STATE_READY
    je sched_hist_store
    cmp al, STATE_RUN
    je sched_hist_store
    jmp sched_hist_next
sched_hist_store:
    mov BYTE PTR [edi+esi], al
sched_hist_next:
    inc esi
    jmp sched_hist_scan

sched_hist_advance:
    mov eax, SchedHistoryHead
    inc eax
    cmp eax, SCHED_HISTORY_SECONDS
    jb sched_hist_head_ok
    xor eax, eax
sched_hist_head_ok:
    mov SchedHistoryHead, eax
    mov eax, SchedHistoryCount
    cmp eax, SCHED_HISTORY_SECONDS
    jae sched_hist_done
    inc eax
    mov SchedHistoryCount, eax
sched_hist_done:
    ret
RecordScheduleHistory ENDP

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
    invoke LoadOrdersFromCsv
    mov esi, 0
init_orders:
    cmp esi, OrderCount
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
    cmp esi, OrderCount
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
    mov SchedHistoryHead, 0
    mov SchedHistoryCount, 0
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
    mov esi, 0
init_queue_all:
    cmp esi, QUEUE_SIZE
    jae init_queue_all_done
    mov BYTE PTR [ReadyQueue+esi], 0FFh
    inc esi
    jmp init_queue_all
init_queue_all_done:
    mov esi, 0
init_sched_history:
    cmp esi, SCHED_HISTORY_SECONDS * ORDER_COUNT
    jae init_sched_history_done
    mov BYTE PTR [SchedHistory+esi], 0
    inc esi
    jmp init_sched_history
init_sched_history_done:
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
;   推进 SimClock；先调度上一轮暂存订单，运行每个运行槽 1 秒；
;   更新订单暂存、资源分配、订单状态和就绪队列。
; Notes:
;   时间片长度写死为 2 秒；并行槽位数量由 ParallelLimit 控制，
;   本 tick 新接纳的订单留在暂存区，下一 tick 才会被调度，便于可视化等待状态。
; ------------------------------------------------------------
SimTick PROC USES ebx esi edi
    inc SimClock

    invoke FillRunningSlots
    invoke RecordScheduleHistory

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
    cmp esi, OrderCount
    jae admit_done
    mov eax, scanBase
    add eax, esi
    xor edx, edx
    mov ebx, OrderCount
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
        mov ebx, OrderCount
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
;   队列满时先按 LRU 淘汰队首订单；QUEUE_SIZE 必须为 2 的幂，因为用 and 做环形取模。
; ------------------------------------------------------------
EnqueueOrder PROC USES ebx orderIndex:DWORD
    cmp QueueCount, QUEUE_SIZE
    jb enqueue_has_space
    invoke EvictReadyOrder
    cmp eax, INVALID_ORDER
    je enqueue_done
enqueue_has_space:
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
; Proc: EvictReadyOrder
; Input:
;   无
; Output:
;   EAX = 被 LRU 淘汰的订单下标；无可淘汰订单时为 INVALID_ORDER
; Clobbers:
;   EAX
; Preserves:
;   EBX, ESI
; Side effects:
;   从暂存队列移出最久等待订单，释放其已分配资源，并清空生产进度。
; Notes:
;   暂存区只保存 READY 订单；队首就是最久未被调度使用的块。
; ------------------------------------------------------------
EvictReadyOrder PROC USES ebx esi
    invoke DequeueOrder
    cmp eax, INVALID_ORDER
    jne have_lru_victim
    ret
have_lru_victim:
    mov esi, eax
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
    mov eax, [OrderTotalTime+esi*4]
    mov [OrderRemain+esi*4], eax
    mov DWORD PTR [OrderRunTime+esi*4], 0
    mov BYTE PTR [OrderState+esi], STATE_WAIT
    invoke AddLogEvent, ADDR LogLruResetA, esi
    mov eax, esi
    ret
EvictReadyOrder ENDP

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
