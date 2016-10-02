program step4;

{$MODE OBJFPC}{$H+}

{$LINKLIB libarosc.a}
{$LINKLIB libautoinit.a}
{$LINK startup.o}

Uses
  MikMod3;  

//
//      Exports
//
var
  // Import variables SysBase and DOSBase
  SysBase         : Pointer; cvar; export;
  DOSBase         : Pointer; cvar; export;

  // Import the two startup entries functions
  procedure __startup_entries_init; cdecl; external;
  procedure ___startup_entries_next(SystemBase: Pointer); cdecl; external;

// startup_entries_next() wrapper function
procedure __startup_entries_next;
begin
  ___startup_entries_next(SysBase);
end;


// AROSC Initialization routine
procedure AROSC_Init;
begin
  // Intialialize SysBase variable
  SysBase := AOS_ExecBase;

  // Initialize DOSBase variable
  DOSBase := AOS_DosBase;

  // Call startup_entries_init()
  __startup_entries_init;

  // Call startup_entries_next()
//  __startup_entries_next;
end;


begin
  WriteLn('Hello');
  AROSC_Init;
  WriteLn('Goodbye');
end.
