program ShowActiveMatrix;
 
{
  Small example that shows how to read and display the current keyboard matrix. 
  
  Note that the matrix result only contains the current keys being pressed.
}

{$MODE OBJFPC}{$H+}


Uses
  exec, amigados, keyboard,
  sysutils;
 
 
Const
  KB_MAXKEYS     = 256;
  KB_MATRIXSIZE  = (KB_MAXKEYS div (sizeof(BYTE)*8))  ;
 
 
procedure ShowMatrix;
Type
  IOStd = Type PIOStdReq;
Var
  mp     : pMsgPort;
  io     : pIORequest = nil;
  i      : integer;
  matrix : packed Array [0..Pred(KB_MATRIXSIZE)] of byte;
begin
  mp := CreateMsgPort;
 
  if (mp <> Nil) then
  begin
    io := CreateIORequest(mp, sizeof (TIOStdReq));
 
    if (io <> nil) then
    begin
 
      If (0 = OpenDevice('keyboard.device', 0, io, 0)) then
      begin
        WriteLn('checking keyboard matrix');
        ioStd(io)^.io_Command := KBD_READMATRIX;
        ioStd(io)^.io_Data    := @matrix[0];
        ioStd(io)^.io_Length  := SizeOf(Matrix);
        DoIO(io);
 
        if (0 = io^.io_Error) then
        begin
          Write('Matrix: ');
          for i := 0 to ioStd(io)^.io_Actual - 1 do
          begin
            Write('0x', IntToHex(matrix[i], 2), ' ');
          end;
        end;
 
        CloseDevice(io);
      end;
 
      DeleteIORequest(io);
    end;
 
    DeleteMsgPort(mp);
  end;
end;
 
 
begin
  WriteLn('enter');

  ShowMatrix;

  WriteLn('leave');
end.