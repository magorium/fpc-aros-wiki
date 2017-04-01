unit Step5_IntWinClass;

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
  TOnCloseWindowProc  = procedure(var DoClose: boolean);
  TOnMouseMoveProc    = procedure(const IMsg: PIntuiMessage);
  TOnMouseButtonsProc = procedure(const IMsg: PIntuiMessage);
  
  TIntuitionWindowClass = class
  private
    FHandle  : PWindow;
    FLeft    : LongInt;
    FTop     : LongInt;
    FWidth   : LongInt;
    FHeight  : LongInt;
    FTitle   : AnsiString;
    FStopped : boolean;
    FOnCloseWindow  : TOnCloseWindowProc;
    FOnMouseMove    : TOnMouseMoveProc;
    FOnMouseButtons : TOnMouseButtonsProc;
  protected
    procedure MsgCloseWindow(var msg: TIntuitionMessageRec); Message IDCMP_CLOSEWINDOW;
    procedure MsgMouseMove(var msg: TIntuitionMessageRec); Message IDCMP_MOUSEMOVE;
    procedure MsgMouseButtons(var msg: TIntuitionMessageRec); Message IDCMP_MOUSEBUTTONS;
  public // creator/destructor
    constructor Create;  
    destructor  Destroy; override;
  public // methods
    procedure Open;
    procedure Close;
    procedure HandleMessages;
    procedure DefaultHandler(var message); override;
  public // properties
    property Left   : LongInt read FLeft   write FLeft;
    property Top    : LongInt read FTop    write FTop;
    property Width  : LongInt read FWidth  write FWidth;
    property Height : LongInt read FHeight write FHeight;
    property Title  : String  read FTitle  write FTitle;
    property Handle : PWindow read FHandle;
   public  // events
    property OnCloseWindow  : TOnCloseWindowProc  read FOnCloseWindow  write FOnCloseWindow;
    property OnMouseMove    : TOnMouseMoveProc    read FOnMouseMove    write FOnMouseMove;
    property OnMouseButtons : TOnMouseButtonsProc read FOnMouseButtons write FOnMouseButtons;
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
