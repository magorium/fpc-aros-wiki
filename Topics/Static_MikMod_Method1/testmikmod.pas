program testmikmod;

//* MikMod Sound Library example program: a simple module player */
{$MODE OBJFPC}{$H+}

uses
  MikMod3;


procedure DumpModInfo(module: PMODULE);
begin
  if not assigned(module) then exit;

  WriteLn('--------- module info dump ---------');
  WriteLn('songname     = ', module^.songname);
  WriteLn('modtype      = ', module^.modtype);
  WriteLn('comment      = ', module^.comment);
  WriteLn('flags        = ', module^.flags);
  WriteLn('numchn       = ', module^.numchn);
  WriteLn('numvoices    = ', module^.numvoices);
  WriteLn('numpos       = ', module^.numpos);
  WriteLn('numpat       = ', module^.numpat);
  WriteLn('numins       = ', module^.numins);
  WriteLn('numsmp       = ', module^.numsmp);

  WriteLn('realchn      = ', module^.realchn);
  WriteLn('totalchn     = ', module^.totalchn);

  WriteLn('reppos       = ', module^.reppos);
  WriteLn('initspeed    = ', module^.initspeed);
  WriteLn('inittempo    = ', module^.inittempo);
  WriteLn('initvolume   = ', module^.initvolume);
//  WriteLn('panning      = ', module^.panning);
//  WriteLn('chanvol      = ', module^.chanvol);
  WriteLn('bpm          = ', module^.bpm);
  WriteLn('sngspd       = ', module^.sngspd);

  WriteLn('volume       = ', module^.volume);
  WriteLn('extspd       = ', module^.extspd);
  WriteLn('panflag      = ', module^.panflag);
  WriteLn('wrap         = ', module^.wrap);
  WriteLn('loop         = ', module^.loop);
  WriteLn('fadeout      = ', module^.fadeout);

  WriteLn('patpos       = ', module^.patpos);
  WriteLn('sngpos       = ', module^.sngpos);
  WriteLn('sngtime      = ', module^.sngtime);

  WriteLn('relspd       = ', module^.relspd);

  WriteLn('numtrk       = ', module^.numtrk);

  WriteLn('forbid       = ', module^.forbid);
  WriteLn('numrow       = ', module^.numrow);
  WriteLn('vbtick       = ', module^.vbtick);
  WriteLn('sngremainder = ', module^.sngremainder);

  WriteLn('globalslide  = ', module^.globalslide);
  WriteLn('pat_repcrazy = ', module^.pat_repcrazy);
  WriteLn('patbrk       = ', module^.patbrk);
  WriteLn('patdly       = ', module^.patdly);
  WriteLn('patdly2      = ', module^.patdly2);
  WriteLn('posjmp       = ', module^.posjmp);
  WriteLn('bpmlimit     = ', module^.bpmlimit);
  WriteLn('------------------------------------');
end;


procedure PlayModule(FileName: String);
var
  module    : PMODULE;
  Ticker    : LongInt = 0;
begin
  //* register all the drivers */
  WriteLn('RegisterAllDrivers()');
  MikMod_RegisterAllDrivers();

  //* register all the module loaders */
  WriteLn('MikMod_RegisterAllLoaders()');
  MikMod_RegisterAllLoaders();

  // Dump information
  WriteLn('Drivers', LineEnding, '-------', LineEnding, MikMod_InfoDriver, LineEnding);
  WriteLn('Loaders', LineEnding, '-------', LineEnding, MikMod_InfoLoader, LineEnding);

  //* initialize the library */
  WriteLn('MikMod_Init('''')');
  md_mode := md_mode or DMODE_SOFT_MUSIC;
  if (MikMod_Init('')) then
  begin
    WriteLn('error');
    WriteLn(stderr, 'Could not initialize sound, reason: ', MikMod_strerror(MikMod_errno));
    exit;
  end;

  //* load module */
  WriteLn('Player_Load("', FileName, '"), 64, false)');
  module := Player_Load(PChar(FileName), 64, false);
  if assigned(module) then
  begin
    WriteLn('Module was loaded successfully');

    DumpModInfo(module);  

    //* start module */
    Player_Start(module);

    while (Player_Active) do
    begin
      //* we're playing */
      MikMod_Sleep(10000);  // 0.01 seconds

      inc(ticker);
      if (ticker mod 400 = 0)  // 4 seconds
      then Writeln('Song: ', Module^.sngpos, '  Pattern: ', Module^.patpos);
      
      MikMod_Update();
    end;

    Player_Stop();
    Player_Free(module);
  end
  else
    WriteLn(stderr, 'Could not load module, reason: ', MikMod_strerror(MikMod_errno));

  //* give up */
  MikMod_Exit();
end;


begin
  WriteLn('main program enter');

  if (ParamCount <> 1) then
  begin
    WriteLn('Usage: testmikmod filename');
    Exit;
  end;

  WriteLn('Using version ', MikMod_GetVersion(), ' of mikmod');  

  WriteLn('Starting PlayModule ...');

  PlayModule(ParamStr(1));

  WriteLn('Stopped PlayModule ...');

  Writeln('main program leave');
end.

