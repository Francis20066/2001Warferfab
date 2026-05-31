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
                                                                                                                                       
                                                                                                                                                                                                                                                                           
; FIFO/LRU 页面置换仿真和缓存可视化。

; ------------------------------------------------------------
; Proc: DrawBuffer
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 缓存面板矩形
; Output:
;   无；绘制 4x4 FIFO 缓存帧和 FIFO/LRU 命中/缺页计数
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   读取 FifoFrames/FifoHits/FifoFaults/LruHits/LruFaults；复用 PageBuffer/NumBuffer。
; Notes:
;   可视化网格只展示 FIFO 帧；LRU 只展示统计数字，不展示 LruFrames 的具体内容。
; ------------------------------------------------------------
DrawBuffer PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
    LOCAL gridL:DWORD
    LOCAL gridT:DWORD
    LOCAL cell:DWORD
    LOCAL x1:DWORD
    LOCAL y1:DWORD
    LOCAL x2:DWORD
    LOCAL y2:DWORD
    LOCAL idx:DWORD
    LOCAL row:DWORD
    LOCAL col:DWORD
    LOCAL hBrush:HBRUSH
    LOCAL rc:RECT

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR BufferText
    mov eax, lft
    add eax, 24
    mov gridL, eax
    mov eax, tp
    add eax, 42
    mov gridT, eax
    mov eax, btm
    sub eax, gridT
    sub eax, 38
    shr eax, 2
    cmp eax, 34
    jae have_cell
    mov eax, 34
have_cell:
    mov cell, eax

    mov idx, 0
    mov row, 0
row_loop:
    mov col, 0
col_loop:
    mov eax, col
    mul cell
    add eax, gridL
    mov x1, eax
    mov eax, row
    mul cell
    add eax, gridT
    mov y1, eax
    mov eax, x1
    add eax, cell
    sub eax, 4
    mov x2, eax
    mov eax, y1
    add eax, cell
    sub eax, 4
    mov y2, eax

    mov eax, idx
    and eax, 1
    .if eax == 0
        invoke CreateSolidBrush, 00C7D8BDh
    .else
        invoke CreateSolidBrush, 00D6C7AEh
    .endif
    mov hBrush, eax
    invoke SetRect, ADDR rc, x1, y1, x2, y2
    invoke FillRect, hdc, ADDR rc, hBrush
    invoke DeleteObject, hBrush
    invoke Rectangle, hdc, x1, y1, x2, y2
    mov esi, idx
    movzx eax, BYTE PTR [FifoFrames+esi]
    cmp eax, 0FFh
    jne frame_has_page
    invoke DrawCellA, hdc, ADDR DashTextA, x1, y1, x2, y2
    jmp frame_label_done
frame_has_page:
    invoke wsprintfA, ADDR PageBuffer, ADDR FmtPage, eax
    invoke DrawCellA, hdc, ADDR PageBuffer, x1, y1, x2, y2
frame_label_done:

    inc idx
    inc col
    cmp col, 4
    jl col_loop
    inc row
    cmp row, 4
    jl row_loop

    mov eax, lft
    add eax, 260
    mov x1, eax
    mov eax, rgt
    sub eax, 14
    mov x2, eax
    mov eax, tp
    add eax, 58
    mov y1, eax
    mov eax, y1
    add eax, 24
    mov y2, eax
    invoke DrawCellA, hdc, ADDR CacheTextA, x1, y1, x2, y2
    mov eax, y2
    add eax, 18
    mov y1, eax
    mov eax, y1
    add eax, 24
    mov y2, eax
    mov eax, FifoHits
    mov ebx, FifoFaults
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtFifo, eax, ebx
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2
    mov eax, y2
    add eax, 8
    mov y1, eax
    mov eax, y1
    add eax, 24
    mov y2, eax
    mov eax, LruHits
    mov ebx, LruFaults
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtLru, eax, ebx
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2
    ret
DrawBuffer ENDP

; ------------------------------------------------------------
; Proc: AccessOrderPage
; Input:
;   orderIndex = 当前运行订单下标
; Output:
;   无
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   按伪页面访问序列更新 FIFO/LRU 缓存帧、替换指针、年龄戳和命中/缺页计数。
; Notes:
;   pageId 由 orderIndex 和 SimClock 生成，并非真实内存访问轨迹；
;   CACHE_SIZE 必须为 2 的幂以配合 FIFO 指针取模。
; ------------------------------------------------------------
AccessOrderPage PROC USES ebx esi edi orderIndex:DWORD
    LOCAL pageId:DWORD
    LOCAL victim:DWORD
    LOCAL minAge:DWORD

    mov eax, orderIndex
    mov ebx, 7
    mul ebx
    add eax, SimClock
    and eax, 31
    mov pageId, eax

    mov esi, 0
fifo_find:
    cmp esi, CACHE_SIZE
    jae fifo_miss
    movzx eax, BYTE PTR [FifoFrames+esi]
    cmp eax, pageId
    je fifo_hit
    inc esi
    jmp fifo_find
fifo_hit:
    inc FifoHits
    jmp lru_part
fifo_miss:
    inc FifoFaults
    mov esi, 0
fifo_free:
    cmp esi, CACHE_SIZE
    jae fifo_replace
    cmp BYTE PTR [FifoFrames+esi], 0FFh
    je fifo_store
    inc esi
    jmp fifo_free
fifo_replace:
    mov esi, FifoCursor
    mov eax, FifoCursor
    inc eax
    and eax, CACHE_SIZE - 1
    mov FifoCursor, eax
fifo_store:
    mov eax, pageId
    mov [FifoFrames+esi], al

lru_part:
    inc LruClock
    mov esi, 0
lru_find:
    cmp esi, CACHE_SIZE
    jae lru_miss
    movzx eax, BYTE PTR [LruFrames+esi]
    cmp eax, pageId
    je lru_hit
    inc esi
    jmp lru_find
lru_hit:
    inc LruHits
    mov eax, LruClock
    mov [LruAge+esi*4], eax
    ret
lru_miss:
    inc LruFaults
    mov esi, 0
lru_free:
    cmp esi, CACHE_SIZE
    jae lru_pick_victim
    cmp BYTE PTR [LruFrames+esi], 0FFh
    je lru_store
    inc esi
    jmp lru_free
lru_pick_victim:
    mov esi, 0
    mov victim, 0
    mov eax, [LruAge]
    mov minAge, eax
    mov edi, 1
lru_victim_loop:
    cmp edi, CACHE_SIZE
    jae lru_victim_done
    mov eax, [LruAge+edi*4]
    cmp eax, minAge
    jae lru_victim_next
    mov minAge, eax
    mov victim, edi
lru_victim_next:
    inc edi
    jmp lru_victim_loop
lru_victim_done:
    mov esi, victim
lru_store:
    mov eax, pageId
    mov [LruFrames+esi], al
    mov eax, LruClock
    mov [LruAge+esi*4], eax
    ret
AccessOrderPage ENDP
