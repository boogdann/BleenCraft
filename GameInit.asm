include "Units\Asm_Includes\Const.asm"
include "Units\Asm_Includes\Code.asm"

proc GameStart
  ;================Modules initialize=================
  stdcall Field.Initialize, [WorldPower], [WorldHeight], [WaterLvl], filename 
  mov     eax, [Field.Length]
  mov     [WorldLength], eax
  mov     eax, [Field.Width]
  mov     [WorldWidth], eax
  
  mov     edi, [Field.Blocks]
  add     edi, 10
  mov     byte[edi], 1
  
  xor     edx, edx
  mov     eax, [WorldLength]
  mul     dword[WorldWidth]
  mul     dword[WorldHeight]
  mov     [SizeWorld], eax
  
  mov     ecx, [WorldPower]
  sub     ecx, 2
  stdcall Field.GenerateClouds, ecx, filenameSky
  mov     dword[SkyLand], eax
  mov     eax, [Field.SkyLength]
  mov     [SkyLength], eax
  mov     eax, [Field.SkyWidth]
  mov     [SkyWidth], eax 
  
  xor     edx, edx
  mov     eax, [SkyLength]
  mul     dword[SkyWidth]
  mov     [SizeSky], eax
  
  stdcall Field.GenerateSpawnPoint, cameraPos
  
  ;================Params initialize=====================
  ;????????? ????????????? ???????? ?????????? ????-????
  stdcall gf_UploadObj3D, obj_cube_name, obj_CubeHandle
  ;1 - ??? | 0 - ??????????
  mov [Dayly_Kof], 0
  stdcall gf_subscribeDayly, Dayly_Kof, 1
  ;======================================================
  

  ret
endp


proc RenderScene
    ;?????????????????? ???????? ?????? ?????
    stdcall gf_RenderBegin, cameraPos, cameraTurn
  
    ;?????????????????? ????????? ?????
    ;????????? ???? ???????? ?? 0 - ????? | 1 - ??? ?????
    stdcall gf_CreateLightning, LightsCount, LightsPositions, [UnderWater]
    ;P.S. ??????? ? ?????? ??????????? ???? ? ?????? ???? ???
    ;??????????? ????? ?????????? ? ??????
    
    ;?????? ?????????:
    ;???? ?? ????? (isOnlyWater) - ???????? ??????
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                                               [WorldHeight], cameraPos, cameraTurn, 0
                                                              
    ;===========;???? ? ??????? c????? ??? ???????????================  
    ;????????? ????????: 0-5 ??????? ?????????????                     
    ;stdcall gf_renderObj3D, obj_CubeHandle, [tx_BOGDANHandle], 0,\
    ;                        LightsPositions, cubeTurn, [cubeScale], 3  
                           
    ;?????? ????????????? ????????? ??????????? ??????? (?????? ?????)
    ;stdcall gf_RenderSelectObj3D, obj_CubeHandle,\ 
    ;                        LightsPositions, cubeTurn, [cubeScale] 
    ;P.S. ??? ????????? ??????? ????? ????????? ??????????? ????????!!!
    ;=================================================================    
    
    cmp [flag], 0
    jz @F
    stdcall gf_RenderSelectObj3D, obj_CubeHandle,\ 
                            selectCubeData, cubeTurn, 1.0
    
    @@: 

    ;??????? ?? ????? (isOnlyWater) - ?????? ????                       
    stdcall gf_RenderMineLand, [Field.Blocks], [WorldLength], [WorldWidth],\
                                               [WorldHeight], cameraPos, cameraTurn, 1
    ;?????? ???????
    stdcall gf_renderSkyObjs, [SkyLand], [SkyLength], [SkyWidth], [SkyHieght]
    
    ;????????? ??????? ?????
    stdcall gf_RenderEnd
  ret
endp