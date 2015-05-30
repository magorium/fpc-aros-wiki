Program RecurseFilematch; 
 
{$MODE OBJFPC}{$H+} 
 
uses 
  aros_exec, 
  aros_dos, 
  SysUtils; 
 
 
 
Procedure FileSearchAROS(const pathname, FileMask: string; const DoRecursive: boolean); 
{ 
  Routine based on thomas-rapps post ->  
   http://eab.abime.net/showpost.php?p=660659&postcount=5 
  FileSearch routine that can search directories recursive (no restrictions) and match 
  a given file pattern. The pattern is not applied to the directory, only to the file. 
  This routine is not foolproof and definatly needs a bit more TLC. 
  Sorry for the ugly code. 
} 
 
var  
  ap          : PAnchorPath; 
  error,  
  level,  
  i           : longint; 
 
  s,                        // We need a temp string because fpc does not have a ? operator 
  filename    : String;     // String to hold the filename (and only filename part) 
  filemaskTOK : pChar;      // C-String to hold the tokenized mask needed for AROS API Routine 
  isMatch     : Longbool;   // Temp boolean placeholder to hold the match result 
begin 
  ap := AllocVec(sizeof(TAnchorPath) + 1024, MEMF_CLEAR); 
  if (ap <> nil) then 
  begin 
    ap^.ap_BreakBits := SIGBREAKF_CTRL_C; 
    ap^.ap_StrLen    := 1024;   
  end; 
 
  level := 0; 
 
  error := MatchFirst(pathname, ap); 
 
  if (error = 0) and (ap^.ap_Info.fib_DirEntryType >= 0) 
    then ap^.ap_Flags := ap^.ap_Flags or APF_DODIR; 
 
  while (error = 0) do 
  begin 
    if ((ap^.ap_Flags and APF_DIDDIR) <> 0) then 
    begin 
      { Leaving a directory entered below (APF_DODIR) } 
      dec(level); 
      ap^.ap_Flags := ap^.ap_Flags and not(APF_DIDDIR);     
    end 
    else 
    begin 
      { 
        Soft linked objects are returned by the scanner 
        but they need special treatments; we are merely 
        ignoring them here in order to keep this example 
        simple 
      } 
      if (ap^.ap_Info.fib_DirEntryType <> ST_SOFTLINK) then 
      begin 
        {  
          provide for some indentation  
        } 
        for i := 0 to pred(level) do write(' '); 
 
        if (ap^.ap_Info.fib_DirEntryType < 0) then 
        begin 
          s := '';  { no ? operator: results in dumb code to mimic the behaviour } 
 
          { 
            According to AutoDocs/FileInfoBlock struct, we can now 
            be certain that we do not deal with a directory, but are 
            dealing with an actual file. 
            So if we can find a way to determine the name of the 
            file then we could do nice things with it, such as  
            emitting the name. 
          } 
          { get the name } 
          Filename := ap^.ap_Info.fib_FileName; 
          { do something nice, and emit the filename } 
          writeln('filename = ',filename); 
 
          { 
            Now we have a real filename (only) to work with. But  
            what should we do with it ? Is it even useful ? 
            We know we need the filename to match the given  
            filemask. 
            Is there perhaps a way to do this ? Lets try:                   
          } 
          { allocate heapmem for pchar: fpc business. Size taken from AutoDocs } 
          FileMaskTOK := stralloc((Length(FileMask) * 2) + 2); 
          { create a tokenized filemask with a trickery cast. Size taken from AutoDocs } 
          ParsePatternNoCase(pchar(FileMask), FileMaskTOK, (Length(FileMask) * 2) + 2); 
          { match a pattern } 
          IsMatch := MatchPatternNoCase(FileMaskTOK, FileName); 
          { check the result, if we match we emit the name, or you can do whatever with it } 
          if IsMatch then writeln('It seems that the above printed filename matches the filemask o/');           
          { return allocated heapmem for pchar: fpc business }           
          strdispose(FileMaskTOK); 
        end   
        else s := ' (Dir)'; { no ? operator: results in dumb code to mimic the behaviour } 
 
        writeln(format('%s%s',[ap^.ap_Buf, s])); 
 
        { If this is a directory, enter it } 
        if ((ap^.ap_Info.fib_DirEntryType >= 0) and DoRecursive) then 
        begin 
          ap^.ap_Flags := (ap^.ap_Flags or APF_DODIR); 
          inc(level); 
        end; 
 
      end; 
    end; 
    error := MatchNext(ap); 
 
  end; 
  MatchEnd(ap); 
  FreeVec(ap); 
end; 
 
 
 
Begin 
  WriteLn('start'); 
 
  FileSearchAROS('Ram:','#?.info', true); 
 
  Writeln('end'); 
End.