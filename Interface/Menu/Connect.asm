include "..\..\Grafic\GraficAPI\gf_assets\gf_macro.ASM"

proc ui_renderMenuConnect, WindowRect 

  locals
    curBackgroundAdd   dd   ? 
    
      n_TEXT             dd    25.0
      n_2                dd   2.0
      err_text_size      dd   0.005
      textWidth          dd   ?
      textHeight         dd   ?
      textX              dd   ?
  endl

  stdcall gf_2D_Render_Start 
    invoke glColor3f, 1.0, 1.0, 1.0
    stdcall ui_draw_text, [WindowRect], connect_text, [connect_text_len], -0.3, 0.4, 0.006
  
  ;############################################################################
    stdcall ui_render_input, [WindowRect], -0.4, 0.2, 0.8, 0.15,     10, \
                             tcp_port_text, [tcp_port_text_len], ConnectionTcpPort_input
                                          
    stdcall ui_render_input, [WindowRect], -0.4, -0.0, 0.8, 0.15,     11, \
                             udp_port_text, [udp_port_text_len], ConnectionUdpPort_input 
                                          
    stdcall ui_render_input, [WindowRect], -0.4, -0.2, 0.8, 0.15,     12, \
                             input_ip_text, [input_ip_text_len], ConnectionIP_input
  ;############################################################################
  
      ;=========== Error Text ==================
    cmp [connect_error], 0 
    jz .SkipErrorText   
        fld [n_2]
        fdiv [n_TEXT]
        fstp [err_text_size]
        stdcall ui_getTextSizes, [WindowRect], [connect_error_len], [err_text_size]
        mov [textWidth], eax
        mov [textHeight], ecx  
    
        fld [n_2]
        fsub [textWidth]
        fdiv [n_TEXT]
        fstp [textX]
        
       invoke glColor3f, 1.0, 0.3, 0.3
       stdcall ui_draw_text, [WindowRect], [connect_error], [connect_error_len], [textX], -0.6, 0.005
    .SkipErrorText:
    ;=========================================
  
    stdcall ui_drawButton, [WindowRect], -0.3, -0.45, 0.6, 0.2,      2, CONNECT_text, 7
    stdcall ui_drawButton, [WindowRect], -0.9, -0.9, 0.4, 0.15,      3, BACK_text, 4
    
    fld [backGroundAdd]
    fcos 
    fstp [curBackgroundAdd]
    
  stdcall ui_renderBackground, [WindowRect], [curBackgroundAdd]
    

  stdcall gf_2D_Render_End
  
  invoke SwapBuffers, [hdc]
  invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


  ret
endp


proc ui_MenuConnectController uses esi edi, WindowRect
  mov [CurFocus], 0
 
  switch  [Selected_ButtonId]
  case    .Connect,       2
  case    .Exit,          3
  case    .IpFocus,       12
  case    .UdpFocus,      11
  case    .TcpFocus,      10
  jmp     .Return
  
  .Connect:
    ;Connect
    stdcall gf_2D_Render_Start 
    stdcall ui_renderBackground, [WindowRect], 0.0
    stdcall gf_2D_Render_End
    invoke SwapBuffers, [hdc]
    invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
    mov [IS_ONLINE],    TRUE   
    mov [IS_HOST],      FALSE
  
    stdcall CopyConnectionData
    
    mov [App_Mode], GAME_MODE
    stdcall InitWorld
    stdcall GameStart
    
    ;error handler
  jmp .Return   
  .Exit:
    mov [CUR_MENU], UI_MAIN_MENU
  jmp .Return 
  .IpFocus:
     mov [CurFocus], 12
  jmp .Return 
  .UdpFocus:
     mov [CurFocus], 11
  jmp .Return  
  .TcpFocus:
     mov [CurFocus], 10
  jmp .Return   
  
  .Return:
  ret
endp


proc ui_ConnectInputController, wParam
  switch  [CurFocus]
  case    .IpFocus,       12
  case    .UdpFocus,      11
  case    .TcpFocus,      10
  jmp     .Return
  
  .IpFocus:
     stdcall AddLetterToInput, ConnectionIP_input, [wParam], 1, 1
  jmp .Return 
  .UdpFocus:
     mov [MAX_LEN_INPUT], 5
     stdcall AddLetterToInput, ConnectionUdpPort_input, [wParam], 0, 1
     mov [MAX_LEN_INPUT], 15
  jmp .Return  
  .TcpFocus:
     mov [MAX_LEN_INPUT], 5
     stdcall AddLetterToInput, ConnectionTcpPort_input, [wParam], 0, 1
     mov [MAX_LEN_INPUT], 15
  jmp .Return 
  
  .Return:
  ret
endp


proc CopyConnectionData uses esi edi  
    mov edi, ServerIp
    mov esi, ConnectionIP_input
    movzx edx, byte[esi]
    inc esi
    mov ecx, 0
    
    cmp edx, 0
    jz .Skip
    .CopyIpLoop:
        mov al, byte[esi]
        mov byte[edi], al
        inc esi
        inc edi
    inc ecx
    cmp ecx, edx 
    jnz .CopyIpLoop
    mov byte[edi], 0
    .Skip:
    
    stdcall GetNumFromInput, ConnectionUdpPort_input
    mov [ServerPortUDP], eax
    stdcall GetNumFromInput, ConnectionTcpPort_input
    mov [ServerPortTCP], eax
    
    mov esi, ConnectionIP_input 
    mov byte[esi], 0
    mov esi, ConnectionTcpPort_input 
    mov byte[esi], 0
    mov esi, ConnectionUdpPort_input 
    mov byte[esi], 0
     
  ret
endp