program Step2_ClassWindow;

{$MODE OBJFPC}{$H+}

uses
  Step2_IntWinClass, Exec, AGraphics, Intuition, InputEvent;


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
  Window1   : TIntuitionWindowClass;
  cont      : Boolean;
  msg       : PIntuiMessage;
  buffer    : String[80];
begin
  Window1 := TIntuitionWindowClass.Create;
  Window1.Left   := 10;
  Window1.Top    := 20;
  Window1.Height := 200;
  Window1.Width  := 320;
  Window1.Title  := 'This is window 1';
  Window1.Open;

  WaitPort(Window1.Handle^.UserPort);

  cont := TRUE;

  while (cont) do
  begin
    while true do
    begin
      msg := PIntuiMessage(GetMsg(Window1.Handle^.UserPort));
      if not Assigned(msg) then break;
      
      case (msg^.IClass) of
        IDCMP_CLOSEWINDOW:
          cont := FALSE;
        IDCMP_MOUSEMOVE:
        begin
          WriteStr(buffer, 'Mouseposition: x=', msg^.MouseX, ' y=', msg^.MouseY, #0);
          print_text(Window1.Handle^.RPort, 10, 30, @buffer[1]);
        end;
        IDCMP_MOUSEBUTTONS:
        case (msg^.Code) of
          IECODE_LBUTTON                      : print_text(Window1.Handle^.RPort, 10, 60, 'Left mousebutton pressed');
          IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text(Window1.Handle^.RPort, 10, 60, 'Left mousebutton released');
          IECODE_RBUTTON                      : print_text(Window1.Handle^.RPort, 10, 90, 'Right mousebutton pressed');
          IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text(Window1.Handle^.RPort, 10, 90, 'Right mousebutton released');
        end;
      end; // case
      ReplyMsg(pMessage(msg));
    end;
  end;
  Window1.Close;
  Window1.Free;

  result := (0);
end;


begin
  ExitCode := Main;
end.
