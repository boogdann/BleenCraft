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
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle, 1
  ;P.S. ������, ��� ��� �������� ������� �� ����� ������ ������ �� Handle (dd ?, ?)
  ;P.S. ������ �������� 
  
  ;������ � ��������� �������!!!
  ;����� �������� ������� ����� � �����������
  ;stdcall gf_UploadTexture, tx_grassName 
  ;mov [tx_grassHandle], eax
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


;(�� ���� ���������� ������������ ��� ������� ���� ��� ������� ����� �
;������� ��� �������� ��� �������� ������, �� ����� �� ����), �� ���� ���
;������ ��������� ��� ������� �����
proc RenderScene
    ;������� ����� ������������������ �������� ������ �����
    stdcall gf_RenderBegin, �ameraPos, �ameraTurn  
    
    ;������ � ��������� �������!!!
    ;����� ����� ������������������ ��������� ����� (���������� ������� ��� �����������!!!)
    ;stdcall gf_CrateLightning, lightningCount, LightPosArray
    
    ;������ � ��������� �������!!!
    ;������ ���������: (LandDataArray - 3-� ������ ������ ���������) (X, Y, Z - �������)
    ;stdcall gf_RenderMineLand, LandDataArray, X, Y, Z
    
    ;��� ������� ���� ��������:
    ;(�������� ������ ���� � ��������� �����)
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_grassHandle],\
                            cubePos, cubeTurn, [cubeScale]  
                            
    ;� �������� ������� �������� ����� ������� ���
    fld   [cubeTurn + Vector3.y]
    fadd  [tmp_turn] 
    fstp  [cubeTurn + Vector3.y]
    
    ;� ����� ����� ������� ����� �����:
    stdcall gf_RenderEnd
  ret
endp


section '.data' data readable writeable
         ;����������� ����� ��������� ���������� ���������:
         ;���� � �������� ������������ ������������:
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         ;���� � ��������� ������������ ������������:
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         
         ;������ ������:
         ;�������
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH) (��� .mobj!)
         ;P.S. L - � ������ ��� ���� � ���������� .mobj c uint8
         ;     B - � ������ ��� ���� � ���������� .mobj c uint16
         ;     B - c������ �� ����������� (��� �� �������)
         obj_CubeHandle  dd   ?, ? ;��, ��� ������ 8 ����, ��� �����!!!
         
         ;��������
         tx_grassName    db   "Grass.png", 0 ;(GF_TEXTURE_PATH)
         tx_grassHandle  dd   ?
         
         ;������� �������:
         cubePos         dd   0.0, 0.0, 0.0
         ;������� �������:  (� ��������)
         cubeTurn        dd   0.0, 0.0, 0.0
         ;������ �������:
         cubeScale       dd   1.0

         ;������� ������
         �ameraPos       dd    0.0, 0.0, -4.0
         ;������� ������:  (� ��������)
         �ameraTurn      dd    0.0, 0.0, 0.0 ;(x, y - ���������, z - �� �������������)
         ;P.S. z - ������ ���������� (��� �������� ��-�� ����� ��� ����� � rainbow six siege),
         ;�� �� ����� ���� ������������ ���������� z ��� �������, ��� ��� ������� ���� �� �����
         
         ;��� ������ � ��������� �������
         tmp_turn        dd    0.005
         

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
