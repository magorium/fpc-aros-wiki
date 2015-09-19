Program RecursiveFileMatchAROS;
 
{$MODE OBJFPC}{$H+} 
 
uses 
  exec, 
  amigados, 
  SysUtils; 
 
 
 
Procedure FileSearchAROS(const pathname, FileMask: string; const DoRecursive: boolean);
{ 
  Routine based on thomas-rapps post ->  
   http://eab.abime.net/showpost.php?p=660659&postcount=5 
  FileSearch routine that can search directories recursive (no restrictions) 
  and match a given file pattern. The FileMask pattern is not applied to the 
  directory, only to the file.
  This routine is by no means foolproof and definitely needs a bit more TLC. 
} 
 
Var
  level       : longint;    // Indentation level for printing 
var  
  ap          : PAnchorPath; 
  error       : longint;    // Holds return code for AROS' match-functions
  s           : String;     // Temp storage used for post entry-type printing
  filename    : String;     // String holds current filename entry (only filename part) 
  filemaskTOK : pChar;      // C-String, hold tokenized mask needed by AROS API
  isMatch     : Longbool;   // Temp boolean placeholder to hold the match result 
  i           : longint;    // used for counting 
begin 
  ap := AllocVec(sizeof(TAnchorPath) + 1024, MEMF_CLEAR); 
  if (ap <> nil) then 
  begin 
    ap^.ap_BreakBits := SIGBREAKF_CTRL_C; 
    ap^.ap_StrLen    := 1024;   
  end; 
 
  level := 0; 
 
  error := MatchFirst(pchar(pathname), ap); 
 
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
        Soft linked objects are returned by the scanner but they need 
        special treatments; we are merely ignoring them here in order 
        to keep this example simple
      } 
      if (ap^.ap_Info.fib_DirEntryType <> ST_SOFTLINK) then 
      begin 
        {  
          provide for some indentation  
        } 
        for i := 0 to pred(level) do write(' '); 
 
        if (ap^.ap_Info.fib_DirEntryType < 0) then 
        begin 
          { Initial postfix printing string is empty (=file) }
          s := '';  
 
          { 
            According to AutoDocs/FileInfoBlock struct, we can now be certain 
            that we do not deal with a directory, but are dealing with an 
            actual file. 
          } 
 
          { Use FileInfoBlock struct to retrieve filename of current entry } 
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
          IsMatch := MatchPatternNoCase(FileMaskTOK, pchar(FileName)); 
 
          { check the result, if matched then emit something }  
          if IsMatch then writeln('It seems that the above printed filename matches the filemask o/');           
 
          { return allocated heapmem for pchar: fpc business }           
          strdispose(FileMaskTOK); 
        end   
        else s := ' (Dir)'; // Change postfix printing string to read directory
 
        // Emit the current entry. ap_Buf contains the full path + filename
        writeln(format('%s%s',[ap^.ap_Buf, s])); 
 
        { If this is a directory, enter it } 
        if ((ap^.ap_Info.fib_DirEntryType >= 0) and DoRecursive) then 
        begin 
          ap^.ap_Flags := (ap^.ap_Flags or APF_DODIR);
 
          { For every directory entered, update indentation level accordingly }
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
  WriteLn('enter'); 
 
  FileSearchAROS('Ram:','#?.info', true); 
 
  Writeln('leave'); 
End.
