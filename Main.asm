format PE GUI 4.0
stack 0x10000
entry Start

;===============Module incleude================
include "win32a.inc" 
include "Grafic\GraficAPI\GraficAPI.asm"
;include "CotrollerAPI\CotrollerAPI.asm"
include "Units\Asm_Includes\Const.asm"

;============For debug=============
include "Units\Movement\keys.code"
include "Units\Movement\move.asm"
include "Units\Movement\Vmove.asm"
;==================================
;==============================================

section '.text' code readable executable     

Start:
  ;================Modules initialize=================
  stdcall gf_grafic_init
  ;===================================================  
  
  ;=============Project data initialize=========================
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle 

  stdcall gf_UploadTexture, tx_grassName, tx_grassHandle 
  stdcall gf_UploadTexture, tx_BOGDAN_Name, tx_BOGDANHandle 
  stdcall gf_UploadTexture, tx_Brick_Name, tx_BrickHandle
  
  stdcall Random.Initialize
  stdcall Field.Initialize, [hHeap], [WorldLength], [WorldWidth], [WorldHeight]
  ;=============================================================
  
  ;================Params initialize=====================
  ;��������� ������������� �������� ���������� ����-����
  ;1 - ��� | 0 - ����������
  stdcall gf_subscribeDayly, Dayly_Kof, 1
  ;======================================================
  
  ;===================Project circle==================
  .MainCycle:
        invoke  GetMessage, msg, 0, 0, 0
        invoke  TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     .MainCycle
  ;====================================================
            
proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        ;stdcall ct_move_check, �ameraPos, �ameraTurn

        stdcall checkMoveKeys
        stdcall OnMouseMove, �ameraTurn, [sensitivity]
        
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        ;case    .Movement,       WM_KEYDOWN
        ;case    .Movement,       WM_CHAR
        ;Debug only:
        case    .KeyDown,       WM_KEYDOWN
        case    .KeyChar,       WM_CHAR
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        ;������
        stdcall RenderScene
        jmp     .ReturnZero
        
  ;============For debug=============      
  .KeyChar:
        ;Debug only:
        stdcall OnCharDown, [wParam]
        jmp     .ReturnZero
  .KeyDown:
        stdcall OnKeyDown, [wParam]
        jmp     .ReturnZero
  ;==================================
  .Movement:
        ;
        jmp     .ReturnZero
  .Destroy:
        invoke ExitProcess, 1
  .ReturnZero:
        xor     eax, eax
  .Return:
        ret
endp



proc RenderScene
    ;������������������ �������� ������ �����
    stdcall gf_RenderBegin, �ameraPos, �ameraTurn
  
    ;������������������ ��������� �����
    ;��������� ���� �������� �� 0 - ����� | 1 - ��� �����
    stdcall gf_CreateLightning, LightsCount, LightsPositions, 0
    ;P.S. ������� � ������ ����������� ���� � ������ ���� ���
    ;����������� ����� ���������� � ������
    
    ;������ ���������:
    ;���� �� ����� (isOnlyWater) - �������� ������
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight], 0
       
    ;===========;���� � ������� c����� ��� �����������================  
    ;��������� ��������: 0-5 ������� �������������                     
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            LightsPositions, cubeTurn, [cubeScale], 3  
                            
    ;������ ������������� ��������� ����������� ������� (������ �����)
    stdcall gf_RenderSelectObj3D, obj_CubeHandle,\ 
                            LightsPositions, cubeTurn, [cubeScale] 
    ;P.S. ��� ��������� ������� ����� ��������� ����������� ��������!!!
    ;=================================================================   
    
    
    ;������� ����� �����!!!!
    ;#################################################################
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            cubePos1, cubeTurn, [cubeScale], 1  
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            cubePos2, cubeTurn, [cubeScale], 2   
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            cubePos3, cubeTurn, [cubeScale], 3  
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            cubePos4, cubeTurn, [cubeScale], 4       
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            cubePos5, cubeTurn, [cubeScale], 5  
    ;#################################################################         
    
                            
    ;������� �� ����� (isOnlyWater) - ������ ����                       
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight], 1
    ;������ �������
    stdcall gf_renderSkyObjs, SkyLand, [SkyLength], [SkyWidth], [SkyHieght]
    
    ;��������� ������� �����
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
                  
                  
         ;=======================Project data==========================
         ;�������
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH)
         obj_CubeHandle  dd   ?, ? ;��, ��� ������ 8 ����
         
         ;��������
         tx_grassName    db   "Grass_64.mbmw", 0 
         tx_BOGDAN_Name  db   "BOGDANI_64.mbmw", 0
         tx_Brick_Name   db   "Brick_64.mbmw", 0
         
         ;texture Handles:
         tx_grassHandle  dd   ?
         tx_BOGDANHandle dd   ?
         tx_BrickHandle  dd   ? 
         
         ;������� �������:
         cubePos         dd   1.0, 5.0, 0.0
         ;������� �������:  (� ��������)
         cubeTurn        dd   0.0, 0.0, 0.0
         ;������ �������:
         cubeScale       dd   1.0

         ;������� ������
         �ameraPos       dd    0.0, 35.0, -4.0
         ;������� ������
         �ameraTurn      dd    0.0, 0.0, 0.0
         
         ;=================Lightning Data==================   
         LightsCount   db    1 ;Byte [0-255]   ;���������� ������
         LightsPositions:
              dd   10.0, 3.0, 7.0  ;��� ����� ���� ��� �����������
              
         ;�������� �� �������� ���������� ����� (���� - ����)     
         Dayly_Kof    dw    0   ;0 - 65535
         ;P.S ������� ����������� ���������� ���� ��� ���������������
         ;��������� ����� ��������� (� ������ (� �� ��� ����������))
         ;================================================================
         
         
         ;=======================Global variables 2=======================
         ;���������� ����:
         hHeap           dd         ?
         ;��������� ����:
         WindowRect      RECT       ?, ?, ?, ?
         ;P.S. WindowRect.right - ������ ������ | WindowRect.bottom - ������ ������
         
         WorldLength dd 100 ;x
         WorldWidth  dd 100  ;y
         WorldHeight dd 60 ;z
         
         ;������ ������ ��� ���� ����������
         SkyLength   dd   10
         SkyWidth    dd   10
         SkyHieght   dd   100
         ;����
         SkyLand  db 1,0,0,0,0,0,0,0,0,0,\ 
                     0,1,1,0,1,0,0,0,1,1,\
                     0,0,0,0,0,1,0,0,1,0,\
                     0,0,0,0,0,0,0,0,0,1,\
                     0,0,0,0,0,0,0,0,0,1,\
                     0,0,0,0,1,1,1,1,0,0,\ 
                     0,0,0,1,1,1,1,1,0,0,\
                     1,1,0,0,0,0,1,1,1,0,\
                     1,1,1,0,1,1,0,0,0,0,\ 
                     1,0,1,0,1,1,1,0,0,0
                     
         ;������� ����� �����!!!!
        ;#############################
        cubePos1         dd    3.0, 3.0, 0.0
        cubePos2         dd    4.5, 3.0, 0.0
        cubePos3         dd    6.0, 3.0, 0.0
        cubePos4         dd    7.5, 3.0, 0.0
        cubePos5         dd    9.0, 3.0, 0.0
        ;#############################
         ;================================================================
         
         ;=============Data imports================
         ;�������� ������� ������ ������ GraficAPI
         include "Grafic\GraficAPI\GraficAPI.inc"
         ;include "CotrollerAPI\CotrollerAPI.inc"
         include "Units\Movement\MConst.asm"  ;;;;;;; 
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
