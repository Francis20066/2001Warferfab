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
                                                                                                                                       
                                                                                                                                       
                                                                                                                                                                                                      
                                                                     

; 主程序入口与 Win32 消息循环。
; 说明：本工程把其他模块用 include 拼进同一个编译单元，因此这里集中声明常量、原型和入口。
.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\gdi32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib

; ------------------------------------------------------------
; Macro: m2m
; Input:
;   dst = 32 位目标内存/寄存器
;   src = 可被 mov 到 EAX 的 32 位值
; Output:
;   dst = src
; Clobbers:
;   EAX
; Preserves:
;   其他寄存器
; Side effects:
;   修改 dst
; Notes:
;   只适合 DWORD 宽度；不要用它搬 byte/word。
; ------------------------------------------------------------
m2m MACRO dst, src
    mov eax, src
    mov dst, eax
ENDM

WinMain        PROTO :HINSTANCE, :HINSTANCE, :LPSTR, :DWORD
WndProc        PROTO :HWND, :UINT, :WPARAM, :LPARAM
PaintUI        PROTO :HWND, :HDC
DrawPanel      PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
DrawGrid       PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
DrawCellW      PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
DrawCellA      PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
DrawOrderTable PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD
DrawResourceTable PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD
DrawSchedule   PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD
DrawBuffer     PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD
DrawLogs       PROTO :HDC, :DWORD, :DWORD, :DWORD, :DWORD
InitSimulation PROTO
SimTick        PROTO
TryAdmitOrder  PROTO :DWORD
BankerSafe     PROTO
EnqueueOrder   PROTO :DWORD
DequeueOrder   PROTO
ReleaseOrder   PROTO :DWORD
AccessOrderPage PROTO :DWORD
GetStatusText  PROTO :DWORD
GetPriorityText PROTO :DWORD
GetSchedRowText PROTO :DWORD

ID_TIMER       equ 1001
ORDER_COUNT    equ 6
RES_COUNT      equ 3
QUEUE_SIZE     equ 16
CACHE_SIZE     equ 16
INVALID_ORDER  equ 0FFFFFFFFh
STATE_NEW      equ 0
STATE_READY    equ 1
STATE_RUN      equ 2
STATE_DONE     equ 3
STATE_WAIT     equ 4
MENU_SYSTEM    equ 2001
MENU_ORDER     equ 2002
MENU_RESOURCE  equ 2003
MENU_SCHEDULE  equ 2004
MENU_MEMORY    equ 2005
MENU_VIEW      equ 2006
MENU_HELP      equ 2007

.data
include states.asm

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke GetCommandLine
    invoke WinMain, hInstance, NULL, eax, SW_SHOWDEFAULT
    invoke ExitProcess, eax

; ------------------------------------------------------------
; Proc: WinMain
; Input:
;   hInst   = 当前模块句柄
;   hPrev   = Win32 兼容参数，本程序不使用
;   CmdLine = 命令行字符串，本程序不解析
;   CmdShow = 窗口显示方式
; Output:
;   EAX = 消息循环结束时的 wParam，作为进程退出码
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   由 stdcall/局部变量约定维护调用栈
; Side effects:
;   注册窗口类，创建菜单和主窗口，进入消息循环。
; Notes:
;   当前代码没有显式处理 RegisterClassExW/CreateWindowExW 失败的情况。
; ------------------------------------------------------------
WinMain PROC hInst:HINSTANCE, hPrev:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hWnd:HWND
    LOCAL hMenu:HMENU

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInst
    mov wc.hInstance, eax
    invoke LoadIcon, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_BTNFACE + 1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, OFFSET ClassNameW
    invoke RegisterClassExW, ADDR wc

    invoke CreateMenu
    mov hMenu, eax
    invoke AppendMenuA, hMenu, MF_STRING, MENU_SYSTEM, ADDR MenuSystem
    invoke AppendMenuA, hMenu, MF_STRING, MENU_ORDER, ADDR MenuOrder
    invoke AppendMenuA, hMenu, MF_STRING, MENU_RESOURCE, ADDR MenuResource
    invoke AppendMenuA, hMenu, MF_STRING, MENU_SCHEDULE, ADDR MenuSchedule
    invoke AppendMenuA, hMenu, MF_STRING, MENU_MEMORY, ADDR MenuMemory
    invoke AppendMenuA, hMenu, MF_STRING, MENU_VIEW, ADDR MenuView
    invoke AppendMenuA, hMenu, MF_STRING, MENU_HELP, ADDR MenuHelp

    invoke CreateWindowExW, 0, ADDR ClassNameW, ADDR TitleText, \
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 980, 720, \
        NULL, hMenu, hInst, NULL
    mov hWnd, eax
    invoke ShowWindow, hWnd, CmdShow
    invoke UpdateWindow, hWnd

msg_loop:
    invoke GetMessage, ADDR msg, NULL, 0, 0
    cmp eax, 0
    je msg_done
    invoke TranslateMessage, ADDR msg
    invoke DispatchMessage, ADDR msg
    jmp msg_loop
msg_done:
    mov eax, msg.wParam
    ret
WinMain ENDP

; ------------------------------------------------------------
; Proc: WndProc
; Input:
;   hWnd   = 主窗口句柄
;   uMsg   = Win32 消息编号
;   wParam = 消息附加参数
;   lParam = 消息附加参数
; Output:
;   EAX = 0 表示本过程已处理；未处理消息返回 DefWindowProcW 的结果
; Clobbers:
;   EAX, ECX, EDX
; Preserves:
;   由 Win32 窗口过程调用约定处理
; Side effects:
;   WM_CREATE 初始化仿真并启动 1 秒定时器；WM_TIMER 推进一步仿真并触发重绘。
; Notes:
;   定时器频率就是仿真节奏；PaintUI 只读状态，SimTick 负责推进状态。
; ------------------------------------------------------------
WndProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ps:PAINTSTRUCT
    LOCAL hdc:HDC

    .if uMsg == WM_CREATE
        invoke InitSimulation
        invoke SetTimer, hWnd, ID_TIMER, 1000, NULL
        xor eax, eax
        ret
    .elseif uMsg == WM_TIMER
        invoke SimTick
        invoke InvalidateRect, hWnd, NULL, FALSE
        xor eax, eax
        ret
    .elseif uMsg == WM_SIZE
        invoke InvalidateRect, hWnd, NULL, TRUE
        xor eax, eax
        ret
    .elseif uMsg == WM_PAINT
        invoke BeginPaint, hWnd, ADDR ps
        mov hdc, eax
        invoke PaintUI, hWnd, hdc
        invoke EndPaint, hWnd, ADDR ps
        xor eax, eax
        ret
    .elseif uMsg == WM_DESTROY
        invoke KillTimer, hWnd, ID_TIMER
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .endif

    invoke DefWindowProcW, hWnd, uMsg, wParam, lParam
    ret
WndProc ENDP


include ui.asm
include orders.asm
include resources.asm
include scheduler.asm
include banker.asm
include pager.asm

END start
