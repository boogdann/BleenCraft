format PE GUI 4.0
entry Start

include "win32a.inc" 
;� ������ ������� ���������� ������ GraficAPI!
include "GraficAPI\GraficAPI.asm"

section '.text' code readable executable     

Start:
  ;������� ����� ������������������ ������
  ;P.S. ��� ����� ���������������� ��� ������� ������
  stdcall gf_grafic_init
  stdcall gf_InitShaders
  
  ;����������� ����
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  DispatchMessage, msg
        jmp     .MainCycle
        
        
;� ������� ���������� ������� ��������� 
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        ;� �������� ���� �����������)
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .KeyDown,       WM_KEYDOWN

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

.Render:
        ;����� ���������� ��� �� ��� � ������� RenderScene
        ;(��� ����������� ����) 
        stdcall RenderScene
        jmp     .ReturnZero

.KeyDown:
        ;����� �� Esc
        cmp     [wParam], VK_ESCAPE
        je      .Destroy
        jmp     .ReturnZero

.Destroy:
        invoke  ExitProcess, 0

.ReturnZero:
        xor     eax, eax

.Return:
        ret
endp


;���������� ������ ��� ����� ����������� �������� ����������� ������
proc RenderScene
 
    invoke SwapBuffers, [hdc]
    invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT 
  ret
endp


section '.data' data readable writeable
         ;�������� ������� ������ ������ GraficAPI
         include "GraficAPI\GraficAPI.inc"            ;1)
         include "GraficAPI\gf_main\gf_api_init.inc"  ;2)

section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\ ;1) ;������ ������ ��� GraficAPI ����������!
          gdi32,    'GDI32.DLL'      ;2)
         

  include 'api\kernel32.inc'
  include 'api\user32.inc'
