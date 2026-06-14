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
;   表格固定每页显示 ORDERS_PER_PAGE 条，OrderPage 控制当前页。
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
    LOCAL pageStart:DWORD

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR OrderListText
    mov eax, OrderPage
    inc eax
    invoke wsprintfA, ADDR PageBuffer, ADDR FmtOrderPage, eax, OrderPageCount
    mov eax, rgt
    sub eax, 172
    mov x1, eax
    mov eax, rgt
    sub eax, 74
    mov x2, eax
    mov eax, tp
    add eax, 4
    mov y1, eax
    mov eax, tp
    add eax, 22
    mov y2, eax
    invoke DrawCellA, hdc, ADDR PageBuffer, x1, y1, x2, y2

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

    mov eax, OrderPage
    mov ebx, ORDERS_PER_PAGE
    mul ebx
    mov pageStart, eax
    mov esi, 0
order_row_loop:
    cmp esi, ORDERS_PER_PAGE
    jae order_rows_done
    mov eax, esi
    inc eax
    mul rh
    add eax, gy1
    mov y1, eax
    add eax, rh
    mov y2, eax

    mov edi, pageStart
    add edi, esi
    cmp edi, OrderCount
    jae order_row_empty

    m2m x1, gx1
    mov eax, x1
    add eax, cw
    mov x2, eax
    mov eax, [OrderIdPtrs+edi*4]
    invoke DrawCellA, hdc, eax, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderState+edi]
    invoke GetStatusText, eax
    invoke DrawCellA, hdc, eax, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [OrderPriority+edi]
    invoke GetPriorityText, eax
    invoke DrawCellA, hdc, eax, x1, y1, x2, y2

    mov ebx, edi
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
    mov eax, [OrderRemain+edi*4]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtSec, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    jmp order_row_next
order_row_empty:
    m2m x1, gx1
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellA, hdc, ADDR DashTextA, x1, y1, x2, y2
order_row_next:
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

; ------------------------------------------------------------
; Proc: UpdateOrderPageCount
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, EBX, EDX
; Preserves:
;   ECX, ESI, EDI
; Side effects:
;   根据 OrderCount 重算分页总数，并把 OrderPage 钳制在有效范围内。
; ------------------------------------------------------------
UpdateOrderPageCount PROC USES ecx esi edi
    mov eax, OrderCount
    cmp eax, 0
    jne have_order_count
    mov eax, 1
have_order_count:
    add eax, ORDERS_PER_PAGE - 1
    xor edx, edx
    mov ebx, ORDERS_PER_PAGE
    div ebx
    cmp eax, 1
    jae have_page_count
    mov eax, 1
have_page_count:
    mov OrderPageCount, eax
    mov ebx, OrderPage
    cmp ebx, eax
    jb page_ok
    dec eax
    mov OrderPage, eax
page_ok:
    ret
UpdateOrderPageCount ENDP

; ------------------------------------------------------------
; Proc: InitOrderIdPtrs
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   将 OrderIdPtrs 指向固定长度的 OrderIdStorage 记录。
; ------------------------------------------------------------
InitOrderIdPtrs PROC USES ebx esi edi
    mov esi, 0
    mov edi, OFFSET OrderIdStorage
init_id_ptr_loop:
    cmp esi, ORDER_COUNT
    jae init_id_ptr_done
    mov [OrderIdPtrs+esi*4], edi
    add edi, ORDER_ID_LEN
    inc esi
    jmp init_id_ptr_loop
init_id_ptr_done:
    ret
InitOrderIdPtrs ENDP

; ------------------------------------------------------------
; Proc: SetDefaultOrders
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   写入 6 条默认订单；CSV 打不开或无有效行时使用。
; ------------------------------------------------------------
SetDefaultOrders PROC USES ebx esi edi
    mov OrderCount, DEFAULT_ORDER_COUNT
    mov OrderPage, 0
    mov esi, 0
default_order_loop:
    cmp esi, DEFAULT_ORDER_COUNT
    jae default_order_done
    mov edi, [OrderIdPtrs+esi*4]
    mov eax, esi
    inc eax
    invoke wsprintfA, edi, ADDR FmtOrderId, eax

    mov al, [DefaultPriority+esi]
    mov [OrderPriority+esi], al
    mov ebx, esi
    lea ebx, [ebx+ebx*2]
    mov al, [DefaultNeed+ebx]
    mov [OrderNeed+ebx], al
    mov al, [DefaultNeed+ebx+1]
    mov [OrderNeed+ebx+1], al
    mov al, [DefaultNeed+ebx+2]
    mov [OrderNeed+ebx+2], al
    mov eax, [DefaultTotalTime+esi*4]
    mov [OrderTotalTime+esi*4], eax
    inc esi
    jmp default_order_loop
default_order_done:
    invoke UpdateOrderPageCount
    ret
SetDefaultOrders ENDP

; ------------------------------------------------------------
; Proc: CsvReadNumber
; Input:
;   pCursor    = 当前字段起始位置
;   pOutCursor = DWORD*，返回下一个字段或行尾位置
; Output:
;   EAX = 解析出的无符号整数；EDX = 读到的数字个数
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   写 pOutCursor。
; ------------------------------------------------------------
CsvReadNumber PROC USES ebx esi edi pCursor:DWORD, pOutCursor:DWORD
    mov esi, pCursor
    xor eax, eax
    xor edi, edi
csv_num_skip_left:
    mov bl, [esi]
    cmp bl, 020h
    je csv_num_skip_one
    cmp bl, 009h
    jne csv_num_loop
csv_num_skip_one:
    inc esi
    jmp csv_num_skip_left
csv_num_loop:
    mov bl, [esi]
    cmp bl, 030h
    jb csv_num_done
    cmp bl, 039h
    ja csv_num_done
    mov ecx, eax
    shl eax, 1
    shl ecx, 3
    add eax, ecx
    movzx ecx, bl
    sub ecx, 030h
    add eax, ecx
    inc esi
    inc edi
    jmp csv_num_loop
csv_num_done:
    mov bl, [esi]
    cmp bl, 020h
    je csv_num_trim_one
    cmp bl, 009h
    jne csv_num_after_trim
csv_num_trim_one:
    inc esi
    jmp csv_num_done
csv_num_after_trim:
    cmp bl, 02Ch
    jne csv_num_store_cursor
    inc esi
csv_num_store_cursor:
    mov ebx, pOutCursor
    mov [ebx], esi
    mov edx, edi
    ret
CsvReadNumber ENDP

; ------------------------------------------------------------
; Proc: ParseOrderCsv
; Input:
;   pBuffer = 以 0 结尾的 CSV 文本，格式 id,priority,need0,need1,need2,time
; Output:
;   EAX = 成功读取的订单数
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   写 OrderIdStorage/OrderPriority/OrderNeed/OrderTotalTime。
; ------------------------------------------------------------
ParseOrderCsv PROC USES ebx esi edi pBuffer:DWORD
    LOCAL cursor:DWORD
    LOCAL idDest:DWORD
    LOCAL idLen:DWORD
    LOCAL needBase:DWORD
    LOCAL rowCount:DWORD

    mov esi, pBuffer
    mov rowCount, 0
parse_line_start:
    mov edi, rowCount
    cmp edi, ORDER_COUNT
    jae parse_done
parse_skip_start:
    mov al, [esi]
    cmp al, 0
    je parse_done
    cmp al, 0EFh
    jne parse_not_bom
    add esi, 3
    jmp parse_skip_start
parse_not_bom:
    cmp al, 020h
    je parse_skip_one
    cmp al, 009h
    je parse_skip_one
    cmp al, 00Dh
    je parse_skip_one
    cmp al, 00Ah
    jne parse_after_skip
parse_skip_one:
    inc esi
    jmp parse_skip_start
parse_after_skip:
    cmp al, 023h
    je parse_bad_line
    cmp al, 069h
    je parse_bad_line
    cmp al, 049h
    je parse_bad_line

    mov eax, edi
    mov ebx, ORDER_ID_LEN
    mul ebx
    mov idDest, OFFSET OrderIdStorage
    add idDest, eax
    mov ebx, idDest
    mov idLen, 0
copy_csv_id:
    mov al, [esi]
    cmp al, 0
    je parse_done
    cmp al, 02Ch
    je csv_id_done
    cmp al, 00Dh
    je parse_bad_line
    cmp al, 00Ah
    je parse_bad_line
    mov ecx, idLen
    cmp ecx, ORDER_ID_LEN - 1
    jae csv_id_skip_store
    mov [ebx+ecx], al
    inc idLen
csv_id_skip_store:
    inc esi
    jmp copy_csv_id
csv_id_done:
    mov ecx, idLen
    cmp ecx, 0
    je parse_bad_line
    mov BYTE PTR [ebx+ecx], 0
    inc esi
    mov cursor, esi

    invoke CsvReadNumber, cursor, ADDR cursor
    cmp edx, 0
    je parse_bad_line
    cmp eax, 2
    jbe csv_prio_ok
    mov eax, 2
csv_prio_ok:
    mov edi, rowCount
    mov [OrderPriority+edi], al

    mov ebx, edi
    lea ebx, [ebx+ebx*2]
    mov needBase, ebx

    invoke CsvReadNumber, cursor, ADDR cursor
    cmp edx, 0
    je parse_bad_line
    mov ebx, needBase
    mov [OrderNeed+ebx], al

    invoke CsvReadNumber, cursor, ADDR cursor
    cmp edx, 0
    je parse_bad_line
    mov ebx, needBase
    mov [OrderNeed+ebx+1], al

    invoke CsvReadNumber, cursor, ADDR cursor
    cmp edx, 0
    je parse_bad_line
    mov ebx, needBase
    mov [OrderNeed+ebx+2], al

    invoke CsvReadNumber, cursor, ADDR cursor
    cmp edx, 0
    je parse_bad_line
    mov edi, rowCount
    mov [OrderTotalTime+edi*4], eax
    inc rowCount
    mov esi, cursor
    jmp parse_bad_line

parse_bad_line:
    mov al, [esi]
    cmp al, 0
    je parse_done
    cmp al, 00Ah
    je parse_next_line
    inc esi
    jmp parse_bad_line
parse_next_line:
    inc esi
    jmp parse_line_start
parse_done:
    mov eax, rowCount
    ret
ParseOrderCsv ENDP

; ------------------------------------------------------------
; Proc: LoadOrdersFromCsv
; Input:
;   无
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   初始化订单指针，读取 resource/orders.csv，成功时覆盖默认订单。
; ------------------------------------------------------------
LoadOrdersFromCsv PROC USES ebx esi edi
    LOCAL hFile:DWORD
    LOCAL bytesRead:DWORD

    invoke InitOrderIdPtrs
    invoke SetDefaultOrders

    invoke CreateFileA, ADDR OrderPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hFile, eax
    cmp eax, INVALID_HANDLE_VALUE
    jne csv_opened
    invoke CreateFileA, ADDR OrderBuildPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hFile, eax
    cmp eax, INVALID_HANDLE_VALUE
    jne csv_opened
    invoke CreateFileA, ADDR OrderFallbackPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hFile, eax
    cmp eax, INVALID_HANDLE_VALUE
    je load_csv_done
csv_opened:
    invoke ReadFile, hFile, ADDR OrderLoadBuffer, ORDER_CSV_BUFFER_SIZE - 1, ADDR bytesRead, NULL
    push eax
    invoke CloseHandle, hFile
    pop eax
    cmp eax, 0
    je load_csv_done
    mov eax, bytesRead
    cmp eax, 0
    je load_csv_done
    mov BYTE PTR [OrderLoadBuffer+eax], 0
    invoke ParseOrderCsv, ADDR OrderLoadBuffer
    cmp eax, 0
    je load_csv_done
    mov OrderCount, eax
    mov OrderPage, 0
    invoke UpdateOrderPageCount
load_csv_done:
    ret
LoadOrdersFromCsv ENDP
