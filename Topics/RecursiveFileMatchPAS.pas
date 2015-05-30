program RecursiveFileMatchPAS;

{$MODE OBJFPC}{$H+}

uses
  SysUtils, 
  fpMasks;

Const
  AllWildMask = '#?';

Procedure FileSearchPAS(const pathname, FileMask: String; const DoRecursive: boolean);
{
  Pascal recursive filesearch routine, based on the AROS' native version to
  show the differences.
  FileSearch routine that can search directories recursive (no restrictions) 
  and match a given file pattern. The FileMask pattern is not applied to the 
  directory, only to the file.
  This routine is by no means foolproof and definitely needs a bit more TLC.
}

Const
  Level       : LongInt= 0; // Indentination level for printing
var
  SR          : TSearchRec; // FileSearch record, similat to AROS' AnchorPath
  sPath       : String;     // Corrected path which is required for FPC
  S           : String;     // Temp storage used for post entry-type printing
  filename    : String;     // String holds current filename entry (only filename part) 
  FilemaskTOK : TMask;      // Pascal class to hold mask needed by FPC to Match a wildcard
  isMatch     : Boolean;    // Temp boolean placeholder to hold the match result
  i           : Longint;    // used for counting
begin
  {
    Pascal's FindFirst/FindNext requires proper path ending, so provide it.
  }
  sPath := IncludeTrailingPathDelimiter(pathname);

  { 
    small workaround to match AROS' native counterpart as FPC's native
    implementation does not start matching the root path, rather files within.
  }
  if ( level = 0 ) then
  begin
    Writeln(sPath + ' (Dir)');
    inc(level);
  end;

  {
    Find anyfile on the given Path matching All possible filenames
  }
  if ( FindFirst(sPath + AllWildMask, faAnyFile, SR) = 0 ) then
  repeat
    { 
      Soft linked objects are returned by the scanner but they need 
      special treatments; we are merely ignoring them here in order 
      to keep this example simple
    } 
    If ((SR.Attr and faSymLink) = 0) then
    begin
      {  
        provide for some indentation  
      } 
      for i := 0 to Pred(level) do write(' ');

      {
        If not directory (= FPC crossplatform Alert!) then assume file.
        It is not foolproof to assume we deal with a file as there are other 
        possible directory entry types on other platforms. As long as you run 
        this implementation on AROS things should work correctly )
      }
      if ((SR.Attr and faDirectory) = 0) then 
      begin
        { Initial postfix printing string is empty (=file) }
        S := '';  

        { Use TSearchRec struct to retrieve the name of the current entry }
        Filename := SR.Name;

        { do something nice, and emit the filename } 
        writeln('filename = ', filename); 
    
        { create mask in pascal to compare mask against current filename }
        FilemaskTOK := TMask.Create(FileMask);

        { match the mask against the curent filename } 
        IsMatch := FileMaskTOK.Matches(FileName);

        { free mask memory. Very inefficient, comparable to AROS counterpart }
        FileMaskTOK.Free;

        { check the result, if matched then emit something } 
        if IsMatch then writeln('It seems that the above printed filename matches the filemask o/'); 
      end
      else S := ' (Dir)'; // Change postfix printing string to read directory

      {
        Emit the current entry. name entry of TSearchrec contains only the 
        name, therefor construct things ouselves in order to get a complete 
        path + filename
      }
      Writeln(sPath + SR.Name + S);

      { If this is a directory, enter it } 
      if ((SR.Attr and faDirectory) <> 0) and DoRecursive then 
      begin

        { For every directory entered, update indentination level accordingly }
        inc(level);

        { 
          In opposite to AROS native implementation, for FPC we manually need 
          to call ourselves recursively. 
          Note that this can lead to stack issues. Increase stack accordingly.
        }  
        FileSearchPAS(sPath + SR.Name, FileMask, DoRecursive);

        { For every directory leaving, update indentination level accordingly } 
        dec(level);
      end;

    end;
  until ( FindNext(SR) <> 0 );

  FindClose(SR);
end;



Begin 
  WriteLn('enter'); 
 
  FileSearchPAS('Ram:','*.info', true); 
 
  Writeln('leave'); 
End.
