unit mikmod3;

{$MODE OBJFPC}{$H+}
{$MACRO ON}

{$IFDEF AROS}
  {$DEFINE STATICLINKING}
{$ENDIF}

{$IFDEF STATICLINKING}
  {$DEFINE libname:=}
{$ELSE}
  {$DEFINE libname:=MikModDll}
{$ENDIF}


{$IFDEF STATICLINKING}
  {$IFDEF AROS}
    {$LINKLIB libmikmod.a}
  {$ENDIF}
{$ENDIF}


interface


{$IFDEF AROS}
uses
  linkedarosc;
{$ENDIF}


// yes, for some strange reason we also support Windows
{$IFDEF WINDOWS}
const
  MikModDll = 'libmikmod-3.dll';
{$ENDIF}


{$IFDEF AROS}
type
  size_t = int32;
{$ENDIF}

  // Macro
  procedure MikMod_Sleep(ns: longint); inline;


(*
 *	========== Library version
 *)
const
  // version number is wrong (should be 030202 ?)
  LIBMIKMOD_VERSION_MAJOR = 3;
  LIBMIKMOD_VERSION_MINOR = 1;
  LIBMIKMOD_REVISION      = 5;

  LIBMIKMOD_VERSION = (LIBMIKMOD_VERSION_MAJOR shl 16) or
                      (LIBMIKMOD_VERSION_MINOR shl 8) or
                      (LIBMIKMOD_REVISION);

  function MikMod_GetVersion : LongInt; cdecl; external libname;

(*
 *	========== Platform independent-type definitions
 *)
type
  SBYTE     = ShortInt;        // 1 byte, signed
  UBYTE     = Byte;            // 1 byte, unsigned
  SWORD     = SmallInt;        // 2 bytes, signed
  UWORD     = Word;            // 2 bytes, unsigned
  SLONG     = LongInt;         // 4 bytes, signed
  ULONG     = LongWord;        // 4 bytes, unsigned
  {$IFDEF HASAMIGA}
  BOOL      = WordBool;        // 0=false, <>0 true
  {$ELSE}
  BOOL      = LongBool;        // 0=false, <>0 true
  {$ENDIF}

  PUBYTE    = ^UBYTE;
  PPUBYTE   = ^PUBYTE;
  PUWORD    = ^UWORD;
  

(*
 *	========== Error codes
 *)
type
  mmErrors  = 
  (
    MMERR_OPENING_FILE = 1,
    MMERR_OUT_OF_MEMORY,

    MMERR_SAMPLE_TOO_BIG,
    MMERR_OUT_OF_HANDLES,
    MMERR_UNKNOWN_WAVE_TYPE,

    MMERR_LOADING_PATTERN,
    MMERR_LOADING_TRACK,
    MMERR_LOADING_HEADER,
    MMERR_LOADING_SAMPLEINFO,
    MMERR_NOT_A_MODULE,
    MMERR_NOT_A_STREAM,
    MMERR_MED_SYNTHSAMPLES,
    MMERR_ITPACK_INVALID_DATA,

    MMERR_DETECTING_DEVICE,
    MMERR_INVALID_DEVICE,
    MMERR_INITIALIZING_MIXER,
    MMERR_OPENING_AUDIO,
    MMERR_8BIT_ONLY,
    MMERR_16BIT_ONLY,
    MMERR_STEREO_ONLY,
    MMERR_ULAW,
    MMERR_NON_BLOCK,

    MMERR_AF_AUDIO_PORT,

    MMERR_AIX_CONFIG_INIT,
    MMERR_AIX_CONFIG_CONTROL,
    MMERR_AIX_CONFIG_START,

    MMERR_HP_SETSAMPLESIZE,
    MMERR_HP_SETSPEED,
    MMERR_HP_CHANNELS,
    MMERR_HP_AUDIO_OUTPUT,
    MMERR_HP_AUDIO_DESC,
    NMERR_HP_BUFFERSIZE,

    MMERR_OSS_SETFRAGMENT,
    MMERR_OSS_SETSAMPLESIZE,
    MMERR_OSS_SETSTEREO,
    MMERR_OSS_SETSPEED,

    MMERR_SGI_SPEED,
    MMERR_SGI_16BIT,
    MMERR_SGI_8BIT,
    MMERR_SGI_STEREO,
    MMERR_SGI_MONO,

    MMERR_SUN_INIT,

    MMERR_OS2_MIXSETUP,
    MMERR_OS2_SEMAPHORE,
    MMERR_OS2_TIMER,
    MMERR_OS2_THREAD,

    MMERR_DS_PRIORITY,
    MMERR_DS_BUFFER,
    MMERR_DS_FORMAT,
    MMERR_DS_NOTIFY,
    MMERR_DS_EVENT,
    MMERR_DS_THREAD,
    MMERR_DS_UPDATE,

    MMERR_WINMM_HANDLE,
    MMERR_WINMM_ALLOCATED,
    MMERR_WINMM_DEVICEID,
    MMERR_WINMM_FORMAT,
    MMERR_WINMM_UNKNOWN,
 
    MMERR_MAC_SPEED,
    MMERR_MAC_START,

    MMERR_MAX
  );


(*
 *	========== Error handling
 *)

Type
  TMikMod_Handler_Proc = procedure; cdecl;

Var
  MikMod_errno      : integer; {cvar;} external libname;
  MikMod_critical   : BOOL;    cvar; external libname;

  function  MikMod_strerror(err : Integer): PChar; cdecl; external libname;

  function  MikMod_RegisterErrorHandler(newhandler: TMikMod_Handler_Proc): TMikMod_Handler_Proc; cdecl; external libname;


(*
 *	========== Library initialization and core functions
 *)


  procedure MikMod_RegisterAllDrivers; cdecl; external libname;

  function  MikMod_InfoDriver: PChar; cdecl; external libname;
//  procedure MikMod_RegisterDriver(driver: PMDRIVER); cdecl; forward;

  function  MikMod_DriverFromAlias(Alias: PChar): integer; cdecl; external libname;

  function  MikMod_Init(const parameters: PChar): BOOL; cdecl; external libname;
  procedure MikMod_Exit; cdecl; external libname;
  function  MikMod_Reset(const parameters: PChar) : BOOL; cdecl; external libname;
  function  MikMod_SetNumVoices(musicvoices: integer; samplevoices: Integer) : BOOL; cdecl; external libname;
  function  MikMod_Active : BOOL; cdecl; external libname;
  function  MikMod_EnableOutput : BOOL; cdecl; external libname;
  procedure MikMod_DisableOutput; cdecl; external libname;
  procedure MikMod_Update; cdecl; external libname;

  function  MikMod_InitThreads: BOOL; cdecl; external libname;
  procedure MikMod_Lock; cdecl; external libname;
  procedure MikMod_Unlock; cdecl; external libname;


(*
 *  ========== Reader, Writer
 *)

Type
  PMREADER = ^TMREADER;
  TMREADER = 
  record
    Seek        : function(reader: PMREADER; offset: longint; whence: integer): integer; cdecl;
    Tell        : function(reader: PMREADER): longint; cdecl;
    Read        : function(reader: PMREADER; dest: pointer; length: size_t): BOOL; cdecl;
    Get         : function(reader: PMREADER): integer; cdecl;
    Eof         : function(reader: PMREADER): BOOL; cdecl;
    // private
    iobase      : LongInt;
    prev_iobase : LongInt;
  end;
  MREADER = TMREADER;

  PMWRITER = ^TMWRITER;
  TMWRITER =
  record
    Seek : function(writer: PMWRITER; offset: longint; whence: integer): integer; cdecl;
    Tell : function(writer: PMWRITER): longint; cdecl;
    Write: function(writer: PMWRITER; const src: pointer; length: size_t): BOOL; cdecl;
    Put  : function(writer: PMWRITER; data: integer): integer; cdecl;
  end;
  MWRITER = TMWRITER;


(*
 *	========== Samples
 *)

const
  // Sample playback should not be interrupted
  SFX_CRITICAL          = 1;

  // Sample format [loading and in-memory] flags:
  SF_16BITS             = $0001;
  SF_STEREO             = $0002;
  SF_SIGNED             = $0004;
  SF_BIG_ENDIAN         = $0008;
  SF_DELTA              = $0010;
  SF_ITPACKED           = $0020;

  SF_FORMATMASK         = $003F;

  // General Playback flags

  SF_LOOP               = $0040;
  SF_BIDI               = $0080;
  SF_REVERSE            = $0100;
  SF_SUSTAIN            = $0200;

  SF_PLAYBACKMASK       = $03C0;

  // Module-only Playback Flags

  SF_OWNPAN             = $0400;
  SF_UST_LOOP           = $0800;

  SF_EXTRAPLAYBACKMASK  = $0C00;

  // Panning constants
  PAN_LEFT      = 0;
  PAN_HALFLEFT  = 64;
  PAN_CENTER    = 128;
  PAN_HALFRIGHT = 192;
  PAN_RIGHT     = 255;
  PAN_SURROUND  = 512;  // panning value for Dolby Surround

type
  PSAMPLE = ^TSAMPLE;
  TSAMPLE =
  record
    panning     : SWORD;    //* panning (0-255 or PAN_SURROUND) */
    speed       : ULONG;    //* Base playing speed/frequency of note */
    volume      : UBYTE;    //* volume 0-64 */
    inflags     : UWORD;    //* sample format on disk */
    flags       : UWORD;    //* sample format in memory */
    length      : ULONG;    //* length of sample (in samples!) */
    loopstart   : ULONG;    //* repeat position (relative to start, in samples) */
    loopend     : ULONG;    //* repeat end */
    susbegin    : ULONG;    //* sustain loop begin (in samples) \  Not Supported */
    susend      : ULONG;    //* sustain loop end                /      Yet! */

    //* Variables used by the module player only! (ignored for sound effects) */
    globvol     : UBYTE;    //* global volume */
    vibflags    : UBYTE;    //* autovibrato flag stuffs */
    vibtype     : UBYTE;    //* Vibratos moved from INSTRUMENT to SAMPLE */
    vibsweep    : UBYTE;
    vibdepth    : UBYTE;
    vibrate     : UBYTE;
    samplename  : PCHAR;    //* name of the sample */

    //* Values used internally only */
    avibpos     : UWORD;    //* autovibrato pos [player use] */
    divfactor   : UBYTE;    //* for sample scaling, maintains proper period slides */
    seekpos     : ULONG;    //* seek position in file */
    handle      : SWORD;    //* sample handle used by individual drivers */
  End;
  SAMPLE = TSAMPLE;

  //* Sample functions */

  function  Sample_Load(const filename: PCHAR): PSAMPLE; cdecl; external libname;
  {$WARNING Sample_LoadFP() uses file parameter}
  function  Sample_LoadFP(f: integer): PSAMPLE; cdecl; external libname;
  function  Sample_LoadGeneric(reader: PMREADER): PSAMPLE; cdecl; external libname;
  procedure Sample_Free(sample: PSAMPLE); cdecl; external libname;
  function  Sample_Play(sample: PSAMPLE; start: ULONG; flags: UBYTE): SBYTE; cdecl; external libname;

  procedure Voice_SetVolume(voice: SBYTE; volume: UWORD); cdecl; external libname;
  function  Voice_GetVolume(voice: SBYTE): UWORD; cdecl; external libname;
  procedure Voice_SetFrequency(voice: SBYTE; frequency: ULONG); cdecl; external libname;
  function  Voice_GetFrequency(voice: SBYTE): ULONG; cdecl; external libname;
  procedure Voice_SetPanning(voice: SBYTE; panning: ULONG); cdecl; external libname;
  function  Voice_GetPanning(voice: SBYTE): ULONG; cdecl; external libname;
  procedure Voice_Play(voice: SBYTE; sample: PSAMPLE; start: ULONG); cdecl; external libname;
  procedure Voice_Stop(voice: SBYTE); cdecl; external libname;
  function  Voice_Stopped(voice: SBYTE): BOOL; cdecl; external libname;
  function  Voice_GetPosition(voice: SBYTE): SLONG; cdecl; external libname;
  function  Voice_RealVolume(voice: SBYTE): ULONG; cdecl; external libname;


(*
 *	========== Internal module representation (UniMod)
 *)

{*
	Instrument definition - for information only, the only field which may be
	of use in user programs is the name field
*}

const
  //* Instrument note count */
  INSTNOTES = 120;

type
  //* Envelope point */
  PENVPT = ^TENVPT;
  TENVPT = record
    pos : SWORD;
    val : SWORD;
  end;
  ENVPT = TENVPT;  

const
  //* Envelope point count */
  ENVPOINTS = 32;

Type
  //* Instrument structure */
  PINSTRUMENT = ^TINSTRUMENT;
  TINSTRUMENT = record
    insname         : PCHAR;

    flags           : UBYTE;
    samplenumber    : Array[0..Pred(INSTNOTES)] of UWORD;
    samplenote      : Array[0..Pred(INSTNOTES)] of UBYTE;

    nnatype         : UBYTE ;
    dca             : UBYTE ;       //* duplicate check action */
    dct             : UBYTE ;       //* duplicate check type */
    globvol         : UBYTE ;
    volfade         : UWORD ;
    panning         : SWORD ;       //* instrument-based panning var */

    pitpansep       : UBYTE ;       //* pitch pan separation (0 to 255) */
    pitpancenter    : UBYTE ;       //* pitch pan center (0 to 119) */
    rvolvar         : UBYTE ;       //* random volume varations (0 - 100%) */
    rpanvar         : UBYTE ;       //* random panning varations (0 - 100%) */

    //* volume envelope */
    volflg          : UBYTE ;       //* bit 0: on 1: sustain 2: loop */
    volpts          : UBYTE ;
    volsusbeg       : UBYTE ;
    volsusend       : UBYTE ;
    volbeg          : UBYTE ;
    volend          : UBYTE ;
    volenv          : array[0..Pred(ENVPOINTS)] of ENVPT;
    //* panning envelope */
    panflg          : UBYTE ;       //* bit 0: on 1: sustain 2: loop */
    panpts          : UBYTE ;
    pansusbeg       : UBYTE ;
    pansusend       : UBYTE ;
    panbeg          : UBYTE ;
    panend          : UBYTE ;
    panenv          : array[0..Pred(ENVPOINTS)] of ENVPT;
    //* pitch envelope */
    pitflg          : UBYTE ;        //* bit 0: on 1: sustain 2: loop */
    pitpts          : UBYTE ;
    pitsusbeg       : UBYTE ;
    pitsusend       : UBYTE ;
    pitbeg          : UBYTE ;
    pitend          : UBYTE ;
    pitenv          : array[0..Pred(ENVPOINTS)] of ENVPT;
  end;
  INSTRUMENT  = TINSTRUMENT;

  PMP_CONTROL = ^TMP_CONTROL;
  TMP_CONTROL = record end;
  MP_CONTROL  = TMP_CONTROL;

  PMP_VOICE   = ^TMP_VOICE;
  TMP_VOICE   = record end;
  MP_VOICE    = TMP_VOICE;


{*
    Module definition
*}
const
  //* maximum master channels supported */
  UF_MAXCHAN    = 64;

  //* Module flags */
  UF_XMPERIODS  = $0001; //* XM periods / finetuning */
  UF_LINEAR     = $0002; //* LINEAR periods (UF_XMPERIODS must be set) */
  UF_INST       = $0004; //* Instruments are used */
  UF_NNA        = $0008; //* IT: NNA used, set numvoices rather than numchn */
  UF_S3MSLIDES  = $0010; //* uses old S3M volume slides */
  UF_BGSLIDES   = $0020; //* continue volume slides in the background */
  UF_HIGHBPM    = $0040; //* MED: can use >255 bpm */
  UF_NOWRAP     = $0080; //* XM-type (i.e. illogical) pattern break semantics */
  UF_ARPMEM     = $0100; //* IT: need arpeggio memory */
  UF_FT2QUIRKS  = $0200; //* emulate some FT2 replay quirks */
  UF_PANNING    = $0400; //* module uses panning effects or have non-tracker default initial panning */


type
  PMODULE = ^TMODULE;
  TMODULE = record
    //* general module information */
    songname        : PCHAR;        //* name of the song */
    modtype         : PCHAR;        //* string type of module loaded */
    comment         : PCHAR;        //* module comments */

    flags           : UWORD;        //* See module flags above */
    numchn          : UBYTE;        //* number of module channels */
    numvoices       : UBYTE;        //* max # voices used for full NNA playback */
    numpos          : UWORD;        //* number of positions in this song */
    numpat          : UWORD;        //* number of patterns in this song */
    numins          : UWORD;        //* number of instruments */
    numsmp          : UWORD;        //* number of samples */
    instruments     : PINSTRUMENT;  //* all instruments */
    samples         : PSAMPLE;      //* all samples */
    realchn         : UBYTE;        //* real number of channels used */
    totalchn        : UBYTE;        //* total number of channels used (incl NNAs) */

    //* playback settings */
    reppos          : UWORD;        //* restart position */
    initspeed       : UBYTE;        //* initial song speed */
    inittempo       : UWORD;        //* initial song tempo */
    initvolume      : UBYTE;        //* initial global volume (0 - 128) */
    panning         : array[0..Pred(UF_MAXCHAN)] of UWORD; //* panning positions */
    chanvol         : array[0..Pred(UF_MAXCHAN)] of UBYTE; //* channel positions */
    bpm             : UWORD;        //* current beats-per-minute speed */
    sngspd          : UWORD;        //* current song speed */
    volume          : SWORD;        //* song volume (0-128) (or user volume) */

    extspd          : BOOL;         //* extended speed flag (default enabled) */
    panflag         : BOOL;         //* panning flag (default enabled) */
    wrap            : BOOL;         //* wrap module ? (default disabled) */
    loop            : BOOL;         //* allow module to loop ? (default enabled) */
    fadeout         : BOOL;         //* volume fade out during last pattern */

    patpos          : UWORD;        //* current row number */
    sngpos          : SWORD;        //* current song position */
    sngtime         : ULONG;        //* current song time in 2^-10 seconds */

    relspd          : SWORD;        //* relative speed factor */

    //* internal module representation */
    numtrk          : UWORD;        //* number of tracks */
    tracks          : PPUBYTE;      //* array of numtrk pointers to tracks */
    patterns        : PUWORD;       //* array of Patterns */
    pattrows        : PUWORD;       //* array of number of rows for each pattern */
    positions       : PUWORD;       //* all positions */

    forbid          : BOOL;         //* if true, no player update! */
    numrow          : UWORD;        //* number of rows on current pattern */
    vbtick          : UWORD;        //* tick counter (counts from 0 to sngspd) */
    sngremainder    : UWORD;        //* used for song time computation */

    control         : PMP_CONTROL;  //* Effects Channel info (size pf->numchn) */
    voice           : PMP_VOICE;    //* Audio Voice information (size md_numchn) */

    globalslide     : UBYTE;        //* global volume slide rate */
    pat_repcrazy    : UBYTE;        //* module has just looped to position -1 */
    patbrk          : UWORD;        //* position where to start a new pattern */
    patdly          : UBYTE;        //* patterndelay counter (command memory) */
    patdly2         : UBYTE;        //* patterndelay counter (real one) */
    posjmp          : SWORD;        //* flag to indicate a jump is needed... */
    bpmlimit        : UWORD;	    //* threshold to detect bpm or speed values */
  end;
  MODULE = TMODULE;


(*
 *	========== Module loaders
 *)

Type
  PMLOADER = ^TMLOADER;
  TMLOADER = record
  end;
  MLOADER  = TMLOADER;

  function  MikMod_InfoLoader: PChar; cdecl; external libname;
  procedure MikMod_RegisterAllLoaders; cdecl; external libname;
  procedure MikMod_RegisterLoader(newloader: PMLOADER); cdecl; external libname;

var
  load_669: MLOADER; cvar; external libname; //* 669 and Extended-669 (by Tran/Renaissance) */
  load_amf: MLOADER; cvar; external libname; //* DMP Advanced Module Format (by Otto Chrons) */
  load_dsm: MLOADER; cvar; external libname; //* DSIK internal module format */
  load_far: MLOADER; cvar; external libname; //* Farandole Composer (by Daniel Potter) */
  load_gdm: MLOADER; cvar; external libname; //* General DigiMusic (by Edward Schlunder) */
  load_it:  MLOADER; cvar; external libname; //* Impulse Tracker (by Jeffrey Lim) */
  load_imf: MLOADER; cvar; external libname; //* Imago Orpheus (by Lutz Roeder) */
  load_med: MLOADER; cvar; external libname; //* Amiga MED modules (by Teijo Kinnunen) */
  load_m15: MLOADER; cvar; external libname; //* Soundtracker 15-instrument */
  load_mod: MLOADER; cvar; external libname; //* Standard 31-instrument Module loader */
  load_mtm: MLOADER; cvar; external libname; //* Multi-Tracker Module (by Renaissance) */
  load_okt: MLOADER; cvar; external libname; //* Amiga Oktalyzer */
  load_stm: MLOADER; cvar; external libname; //* ScreamTracker 2 (by Future Crew) */
  load_stx: MLOADER; cvar; external libname; //* STMIK 0.2 (by Future Crew) */
  load_s3m: MLOADER; cvar; external libname; //* ScreamTracker 3 (by Future Crew) */
  load_ult: MLOADER; cvar; external libname; //* UltraTracker (by MAS) */
  load_uni: MLOADER; cvar; external libname; //* MikMod and APlayer internal module format */
  load_xm:  MLOADER; cvar; external libname; //* FastTracker 2 (by Triton) */


(*
 *	========== Module player
 *)

  function  Player_Load(Filename: PChar; maxchan: Integer; curious: BOOL): PMODULE; cdecl; external libname;
  // Warn that LoadFP() requires a c stream file parameter
  {$WARNING Player_LoadFP() uses file parameter}
  function  Player_LoadFP(Fil: integer; maxchan: Integer; curious: BOOL): PMODULE; cdecl; external libname;
  function  Player_LoadGeneric(reader: PMREADER; maxchan: integer; curious: BOOL): PMODULE; cdecl; external libname;
  function  Player_LoadTitle(const filename: PChar): PChar; cdecl; external libname;
  // Warn that LoadTitleFP() requires a c stream file parameter
  {$WARNING Player_LoadTitleFP() uses file parameter}
  function  Player_LoadTitleFP(fil: integer): PChar; cdecl; external libname;
  procedure Player_Free(module: PMODULE); cdecl; external libname;
  procedure Player_Start(module: PMODULE); cdecl; external libname;
  function  Player_Active : BOOL; cdecl; external libname;
  procedure Player_Stop; cdecl; external libname;
  procedure Player_TogglePause; cdecl; external libname;
  function  Player_Paused: BOOL; cdecl; external libname;
  procedure Player_NextPosition; cdecl; external libname;
  procedure Player_PrevPosition; cdecl; external libname;
  procedure Player_SetPosition(position: UWORD); cdecl; external libname;
  function  Player_Muted(channel: UBYTE): BOOL; cdecl; external libname;
  procedure Player_SetVolume(volume: SWORD); cdecl; external libname;
  function  Player_GetModule: PMODULE; cdecl; external libname;
  procedure Player_SetSpeed(speed: UWORD); cdecl; external libname;
  procedure Player_SetTempo(tempo: UWORD); cdecl; external libname;
  procedure Player_Unmute(operation: SLONG); cdecl; varargs; external libname;
  procedure Player_Mute(operation: SLONG); cdecl; varargs; external libname;
  procedure Player_ToggleMute(operation: SLONG); cdecl; varargs external libname;
  function  Player_GetChannelVoice(channel: UBYTE): integer; cdecl; external libname;
  function  Player_GetChannelPeriod(channel: UBYTE): UWORD; cdecl; external libname;


Type
  PMikMod_player  = pointer;
  MikMod_player_t = PMikMod_player;

  function  MikMod_RegisterPlayer(newplayer: MikMod_player_t): MikMod_player_t; cdecl; external libname;


const
  MUTE_EXCLUSIVE = 32000;
  MUTE_INCLUSIVE = 32001;


(*
 *	========== Drivers
 *)

const
  MD_MUSIC      = 0;
  MD_SNDFX      = 1;

const
  MD_HARDWARE   = 0;
  MD_SOFTWARE   = 1;


const
  // Mixing flags

  (* These ones take effect only after MikMod_Init or MikMod_Reset *)
  DMODE_16BITS     =  1; (* enable 16 bit output *)
  DMODE_STEREO     =  2; (* enable stereo output *)
  DMODE_SOFT_SNDFX =  4; (* Process sound effects via software mixer *)
  DMODE_SOFT_MUSIC =  8; (* Process music via software mixer *)
  DMODE_HQMIXER    = 16; (* Use high-quality (slower) software mixer *)
  (* These take effect immediately. *)
  DMODE_SURROUND   = 16; (* enable surround sound *)
  DMODE_INTERP     = 32; (* enable interpolation *)
  DMODE_REVERSE    = 64; (* reverse stereo *)


type
  PSAMPLOAD = ^TSAMPLOAD;
  TSAMPLOAD = record end;
  SAMPLOAD  = TSAMPLOAD;

  PMDRIVER  = ^TMDRIVER;
  TMDRIVER  = record
    next                : PMDRIVER;
    Name                : PCHAR;
    Version             : PCHAR;

    HardVoiceLimit      : UBYTE; //* Limit of hardware mixer voices */
    SoftVoiceLimit      : UBYTE; //* Limit of software mixer voices */

    Alias               : PCHAR;

    CommandLine         : procedure(x: PChar); cdecl;
    IsPresent           : function: BOOL; cdecl;
    SampleLoad          : function(x: PSAMPLOAD; y: integer): SWORD; cdecl;
    SampleUnload        : procedure(x: SWORD); cdecl;
    FreeSampleSpace     : function(x:integer): ULONG; cdecl;
    RealSampleLength    : function(x: integer; y: PSAMPLE): ULONG; cdecl;
    init                : function: BOOL; cdecl;
    exit                : procedure; cdecl;
    Reset               : function: BOOL; cdecl;
    SetNumVoices        : function: BOOL; cdecl;
    PlayStart           : function: BOOL; cdecl;
    PlayStop            : procedure; cdecl;
    Update              : procedure; cdecl;
    Pause               : procedure; cdecl;
    VoiceSetVolume      : procedure(voice: UBYTE; vol: UWORD); cdecl;
    VoiceGetVolume      : function(voice: UBYTE): UWORD; cdecl;
    VoiceSetFrequency   : procedure(voice: UBYTE; frq: ULONG); cdecl;
    VoiceGetFrequency   : function(voice: UBYTE): ULONG; cdecl;
    VoiceSetPanning     : procedure(voice: UBYTE; pan: ULONG); cdecl;
    VoiceGetPanning     : function(voice: UBYTE): ULONG; cdecl;
    VoicePlay           : procedure(voice: UBYTE; handle: SWORD; start: ULONG; size: ULONG; reppos: ULONG; repend: ULONG; flags: UWORD); cdecl;
    VoiceStop           : procedure(voice: UBYTE); cdecl;
    VoiceStopped        : function(voice: UBYTE): BOOL; cdecl;
    VoiceGetPosition    : function(voice: UBYTE): SLONG; cdecl;
    VoiceRealVolume     : function(voice: UBYTE): ULONG; cdecl;
  end;
  MDRIVER   = TMDRIVER;


var
  //* These variables can be changed at ANY time and results will be immediate */
  md_volume         : UBYTE; cvar; external libname;//* global sound volume (0-128) */
  md_musicvolume    : UBYTE; cvar; external libname;//* volume of song */
  md_sndfxvolume    : UBYTE; cvar; external libname;//* volume of sound effects */
  md_reverb         : BYTE;  cvar; external libname;//* 0 = none;  15 = chaos */
  md_pansep         : UBYTE; cvar; external libname;//* 0 = mono;  128 == 100% (full left/right) */

  {* The variables below can be changed at any time, but changes will not be
   implemented until MikMod_Reset is called. A call to MikMod_Reset may result
   in a skip or pop in audio (depending on the soundcard driver and the settings
   changed). *}
  md_device         : UWORD; cvar; external libname; //* device */
  md_mixfreq        : UWORD; cvar; external libname; //* mixing frequency */
//  md_mode           : UWORD; cvar; external libname; //* mode. See DMODE_? flags above */
  md_mode           : UWORD; external libname; //* mode. See DMODE_? flags above */

  //* The following variable should not be changed! */
  md_driver         : PMDRIVER; external libname; //* Current driver in use. */

  //* Known drivers list */
  drv_ds            : MDRIVER; cvar; external libname;
  drv_nos           : MDRIVER; cvar; external libname;
  drv_raw           : MDRIVER; cvar; external libname;
  drv_stdout        : MDRIVER; cvar; external libname;
  drv_wav           : MDRIVER; cvar; external libname;
  drv_win           : MDRIVER; cvar; external libname;


implementation


{$IFDEF WINDOWS}
Uses
  Windows;
{$ENDIF}


{$IFDEF AROS}
procedure MikMod_Sleep(ns: longint);
begin
  c_usleep(ns);
end;
{$ENDIF}


{$IFDEF WINDOWS}
procedure MikMod_Sleep(ns: longint);
begin
  Sleep(ns div 1000);
end;
{$ENDIF}

end.
