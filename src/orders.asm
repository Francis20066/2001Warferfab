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
                                                                                                                                       
                                                                                                                                                                                                                                                                              
; 订单列表绘制和订单字段显示辅助函数。

; ------------------------------------------------------------
; Proc: DrawOrderTable
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 订单表面板矩形
; Output:
;   无；绘制订单编号、状态、优先级、三类资源需求和剩余时间
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   读取 OrderState/OrderNeed/OrderRemain 等全局状态；复用 NumBuffer 格式化数字。
; Notes:
;   假设 ORDER_COUNT 为 6，网格为 7 行；改订单数量时要同步表格行数。
; ------------------------------------------------------------
DrawOrderTable PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL gx1:DWORD
    LOCAL gy1:DWORD
    LOCAL gx2:DWORD
    LOCAL gy2:DWORD
    LOCAL cw:DWORD
    LOCAL rh:DWORD
    LOCAL x1:DWORD
    LOCAL x2:DWORD
    LOCAL y1:DWORD
    LOCAL y2:DWORD

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR OrderListText
    mov eax, lft
    add eax, 10
    mov gx1, eax
    mov eax, tp
    add eax, 36
    mov gy1, eax
    mov eax, rgt
    sub eax, 10
    mov gx2, eax
    mov eax, btm
    sub eax, 10
    mov gy2, eax
    invoke DrawGrid, hdc, gx1, gy1, gx2, gy2, 7, 7
    mov eax, gx2
    sub eax, gx1
    xor edx, edx
    mov ebx, 7
    div ebx
    mov cw, eax
    mov eax, gy2
    sub eax, gy1
    xor edx, edx
    mov ebx, 7
    div ebx
    mov rh, eax

    m2m y1, gy1
    mov eax, gy1
    add eax, rh
    mov y2, eax
    m2m x1, gx1
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR OrderNoText, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR StatusText, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR PriorityText, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR NeedDev0Text, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR NeedDev1Text, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR NeedDev2Text, x1, y1, x2, y2
    m2m x1, x2
    m2m x2, gx2
    invoke DrawCellW, hdc, ADDR NeedTimeText, x1, y1, x2, y2

    mov esi, 0
order_row_loop:
    cmp esi, ORDER_COUNT
    jae order_rows_done
    mov eax, esi
    inc eax
    mul rh
    add eax, gy1
    mov y1, eax
    add eax, rh
    mov y2, eax

    m2m x1, gx1
    mov eax, x1
    add eax, cw
    mov x2, eax
    mov eax, [OrderIdPtrs+esi*4]
    invoke DrawCellA, hdc, eax, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderState+esi]
    invoke GetStatusText, eax
    invoke DrawCellA, hdc, eax, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderPriority+esi]
    invoke GetPriorityText, eax
    invoke DrawCellA, hdc, eax, x1, y1, x2, y2

    mov ebx, esi
    lea ebx, [ebx+ebx*2]
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderNeed+ebx]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderNeed+ebx+1]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderNeed+ebx+2]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    m2m x1, x2
    m2m x2, gx2
    mov eax, [OrderRemain+esi*4]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtSec, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    inc esi
    jmp order_row_loop
order_rows_done:

    ret
DrawOrderTable ENDP

; ------------------------------------------------------------
; Proc: GetStatusText
; Input:
;   stateValue = STATE_* 枚举值
; Output:
;   EAX = 对应 ANSI 状态字符串地址
; Clobbers:
;   EAX
; Preserves:
;   EBX, ECX, EDX, ESI, EDI
; Side effects:
;   无
; Notes:
;   非法状态会被钳制为 STATE_WAIT，方便显示但可能掩盖状态写错。
; ------------------------------------------------------------
GetStatusText PROC stateValue:DWORD
    mov eax, stateValue
    cmp eax, STATE_WAIT
    jbe status_ok
    mov eax, STATE_WAIT
status_ok:
    mov eax, [StatusPtrs+eax*4]
    ret
GetStatusText ENDP

; ------------------------------------------------------------
; Proc: GetPriorityText
; Input:
;   priorityValue = 0..2
; Output:
;   EAX = P0/P1/P2 字符串地址
; Clobbers:
;   EAX
; Preserves:
;   EBX, ECX, EDX, ESI, EDI
; Side effects:
;   无
; Notes:
;   非法优先级会被钳制为 2；以后增加优先级档位时要扩展 PriorityPtrs。
; ------------------------------------------------------------
GetPriorityText PROC priorityValue:DWORD
    mov eax, priorityValue
    cmp eax, 2
    jbe prio_ok
    mov eax, 2
prio_ok:
    mov eax, [PriorityPtrs+eax*4]
    ret
GetPriorityText ENDP
