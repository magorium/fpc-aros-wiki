program ShowQualifiers;


{
  Example 1: Show keyboard + mouse qualifiers
  
  Small example showing how to use PeekQualifiers() function. It displays the 
  active qualifiers for keyboard and mouse.
}

{$MODE OBJFPC}{$H+}


Uses
  exec, amigados, input,
  sysutils;


Type
  {$packset 1}
  {$packenum 1}

  TQualifierBits = 
  (
    FIEQUALIFIERB_LSHIFT         , // = 0;
    FIEQUALIFIERB_RSHIFT         , // = 1;
    FIEQUALIFIERB_CAPSLOCK       , // = 2;
    FIEQUALIFIERB_CONTROL        , // = 3;
    FIEQUALIFIERB_LALT           , // = 4;
    FIEQUALIFIERB_RALT           , // = 5;
    FIEQUALIFIERB_LCOMMAND       , // = 6;
    FIEQUALIFIERB_RCOMMAND       , // = 7;
    FIEQUALIFIERB_NUMERICPAD     , // = 8;
    FIEQUALIFIERB_REPEAT         , // = 9;
    FIEQUALIFIERB_INTERRUPT      , // = 10;
    FIEQUALIFIERB_MULTIBROADCAST , // = 11;
    FIEQUALIFIERB_MIDBUTTON      , // = 12;
    FIEQUALIFIERB_RBUTTON        , // = 13;
    FIEQUALIFIERB_LEFTBUTTON     , // = 14;
    FIEQUALIFIERB_RELATIVEMOUSE    // = 15;
  );

  TQualifiers = Set of TQualifierBits;


Function QualsToStr(quals: TQualifiers): String;
Const
  QualifierNames : Array[TQualifierBits] of pchar =
  (
    'LSHIFT', 'RSHIFT',
    'CAPSLOCK',
    'CTRL',
    'LALT', 'RALT',
    'LCOMMAND', 'RCOMMAND',
    'NUMLOCK',
    'REPEAT',
    'INTERRUPT',
    'BROADCAST',
    'MMOUSEBTN',
    'RMOUSEBTN',
    'LMOUSEBTN',
    'MOUSEWHEELBTN'
  );
Var 
  s: String; B: TQualifierBits;
begin
  S := '';
  For B := Low(B) to High(B) do
  begin
    if B in quals then
    begin
      if S <> '' then S := S + '+';
      S := S + QualifierNames[B];
    end;
  end;
  Result := '[' + S + ']';
end;


procedure DoShowQualifiers;
Var
  InputBase : pLibrary absolute input.InputBase;  // Make sure to initialize original library base.
  InputIO   : pIORequest;
  quals     : UWORD;
Var
  mp : pMsgPort;
begin
  mp := CreateMsgPort;
 
  if (mp <> nil) then
  begin
    InputIO := CreateIORequest(mp, sizeof (TIOStdReq));
 
    if (InputIO <> nil) then
    begin
 
      If (0 = OpenDevice('input.device', 0, InputIO, 0)) then
      begin
        WriteLn('checking qualifiers');
        InputBase := pLibrary(InputIO^.io_Device);
 
        If (Inputbase <> nil) then
        begin
          Quals := PeekQualifier;
          WriteLn('Qualifiers (UWORD) = ', QualsToStr(TQualifiers(Quals)));
        end;  
 
        CloseDevice(InputIO);
      end;
 
      DeleteIORequest(InputIO);
    end;
 
    DeleteMsgPort(mp);
  end;
end;
 
 
begin
  WriteLn('enter');

  DoShowQualifiers;

  WriteLn('leave');
end.
