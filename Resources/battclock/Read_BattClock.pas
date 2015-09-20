program Read_BattClock;

{
  Example 1: Reading battclock
  
  Example that reads BattClock and converts retrieved values to a human 
  readable date and time by calling the Amiga2Date() function from utility.
}

{$MODE OBJFPC}{$H+}

Uses
  Exec, Utility, battclock, 
  sysutils;


{$IFDEF AROS}
var
  UtilityBase   : pLibrary absolute AOS_UtilityBase;
  BattClockBase : pLibrary absolute battclock.BattClockBase;
{$ENDIF}


procedure Main;
const
  Days      : Array[0.. 6] of String   = 
    (
      'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
    );
  Months    : Array[0..11] of String   = 
    (
     'January','February','March','April','May','June',
     'July','August','September','October','November','December'
    );
var
  ampm      : string;
  AmigaTime : ULONG;
  MyClock   : TClockData;
begin
  {$IFNDEF AROS}
  UtilityBase := OpenLibrary('utility.library',33);
  {$ENDIF}
  if (UtilityBase <> nil) then
  begin
    {$IFNDEF AROS}
    BattClockBase := OpenResource(BATTCLOCKNAME);
    {$ENDIF}
    if (BattClockBase <> nil) then
    begin
      //* Get number of seconds till now */
      AmigaTime := ReadBattclock;

      //* Convert to a ClockData structure */
      Amiga2Date(AmigaTime, @MyClock);

      Write(LineEnding, 'Robin, tell everyone the BatDate and BatTime');

      //* Print the Date */
      Write(LineEnding, LineEnding, 'Okay Batman, the BatDate is ');
      Write(Format('%s, %s %d, %d',
      [
        Days[MyClock.wday], Months[MyClock.month-1], 
        MyClock.mday, MyClock.year
      ]));

      //* Convert militairy time to normal time and set AM/PM */
      if (MyClock.hour < 12) then ampm := 'AM'
      else
      begin
        ampm := 'PM';
        MyClock.hour := MyClock.hour - 12;
      end;

      if (MyClock.hour = 0) then MyClock.hour := 12;

      //* Print the time */
      Write(LineEnding, '             the BatTime is ');
      WriteLn(Format('%d:%.2d:%.2d %s',
      [
        MyClock.hour,MyClock.min,MyClock.sec,ampm
      ]));
      WriteLn;
    end
    else
      WriteLn('Error: Unable to open the ',BATTCLOCKNAME);

    {$IFNDEF AROS}
    //* Close the utility library * /
    CloseLibrary(UtilityBase);
    {$ENDIF}
  end
  else
    WriteLn('Error: Unable to open utility.library');
end;


begin
  WriteLn('enter');

  Main;

  WriteLn('leave');
end.
