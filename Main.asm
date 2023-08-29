format PE GUI 4.0
stack 0x10000
entry Start

;===============Module incleude================
include "win32a.inc" 
include "Grafic\GraficAPI\GraficAPI.asm"
include "CotrollerAPI\CotrollerAPI.asm"
include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"
;==============================================

section '.text' code readable executable     

Start:
    invoke  GetProcessHeap
    mov    [hHeap], eax    
  ;================Modules initialize=================
  stdcall Field.Initialize, [WorldPower] ,[WorldHeight] 
  mov     eax, [Field.Length]
  mov     [WorldLength], eax
  mov     eax, [Field.Width]
  mov     [WorldWidth], eax
      
  stdcall gf_grafic_init
  ;���� = 1 - �������� �����
  stdcall ct_change_mouse, 0
  ;===================================================  
  
  ;=============Project data initialize=========================
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle 

  stdcall gf_UploadTexture, tx_grassName, tx_grassHandle 
  stdcall gf_UploadTexture, tx_BOGDAN_Name, tx_BOGDANHandle 
  stdcall gf_UploadTexture, tx_Brick_Name, tx_BrickHandle
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
     
        stdcall ct_move_check, �ameraPos, �ameraTurn,\
                               [Field.Blocks], [WorldLength], [WorldWidth], [WorldHeight]                      
        ;Debug only:
        ;stdcall checkMoveKeys
        ;stdcall OnMouseMove, �ameraTurn, [sensitivity]
        
        switch  [uMsg]
        case    .Render,        WM_PAINT
        case    .Destroy,       WM_DESTROY
        case    .Movement,      WM_KEYDOWN  
        
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

  .Render:
        
        ;������
        stdcall RenderScene
        
        mov [isFalling], 1
        
        jmp     .ReturnZero
        
        .Movement:
        stdcall ct_on_keyDown, [wParam] 
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
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                                               [WorldHeight], �ameraPos, �ameraTurn, 0
       
    ;===========;���� � ������� c����� ��� �����������================  
    ;��������� ��������: 0-5 ������� �������������                     
    stdcall gf_renderObj3D, obj_CubeHandle, [tx_BrickHandle], 0,\
                            LightsPositions, cubeTurn, [cubeScale], 3  
                            
    ;������ ������������� ��������� ����������� ������� (������ �����)
    stdcall gf_RenderSelectObj3D, obj_CubeHandle,\ 
                            LightsPositions, cubeTurn, [cubeScale] 
    ;P.S. ��� ��������� ������� ����� ��������� ����������� ��������!!!
    ;=================================================================    
                            
    ;������� �� ����� (isOnlyWater) - ������ ����                       
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                                               [WorldHeight], �ameraPos, �ameraTurn, 1
    ;������ �������
    stdcall gf_renderSkyObjs, SkyLand, [SkyLength], [SkyWidth], [SkyHieght]
    
    ;��������� ������� �����
    stdcall gf_RenderEnd
  ret
endp

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
         ;��������������� ����������� �� ��������� ������:
         GF_BLOCKS_RADIUS   dd     400, 400, 40 ;(�� x, y, z)
         ;===================================================
                  
                  
         ;=======================Project data==========================
         ;�������
         obj_cube_name   db   "LCube.mobj", 0 ;(GF_OBJ_PATH)
         obj_CubeHandle  dd   ?, ? ;��, ��� ������ 8 ����
         
         ;��������
         tx_grassName    db   "Grass_64.mbmw", 0 
         tx_BOGDAN_Name  db   "BOGDANI2_64.mbmw", 0
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
         �ameraPos       dd    500.0, 110.0, 500.0
         ;������� ������
         �ameraTurn      dd    0.0, 0.0, 0.0
         
         ;=================Lightning Data==================   
         LightsCount   db    1 ;Byte [0-15]   ;���������� ������
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
         
         WorldPower  dd 10 ; ������ ���� ������� �������� ������
         
         WorldLength dd ? ;x �� �������
         WorldWidth  dd ? ;y
         WorldHeight dd 250  ;z
         
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
         ;================================================================
         
         ;=============Data imports================
         ;�������� ������� ������ ������ GraficAPI
         include "Grafic\GraficAPI\GraficAPI.inc"
         include "CotrollerAPI\CotrollerAPI.inc"
         ;include "Units\Movement\MConst.asm"  
         ;=========================================   

section '.idata' import data readable writeable

  ;=============Library imports==============
  library kernel32, 'KERNEL32.DLL',\
	        user32,   'USER32.DLL',\    
          opengl32, 'opengl32.DLL',\   
          gdi32,    'GDI32.DLL'          
                                       
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  ;===========Data imports============
  include "Units\Asm_Includes\Di.asm"
  include "Units\Asm_Includes\Du.asm"
