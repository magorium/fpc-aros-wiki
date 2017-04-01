program Step1_SimpleWindow;

{$MODE OBJFPC}{$H+}

Uses
  Exec, AGraphics, Intuition, InputEvent, Utility;


Function AsTag(tag: LongWord): LongInt; inline;
begin
  Result := LongInt(tag);
end;

  
//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure print_text(rp: PRastPort; x: LongInt; y: LongInt; txt: PChar);
begin
  GfxMove(rp, x, y);
  SetABPenDrMd(rp, 1, 0, JAM2);
  GfxText(rp, txt, strlen(txt));
  ClearEOL(rp);
end;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : PWindow;
  cont      : Boolean;
  msg       : PIntuiMessage;
  buffer    : String[80];
begin
  win := OpenWindowTags( nil,
  [
    AsTag(WA_Left)         , 100,
    AsTag(WA_Top)          , 100,
    AsTag(WA_Width)        , 250,
    AsTag(WA_Height)       , 150,
    AsTag(WA_Flags)        , AsTag(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH or WFLG_RMBTRAP or WFLG_REPORTMOUSE),
    AsTag(WA_IDCMP)        , AsTag(IDCMP_CLOSEWINDOW or IDCMP_MOUSEMOVE or IDCMP_MOUSEBUTTONS),
    TAG_END
  ]);
  
  if Assigned(win) then
  begin
    cont := TRUE;

    while (cont) do
    begin
      WaitPort(win^.UserPort);
      while true do
      begin
        msg := PIntuiMessage(GetMsg(win^.UserPort));
        if not Assigned(msg) then break;
      
        case (msg^.IClass) of
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
          IDCMP_MOUSEMOVE:
          begin
            WriteStr(buffer, 'Mouseposition: x=', msg^.MouseX, ' y=', msg^.MouseY, #0);
            print_text(win^.RPort, 10, 30, @buffer[1]);
          end;
          IDCMP_MOUSEBUTTONS:
          case (msg^.Code) of
            IECODE_LBUTTON                      : print_text(win^.RPort, 10, 60, 'Left mousebutton pressed');
            IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text(win^.RPort, 10, 60, 'Left mousebutton released');
            IECODE_RBUTTON                      : print_text(win^.RPort, 10, 90, 'Right mousebutton pressed');
            IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text(win^.RPort, 10, 90, 'Right mousebutton released');
          end;
        end; // case
        ReplyMsg(pMessage(msg));
      end;
    end; // while
    CloseWindow(win);
  end;

  result := (0);
end;

begin
  ExitCode := Main;
end.