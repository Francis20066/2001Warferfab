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
    sub eax, 320
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
    mov eax, w
    sub eax, 292
    mov textLeft, eax
    mov eax, w
    sub eax, 20
    mov textRight, eax
    invoke DrawCellA, hdc, ADDR TimeBuffer, textLeft, 26, textRight, 62

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
    invoke MoveToEx, hdc, x, tp, NULL
    invoke LineTo, hdc, x, btm
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
    invoke MoveToEx, hdc, lft, y, NULL
    invoke LineTo, hdc, rgt, y
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
; Proc: DrawLogs
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 日志面板矩形
; Output:
;   无；绘制固定的系统日志说明文字
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   无显式保存
; Side effects:
;   调用 DrawPanel/DrawCellW 写入 hdc。
; Notes:
;   日志内容是静态说明，不是逐 tick 的真实事件历史。
; ------------------------------------------------------------
DrawLogs PROC hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL x1:DWORD
    LOCAL x2:DWORD
    LOCAL y1:DWORD
    LOCAL y2:DWORD

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR LogText
    mov eax, lft
    add eax, 18
    mov x1, eax
    mov eax, rgt
    sub eax, 18
    mov x2, eax
    mov eax, tp
    add eax, 34
    mov y1, eax
    mov eax, y1
    add eax, 20
    mov y2, eax
    invoke DrawCellW, hdc, ADDR LogLine1, x1, y1, x2, y2
    mov eax, y2
    add eax, 4
    mov y1, eax
    mov eax, y1
    add eax, 20
    mov y2, eax
    invoke DrawCellW, hdc, ADDR LogLine2, x1, y1, x2, y2
    mov eax, y2
    add eax, 4
    mov y1, eax
    mov eax, y1
    add eax, 20
    mov y2, eax
    invoke DrawCellW, hdc, ADDR LogLine3, x1, y1, x2, y2
    mov eax, y2
    add eax, 4
    mov y1, eax
    mov eax, y1
    add eax, 20
    mov y2, eax
    invoke DrawCellW, hdc, ADDR LogLine4, x1, y1, x2, y2
    ret
DrawLogs ENDP
