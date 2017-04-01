program ClassWindow;

{$MODE OBJFPC}{$H+}

uses
  Contnrs, SysUtils, IntWinClass, Exec, AGraphics, Intuition, InputEvent;


const
  NumberOfWindows = 10;


procedure print_text(rp: PRastPort; x: LongInt; y: LongInt; txt: PChar);
begin
  GfxMove(rp, x, y);
  SetABPenDrMd(rp, 1, 0, JAM2);
  GfxText(rp, txt, strlen(txt));
  ClearEOL(rp);
end;


//*-------------------------------------------------------------------------*/
//* Window(s) events
//*-------------------------------------------------------------------------*/


procedure DoMouseMove(const IMsg: PIntuiMessage);
var
  buffer    : String[80];
begin
  WriteStr(buffer, 'Mouseposition: x=', IMsg^.MouseX, ' y=', IMsg^.MouseY, #0);
  print_text({$IFDEF AMIGA}PWindow({$ENDIF}IMsg^.IDCMPWindow{$IFDEF AMIGA}){$ENDIF}^.RPort, 10, 30, @buffer[1]);
end;


procedure DoMouseButtons(const IMsg: PIntuiMessage);
begin
  case IMsg^.Code of
    IECODE_LBUTTON                      : print_text({$IFDEF AMIGA}PWindow({$ENDIF}IMsg^.IDCMPWindow{$IFDEF AMIGA}){$ENDIF}^.RPort, 10, 60, 'Left mousebutton pressed');
    IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text({$IFDEF AMIGA}PWindow({$ENDIF}IMsg^.IDCMPWindow{$IFDEF AMIGA}){$ENDIF}^.RPort, 10, 60, 'Left mousebutton released');
    IECODE_RBUTTON                      : print_text({$IFDEF AMIGA}PWindow({$ENDIF}IMsg^.IDCMPWindow{$IFDEF AMIGA}){$ENDIF}^.RPort, 10, 90, 'Right mousebutton pressed');
    IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text({$IFDEF AMIGA}PWindow({$ENDIF}IMsg^.IDCMPWindow{$IFDEF AMIGA}){$ENDIF}^.RPort, 10, 90, 'Right mousebutton released');
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
  Window     : TIntuitionWindowClass;
  Window2Remove : TIntuitionWindowClass;
  WindowList : TObjectList;
  PrgMsgPort : PMsgPort;
  i          : Integer;
  IMsg       : PIntuiMessage;
begin
  WindowList := TObjectList.Create(true);

  PrgMsgPort := CreateMsgPort;
  if Assigned(PrgMsgPort) then
  begin
    (*
      Create and open a bunch of windows and 'collect' them inside
      WindowList.
    *)
    for i := 1 to NumberOfWindows do
    begin
      Window := TIntuitionWindowClass.Create;
      // Set initial dimension, position and title
      Window.Left   := i * 10;
      Window.Top    := i * 20;
      Window.Height := 200;
      Window.Width  := 320;
      Window.Title  := 'This is window ' + IntToStr(i);
      // Assign events
      Window.OnMouseMove    := @DoMouseMove;
      Window.OnMouseButtons := @DoMouseButtons;
      Window.OnCloseWindow  := @DoCloseWindow;
      // Actually open the window
      Window.Open(PrgMsgPort);
      // Add every opened window to the WindowList
      WindowList.Add(Window);
    end;

    (*
      Process messages just as long as there are windows left
      in the WindowList
    *)
    while WindowList.Count > 0 do
    begin
      // Wait for an action to arrive on this port.
      WaitPort(PrgMsgPort);

      while true do
      begin
        // Retrieve a message from the port
        imsg := PIntuiMessage(GetMsg(PrgMsgPort));
        // Oh dear, we've already handled all the messages that were waiting
        // so break the GetMsg()-loop
        if not assigned(imsg) then break;
        // Amiga requires to reply to the message before anything else is done
        // while AROS does not seem to care either way. 
        // (Other implemenation of ReplyMsg() ?)
        ReplyMsg(PMessage(imsg));

        (*
          Figure out for which window this message was ment to be and invoke 
          the HandleMessage() method of the correct/corresponding Window 
          Class. We do this by traversing the WindowList and check whether the
          the IDCMPWindow of the messsage and the Handle property of a 
          TIntuitionWindowClass object in the WindowList 'matches'.
        *)
        for Pointer(Window) in WindowList do
        begin
          if Window.Handle = imsg^.IDCMPWindow then
          (*
            If HandleMessage() returns true then this indicates that a close
            message was received and the window is being closed. Therefor we 
            need to remove the window from the WindowList so that we don't 
            check for it anymore next time we iterate the WindowList.
          *)
          if Window.HandleMessage(imsg)
          (*
            Can't remove from the list exactly here at this point, as it would 
            give an index out of range because of the loop (index) itself.
            Instead we 'mark' the item to be removed. Note that THIS
            ONLY WORKS WHEN _NO_ 2 WINDOWS ARE CLOSED INSIDE THIS ITERATION
            Something that in theory should be impossible.
            In case it does happen we can solve this by marking individual
            items in the list for deletion.
          *)
          then Window2Remove := Window else Window2Remove := nil;
        end;
//        ReplyMsg(PMessage(imsg));

        // Remove window from the list in case it was 'marked' as closed
        if Assigned(Window2Remove) 
          then WindowList.Remove(Window2Remove);
      end;
    end;

    DeleteMsgPort(PrgMsgPort);
  end;

  WindowList.Free;

  result := (0);
end;


begin
  ExitCode := Main;
end.
