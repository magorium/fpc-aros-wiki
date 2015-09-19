unit input;
 
{
  input.device
}

{$MODE OBJFPC}{$H+}
 
interface
 

Uses
  Exec;
 

Const
  IND_ADDHANDLER    = (CMD_NONSTD + 0);
  IND_REMHANDLER    = (CMD_NONSTD + 1);
  IND_WRITEEVENT    = (CMD_NONSTD + 2);
  IND_SETTHRESH     = (CMD_NONSTD + 3);
  IND_SETPERIOD     = (CMD_NONSTD + 4);
  IND_SETMPORT      = (CMD_NONSTD + 5);
  IND_SETMTYPE      = (CMD_NONSTD + 6);
  IND_SETMTRIG      = (CMD_NONSTD + 7);
 
  IND_ADDEVENT      = (CMD_NONSTD + 15); //* V50! */
 

Type
  //* The following is AROS-specific, experimental and subject to change */
  TInputDevice      = record
    id_Device       : TDevice;
    id_Flags        : ULONG;
  end;
 

Const
  IDF_SWAP_BUTTONS  = $0001;
 
 
// qualifiers are located in unit inputevent (e.g. IEQUALIFIERB_LSHIFT)
 
 
Var
  InputBase : pLibrary = nil;
 
 
  Function PeekQualifier(): UWORD; syscall InputBase 7;
 
 
Implementation
 
end.
