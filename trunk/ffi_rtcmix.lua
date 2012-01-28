print[[

=============================================================
H E L L O ,   T H I S   I S   R T C M I X   F R O M   L U A .
Example code by Michael Gogins
25 January 2012
=============================================================

]]

-- Load the just-in-time compiler
-- and its foreign function interface library.

local jit = require('jit')
local ffi = require('ffi')

-- Declare to the FFI library the functions that we need,
-- using basic C synatax. Note that "RTcmix *" has become "void *"
-- because we do not wish to declare the type of RTcmix to FFI.
-- Note that [[ begins a multi-line string constant and ]] ends it.

ffi.cdef[[

// RTCmix types.

void *ffi_create(double tsr, int tnchans, int bsize, const char *opt1, const char *opt2, const char *opt3);
double ffi_cmdval(const char *name);
double ffi_cmdval_d(const char *name, int n_args, double p0, ...);
double ffi_cmdval_s(const char *name, int n_args, const char* p0, ...);
void *ffi_cmd_d(const char *name, int n_args, double p0, ...);
void *ffi_cmd_s(const char *name, int n_args, const char* p0, ...);
void *ffi_cmd_l(const char *name, const char *luaname, int n_args, ...);
void ffi_printOn();
void ffi_printOff();
void ffi_close();
void ffi_destroy();
int advise(const char*, const char *,...);
int warn(const char*, const char *,...);
int rterror(const char*, const char *,...);
int die(const char*, const char *,...);

// Operating system and runtime library functions.

unsigned int sleep(unsigned int seconds);

]]

-- Load the RTcmix library. Note that symbols must be loaded as globals, 
-- so they can be referenced by instruments that RTcmix, later on,
-- will itself dynamically load.

local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so', true)

-- Now we are ready to actually use RTcmix in the usual way.
-- It seems to be necessary to pass the device selection to the creator.

cmix.ffi_create(44100, 2, 4096, 'device=plughw', nil, nil)
ffi.C.sleep(1)
cmix.ffi_printOn()

-- Because all FFI functions are typed as C, there are no
-- parameter type overloads; hence the FFI function names end with _s or _d 
-- to indicate whether they have string or double varargs.

print[[
============================================
First, we create and perform a score in Lua.
============================================
]]

cmix.ffi_cmd_s("load", 1, "METAFLUTE")
cmix.ffi_cmd_d("makegen", 7, 1.0, 24.0, 1000.0, 0.0, 1.0, 1.0, 1.0)
cmix.ffi_cmd_d("makegen", 11, 2.0, 24.0, 1000.0, 0.0, 0.0, 0.05, 1.0, 0.95, 1.0, 1.0, 0.0)
cmix.ffi_cmd_d("SFLUTE", 7, 0.0, 1.0, 0.1, 106.0, 25.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 1.0, 1.0, 0.1, 95.0, 21.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 2.0, 1.0, 0.1, 89.0, 19.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 3.0, 1.0, 0.1, 75.0, 19.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 4.0, 1.0, 0.1, 70.0, 15.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 5.0, 1.0, 0.1, 67.0, 16.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 6.0, 1.0, 0.1, 56.0, 17.0, 5000.0, 0.5)
cmix.ffi_cmd_d("SFLUTE", 7, 7.0, 1.0, 0.1, 53.0, 25.0, 5000.0, 0.5)

print[[

=======================================================
Next, a totally rudimentary synthesizer written in Lua!
=======================================================

]]

cmix.ffi_cmd_s("load", 1, "LUAINST")
--[[
The next line is key. We are registering the Lua instrument
LUA_OSC's Lua code, using the lua_intro function that the 
LUAINST library has loaded into RTcmix.

The double brackets enclose Lua multi-line string constants;
zero or more equals signs within the brackets denote zero or 
more levels of nesting.
]]
cmix.ffi_cmd_s("lua_intro", 2, "LUA_OSC", [[
local ffi = require('ffi')
local math = require('math')
local m = ffi.load('m')
ffi.cdef[=[
  double sin(double);
  void *ffi_create(double tsr, int tnchans, int bsize, const char *opt1, const char *opt2, const char *opt3);
  double ffi_cmdval(const char *name);
  double ffi_cmdval_d(const char *name, int n_args, double p0, ...);
  double ffi_cmdval_s(const char *name, int n_args, const char* p0, ...);
  void *ffi_cmd_d(const char *name, int n_args, double p0, ...);
  void *ffi_cmd_s(const char *name, int n_args, const char* p0, ...);
  void *ffi_cmd_l(const char *name, const char *luaname, int n_args, ...);
  void ffi_printOn();
  void ffi_printOff();
  void ffi_close();
  int ffi_bufsamps();
  float ffi_sr(); 
  int ffi_chans(); 
  long ffi_getElapsedFrames(); 
  void ffi_destroy();
  int LUA_INTRO(const char *NAME, const char *luacode);
  int advise(const char*, const char *,...);
  double cpsoct(double oct);
  double octcps(double cps);
  double octpch(double pch);
  double cpspch(double pch);
  double pchoct(double oct);
  double pchcps(double cps);
  double midipch(double pch);
  double pchmidi(unsigned char midinote);
  double octmidi(unsigned char midinote);
  void *calloc(size_t num, size_t size);	
  struct LuaInstrumentState
  {
    char *name;
    double *parameters;
    int parameterCount;
    int frameI;
    int frameCount;
    int inputChannelCount;
    int inputSampleCount;
    float *input;
    int outputChannelCount;
    float *output;
    int branch;
    long currentFrame;
    bool initialized;
    // This points to a C structure, declared as a LuaJIT FFI cdef in Lua code,
    // which contains state that specifically belongs to an instance of a Lua 
    // instrument. If such state exists, the NAME_init function must declare 
    // and define an instance of a C structure containing all elements of that 
    // state, and set this pointer to the address of that structure.
    void *instanceState;
  };
]=]

-- Obtain a ctype for a pointer to the LuaInstrumentState struct,
-- for greater efficiency.

local LuaInstrumentState_ct = ffi.typeof("struct LuaInstrumentState *");

-- We may, if we wish, load RTcmix into the symbol table for the Lua instrument.

local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so', true)

function LUA_OSC_init(state)
	-- Type casting the ctype for LuaInstrumentState enables us to 
	-- access members of that type as though they are Lua variables.
	local luastate = ffi.cast(LuaInstrumentState_ct, state)
	cmix.advise('LUA_OSC', string.format('outskip: %9.4f  inskip: %9.4f  dur: %9.4f  amp: %9.4f  freq: %9.4f', luastate.parameters[1], luastate.parameters[2], luastate.parameters[3], luastate.parameters[4], luastate.parameters[5]))
	return 0
end

function LUA_OSC_run(state)
	 -- Type casting the ctype for LuaInstrumentState enables us to 
	 -- access members of that type as though they are Lua variables.
	 local luastate = ffi.cast(LuaInstrumentState_ct, state)
	 local t = luastate.currentFrame / cmix.ffi_sr()
	 local w = 2.0 * math.pi * luastate.parameters[5]
         local x = m.sin(w * t)
	 local signal = x * luastate.parameters[4]
	 luastate.output[0] = signal
	 luastate.output[1] = signal
	 return 0
end

]])

-- The ffi_cmd_l function invokes a Lua instrument; there is a second
-- string name for the actual Lua instrument class defined above.
-- This function could be invoked from Minc or any other language as it is 
-- now a loaded and bound CMIX function.

cmix.ffi_cmd_l("LUAINST", "LUA_OSC", 5,  9.0, 0.0, 5.0, 4000.0, 440.00)
cmix.ffi_cmd_l("LUAINST", "LUA_OSC", 5, 10.0, 0.0, 5.0, 4000.0, 554.37)
cmix.ffi_cmd_l("LUAINST", "LUA_OSC", 5, 11.0, 0.0, 5.0, 4000.0, 659.26)

print[[

====================================
Chua's oscillator written in Lua!...
====================================

]]

cmix.ffi_cmd_s("lua_intro", 2, "CHUA", [[
local ffi = require('ffi')
local math = require('math')
local m = ffi.load('m')
ffi.cdef[=[

  struct CHUA 
  {
	/* Non-linear resistor parameters */
	double Bp1;
	double Bp2;
	double m0;
	double m1;
	double m2;
	/* State variables */
	double Vc1;
	double Vc2;
	double I1;		
	/* Derivatives of state variables */
	double dVc1;
	double dVc2;
	double dI1;
	double L;
	double C1;
	double C2;
	/* Time scaled values of L,C1 and C2 */
	double Ls;
	double C1s;
	double C2s;		
	/* Used for time scaling */
	double tscale;			
	/* Frequency of fundamental harmonic */
	double freq;		
	/* Time increment of each differential step */
	double tstep;			
	double G1;
	double G2;
	double waitc;
  };
]=]

local LuaInstrumentState_ct = ffi.typeof("struct LuaInstrumentState *")
local CHUA_ct = ffi.typeof("struct CHUA")
local CHUAp_ct = ffi.typeof("struct CHUA *")
local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so', true)

function CHUA_init(state)
	local luastate = ffi.cast(LuaInstrumentState_ct, state)
	luastate.instanceState = ffi.C.calloc(1, ffi.sizeof(CHUA_ct))
	local chua = ffi.cast(CHUAp_ct, luastate.instanceState)
	cmix.advise('CHUA', '%s', tostring(chua))
	cmix.advise('CHUA', 'p[ 1] outskip: %9.4f', luastate.parameters[ 1])
	cmix.advise('CHUA', 'p[ 2] inskip:  %9.4f', luastate.parameters[ 2])
	cmix.advise('CHUA', 'p[ 3] dur:     %9.4f', luastate.parameters[ 3])
	cmix.advise('CHUA', 'p[ 4] amp:     %9.4f', luastate.parameters[ 4])
	chua.freq = 	    	   	    	    cmix.cpsoct(cmix.octmidi(luastate.parameters[ 5]))
	cmix.advise('CHUA', 'p[ 5] freq :   %9.4f', chua.freq) 
	chua.L     = 	    	   	    	    luastate.parameters[ 6]
	cmix.advise('CHUA', 'p[ 6] L:       %9.4f', chua.L) 
	chua.C1    = 	    	   	    	    luastate.parameters[ 7]
	cmix.advise('CHUA', 'p[ 7] C1:      %9.4f', chua.C1) 
	chua.C2    = 	    	   	    	    luastate.parameters[ 8]
	cmix.advise('CHUA', 'p[ 8] C2:      %9.4f', chua.C2) 
	chua.G1    = 	    	   	    	    luastate.parameters[ 9]
	cmix.advise('CHUA', 'p[ 9] G:       %9.4f', chua.G1) 
	chua.Bp1   = 	    	   	    	    luastate.parameters[10]
	cmix.advise('CHUA', 'p[10] Bp1:     %9.4f', chua.Bp1) 
	chua.Bp2   = 	    	   	    	    luastate.parameters[11]
	cmix.advise('CHUA', 'p[11] Bp2:     %9.4f', chua.Bp2) 
	chua.m0    = 	    	   	    	    luastate.parameters[12]
	cmix.advise('CHUA', 'p[12] m0:      %9.4f', chua.m0) 
	chua.m1    = 	    	   	    	    luastate.parameters[13]
	cmix.advise('CHUA', 'p[13] m1:      %9.4f', chua.m1) 
	chua.m2 = 	    	   	    	    luastate.parameters[14]
	cmix.advise('CHUA', 'p[14] m2:      %9.4f', chua.m2)
	chua.tscale = 0.325 / chua.freq
	chua.waitc = 20
	chua.tstep = 1.0 / chua.waitc * 1 / cmix.ffi_sr()
	chua.Vc1 = 0
	chua.Vc2 = 0.1
	chua.I1 = 0
	chua.Ls = chua.tscale * chua.L
	chua.C1s = chua.tscale * chua.C1
	chua.C2s = chua.tscale * chua.C2
	return 0
end

function CHUA_run(state)
	local luastate = ffi.cast(LuaInstrumentState_ct, state)
	local chua = ffi.cast(CHUAp_ct, luastate.instanceState)
	if chua.Vc1 < chua.Bp1 then
	   chua.G2 = chua.m0 * (chua.Vc1 - chua.Bp1) + chua.m1 * chua.Bp1
	end
	if (chua.Vc1 >= chua.Bp1) and (chua.Vc1 <= chua.Bp2) then 
	   chua.G2 = chua.m1 * chua.Vc1
	end
	if chua.Vc1 > chua.Bp2 then
	   chua.G2 = chua.m2 * (chua.Vc1 - chua.Bp2) + chua.m1 * chua.Bp2
	end
	chua.dVc1 = (chua.G1 * (chua.Vc2 - chua.Vc1) - chua.G2) / chua.C1s 
	chua.dVc2 = (chua.G1 * (chua.Vc1 - chua.Vc2) + chua.I1) / chua.C2s
	chua.dI1 = - chua.Vc2 / chua.Ls
	chua.Vc1 = chua.Vc1 + chua.dVc1 * chua.tstep
	chua.Vc2 = chua.Vc2 + chua.dVc2 * chua.tstep
	chua.I1 = chua.I1 + chua.dI1 * chua.tstep
	luastate.output[0] = chua.Vc1 * luastate.parameters[4]
	luastate.output[1] = chua.Vc1 * luastate.parameters[4]
	--print (luastate.output[0])
	return 0
end

]])

cmix.ffi_cmd_l("LUAINST", "CHUA", 14, 16.0, 0.0, 120.0, 4000.0, 48.0, 0.142857, 0.111111, 1, 0.7, -1, 1, -0.5, -0.8, -0.5)

print[[

Press Control-C to exit....'

]]

while true do
      ffi.C.sleep(1)
end



