unit IntWinClass;

{$MODE OBJFPC}{$H+}

interface

uses
  Contnrs, Intuition, Exec;

type
  TIntuitionMessageRec = record
    MsgCode : DWord;
    IMsg    : PIntuiMessage;
  end;

type
  TOnCloseWindowProc  = procedure(var DoClose: boolean);
  TOnMouseMoveProc    = procedure(const IMsg: PIntuiMessage);
  TOnMouseButtonsProc = procedure(const IMsg: PIntuiMessage);


  TIntuitionWindowClass = class
   private      // variables
    FHandle  : PWindow;
    FLeft    : LongInt;
    FTop     : LongInt;
    FWidth   : LongInt;
    FHeight  : LongInt;
    FTitle   : AnsiString;
    FStopped : boolean;
   private      // events
    FOnCloseWindow  : TOnCloseWindowProc;
    FOnMouseMove    : TOnMouseMoveProc;
    FOnMouseButtons : TOnMouseButtonsProc;
   protected
    procedure MsgCloseWindow(var msg: TIntuitionMessageRec); Message IDCMP_CLOSEWINDOW;
    procedure MsgMouseMove(var msg: TIntuitionMessageRec); Message IDCMP_MOUSEMOVE;
    procedure MsgMouseButtons(var msg: TIntuitionMessageRec); Message IDCMP_MOUSEBUTTONS;
   public       // creator/destructor
    constructor Create;  
    destructor  Destroy; override;
   public       // methods
    procedure Open(port: PMsgPort); // procedure Open;
    procedure Close;
    procedure CloseWindowSafely;
    function  HandleMessage(IMsg: PIntuiMessage): boolean;

    procedure DefaultHandler(var message); override;
   public       // properties
    property Left   : LongInt read FLeft   write FLeft;
    property Top    : LongInt read FTop    write FTop;
    property Width  : LongInt read FWidth  write FWidth;
    property Height : LongInt read FHeight write FHeight;
    property Title  : String  read FTitle  write FTitle;
    property Handle : PWindow read FHandle;
   public       // events
    property OnCloseWindow  : TOnCloseWindowProc  read FOnCloseWindow  write FOnCloseWindow;
    property OnMouseMove    : TOnMouseMoveProc    read FOnMouseMove    write FOnMouseMove;
    property OnMouseButtons : TOnMouseButtonsProc read FOnMouseButtons write FOnMouseButtons;
  end;


implementation

uses
  SysUtils, AGraphics, InputEvent{$IFDEF AMIGA}, Utility{$ENDIF};


// Some stuff that is missing from 3.0.x compiler but is present in trunk (3.1.1)
{$IF (FPC_FULLVERSION < 30101)}
{$IFDEF AMIGA}
function  OpenWindowTags(NewWindow: PNewWindow; const TagArray: Array of PtrUInt): PWindow; inline;
begin
  OpenWindowTags := OpenWindowTagList(NewWindow, @TagArray);
end;
{$ENDIF}

{$IFDEF AMIGA}
function AsTag(tag: LongInt): LongWord; inline;
begin
  Result := LongWord(tag);
end;

function AsTag(tag: PChar): LongWord; inline;
begin
  Result := LongWord(Tag);
end;
{$ENDIF}

{$IFDEF AROS}
function AsTag(tag: LongWord): LongInt; inline;
begin
  Result := LongInt(tag);
end;

function AsTag(tag: PChar): LongInt; inline;
begin
  Result := LongInt(Tag);
end;
{$ENDIF}
{$ENDIF}


procedure error(Const msg : string);  
begin  
  raise exception.create(Msg) at  
    get_caller_addr(get_frame),  
    get_caller_frame(get_frame);  
end;  


Constructor TIntuitionWindowClass.Create;
begin
  Inherited;
  
  FHandle := nil;
  FLeft   := 10;
  FTop    := 10;
  FHeight := 30;
  FWidth  := 30;
  FTitle  := '';
  FStopped := false;
end;


Destructor TIntuitionWindowClass.Destroy;
begin
  inherited;
end;


(*
  Method Open() now requires a port to which it must listen to as we
  cannot use the automatically by intuition created port anymore because
  every window is now using the same userport. e.g. Application's port.
  Another solution could pehaps be to use a named port based on execetable
  name, which would then offer the possibillity to omit the parameter again.
*)
procedure TIntuitionWindowClass.Open(port: PMsgPort);
var
  aTitle : PChar;
begin
  if FTitle <> '' then aTitle := PChar(FTitle) else aTitle := nil;

  FHandle := OpenWindowTags( nil,
  [
    AsTag(WA_Left)        , FLeft,
    AsTag(WA_Top)         , FTop,
    AsTag(WA_Width)       , FWidth,
    AsTag(WA_Height)      , FHeight,
    AsTag(WA_Title)       , AsTag(aTitle),
    // Non use settable flags (for now)
    AsTag(WA_Flags)       , AsTag(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH or WFLG_RMBTRAP or WFLG_REPORTMOUSE),
    TAG_END
  ]);
  if not Assigned(FHandle) then Error('Unable to Open Window');
  
  (*
    Use main program provided port
  *)
  FHandle^.UserPort := Port;
  (*
    Because IDMCP flags were omitted form creation, we still need to 'add' those
    flags for message that we're interested in receiving.
  *)
  ModifyIDCMP(FHandle,  AsTag(IDCMP_CLOSEWINDOW or IDCMP_MOUSEMOVE or IDCMP_MOUSEBUTTONS));
end;


procedure TIntuitionWindowClass.Close;
begin
  if Assigned(FHandle) 
  then CloseWindowSafely // Intuition.CloseWindow(FHandle)
  else Error('Unable to Close Window because the handle is invalid');
end;


(*
  http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_3._guide/node03A0.html
  function CloseWindow() from RKRM states:
  When this function is called, all IDCMP messages which have been sent
  to your window are deallocated.  If the window had shared a message
  Port with other windows, you must be sure that there are no unreplied
  messages for this window in the message queue.  Otherwise, your program
  will try to make use of a linked list (the queue) which contains free
  memory (the old messages).  This will give you big problems.
  See the code fragment CloseWindowSafely(), below.
*)
(*
  CloseWindowSafely from RKRM:
  Strip all IntuiMessages from an IDCMP which are waiting for a specific
  window.  When the messages are gone, set the UserPort of the window to
  NULL and call ModifyIDCMP(win,0).  This will free the Intuition parts of
  the IDMCMP and turn off message to this port without changing the
  original UserPort (which may be in use by other windows).  
*)
procedure TIntuitionWindowClass.CloseWindowSafely;
var
  port : PMsgPort;
  succ : PNode;
  imsg : PIntuiMessage;
begin
  //* we forbid here to keep out of race conditions with Intuition */
  Forbid;

  //* shortcut to the message port
  port := FHandle^.UserPort;

  //* Strip Intuition messages *//
  (* 
    remove and reply to all IntuiMessages on a port that have been
    sent to a particular window (note that we don't rely on the ln_Succ
    pointer of a message after we have replied it)
  *)
  imsg := PIntuiMessage(port^.mp_MsgList.lh_Head);
  while true do
  begin
    succ := imsg^.ExecMessage.mn_Node.ln_Succ;
    if not Assigned(succ) then break;
        
    if imsg^.IDCMPWindow = FHandle then
    begin
      (*
        Intuition is about to free this message.
        Make sure that we have politely sent it back.
      *)
      Remove(PNode(imsg));
      ReplyMsg(PMessage(imsg));
    end;
    imsg := PIntuiMessage(succ);
  end;

  //* clear UserPort so Intuition will not free it */
  FHandle^.UserPort := nil;

  //* tell Intuition to stop sending more messages */
  ModifyIDCMP(FHandle, 0);

  //* turn multitasking back on */
  Permit;

  //* Now it's safe to really close the window */
  CloseWindow(FHandle);
  
  // ... and make sure our handle is cleared
  FHandle := nil;
end;


function  TIntuitionWindowClass.HandleMessage(IMsg: PIntuiMessage): boolean;
var
  msgrec : TIntuitionMessageRec;
begin
  if Assigned(IMsg) then
  begin
    (*
      Prepare a FPC dispatch message. The first cardinal (DWORD) in the 
      message structure need to match the message ID used in the class.
      Since we're using IDCP message we copy the IDCMP ID value into here.
      Seems like the rest of the message structue is free for us to use
      as we want so, we put the actual intuitmessage that was recieved 
      in the second field of the message structure.
    *)
    MsgRec.MsgCode := IMsg^.IClass; 
    MsgRec.IMsg    := IMsg;
    Dispatch(msgrec);

    (*
      if, after dispatch finished, the FStopped private variable is set
      then a closewindow message was accepted. Since we would like to
      put all stuff related to closing a window into the class itself
      we check for this situation and close the window (in a safe way).
      Would we not close the window in such a secure way then it would 
      only be possible to close the windows in the reverse order in which 
      they were opened (otherwise intuition would crahsh).
    *)
    if FStopped then CloseWindowSafely;
  end;
  (*
    Because we need a way to remove the window from the main programs
    WindowList, we give back a return value that indictates whether or not
    this window has to removed from the WindowList.
  *)
  Result := FStopped;
end;


(*
  http://www.freepascal.org/docs-html/rtl/system/tobject.defaulthandler.html
  DefaultHandler is the default handler for messages. If a message has an 
  unknown message ID (i.e. does not appear in the table with integer message 
  handlers), then it will be passed to DefaultHandler by the Dispatch method.
*)

(*
  http://www.freepascal.org/docs-html/rtl/system/tobject.dispatch.html
  Dispatch looks in the message handler table for a handler that handles 
  message. The message is identified by the first dword (cardinal) in the 
  message structure. 

  If no matching message handler is found, the message is passed to the 
  DefaultHandler method, which can be overridden by descendent classes to add 
  custom handling of messages.  
*)
procedure TIntuitionWindowClass.DefaultHandler(var message);
begin
  WriteLn('invoked default handler');
end;


procedure TIntuitionWindowClass.MsgCloseWindow(var msg: TIntuitionMessageRec);
var
  DoClose: boolean = true;
begin
  WriteLn('IDCMP_CLOSEWINDOW message received');

  if Assigned(FOnCloseWindow) then FOnCloseWindow(DoClose);
  FStopped := DoClose;
end;


procedure TIntuitionWindowClass.MsgMouseMove(var msg: TIntuitionMessageRec);
begin
  WriteLn('IDCMP_MOUSEMOVE message received');

  if assigned(FOnMouseMove) then FOnMouseMove(msg.IMsg);
end;


procedure TIntuitionWindowClass.MsgMouseButtons(var msg: TIntuitionMessageRec);
begin
  WriteLn('IDCMP_MOUSEBUTTONS message received');

  if Assigned(FOnMouseButtons) then FOnMouseButtons(msg.Imsg);
end;

end.
