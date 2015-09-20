unit battclock;

{
  battclock.resource
  https://trac.aros.org/trac/browser/AROS/branches/ABI_V0-on-trunk-20141231/AROS/rom/battclock  
}

{$MODE OBJFPC}{$H+}


interface


uses
  Exec;
  
  
const
  BATTCLOCKNAME = 'battclock.resource';


var
  BattClockBase : APTR;


  procedure ResetBattClock; syscall BattClockBase 1;
  function  ReadBattClock: ULONG; syscall BattClockBase 2;
  procedure WriteBattClock(time: ULONG); syscall BattClockBase 3;
  

implementation


Initialization

  BattClockBase := OpenResource(BATTCLOCKNAME);


finalization

  // resources do not need to be closed

end.
