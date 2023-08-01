format PE GUI 4.0
stack 0x10000
entry Start

;===============Module incleude================
include "win32a.inc" 
;� ������ ������� ���������� ������ GraficAPI!
include "Grafic\GraficAPI\GraficAPI.asm"
include "Units\Asm_Includes\Const.asm"
include "Units\Movement\keys.code"
include "Units\Movement\move.asm"
include "Units\Movement\Vmove.asm"
;==============================================

section '.text' code readable executable     

Start:
  ;================Module initialize==================
  ;������� ����� ������������������ ������
  ;P.S. ��� ����� ���������������� ��� ������� ������
  stdcall gf_grafic_init
  ;===================================================
  
  ;=============Project data initialize=========================
  ;������ � �������� ������� �������� ��� � �����������
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle
  ;P.S. ��� �������� ������� �� ������ ������(!) �� Handle (dd ?, ?)

  ;����� �������� ������� ����� � ����������� � ������� Handle
  stdcall gf_UploadTexture, tx_grassName 
  mov [tx_grassHandle], eax
  
  stdcall gf_UploadTexture, tx_BOGDAN_Name 
  mov [tx_BOGDANHandle], eax
  
  stdcall Field.Initialize
  
  invoke  ShowCursor, 0
  ;===============================================================
  
  
  
  ;===================Project circle==================
  ;����������� ���� ������� ���������
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
  ;====================================================
            
        
;� ������� ���������� ������� ���������
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        stdcall checkMoveKeys
        stdcall OnMouseMove, �ameraTurn, [sensitivity]
        
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
    
    ;(�������� ������ ���� � ��������� �����)  (������ ��������)
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_grassHandle],\
                            cubePos, cubeTurn, [cubeScale]  
    
    ;� ����� ����� ������� ����� �����:
    stdcall gf_RenderEnd
  ret
endp

  include "Units\Asm_Includes\Code.asm"

section '.data' data readable writeable
         ;����������� ����� ��������� ���������� ���������:
         ;===============Global variables===================
         ;���� � �������� ������������ ������������:
         GF_OBJ_PATH        db     "Assets\ObjectsPack\", 0
         ;���� � ��������� ������������ ������������:
         GF_TEXTURE_PATH    db     "Assets\TexturesPack\", 0
         ;���� � ����� ������� 
         GF_PATH            db     "Grafic\GraficAPI\", 0
         GF_PATH_LEN        db     $ - GF_PATH
         ;===================================================
                  
                  
         ;������ ������:
         ;=======================Project data==========================
         ;�������
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH) (��� .mobj!)
         ;P.S. L - � ������ ��� ���� � ���������� .mobj c uint8
         ;     B - � ������ ��� ���� � ���������� .mobj c uint16
         ;     B - c������ �� ����������� (��� �� �������)
         obj_CubeHandle  dd   ?, ? ;��, ��� ������ 8 ����, ��� �����!!!
         
         ;��������
         tx_grassName    db   "Grass_64.mbmw", 0 ;(GF_TEXTURE_PATH) 
         tx_BOGDAN_Name  db   "BOGDANI_64.mbmw", 0 ;(GF_TEXTURE_PATH) 
         ;texture Handles:
         tx_grassHandle  dd   ?
         tx_BOGDANHandle dd   ?
         
         ;������� �������:
         cubePos         dd   1.0, 5.0, 0.0
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
         ;================================================================
         
         
         ;=======================Global variables 2=======================
         ;���������� ����:
         hHeap           dd         ?
         ;��������� ����:
         WindowRect      RECT       ?, ?, ?, ?
         ;P.S. WindowRect.right - ������ ������ | WindowRect.bottom - ������ ������
         
         WorldLength dd Field.LENGTH ;x
         WorldWidth  dd Field.WIDTH  ;y
         WorldHeight dd Field.HEIGHT ;z
         ;================================================================
         
         ;=============Data imports================
         ;�������� ������� ������ ������ GraficAPI
         include "Grafic\GraficAPI\GraficAPI.inc"
         include "Units\Movement\MConst.asm"   
         ;=========================================   

section '.idata' import data readable writeable

  ;=============Library imports==============
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\    ;1) ;������ ������ ��� GraficAPI ����������!
          gdi32,    'GDI32.DLL'         ;2) 
                                       
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  ;===========Data imports============
  include "Units\Asm_Includes\Di.asm"
  include "Units\Asm_Includes\Du.asm"
