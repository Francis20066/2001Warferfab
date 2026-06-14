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
                                                                                                                                       
; 资源分配表绘制。

; ------------------------------------------------------------
; Proc: DrawResourceTable
; Input:
;   hdc             = 绘制目标
;   lft,tp,rgt,btm = 资源表面板矩形
; Output:
;   无；绘制每类设备的总量、已分配量、可用量和最大需求
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   EBX, ESI, EDI
; Side effects:
;   读取 ResTotal/ResAvail/ResMaxDemand；复用 NumBuffer 格式化数字。
; Notes:
;   假设 RES_COUNT 为 3，网格为 4 行；改资源种类时要同步表格行数。
; ------------------------------------------------------------
DrawResourceTable PROC USES ebx esi edi hdc:HDC, lft:DWORD, tp:DWORD, rgt:DWORD, btm:DWORD
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

    invoke DrawPanel, hdc, lft, tp, rgt, btm, ADDR ResListText
    ; 表格区域 = (lft + 10, tp + 36, rgt - 10, btm - 10)
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
    invoke DrawGrid, hdc, gx1, gy1, gx2, gy2, 5, 4
    ; cw = (gx2 - gx1) / 5
    mov eax, gx2
    sub eax, gx1
    xor edx, edx
    mov ebx, 5
    div ebx
    mov cw, eax
    ; rh = (gy2 - gy1) / 4
    mov eax, gy2
    sub eax, gy1
    xor edx, edx
    mov ebx, 4
    div ebx
    mov rh, eax

    m2m y1, gy1
    ; 表头 y2 = gy1 + rh；每列 x2 = x1 + cw
    mov eax, gy1
    add eax, rh
    mov y2, eax
    m2m x1, gx1
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR DevTypeText, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR TotalText, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR AllocText, x1, y1, x2, y2
    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    invoke DrawCellW, hdc, ADDR AvailText, x1, y1, x2, y2
    m2m x1, x2
    m2m x2, gx2
    invoke DrawCellW, hdc, ADDR MaxNeedText, x1, y1, x2, y2

    mov esi, 0
res_row_loop:
    cmp esi, RES_COUNT
    jae res_rows_done
    ; 第 esi 个资源行：y1 = gy1 + (esi + 1) * rh，y2 = y1 + rh
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
    mov eax, [DevPtrs+esi*4]
    invoke DrawCellW, hdc, eax, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [ResTotal+esi]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [ResTotal+esi]
    movzx ebx, BYTE PTR [ResAvail+esi]
    ; 已分配量 = ResTotal[esi] - ResAvail[esi]
    sub eax, ebx
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    m2m x1, x2
    mov eax, x1
    add eax, cw
    mov x2, eax
    movzx eax, BYTE PTR [ResAvail+esi]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    m2m x1, x2
    m2m x2, gx2
    movzx eax, BYTE PTR [ResMaxDemand+esi]
    invoke wsprintfA, ADDR NumBuffer, ADDR FmtNum, eax
    invoke DrawCellA, hdc, ADDR NumBuffer, x1, y1, x2, y2

    inc esi
    jmp res_row_loop
res_rows_done:
    ret
DrawResourceTable ENDP
