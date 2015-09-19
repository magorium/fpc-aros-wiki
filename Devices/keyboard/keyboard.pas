unit keyboard;

{
  keyboard.device
}
 
{$MODE OBJFPC}{$H+}
 
interface
 
Uses
  Exec;
 
 
Const
  //**********************************************************************
  //********************** Keyboard Device Commands **********************
  //**********************************************************************/
 
  KBD_READEVENT        = (CMD_NONSTD + 0);
  KBD_READMATRIX       = (CMD_NONSTD + 1);
  KBD_ADDRESETHANDLER  = (CMD_NONSTD + 2);
  KBD_REMRESETHANDLER  = (CMD_NONSTD + 3);
  KBD_RESETHANDLERDONE = (CMD_NONSTD + 4);
 
implementation
 
end.
