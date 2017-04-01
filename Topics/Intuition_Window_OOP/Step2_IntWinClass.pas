unit Step2_IntWinClass;

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
    FTitle  : String;
  protected
  public
    Constructor Create;  
    Destructor  Destroy; override;
  public
    procedure Open;
    procedure Close;
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
  SysUtils;


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
end;


Destructor TIntuitionWindowClass.Destroy;
begin
  inherited;
end;


procedure TIntuitionWindowClass.Open;
begin
  FHandle := OpenWindowTags( nil,
  [
    AsTag(WA_Left)        , FLeft,
    AsTag(WA_Top)         , FTop,
    AsTag(WA_Width)       , FWidth,
    AsTag(WA_Height)      , FHeight,
    AsTag(WA_Title)       , PChar(FTitle),
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

end.
