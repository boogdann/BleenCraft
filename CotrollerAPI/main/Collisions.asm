proc ct_collisionsBegin uses esi edi, playerPos
  mov esi, [playerPos]
  fld dword[esi]
  fstp [ct_lastPos]
  fld dword[esi + 4]
  fstp [ct_lastPos + 8]
  fld dword[esi + 8]
  fstp [ct_lastPos + 8]
  ret
endp


proc ct_collisionsCheck, playerPos, lastPos, Field, X, Y, Z

  ;������ �������:
  ;1. �� ���� ������ ������ �����������
  ;2. ��������� ����� ������� �� �����, � ����� ��� 
  ;  (�� ����� ������� ����� �� �������) (ct_isJump)
  ;  ct_isJump = 1 - ����� ������� | 0 - ������
  
  ;�������:
  ;� ����� ������� ��������� ����� ��������� ([playerPos])
  ;� � �� ������� ����� ���� � ������� � ���� ���, �� �����
  ;����� ��� ���������� � ������ ��� ������� ��������� 
  ;(100% ��� �������) �������c� � [ct_lastPos]
  ;������ ������ ��������� � ������� ��������� ������
  ;�.�. ���� ������� � "����������� � ���� �����" ���
  ;������ ���� ������ �� ���� � �.�.
  
  ;� ����� �������:
  ;playerPos - ����� ���������������� �������
  ;lastPos - ������ �������������� �������
  ;Field - ������ �� 3-� ������ ������ ��������
  ;X, Y, Z - ������� ��������
   
  ret
endp 


proc ct_fall_check, playerPos
  locals
    g       dd      0.00002
    curTime dd     ?
  endl
  
  invoke GetTickCount
  sub eax, [ct_last_ch_spd]
  cmp eax, 10
  jl @F
    fld  [ct_fall_speed]
    fadd [g]
    fstp [ct_fall_speed]
    mov [ct_last_ch_spd], eax
  @@:
  
  mov esi, [playerPos]
  fld  dword[esi + 4]
  fsub [ct_fall_speed]
  fstp dword[esi + 4]

  ret
endp


;������
proc ct_check_Jump

  locals
      Jump_speed  dd    -0.0007
  endl

  cmp [ct_isJump], 0
  jz @F
  invoke  GetAsyncKeyState, VK_SPACE
  cmp eax, 0
  jz @F
      fld [Jump_speed]
      fstp [ct_fall_speed]
  @@:

  ret
endp