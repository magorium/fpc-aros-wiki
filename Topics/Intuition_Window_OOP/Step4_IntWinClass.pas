unit Step4_IntWinClass;

{$MODE OBJFPC}{$H+}

interface

uses
  Intuition;


type
  TIntuitionMessageRec = record
    MsgCode : DWord;
    IMsg    : PIntuiMessage;
  end;

type
  TIntuitionWindowClass = class
  private
    FHandle  : PWindow;
    FLeft    : LongInt;
    FTop     : LongInt;
    FWidth   : LongInt;
    FHeight  : LongInt;
    FTitle   : AnsiString;
    FStopped : boolean;
  protected
    procedure MsgCloseWindow(var msg: TIntuitionMessageRec); Message IDCMP_CLOSEWINDOW;
    procedure MsgMouseMove(var msg: TIntuitionMessageRec); Message IDCMP_MOUSEMOVE;
    procedure MsgMouseButtons(var msg: TIntuitionMessageRec); Message IDCMP_MOUSEBUTTONS;
  public
    constructor Create;  
    destructor  Destroy; override;
  public
    procedure Open;
    procedure Close;
    procedure HandleMessages;
    procedure DefaultHandler(var message); override;
  public
    property Left   : LongInt read FLeft   write FLeft;
    property Top    : LongInt read FTop    write FTop;
    property Width  : LongInt read FWidth  write FWidth;
    property Height : LongInt read FHeight write FHeight;
    property Title  : String  read FTitle  write FTitle;
    property Handle : PWindow read FHandle;
  end;


implementation

uses
  SysUtils, Exec, AGraphics, InputEvent;


function AsTag(tag: LongWord): LongInt; inline;
begin
  Result := LongInt(tag);
end;


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


procedure TIntuitionWindowClass.Open;
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
    AsTag(WA_Title)       , aTitle,
    // Non use settable flags (for now)
    AsTag(WA_Flags)       , AsTag(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH or WFLG_RMBTRAP or WFLG_REPORTMOUSE),
    AsTag(WA_IDCMP)       , AsTag(IDCMP_CLOSEWINDOW or IDCMP_MOUSEMOVE or IDCMP_MOUSEBUTTONS),
    TAG_END
  ]);
  if not Assigned(FHandle) then Error('Unable to Open Window');
end;


procedure TIntuitionWindowClass.Close;
begin
  if Assigned(FHandle) 
  then Intuition.CloseWindow(FHandle)
  else Error('Unable to Close Window because the handle is invalid');
end;


procedure print_text(rp: PRastPort; x: LongInt; y: LongInt; txt: PChar);
begin
  GfxMove(rp, x, y);
  SetABPenDrMd(rp, 1, 0, JAM2);
  GfxText(rp, txt, strlen(txt));
  ClearEOL(rp);
end;


procedure TIntuitionWindowClass.HandleMessages;
var
  msg       : PIntuiMessage;
  msgrec    : TIntuitionMessageRec;
begin
  while not FStopped do
  begin
    WaitPort(FHandle^.UserPort);
  
    while true do
    begin
      msg := PIntuiMessage(GetMsg(FHandle^.UserPort));
      if not Assigned(msg) then break;

//      WriteLn('ReplyMsg');
      ReplyMsg(pMessage(msg));
//      WriteLn('Dispatch');
      MsgRec.MsgCode := msg^.IClass; 
      MsgRec.IMsg    := msg;
      Dispatch(msgrec);
    end;
  end;
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
  Writeln('invoked default handler');
end;


procedure TIntuitionWindowClass.MsgCloseWindow(var msg: TIntuitionMessageRec);
begin
  WriteLn('IDCMP_CLOSEWINDOW message received');
  FStopped := true;
end;


procedure TIntuitionWindowClass.MsgMouseMove(var msg: TIntuitionMessageRec);
var
  buffer    : String[80];
begin
  WriteLn('IDCMP_MOUSEMOVE message received');
  WriteStr(buffer, 'Mouseposition: x=', msg.IMsg^.MouseX, ' y=', msg.IMsg^.MouseY, #0);
  print_text(FHandle^.RPort, 10, 30, @buffer[1]);
end;


procedure TIntuitionWindowClass.MsgMouseButtons(var msg: TIntuitionMessageRec);
begin
  WriteLn('IDCMP_MOUSEBUTTONS message received');
  case msg.IMsg^.Code of
    IECODE_LBUTTON                      : print_text(FHandle^.RPort, 10, 60, 'Left mousebutton pressed');
    IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text(FHandle^.RPort, 10, 60, 'Left mousebutton released');
    IECODE_RBUTTON                      : print_text(FHandle^.RPort, 10, 90, 'Right mousebutton pressed');
    IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text(FHandle^.RPort, 10, 90, 'Right mousebutton released');
  end;
end;

end.
