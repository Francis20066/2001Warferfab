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
                                                                                                                                       
              
; ------------------------------------------------------------
; Module: states.asm
; Input:
;   无；本文件由 main.asm 在 .data 段 include。
; Output:
;   导出 UI 文本、查找表和所有仿真全局状态符号。
; Clobbers:
;   无；这里只有数据定义。
; Preserves:
;   无。
; Side effects:
;   定义可变全局状态，scheduler/banker/pager/ui 会读写这些变量。
; Notes:
;   数组长度必须与 ORDER_COUNT/RES_COUNT/CACHE_SIZE/QUEUE_SIZE 同步。
; ------------------------------------------------------------
hInstance      dd 0

; 宽字符字符串用 UTF-16 code unit 手写，避免源码编码影响中文窗口标题。
ClassNameW     dw 0057h,0061h,0066h,0065h,0072h,0046h,0061h,0062h,0057h,006Eh,0064h,0000h
FaceTahomaW    dw 0054h,0061h,0068h,006Fh,006Dh,0061h,0000h
ButtonClassW   dw 0042h,0055h,0054h,0054h,004Fh,004Eh,0000h
StaticClassW   dw 0053h,0054h,0041h,0054h,0049h,0043h,0000h

; 菜单项使用 ANSI 字符串，因为窗口菜单通过 AppendMenuA 创建。
MenuSystem     db "System",0
MenuOrder      db "Order",0
MenuResource   db "Resource",0
MenuSchedule   db "Schedule",0
MenuMemory     db "Memory",0
MenuView       db "View",0
MenuHelp       db "Help",0

; wsprintfA 的格式串和共享缓冲区；绘制是串行的，所以这些缓冲区可复用。
FmtTime        db "2001-%02u-%02u %02u:%02u:%02u",0
FmtPage        db "P%02u",0
FmtNum         db "%u",0
FmtSec         db "%us",0
FmtFifo        db "FIFO  hit %u  fault %u",0
FmtLru         db "LRU   hit %u  fault %u",0
FmtBufferUsed  db "buffer used %u/%u",0
FmtTick        db "%u",0
FmtLog         db "T%03u  %-8s  %s",0
TimeBuffer     db 64 dup(0)
PageBuffer     db 16 dup(0)
TickBuffer     db 16 dup(0)
NumBuffer      db 64 dup(0)

; 中文 UI 文本：传给 DrawCellW/DrawTextW，末尾必须保留 0000h。
TitleText      dw 06676h,05706h,05382h,08BBEh,05907h,076D1h,063A7h,04E0Eh,08C03h,05EA6h,07CFBh,07EDFh,0000h
OrderListText  dw 08BA2h,05355h,05217h,08868h,0000h
OrderNoText    dw 08BA2h,05355h,053F7h,0000h
StatusText     dw 072B6h,06001h,0000h
PriorityText   dw 04F18h,05148h,07EA7h,0000h
NeedDev0Text   dw 06240h,09700h,08BBEh,05907h,00030h,0000h
NeedDev1Text   dw 06240h,09700h,08BBEh,05907h,00031h,0000h
NeedDev2Text   dw 06240h,09700h,08BBEh,05907h,00032h,0000h
NeedTimeText   dw 06240h,09700h,065F6h,095F4h,0000h
ResListText    dw 08D44h,06E90h,05206h,0914Dh,05217h,08868h,0000h
DevTypeText    dw 08BBEh,05907h,07C7Bh,0578Bh,0000h
TotalText      dw 0603Bh,06570h,0000h
AllocText      dw 05DF2h,05206h,0914Dh,0000h
AvailText      dw 053EFh,07528h,0000h
MaxNeedText    dw 06700h,05927h,09700h,06C42h,0000h
SchedText      dw 08C03h,05EA6h,0961Fh,05217h,0000h
AlgoText       dw 07B97h,06CD5h,0FF1Ah,00020h,065F6h,095F4h,07247h,08F6Eh,08F6Ch,00020h,00028h,00052h,0006Fh,00075h,0006Eh,00064h,00020h,00052h,0006Fh,00062h,00069h,0006Eh,00029h,0000h
SliceText      dw 065F6h,095F4h,07247h,0FF1Ah,00032h,079D2h,0000h
QueueText      dw 0961Fh,05217h,0000h
AxisText       dw 065F6h,095F4h,08F74h,00020h,00028h,00054h,00069h,0006Dh,00065h,00029h,0000h
BufferText     dw 0751Fh,04EA7h,06682h,05B58h,053EFh,089C6h,05316h,0000h
LogText        dw 07CFBh,07EDFh,065E5h,05FD7h,0000h
LogLine1       dw 0542Fh,052A8h,08BBEh,05907h,076D1h,063A7h,07EC8h,07AEFh,0000h
LogLine2       dw 0521Dh,059CBh,05316h,094F6h,0884Ch,05BB6h,07B97h,06CD5h,05B89h,05168h,077E9h,09635h,0000h
LogLine3       dw 08C03h,05EA6h,05668h,08FDBh,05165h,065F6h,095F4h,07247h,08F6Eh,08F6Ch,06A21h,05F0Fh,0000h
LogLine4       dw 0751Fh,04EA7h,06682h,05B58h,0533Ah,05BB9h,091CFh,0FF1Ah,00031h,00036h,09875h,0000h
ParallelLabelW dw 05E76h,0884Ch,05EA6h,0FF1Ah,0000h
Num1W          dw 0031h,0000h
Num2W          dw 0032h,0000h
Num3W          dw 0033h,0000h
Num4W          dw 0034h,0000h
Num5W          dw 0035h,0000h
DashTextW      dw 0002Dh,0002Dh,0000h
Dev0Text       dw 08BBEh,05907h,00030h,0000h
Dev1Text       dw 08BBEh,05907h,00031h,0000h
Dev2Text       dw 08BBEh,05907h,00032h,0000h

Order001       db "ORDER001",0
Order002       db "ORDER002",0
Order003       db "ORDER003",0
Order004       db "ORDER004",0
Order005       db "ORDER005",0
Order006       db "ORDER006",0
ReadyTextA     db "READY",0
NewTextA       db "NEW",0
RunTextA       db "RUN",0
WaitTextA      db "WAIT",0
DoneTextA      db "DONE",0
P0TextA        db "P0",0
P1TextA        db "P1",0
P2TextA        db "P2",0
Num0           db "0",0
Num1           db "1",0
Num2           db "2",0
Num3           db "3",0
Num4           db "4",0
Num5           db "5",0
Num6           db "6",0
Num7           db "7",0
Num8           db "8",0
Num10          db "10",0
Num12          db "12",0
Sec8           db "8s",0
Sec10          db "10s",0
Sec12          db "12s",0
DashTextA      db "--",0
FifoTextA      db "FIFO  hit 71%",0
LruTextA       db "LRU   hit 84%",0
CacheTextA     db "16 block order buffer",0
BufferRuleA    db "READY queue occupies buffer",0
BufferRunRuleA db "RUN releases its block",0
LogInitA       db "simulation initialized",0
LogAdmitA      db "admitted by banker",0
LogWaitResA    db "waiting for resources",0
LogWaitSafeA   db "blocked by safe check",0
LogRunA        db "dispatch to CPU",0
LogDoneA       db "finished and released",0
LogRotateA     db "time slice expired",0
LogIdleA       db "idle: ready queue empty",0

; 显示查找表：用状态值、优先级值或设备编号直接换成字符串地址。
OrderIdPtrs    dd OFFSET Order001, OFFSET Order002, OFFSET Order003
               dd OFFSET Order004, OFFSET Order005, OFFSET Order006
StatusPtrs     dd OFFSET NewTextA, OFFSET ReadyTextA, OFFSET RunTextA
               dd OFFSET DoneTextA, OFFSET WaitTextA
PriorityPtrs   dd OFFSET P0TextA, OFFSET P1TextA, OFFSET P2TextA
DevPtrs        dd OFFSET Dev0Text, OFFSET Dev1Text, OFFSET Dev2Text
ParallelBtnTextPtrs dd OFFSET Num1W, OFFSET Num2W, OFFSET Num3W
                   dd OFFSET Num4W, OFFSET Num5W



; 
OrderPath       db "resource/orders",0
OrderLoadBuffer db 1024 dup(0)



; 算法状态：订单、资源、RR 就绪队列、FIFO/LRU 页面缓存。
; 约定：
;   OrderNeed/OrderAlloc 按订单连续存 3 个资源量，偏移 = orderIndex * RES_COUNT。
;   ReadyQueue 是环形队列，QUEUE_SIZE 必须是 2 的幂，因为入队/出队用 and 做取模。
;   0FFh 表示空缓存帧/空队列槽；INVALID_ORDER 表示当前没有运行订单。
OrderState     db ORDER_COUNT dup(STATE_NEW)
OrderPriority  db 1, 0, 2, 1, 2, 0
OrderNeed      db 1, 0, 2,   2, 1, 1,   0, 1, 2
               db 1, 2, 0,   2, 0, 2,   0, 2, 1
OrderAlloc     db ORDER_COUNT * RES_COUNT dup(0)
OrderTotalTime dd 10, 12, 8, 14, 9, 15
OrderRemain    dd ORDER_COUNT dup(0)
OrderRunTime   dd ORDER_COUNT dup(0)
ResTotal       db 5, 4, 6
ResAvail       db 5, 4, 6
ResMaxDemand   db 0, 0, 0
ReadyQueue     db QUEUE_SIZE dup(0FFh)
QueueHead      dd 0
QueueTail      dd 0
QueueCount     dd 0
CurrentOrder   dd INVALID_ORDER
SliceLeft      dd 0
ParallelLimit  dd 1
RunningOrders  dd MAX_PARALLEL dup(INVALID_ORDER)
RunningSliceLeft dd MAX_PARALLEL dup(0)
NextAdmission  dd 0
SimClock       dd 0
hParallelLabel dd 0
hParallelBtns  dd MAX_PARALLEL dup(0)

FifoFrames     db CACHE_SIZE dup(0FFh)
FifoCursor     dd 0
FifoHits       dd 0
FifoFaults     dd 0
LruFrames      db CACHE_SIZE dup(0FFh)
LruAge         dd CACHE_SIZE dup(0)
LruClock       dd 0
LruHits        dd 0
LruFaults      dd 0
LogHead        dd 0
LogCount       dd 0
LogBuffer      db LOG_COUNT * LOG_LINE_LEN dup(0)

