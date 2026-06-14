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
                                                                                                                                       
; 公共窗口绘制工具和主界面布局。
; 本文件只负责把当前全局状态画出来，不推进仿真。

; ------------------------------------------------------------
; Proc: PaintUI
; Input:
;   hWnd = 主窗口句柄
;   hdc  = WM_PAINT 中 BeginPaint 得到的设备上下文
; Output:
;   无；完整界面绘制到 hdc
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   创建/选择/删除 GDI 字体和画刷；读取订单、资源、调度、缓存等全局状态。
; Notes:
;   布局按当前窗口大小动态计算；窗口过小时面板会被压缩。
; ------------------------------------------------------------
PaintUI PROC USES ebx esi edi hWnd:HWND, hdc:HDC
    LOCAL rc:RECT
    LOCAL sysTime:SYSTEMTIME
    LOCAL hBrush:HBRUSH
    LOCAL hOldFont:HFONT
    LOCAL hTitleFont:HFONT
    LOCAL hBodyFont:HFONT
    LOCAL hSmallFont:HFONT
    LOCAL w:DWORD
    LOCAL h:DWORD
    LOCAL margin:DWORD
    LOCAL gap:DWORD
    LOCAL row1Top:DWORD
    LOCAL row1Bottom:DWORD
    LOCAL row2Top:DWORD
    LOCAL row2Bottom:DWORD
    LOCAL row3Top:DWORD
    LOCAL row3Bottom:DWORD
    LOCAL row4Top:DWORD
    LOCAL row4Bottom:DWORD
    LOCAL midX:DWORD
    LOCAL rightPanelLeft:DWORD
    LOCAL textLeft:DWORD
    LOCAL textRight:DWORD
    LOCAL textTop:DWORD
    LOCAL textBottom:DWORD
    LOCAL remain:DWORD

    invoke GetClientRect, hWnd, ADDR rc
    mov eax, rc.right
    sub eax, rc.left
    mov w, eax
    mov eax, rc.bottom
    sub eax, rc.top
    mov h, eax

    invoke CreateSolidBrush, 00D6D0C6h
    mov hBrush, eax
    invoke FillRect, hdc, ADDR rc, hBrush
    invoke DeleteObject, hBrush

    invoke SetBkMode, hdc, TRANSPARENT
    invoke CreateFontW, -26, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, DEFAULT_CHARSET, \
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, ADDR FaceTahomaW
    mov hTitleFont, eax
    invoke CreateFontW, -16, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET, \
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, ADDR FaceTahomaW
    mov hBodyFont, eax
    invoke CreateFontW, -13, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET, \
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, ADDR FaceTahomaW
    mov hSmallFont, eax

    mov margin, 12
    mov gap, 10
    mov row1Top, 12
    mov row1Bottom, 70

    mov eax, h
    sub eax, 120
    mov row4Top, eax
    mov eax, h
    sub eax, 12
    mov row4Bottom, eax

    mov eax, row4Top
    sub eax, row1Bottom
    sub eax, 20
    mov remain, eax
    mov eax, remain
    mov ebx, 45
    mul ebx
    mov ebx, 100
    div ebx
    add eax, row1Bottom
    add eax, 10
    mov row2Bottom, eax
    mov eax, row1Bottom
    add eax, 10
    mov row2Top, eax
    mov eax, row2Bottom
    add eax, 10
    mov row3Top, eax
    mov eax, row4Top
    sub eax, 10
    mov row3Bottom, eax

    mov eax, w
    sub eax, 34
    shr eax, 1
    add eax, 12
    mov midX, eax
    mov eax, midX
    add eax, 10
    mov rightPanelLeft, eax

    invoke SelectObject, hdc, hTitleFont
    mov hOldFont, eax
    invoke SetTextColor, hdc, 00242424h
    mov textLeft, 22
    mov textTop, 24
    mov eax, w
    sub eax, 250
    mov textRight, eax
    mov textBottom, 62
    invoke DrawCellW, hdc, ADDR TitleText, textLeft, textTop, textRight, textBottom

    invoke GetLocalTime, ADDR sysTime
    movzx eax, sysTime.wMonth
    movzx ebx, sysTime.wDay
    movzx ecx, sysTime.wHour
    movzx edx, sysTime.wMinute
    movzx esi, sysTime.wSecond
    invoke wsprintfA, ADDR TimeBuffer, ADDR FmtTime, eax, ebx, ecx, edx, esi
    invoke SelectObject, hdc, hSmallFont
    mov eax, w
    sub eax, 230
    cmp eax, 22
    jge time_left_ok
    mov eax, 22
time_left_ok:
    mov textLeft, eax
    mov eax, w
    sub eax, 20
    mov textRight, eax
    invoke SetRect, ADDR rc, textLeft, 26, textRight, 62
    invoke DrawTextA, hdc, ADDR TimeBuffer, -1, ADDR rc, \
        DT_RIGHT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS

    invoke SelectObject, hdc, hSmallFont

    mov eax, midX
    invoke DrawOrderTable, hdc, 12, row2Top, eax, row2Bottom
    mov eax, w
    sub eax, 12
    invoke DrawResourceTable, hdc, rightPanelLeft, row2Top, eax, row2Bottom

    mov eax, midX
    invoke DrawSchedule, hdc, 12, row3Top, eax, row3Bottom
    mov eax, w
    sub eax, 12
    invoke DrawBuffer, hdc, rightPanelLeft, row3Top, eax, row3Bottom

    mov eax, w
    sub eax, 12
    invoke SelectObject, hdc, hBodyFont
    invoke DrawLogs, hdc, 12, row4Top, eax, row4Bottom

    invoke SelectObject, hdc, hOldFont
    invoke DeleteObject, hTitleFont
    invoke DeleteObject, hBodyFont
    invoke DeleteObject, hSmallFont
    ret
PaintUI ENDP

; ------------------------------------------------------------
; Proc: CreateParallelControls
; Input:
;   hWnd = 主窗口句柄
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   创建并行度 radio button 组，默认选中 1。
; ------------------------------------------------------------
CreateParallelControls PROC USES ebx esi hWnd:HWND
    invoke CreateWindowExW, 0, ADDR StaticClassW, ADDR ParallelLabelW, \
        WS_CHILD, 0, 0, 82, 22, hWnd, CTRL_PARALLEL_LABEL, hInstance, NULL
    mov hParallelLabel, eax

    mov esi, 0
create_parallel_loop:
    cmp esi, MAX_PARALLEL
    jae create_parallel_done
    mov eax, [ParallelBtnTextPtrs+esi*4]
    mov ebx, CTRL_PARALLEL_1
    add ebx, esi
    invoke CreateWindowExW, 0, ADDR ButtonClassW, eax, \
        WS_CHILD or BS_AUTORADIOBUTTON, 0, 0, 38, 22, hWnd, ebx, hInstance, NULL
    mov [hParallelBtns+esi*4], eax
    inc esi
    jmp create_parallel_loop
create_parallel_done:
    invoke CheckRadioButton, hWnd, CTRL_PARALLEL_1, CTRL_PARALLEL_5, CTRL_PARALLEL_1
    invoke LayoutParallelControls, hWnd
    invoke ShowWindow, hParallelLabel, SW_SHOW
    mov esi, 0
show_parallel_loop:
    cmp esi, MAX_PARALLEL
    jae show_parallel_done
    mov eax, [hParallelBtns+esi*4]
    invoke ShowWindow, eax, SW_SHOW
    inc esi
    jmp show_parallel_loop
show_parallel_done:
    ret
CreateParallelControls ENDP

; ------------------------------------------------------------
; Proc: LayoutParallelControls
; Input:
;   hWnd = 主窗口句柄
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   根据窗口宽度移动并行度控件。
; ------------------------------------------------------------
LayoutParallelControls PROC USES esi hWnd:HWND
    LOCAL rc:RECT
    LOCAL w:DWORD
    LOCAL h:DWORD
    LOCAL row4Top:DWORD
    LOCAL row2Bottom:DWORD
    LOCAL row3Top:DWORD
    LOCAL midX:DWORD
    LOCAL remain:DWORD
    LOCAL x:DWORD
    LOCAL y:DWORD

    cmp hParallelLabel, 0
    je layout_parallel_done

    invoke GetClientRect, hWnd, ADDR rc
    mov eax, rc.right
    sub eax, rc.left
    mov w, eax
    mov eax, rc.bottom
    sub eax, rc.top
    mov h, eax

    cmp eax, 260
    jae parallel_calc_rows
    mov row3Top, 170
    jmp parallel_rows_done
parallel_calc_rows:
    mov eax, h
    sub eax, 120
    mov row4Top, eax
    mov eax, row4Top
    sub eax, 70
    sub eax, 20
    mov remain, eax
    mov eax, remain
    mov ecx, 45
    mul ecx
    mov ecx, 100
    div ecx
    add eax, 70
    add eax, 10
    mov row2Bottom, eax
    add eax, 10
    mov row3Top, eax
parallel_rows_done:

    mov eax, w
    sub eax, 34
    shr eax, 1
    add eax, 12
    mov midX, eax
    sub eax, 294
    cmp eax, 22
    jge have_parallel_x
    mov eax, 22
have_parallel_x:
    mov x, eax
    mov eax, row3Top
    add eax, 2
    mov y, eax

    invoke MoveWindow, hParallelLabel, x, y, 82, 22, TRUE
    add x, 84
    mov esi, 0
layout_btn_loop:
    cmp esi, MAX_PARALLEL
    jae layout_parallel_done
    mov eax, [hParallelBtns+esi*4]
    invoke MoveWindow, eax, x, y, 38, 22, TRUE
    add x, 40
    inc esi
    jmp layout_btn_loop
layout_parallel_done:
    ret
LayoutParallelControls ENDP

; ------------------------------------------------------------
; Proc: CreateOrderPageControls
; Input:
;   hWnd = 主窗口句柄
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   创建订单列表上一页/下一页按钮；页码由 DrawOrderTable 绘制。
; ------------------------------------------------------------
CreateOrderPageControls PROC hWnd:HWND
    mov hOrderPageLabel, 0
    invoke CreateWindowExW, 0, ADDR ButtonClassW, ADDR PrevPageW, \
        WS_CHILD or BS_PUSHBUTTON, 0, 0, 28, 22, hWnd, CTRL_ORDER_PREV, hInstance, NULL
    mov hOrderPrevBtn, eax
    invoke CreateWindowExW, 0, ADDR ButtonClassW, ADDR NextPageW, \
        WS_CHILD or BS_PUSHBUTTON, 0, 0, 28, 22, hWnd, CTRL_ORDER_NEXT, hInstance, NULL
    mov hOrderNextBtn, eax
    invoke LayoutOrderPageControls, hWnd
    invoke ShowWindow, hOrderPrevBtn, SW_SHOW
    invoke ShowWindow, hOrderNextBtn, SW_SHOW
    ret
CreateOrderPageControls ENDP

; ------------------------------------------------------------
; Proc: LayoutOrderPageControls
; Input:
;   hWnd = 主窗口句柄
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   根据窗口宽度移动订单分页按钮到订单面板标题栏右侧。
; ------------------------------------------------------------
LayoutOrderPageControls PROC USES ebx hWnd:HWND
    LOCAL rc:RECT
    LOCAL x:DWORD
    LOCAL y:DWORD

    cmp hOrderPrevBtn, 0
    je layout_order_page_done

    invoke GetClientRect, hWnd, ADDR rc
    mov eax, rc.right
    sub eax, 34
    shr eax, 1
    add eax, 12
    sub eax, 68
    cmp eax, 120
    jge have_order_page_x
    mov eax, 120
have_order_page_x:
    mov x, eax
    mov y, 82

    invoke MoveWindow, hOrderPrevBtn, x, y, 28, 22, TRUE
    mov eax, x
    add eax, 30
    invoke MoveWindow, hOrderNextBtn, eax, y, 28, 22, TRUE
layout_order_page_done:
    ret
LayoutOrderPageControls ENDP

; ------------------------------------------------------------
; Proc: DrawPanel
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 面板矩形
;   pTitle          = UTF-16 标题字符串地址
; Output:
;   无；画出面板背景、标题栏、边框和标题文字
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX
; Side effects:
;   临时创建画刷和画笔，并改变 hdc 的当前笔/文字颜色。
; Notes:
;   pTitle 必须以 0 结尾；坐标应满足 rgt > lft 且 btm > tp。
; ------------------------------------------------------------
DrawPanel PROC USES ebx hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD, pTitle:DWORD
    LOCAL rc:RECT
    LOCAL hBrush:HBRUSH
    LOCAL hPen:HPEN
    LOCAL hOldPen:HPEN
    LOCAL tx1:DWORD
    LOCAL ty1:DWORD
    LOCAL tx2:DWORD
    LOCAL ty2:DWORD

    invoke SetRect, ADDR rc, lft, tp, rgt, btm
    invoke CreateSolidBrush, 00DDD8CEh
    mov hBrush, eax
    invoke FillRect, hdc, ADDR rc, hBrush
    invoke DeleteObject, hBrush

    mov eax, tp
    add eax, 24
    invoke SetRect, ADDR rc, lft, tp, rgt, eax
    invoke CreateSolidBrush, 00B7B1A7h
    mov hBrush, eax
    invoke FillRect, hdc, ADDR rc, hBrush
    invoke DeleteObject, hBrush

    invoke CreatePen, PS_SOLID, 1, 00807A70h
    mov hPen, eax
    invoke SelectObject, hdc, hPen
    mov hOldPen, eax
    invoke GetStockObject, NULL_BRUSH
    invoke SelectObject, hdc, eax
    invoke Rectangle, hdc, lft, tp, rgt, btm
    invoke SelectObject, hdc, hOldPen
    invoke DeleteObject, hPen

    mov eax, lft
    add eax, 8
    mov tx1, eax
    mov eax, tp
    add eax, 4
    mov ty1, eax
    mov eax, rgt
    sub eax, 8
    mov tx2, eax
    mov eax, tp
    add eax, 22
    mov ty2, eax
    invoke SetTextColor, hdc, 00252525h
    invoke DrawCellW, hdc, pTitle, tx1, ty1, tx2, ty2
    ret
DrawPanel ENDP

; ------------------------------------------------------------
; Proc: DrawCellW
; Input:
;   hdc             = 绘制目标
;   pText           = UTF-16 文本地址
;   lft,tp,rgt,btm = 文本矩形
; Output:
;   无；文本居中绘制，超出时省略
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   无显式保存
; Side effects:
;   调用 DrawTextW 写入 hdc。
; Notes:
;   不负责设置字体/颜色；调用前应已在 hdc 上选好字体。
; ------------------------------------------------------------
DrawCellW PROC hdc:HDC, pText:DWORD, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL rc:RECT
    invoke SetRect, ADDR rc, lft, tp, rgt, btm
    invoke DrawTextW, hdc, pText, -1, ADDR rc, DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS
    ret
DrawCellW ENDP

; ------------------------------------------------------------
; Proc: DrawCellA
; Input:
;   hdc             = 绘制目标
;   pText           = ANSI 文本地址
;   lft,tp,rgt,btm = 文本矩形
; Output:
;   无；文本居中绘制，超出时省略
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   无显式保存
; Side effects:
;   调用 DrawTextA 写入 hdc。
; Notes:
;   不做编码转换；中文文本应使用 DrawCellW。
; ------------------------------------------------------------
DrawCellA PROC hdc:HDC, pText:DWORD, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL rc:RECT
    invoke SetRect, ADDR rc, lft, tp, rgt, btm
    invoke DrawTextA, hdc, pText, -1, ADDR rc, DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS
    ret
DrawCellA ENDP

; ------------------------------------------------------------
; Proc: DrawGrid
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 网格外框
;   cols            = 列数
;   rows            = 行数
; Output:
;   无；在 hdc 上画出完整网格线
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   临时创建画笔并改变 hdc 当前笔。
; Notes:
;   cols 和 rows 不能为 0；宽高太小时整数除法会让线重叠。
; ------------------------------------------------------------
DrawGrid PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD, cols:DWORD, rows:DWORD
    LOCAL hPen:HPEN
    LOCAL hOldPen:HPEN
    LOCAL x:DWORD
    LOCAL y:DWORD
    LOCAL step:DWORD
    LOCAL i:DWORD

    invoke CreatePen, PS_SOLID, 1, 00958F84h
    mov hPen, eax
    invoke SelectObject, hdc, hPen
    mov hOldPen, eax

    mov eax, rgt
    sub eax, lft
    xor edx, edx
    div cols
    mov step, eax
    m2m x, lft
    mov i, 0
v_loop:
    mov eax, i
    cmp eax, cols
    ja v_done
    jne v_draw
    m2m x, rgt
v_draw:
    invoke MoveToEx, hdc, x, tp, NULL
    invoke LineTo, hdc, x, btm
    mov eax, i
    cmp eax, cols
    jae v_done
    mov eax, x
    add eax, step
    mov x, eax
    inc i
    jmp v_loop
v_done:

    mov eax, btm
    sub eax, tp
    xor edx, edx
    div rows
    mov step, eax
    m2m y, tp
    mov i, 0
h_loop:
    mov eax, i
    cmp eax, rows
    ja h_done
    jne h_draw
    m2m y, btm
h_draw:
    invoke MoveToEx, hdc, lft, y, NULL
    invoke LineTo, hdc, rgt, y
    mov eax, i
    cmp eax, rows
    jae h_done
    mov eax, y
    add eax, step
    mov y, eax
    inc i
    jmp h_loop
h_done:
    invoke SelectObject, hdc, hOldPen
    invoke DeleteObject, hPen
    ret
DrawGrid ENDP

; ------------------------------------------------------------
; Proc: AddLogEvent
; Input:
;   eventText  = ANSI 事件文本地址
;   orderIndex = 订单下标，INVALID_ORDER 表示系统事件
; Output:
;   无；把格式化后的日志写入环形缓冲
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   写 LogBuffer/LogHead/LogCount，复用 wsprintfA。
; Notes:
;   日志使用 ANSI 文本，避免源码编码影响中文字符串。
; ------------------------------------------------------------
AddLogEvent PROC USES ebx esi edi eventText:DWORD, orderIndex:DWORD
    mov eax, LogHead
    mov ebx, LOG_LINE_LEN
    mul ebx
    mov edi, OFFSET LogBuffer
    add edi, eax

    mov eax, orderIndex
    cmp eax, OrderCount
    jb log_has_order
    mov esi, OFFSET DashTextA
    jmp log_format
log_has_order:
    mov esi, [OrderIdPtrs+eax*4]
log_format:
    invoke wsprintfA, edi, ADDR FmtLog, SimClock, esi, eventText

    mov eax, LogHead
    inc eax
    cmp eax, LOG_COUNT
    jb log_head_ok
    xor eax, eax
log_head_ok:
    mov LogHead, eax
    mov eax, LogCount
    cmp eax, LOG_COUNT
    jae log_done
    inc eax
    mov LogCount, eax
log_done:
    ret
AddLogEvent ENDP

; ------------------------------------------------------------
; Proc: DrawLogs
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 日志面板矩形
; Output:
;   无；绘制最近的系统事件日志
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   无显式保存
; Side effects:
;   调用 DrawPanel/DrawCellA 写入 hdc。
; Notes:
;   LogBuffer 是环形缓冲；满后从 LogHead 开始读到的就是最旧条目。
; ------------------------------------------------------------
DrawLogs PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL x1:DWORD
    LOCAL x2:DWORD
    LOCAL y1:DWORD
    LOCAL y2:DWORD
    LOCAL lineH:DWORD
    LOCAL idx:DWORD

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR LogText
    mov eax, lft
    add eax, 18
    mov x1, eax
    mov eax, rgt
    sub eax, 18
    mov x2, eax
    mov eax, tp
    add eax, 32
    mov y1, eax
    mov eax, btm
    sub eax, 6
    cmp eax, y1
    jbe logs_done
    sub eax, y1
    xor edx, edx
    mov ebx, LOG_COUNT
    div ebx
    cmp eax, 1
    jae have_log_line_height
    mov eax, 1
have_log_line_height:
    mov lineH, eax

    mov esi, 0
draw_log_loop:
    cmp esi, LogCount
    jae logs_done
    mov eax, LogCount
    cmp eax, LOG_COUNT
    jne log_not_full
    mov eax, LogHead
    add eax, esi
    jmp log_wrap
log_not_full:
    mov eax, esi
log_wrap:
    cmp eax, LOG_COUNT
    jb log_idx_ok
    sub eax, LOG_COUNT
log_idx_ok:
    mov idx, eax
    mov ebx, LOG_LINE_LEN
    mul ebx
    mov edi, OFFSET LogBuffer
    add edi, eax

    mov eax, y1
    add eax, lineH
    dec eax
    mov y2, eax
    invoke DrawCellA, hdc, edi, x1, y1, x2, y2
    mov eax, y1
    add eax, lineH
    mov y1, eax
    inc esi
    jmp draw_log_loop
logs_done:
    ret
DrawLogs ENDP
