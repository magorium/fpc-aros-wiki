program Step4_ClassWindow;

{$MODE OBJFPC}{$H+}

uses
  Step4_IntWinClass, Exec, AGraphics, Intuition, InputEvent;


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
  Window1.Open;

  Window1.HandleMessages;

  Window1.Close;
  Window1.Free;

  result := (0);
end;


begin
  ExitCode := Main;
end.
