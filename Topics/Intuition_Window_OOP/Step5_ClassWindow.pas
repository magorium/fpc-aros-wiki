program Step5_ClassWindow;

{$MODE OBJFPC}{$H+}

uses
  Step5_IntWinClass, Exec, AGraphics, Intuition, InputEvent;


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
//* Window1 events
//*-------------------------------------------------------------------------*/

procedure DoMouseMove(const IMsg: PIntuiMessage);
var
  buffer    : String[80];
begin
  WriteStr(buffer, 'Mouseposition: x=', IMsg^.MouseX, ' y=', IMsg^.MouseY, #0);
  print_text(IMsg^.IDCMPWindow^.RPort, 10, 30, @buffer[1]);
end;


procedure DoMouseButtons(const IMsg: PIntuiMessage);
begin
  case IMsg^.Code of
    IECODE_LBUTTON                      : print_text(IMsg^.IDCMPWindow^.RPort, 10, 60, 'Left mousebutton pressed');
    IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text(IMsg^.IDCMPWindow^.RPort, 10, 60, 'Left mousebutton released');
    IECODE_RBUTTON                      : print_text(IMsg^.IDCMPWindow^.RPort, 10, 90, 'Right mousebutton pressed');
    IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text(IMsg^.IDCMPWindow^.RPort, 10, 90, 'Right mousebutton released');
  end;
end;


procedure DoCloseWindow(var DoClose: boolean);
begin
  DoClose := True;
end;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  Window1   : TIntuitionWindowClass;
begin
  Window1 := TIntuitionWindowClass.Create;
  Window1.Left   := 10;
  Window1.Top    := 20;
  Window1.Height := 200;
  Window1.Width  := 320;
  Window1.Title  := 'This is window 1';
  Window1.OnMouseMove    := @DoMouseMove;
  Window1.OnMouseButtons := @DoMouseButtons;
  Window1.OnCloseWindow  := @DoCloseWindow;
  Window1.Open;

  Window1.HandleMessages;

  Window1.Close;
  Window1.Free;

  result := (0);
end;


begin
  ExitCode := Main;
end.
