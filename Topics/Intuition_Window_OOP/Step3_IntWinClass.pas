unit Step3_IntWinClass;

{$MODE OBJFPC}{$H+}

interface

uses
  Intuition;


type
  TIntuitionWindowClass = class
  private
    FHandle : PWindow;
    FLeft   : LongInt;
    FTop    : LongInt;
    FWidth  : LongInt;
    FHeight : LongInt;
    FTitle  : AnsiString;
  protected
  public
    Constructor Create;  
    Destructor  Destroy; override;
  public
    procedure Open;
    procedure Close;
    procedure HandleMessages;
  public
    property Left  : LongInt read FLeft   write FLeft;
    property Top   : LongInt read FTop    write FTop;
    property Width : LongInt read FWidth  write FWidth;
    property Height: LongInt read FHeight write FHeight;
    property Title : String  read FTitle  write FTitle;
    property Handle : PWindow read FHandle;
  end;


implementation

uses
  SysUtils, Exec, AGraphics, InputEvent;


Function AsTag(tag: LongWord): LongInt; inline;
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
  then CloseWindow(FHandle)
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
  cont      : Boolean;
  msg       : PIntuiMessage;
  buffer    : String[80];
begin
  cont := TRUE;

  while (cont) do
  begin
    WaitPort(FHandle^.UserPort);

    while true do
    begin
      msg := PIntuiMessage(GetMsg(FHandle^.UserPort));
      if not Assigned(msg) then break;
      
      case (msg^.IClass) of
        IDCMP_CLOSEWINDOW:
          cont := FALSE;
        IDCMP_MOUSEMOVE:
        begin
          WriteStr(buffer, 'Mouseposition: x=', msg^.MouseX, ' y=', msg^.MouseY, #0);
          print_text(FHandle^.RPort, 10, 30, @buffer[1]);
        end;
        IDCMP_MOUSEBUTTONS:
        case (msg^.Code) of
          IECODE_LBUTTON                      : print_text(FHandle^.RPort, 10, 60, 'Left mousebutton pressed');
          IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text(FHandle^.RPort, 10, 60, 'Left mousebutton released');
          IECODE_RBUTTON                      : print_text(FHandle^.RPort, 10, 90, 'Right mousebutton pressed');
          IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text(FHandle^.RPort, 10, 90, 'Right mousebutton released');
        end;
      end; // case
      ReplyMsg(pMessage(msg));
    end;
  end;
end;

end.
