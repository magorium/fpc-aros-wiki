program step6;

{$MODE OBJFPC}{$H+}

{$LINKLIB libarosc.a}
{$LINKLIB libautoinit.a}
{$LINK startup.o}

Uses
  MikMod3;  

//
//      Exports
//
type
  TAROS_Startup_Function = function(argc: integer; argv: PPChar): integer; cdecl;
var
  // Import variables SysBase and DOSBase
  SysBase             : Pointer; cvar; export;
  DOSBase             : Pointer; cvar; export;
  __main_function_ptr : TAROS_Startup_Function = nil; cvar; export;

var
  __nocommandline   : Integer; cvar; export;
  __nostdiowin      : integer; cvar; export;
  __nowbsupport     : Integer; cvar; export;


  // Import the two startup entries functions
  procedure __startup_entries_init; cdecl; external;
  procedure ___startup_entries_next(SystemBase: Pointer); cdecl; external;

// startup_entries_next() wrapper function
procedure __startup_entries_next;
begin
  ___startup_entries_next(SysBase);
end;



function AROSC_Startup_Entry(argc: integer; argv: PPChar): integer; cdecl;
begin
  DebugLn('ENTER - AROSC_Startup_Entry()');

  result := 0;

  DebugLn('LEAVE - AROSC_Startup_Entry()');
end;


// AROSC Initialization routine
procedure AROSC_Init;
begin
  // Intialialize SysBase variable
  SysBase := AOS_ExecBase;

  // Initialize DOSBase variable
  DOSBase := AOS_DosBase;

  __main_function_ptr := @AROSC_Startup_Entry;

  // Call startup_entries_init()
  __startup_entries_init;

  // Call startup_entries_next()
  __startup_entries_next;
end;


begin
  WriteLn('Hello');
  AROSC_Init;
  WriteLn('Goodbye');
end.
