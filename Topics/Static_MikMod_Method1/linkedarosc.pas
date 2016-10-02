unit linkedarosc;

{$MODE OBJFPC}{$H+}

{$IFDEF AROS}
  {$DEFINE STATICLINKING}
  // Use eax calling convention for syscalls
  {$SYSCALL EAXBASE}
{$ENDIF}

{$IFDEF STATICLINKING}
  {$IFDEF AROS}
    {$LINKLIB libgcc.a}
    {$LINKLIB libstdc.static.a}
  {$ENDIF}
{$ENDIF}


interface

uses
  ctypes;


const
  ArosCName : PChar     = 'arosc.library';

var
  ArosCBase : Pointer;
  SysBase   : Pointer; cvar; export;


type
  cssize_t    = cslong;
  cuseconds_t = cuint32;


type
  Parosc_ctype = ^Tarosc_ctype;
  Tarosc_ctype = record
    b       : pcushort;
    toupper : pcint;
    tolower : pcint;
  end;
  arosc_ctype = Tarosc_ctype;


  function  c_fopen(const filename: PChar; const mode: PChar): pointer;                               syscall ArosCBase   5;
  function  c_fclose(stream: pointer): cint;                                                          syscall ArosCBase   7;
  function  c_fputc(c: cint; stream: pointer): cint;                                                  syscall ArosCBase  12;
  function  c_fgetc(stream: pointer): cint;                                                           syscall ArosCBase  16;
  function  c_feof(stream: pointer): cint;                                                            syscall ArosCBase  19;
  function  c_fread(ptr: pointer; size: csize_t; nmemb: csize_t; stream: pointer): csize_t;           syscall ArosCBase  24;
  function  c_fwrite(const ptr: pointer; size: csize_t; nmemb: csize_t; stream: pointer): csize_t;    syscall ArosCBase  25;
  function  c_fseek(stream: pointer; offset: clong; whence: cint): cint;                              syscall ArosCBase  37;
  function  c_ftell(stream: pointer): clong;                                                          syscall ArosCBase  38;
  function  c_close(fd: cint): cint;                                                                  syscall ArosCBase  49;
  function  c_unlink(const path: pChar): cint;                                                        syscall ArosCBase  57;
  function  c_write(fd: cint; const buf: pointer; nbytes: csize_t): cssize_t;                         syscall ArosCBase  58;
  // Unfortunately no support for variadic declarations
  // int open(const char * filename, int flags, ...)
  function  c_open(const filename: PChar; flags: cint): cint;                                         syscall ArosCBase  59;
  function  c_rand: cint;                                                                             syscall ArosCBase  70;
  function  c_calloc(count: csize_t; size: csize_t): Pointer;                                         syscall ArosCBase  88;
  function  c_realloc(oldmem: pointer; newsize: csize_t): pointer;                                    syscall ArosCBase  89;
  procedure c_free(memory: Pointer);                                                                  syscall ArosCBase  90;

  function  c_usleep(usec: cuseconds_t): cuint;                                                       syscall ArosCBase 252;


  
implementation

uses
  Exec;



function  fopen(const filename: PChar; const mode: PChar): pointer; cdecl; export;
begin
  fopen := c_fopen(filename, mode);
end;

function  fclose(stream: pointer): cint; cdecl; export;
begin
  fclose := c_fclose(stream);
end;

function  fputc(c: cint; stream: pointer): cint; cdecl; export;
begin
  fputc := c_fputc(c, stream);
end;

function  fgetc(stream: pointer): cint; cdecl; export;
begin
  fgetc := c_fgetc(stream);
end;

function  feof(stream: pointer): cint; cdecl; export;
begin
  feof := c_feof(stream);
end;

function  fread(ptr: pointer; size: csize_t; nmemb: csize_t; stream: pointer): csize_t;  cdecl; export;
begin
  fread := c_fread(ptr, size, nmemb, stream);
end;

function  fwrite(const ptr: pointer; size: csize_t; nmemb: csize_t; stream: pointer): csize_t; cdecl; export;
begin
  fwrite := c_fwrite(ptr, size, nmemb, stream);
end;

function  fseek(stream: pointer; offset: clong; whence: cint): cint; cdecl; export;
begin
  fseek := c_fseek(stream, offset, whence);
end;

function  ftell(stream: pointer): clong; cdecl; export;
begin
  ftell := c_ftell(stream);
end;

function  close(fd: cint): cint; cdecl; export;
begin
  close := c_close(fd);
end;

function  unlink(const path: pChar): cint; cdecl; export;
begin
  unlink := c_unlink(path);
end;

function  write(fd: cint; const buf: pointer; nbytes: csize_t): cssize_t; cdecl; export;
begin
  write := c_write(fd, buf, nbytes);
end;

function  open(const filename: PChar; flags: cint): cint;  cdecl; export;
begin
  // Safety informational message
  WriteLn(stdout, 'C-Function open() is invoked. Filename = ', filename, ' flags = ', flags);
  open := c_open(filename, flags);
end;

function  rand: cint;  cdecl; export;
begin
  rand := c_rand;
end;

function  calloc(count: csize_t; size: csize_t): Pointer; cdecl; export;
begin
  calloc := c_calloc(count, size);
end;

function  realloc(oldmem: pointer; newsize: csize_t): pointer; cdecl; export;
begin
  realloc := c_realloc(oldmem, newsize);
end;

procedure free(memory: Pointer);  cdecl; export;
begin
  c_free(memory);
end;



///////////////////////////////////////////////////////////////////////////////



function  frexp(value: cdouble; exp: pcint): cdouble; cdecl; export;
begin
  exp^ := 0;
  if (abs(value)<0.5) then
    While (abs(value)<0.5) do
    begin
      value := value*2;
      Dec(exp^);
    end
  else
    While (abs(value)>1) do
    begin
      value := value/2;
      Inc(exp^);
    end;
  frexp := value;
end;



///////////////////////////////////////////////////////////////////////////////



  function  __get_arosc_ctype: Parosc_ctype;                                            syscall ArosCBase 284;
  function  __posixc_set_environptr(environptr: PPPChar): cint;                         syscall ArosCBase 287;



///////////////////////////////////////////////////////////////////////////////



var
  environ   : PPChar;


function __environ_init(SysBase: PExecBase): cint;
begin
  __posixc_set_environptr(@environ);

  exit( 1 );
end;


procedure __arosc_startup(SysBase: PExecBase);
var
  exitjmp: jmp_buf;
begin
  if (setjmp(exitjmp) = 0) then
  begin
    WriteLn('[__stdc_startup] setjmp() called');

    //* Tell stdc.library a program using it has started */
//    __stdc_program_startup(exitjmp, pcint(@__startup_error));
    WriteLn('[__stdc_startup] Library startup called');

//    __startup_entries_next();
  end
  else
  begin
    WriteLn('[__stdc_startup] setjmp() return from longjmp');
  end;
end;



var
  __ctype_b_ptr         : pcushort = nil;
  //* ABI_V0 compatibility */
  __ctype_toupper_ptr   : pcint = nil;
  __ctype_tolower_ptr   : pcint = nil;


function __ctype_init(SysBase: PExecBase): cint;
var
  ctype : ^arosc_ctype;
begin  
  if not assigned(aroscbase) then exit(0);

  ctype := __get_arosc_ctype();

  __ctype_b_ptr       := @ctype^.b;
  __ctype_toupper_ptr := @ctype^.toupper;
  __ctype_tolower_ptr := @ctype^.tolower;

  exit( 1 );
end;



initialization



begin
  WriteLn('unit linkedarosc is being initialized');
  writeln('initializing SysBase export variable');
  SysBase := AOS_ExecBase;

  Writeln('opening arosc.library');
  ArosCBase := OpenLibrary(AROSCNAME,0);
  If assigned(ArosCBase) then
  begin
    writeln('arosc.library opened');

    __arosc_startup(AOS_ExecBase);
    __environ_init(AOS_ExecBase);
    __ctype_init(AOS_ExecBase);

  end
  else writeln('arosc.library could not be openend')
end;



finalization



begin
  WriteLn('unit linkedarosc is being finalized, closing arosc.library');
  CloseLibrary(ArosCbase);
end;



end.
