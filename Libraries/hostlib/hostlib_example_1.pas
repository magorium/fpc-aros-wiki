program hostlib_example_1;


{$MODE OBJFPC}{$H+}

{
  Example for AROS hosted by Windows.
  
  This example opens the kernel32.dll library, gets the interface to the 
  library and attempts to locate library functions GetEnvironmentStringsA() 
  and FreeEnvironmentStringsA().
  
  It then calls the GetEnvironmentStringsA() function in order to retrieve the
  actual Windows environment strings, and prints the values to the AROS shell.
  
  An additional accompanied call to FreeEnvironmentStringsA() is done in order
  to release the resources allocated by Windows.
  
  Once done the interface to the kernel32.dll library is dropped and the 
  host library is closed.
}


Uses
  exec, hostlib, 
  sysutils;


const
  Symbols : array[0..2] of PChar =
  (
    'GetEnvironmentStringsA',
    'FreeEnvironmentStringsA',
    nil
  );


Type
  PKernel32Interface = ^TKernel32Interface;
  TKernel32Interface = record
    GetEnvironmentStringsA   : Function(): PChar; stdcall;
    FreeEnvironmentStringsA  : Function(lpszEnvironmentBlock: PChar): LongBool; stdcall;
  end;


Var
  kernel32base  : pointer;
  kernel32iface : PKernel32Interface;
  n             : LongWord;


procedure GetHostEnvStrings;
var
  EnvStrings : PChar;
  i          : integer;
begin
  Forbid;
  EnvStrings := kernel32iface^.GetEnvironmentStringsA();
  Permit;
 
  i := 0;
 
  If (EnvStrings <> nil) then
  while (EnvStrings^ <> #0) do
  begin
    WriteLn('EnvStrings[', i, ']  ->  ', StrPas(EnvStrings));
    Inc(EnvStrings, StrLen(EnvStrings) + 1);
    inc(i);
  end;
 
  Forbid;
  kernel32iface^.FreeEnvironmentStringsA(EnvStrings);
  Permit;
end;


procedure Do_Windows_Host_Kernel32;
begin
  If (hostlibbase = nil) then
  begin
    WriteLn('unable to open hostlib.resource');
    exit;
  end
  else
    WriteLn('hostlibbase = ', IntToHex(longword(hostlibbase),8));
 
 
  kernel32Base := HostLib_Open('kernel32.dll', nil);
  if (kernel32Base <> nil) then
  begin
    WriteLn('kernel32.dll opened succesfully');
 
    n := 0;
    kernel32iface := PKernel32Interface(HostLib_GetInterface(Kernel32base, Symbols, @n));
 
    if (Kernel32iface <> nil) then
    begin
      WriteLn('interface to kernel openen succesfully');
      WriteLn('n = ', n);
 
      if (n = 0) then
      begin
        WriteLn('n was ok');
 
        // checking functions
        write('function kernel32.dll->GetEnvironmentStrings is ');
        if (pointer(kernel32iface^.GetEnvironmentStringsA) <> nil)
        then WriteLn('valid')
        else WriteLn('invalid');
 
        write('function kernel32.dll->FreeEnvironmentString is ');
        if (pointer(kernel32iface^.FreeEnvironmentStringsA) <> nil)
        then WriteLn('valid')
        else WriteLn('invalid');
 
        // checking out something ;-p
        GetHostEnvStrings;
      end
      else WriteLn('unresolved functions found');
 
      HostLib_DropInterface(paptr(Kernel32IFace));
    end
    else WriteLn('failed to retrieve interface to kernel32');
 
    HostLib_Close(Kernel32Base, nil);
  end
  else WriteLn('opening of kernel32.dll failed');
end;


begin
  WriteLn('enter');

  Do_Windows_Host_Kernel32;

  WriteLn('leave');
end.
