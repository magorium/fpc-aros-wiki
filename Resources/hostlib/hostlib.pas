unit hostlib;
 

{
  hostlib.resource
}
 
{$MODE OBJFPC}{$H+}


interface
 

uses
  Exec;


type
  PVoid         = pointer;

 
const
  HOSTLIBNAME   = 'hostlib.resource';


var
  HostLibBase   : pLibrary;
 
 
  function  HostLib_Open(const filename: PChar; error: PPChar): PVoid; syscall HostLibBase 1;
  function  HostLib_Close(handle: PVoid; error: PPChar): integer; syscall HostLibBase 2;
  function  HostLib_GetPointer(handle: PVoid; const symbol: PChar; error: PPChar): PVoid; syscall HostLibBase 3;
  procedure HostLib_FreeErrorStr(error: PPChar); syscall HostLibBase 4;
  function  HostLib_GetInterface(handle: PVoid; const symbols: PPChar; unresolved: PULONG): PAPTR; syscall HostLibBase 5;
  procedure HostLib_DropInterface(interface_: PAPTR); syscall HostLibBase 6;
  procedure HostLib_Lock; syscall HostLibBase 7;
  procedure HostLib_Unlock; syscall HostLibBase 8;
 
 
implementation
 
 
Initialization

  HostLibBase := OpenResource(HOSTLIBNAME);
 

finalization

  // resources do not need to be closed

end.
