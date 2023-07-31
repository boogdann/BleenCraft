format PE GUI 4.0
stack 0x10000
entry Start

;#############Module incleude#################
include "win32a.inc" 
;� ������ ������� ���������� ������ GraficAPI!
include "Grafic\GraficAPI\GraficAPI.asm"
include "Units\Asm_Includes\Const.asm"
include "Units\Movement\keys.code"
include "Units\Movement\move.asm"
;#############################################

section '.text' code readable executable     

Start:
  ;###############Module initialize###################
  ;������� ����� ������������������ ������
  ;P.S. ��� ����� ���������������� ��� ������� ������
  stdcall gf_grafic_init
  ;###################################################
  
  ;##############Project data initialize###############
  ;������ � �������� ������� �������� ��� � �����������
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle
  ;P.S. ������, ��� ��� �������� ������� �� ����� ������ ������ �� Handle (dd ?, ?)

  ;����� �������� ������� ����� � ����������� � ������� Handle
  stdcall gf_UploadTexture, tx_grassName 
  mov [tx_grassHandle], eax
  ;####################################################
  
  stdcall Field.Initialize
  
  ;#################Project circle####################
  ;����������� ���� ������� ���������
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
  ;####################################################
            
        
;� ������� ���������� ������� ���������
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        stdcall checkMoveKeys
        stdcall OnMouseMove, �ameraTurn, 0.01
        
        ;� �������� ���� �����������) (���� ��� ����)
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .KeyDown,       WM_KEYDOWN
        case    .KeyChar,       WM_CHAR
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        ;����� ���������� ��� �� ��� � ������� RenderScene
        ;(��� ����������� ����)
        stdcall RenderScene
        jmp     .ReturnZero
  
  .KeyChar:
        
        stdcall OnCharDown, [wParam]
        
        jmp     .ReturnZero
        
  .KeyDown:
        ;����� �� Esc
        
        stdcall OnKeyDown, [wParam]
        
        jmp     .ReturnZero
 
 .Destroy:
 
        invoke ExitProcess, 1
  
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
    
    ;������ ���������: (LandDataArray - 3-x ������ ������ ���������) (X, Y, Z - �������)
    stdcall gf_RenderMineLand, Field.Blocks, [WorldLength], [WorldWidth], [WorldHeight], obj_CubeHandle
    
    ;��� ������� ���� ��������:
    ;(�������� ������ ���� � ��������� �����)
    ;stdcall gf_renderObj3D, obj_CubeHandle, [tx_grassHandle],\
    ;                        cubePos, cubeTurn, [cubeScale]  
                            
    ;� �������� ������� �������� ����� ������� ���
    ;fld   [cubeTurn + Vector3.y]
    ;fadd  [tmp_turn] 
    ;fstp  [cubeTurn + Vector3.y]
    
    ;� ����� ����� ������� ����� �����:
    stdcall gf_RenderEnd
  ret
endp

  include "Units\Asm_Includes\Code.asm"

section '.data' data readable writeable
         ;����������� ����� ��������� ���������� ���������:
         ;###############Global variables##################
         ;���� � �������� ������������ ������������:
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         ;���� � ��������� ������������ ������������:
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         ;���� � ����� ������� 
         GF_PATH            db     "Grafic\GraficAPI\", 0
         GF_PATH_LEN        db     $ - GF_PATH
         ;################################################# 
                  
                  
         ;������ ������:
         ;####################Project data###########################
         ;�������
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH) (��� .mobj!)
         ;P.S. L - � ������ ��� ���� � ���������� .mobj c uint8
         ;     B - � ������ ��� ���� � ���������� .mobj c uint16
         ;     B - c������ �� ����������� (��� �� �������)
         obj_CubeHandle  dd   ?, ? ;��, ��� ������ 8 ����, ��� �����!!!
         
         ;��������
         tx_grassName    db   "Grass.mbmp", 0 ;(GF_TEXTURE_PATH)
         tx_grassHandle  dd   ?
         
         ;������� �������:
         cubePos         dd   0.0, 0.0, 0.0
         ;������� �������:  (� ��������)
         cubeTurn        dd   0.0, 0.0, 0.0
         ;������ �������:
         cubeScale       dd   0.5

         ;������� ������
         �ameraPos       dd    0.0, 0.0, -4.0
         ;������� ������:  (� ��������)
         �ameraTurn      dd    0.0, 0.0, 0.0 ;(x, y - ���������, z - �� �������������)
         ;P.S. z - ������ ���������� (��� �������� ��-�� ����� ��� ����� � rainbow six siege),
         ;�� �� ����� ���� ������������ ���������� z ��� �������, ��� ��� ������� ���� �� �����
         
         ;��� ������ � ��������� �������
         tmp_turn        dd    0.005
         ;############################################################ 
         
         
         ;####################Global variables 2######################
         ;���������� ����:
         hHeap           dd              ?
         ;��������� ����:
         WindowRect      RECT       ?, ?, ?, ?
         ;P.S. WindowRect.right - ������ ������ | WindowRect.bottom - ������ ������
         
         _isCursor       dd    1
         
         mouse POINT
         ;############################################################
         
         WorldLength dd Field.LENGTH ;x
         WorldWidth  dd Field.WIDTH ;y
         WorldHeight dd Field.HEIGHT ;z
                 
         ;################Data imports#################
         ;�������� ������� ������ ������ GraficAPI
         include "Grafic\GraficAPI\GraficAPI.inc"   
         ;#############################################      

section '.idata' import data readable writeable

  ;################library imports##############
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\ ;1) ;������ ������ ��� GraficAPI ����������!
          gdi32,    'GDI32.DLL', \      ;2) 
          GetCursorPos, 'GetCursorPos'

  include 'api\kernel32.inc'
  include 'api\user32.inc'
  ;################Data imports#################
  include "Units\Asm_Includes\Di.asm"
  include "Units\Asm_Includes\Du.asm"
