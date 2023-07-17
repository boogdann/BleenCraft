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
  
  ;������ � �������� ������� �������� ��� � �����������
  ;stdcall gf_UploadObj3D, obj_cube_name
  mov [obj_CubeHandle], eax
  ;����� �������� ������� ����� � �����������
  ;stdcall gf_UploadTexture, tx_grassName 
  mov [tx_grassHandle], eax
  ;P.S. ����� ��� Handle-� ����� �������������
  
  ;����������� ���� ������� ���������
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  DispatchMessage, msg
        jmp     .MainCycle
        
        
;� ������� ���������� ������� ��������� 
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        ;� �������� ���� �����������) (���� ��� ����)
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


;������ ��������� ��� ������� �����
proc RenderScene
    ;������� ����� ������������������ �������� ������ �����
    stdcall gf_RenderBegin
    ;��� ������� �������:
    ;(�������� ������ ���� � ��������� �����)
    ;stdcall gf_renderObj3D, obj_CubeHandle, tx_grassHandle, ...

    ;� ����� ����� ������� ����� �����:
    stdcall gf_RenderEnd
  ret
endp


section '.data' data readable writeable
         ;������ ������:
         ;�������
         obj_cube_name   db   "Cube.obj", 0
         obj_CubeHandle  dd   ?
         ;��������
         tx_grassName    db   "Grass.png", 0
         tx_grassHandle  dd   ?

         ;�������� ������� ������ ������ GraficAPI
         include "GraficAPI\GraficAPI.inc"            ;1)
         include "GraficAPI\gf_main\gf_api_init.inc"  ;2)  
         include "GraficAPI\gf_main\gf_render_data.inc"  ;3) 

section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\ ;1) ;������ ������ ��� GraficAPI ����������!
          gdi32,    'GDI32.DLL'      ;2)
         

  include 'api\kernel32.inc'
  include 'api\user32.inc'
