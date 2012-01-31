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
void *ffi_cmd_l_15(const char *name, const char *luaname, double p1, double p2, double p3, double p4, double p5, double p6, double p7, double p8, double p9, double p10, double p11, double p12, double p13, double p14, double p15);
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
	int parameterCount;
	double *parameters;
  	int inputChannelCount;
  	int inputSampleCount;
  	float *input;
  	int outputChannelCount;
	int outputSampleCount;
  	float *output;
  	int startFrame;
  	int currentFrame;
  	int endFrame;
  	bool initialized;
  	// This points to a C structure, declared as a LuaJIT FFI cdef in Lua code,
  	// which contains state that specifically belongs to an instance of a Lua 
  	// instrument. If such state exists, the NAME_init function must declare 
  	// and define an instance of a C structure containing all elements of that 
  	// state, and set this pointer to the address of that structure. And,
	// the C allocator must be used to allocate this structure so that it will 
	// not be garbage-collected by the Lua runtime.
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
	 local sampleI = 0
	 for currentFrame = luastate.startFrame, luastate.endFrame - 1 do
	     -- print(luastate.startFrame, currentFrame, luastate.endFrame)
	     local t = currentFrame / cmix.ffi_sr()      
	     local w = 2.0 * math.pi * luastate.parameters[5]
             local x = m.sin(w * t)
	     local signal = x * luastate.parameters[4]
	     luastate.output[sampleI] = signal
	     sampleI = sampleI + 1
	     luastate.output[sampleI] = signal
	     sampleI = sampleI + 1
	 end
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
    // OUTPUTS
    double I3;
    double V2;
    double V1;
    // INPUTS
    // sys_variables = system_vars(5:12); % L,R0,C2,G,Ga,Gb,E,C1
    // % x0,y0,z0,dataset_size,step_size
    // integ_variables = [system_vars(14:16),system_vars(1:2)];
    // function TimeSeries = chuacc(L,R0,C2,G,Ga,Gb,C1,E,x0,y0,z0,
    //                              dataset_size,step_size)
    // Circuit elements.
    double L;		
    double R0;	   	
    double C2;	   	
    double G;	   	
    double Ga;	   	
    double Gb;	   	
    // Defaulting to 1 here...
    double E;	   	
    double C1;	   	
    // Initial values...
    double I3;		
    double V2;	   	
    double V1;		
    double step_size; 	
    // STATE
    // Runge-Kutta step sizes.
    double h;	   
    double h2;	   
    double h6;	   
    // Runge-Kutta slopes.
    // NOTE: The original MATLAB code uses 1-based indexing.
    // Although the MATLAB vectors are columns,
    // these are rows; it doesn't matter here.
    // k1 = [0 0 0]';
    double k1[4];
    double k2[4];
    double k3[4];
    double k4[4];
    // Temporary value.
    double M[4];
    // Other variables.
    double step_size;
    double anor;
    double bnor;
    double bnorplus1;
    double alpha;
    double beta;
    double gammaloc;
    double bh;
    double bh2;
    double ch;
    double ch2;
    double omch2;
    double temp;
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
    	chua.step_size = luastate.parameters[ 5]
	print(string.format("step_size: %f", chua.step_size))
    	chua.L =     	 luastate.parameters[ 6]
	print("L:         ", chua.L)
    	chua.R0 =  	 luastate.parameters[ 7]
	print("R0:        ", chua.R0)
    	chua.C2 =  	 luastate.parameters[ 8]
	print("C2:        ", chua.C2)
    	chua.G =   	 luastate.parameters[ 9]
	print("G:         ", chua.G)
    	chua.Ga =  	 luastate.parameters[10]
	print("Ga:        ", chua.Ga)
    	chua.Gb =  	 luastate.parameters[11]
	print("Gb:        ", chua.Gb)
    	chua.C1 =  	 luastate.parameters[12]
	print("C1:        ", chua.C1)
    	chua.I3 =  	 luastate.parameters[13]
	print("I3:        ", chua.I3)
    	chua.V2 =  	 luastate.parameters[14]
	print("V2:        ", chua.V2)
    	chua.V1 =  	 luastate.parameters[15]
	print("V1:        ", chua.V1)
	chua.E = 1.0
	print(string.format("E:         %f", chua.E))
    	chua.M[1] = chua.V1 /  chua.E
    	chua.M[2] = chua.V2 /  chua.E
    	chua.M[3] = chua.I3 / (chua.E * chua.G)
	return 0
end

function CHUA_run(state)
	local luastate = ffi.cast(LuaInstrumentState_ct, state)
	local chua = ffi.cast(CHUAp_ct, luastate.instanceState)
    	-- Recompute Runge-Kutta stuff every buffer, 
	-- in case control variables have changed.
    	chua.h = chua.step_size * chua.G / chua.C2
    	chua.h2 = chua.h / 2.0
    	chua.h6 = chua.h / 6.0
    	chua.anor = chua.Ga / chua.G
    	chua.bnor = chua.Gb / chua.G
    	chua.bnorplus1 = chua.bnor + 1.0
    	chua.alpha = chua.C2 / chua.C1
    	chua.beta = chua.C2 / (chua.L * chua.G * chua.G)
    	chua.gammaloc = (chua.R0 * chua.C2) / (chua.L * chua.G)
    	chua.bh = chua.beta * chua.h
    	chua.bh2 = chua.beta * chua.h2
    	chua.ch = chua.gammaloc * chua.h
    	chua.ch2 = chua.gammaloc * chua.h2
    	chua.omch2 = 1.0 - chua.ch2
     	-- Standard 4th-order Runge-Kutta integration.
	local sampleI = 0
	for currentFrame = luastate.startFrame, luastate.endFrame - 1 do
      	    -- Stage 1.
      	    chua.k1[1] = chua.alpha * (chua.M[2] - chua.bnorplus1 * chua.M[1] - 0.5 * (chua.anor - chua.bnor) * (m.abs(chua.M[1] + 1) - m.abs(chua.M[1] - 1)))
      	    chua.k1[2] = chua.M[1] - chua.M[2] + chua.M[3]
      	    chua.k1[3] = -chua.beta * chua.M[2] - chua.gammaloc * chua.M[3]
      	    -- Stage 2.
      	    local temp = chua.M[1] + chua.h2 * chua.k1[1]
      	    chua.k2[1] = chua.alpha * (chua.M[2] + chua.h2 * chua.k1[2] - chua.bnorplus1 * temp - 0.5 * (chua.anor - chua.bnor) * (m.abs(temp + 1) - m.abs(temp - 1)))
            chua.k2[2] = chua.k1[2] + chua.h2 * (chua.k1[1] - chua.k1[2] + chua.k1[3])
      	    chua.k2[3] = chua.omch2 * chua.k1[3] - chua.bh2 * chua.k1[2]
      	    -- Stage 3.
      	    temp = chua.M[1] + chua.h2 * chua.k2[1]
      	    chua.k3[1] = chua.alpha * (chua.M[2] + chua.h2 * chua.k2[2] - chua.bnorplus1 * temp - 0.5 * (chua.anor - chua.bnor) * (m.abs(temp + 1) - m.abs(temp - 1)))
            chua.chua.k3[2] = chua.k1[2] + chua.h2 * (chua.k2[1] - chua.k2[2] + chua.k2[3])
      	    chua.k3[3] = chua.k1[3] - chua.bh2 * chua.k2[2] - chua.ch2 * chua.k2[3]
      	    -- Stage 4.
      	    temp = chua.M[1] + chua.h * chua.k3[1]
      	    chua.k4[1] = chua.alpha * (chua.M[2] + chua.h * chua.k3[2] - chua.bnorplus1 * temp - 0.5 * (chua.anor - chua.bnor) * (m.abs(temp + 1) - m.abs(temp - 1)))
      	    chua.k4[2] = chua.k1[2] + chua.h * (chua.k3[1] - chua.k3[2] + chua.k3[3])
      	    chua.k4[3] = chua.k1[3] - chua.bh * chua.k3[2] - chua.ch * chua.k3[3]
      	    -- TODO Unroll: M = M + (k1 + 2*k2 + 2*k3 + k4)*(h6)
	    for j = 0, 3 do
	    	chua.M[j] = chua.M[j] + (chua.k1[j] + 2 * chua.k2[j] + 2 * chua.k3[j] + chua.k4[j]) * (chua.h6)
	    end
	    -- Pick one of the following time series as the output signal:
      	    -- TimeSeries(3,i+1) = E*M(1)
	    local signal = chua.E * chua.M[1]
	    -- V1[i] = E * M(1)
      	    -- TimeSeries(2,i+1) = E*M(2)
      	    -- V2[i] = E * M(2)
      	    -- TimeSeries(1,i+1) = (E*G)*M(3)
      	    -- I3[i] = (E * G) * M(3)
	    luastate.output[sampleI] = signal
	    sampleI = sampleI + 1
	    luastate.output[sampleI] = signal
	    sampleI = sampleI + 1
        end
	return 0
end

]])

-- Torus attractor from the gallery of attractors.

local outskip = 20.0
local inskip = 0.0
local dur = 20.0
cmix.ffi_cmd_l_15("LUAINST", "CHUA", outskip,	inskip,	dur,	1500.00000000000000,	0.10000000000000,	-0.00707925000000,	0.00001647000000,	100.00000000000000,	1.00000000000000,	-0.99955324000000,	-1.00028375000000,	-0.00222159000000,	-2.36201596260071, 0.00308917625807, 3.87075614929199)

--[[

p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	p11	p12	p13	p14	p15
outskip	inskip	dur	amp	stepsize	L	R0	C2	G	Ga	Gb	C1	I3	V2	V1
outskip	inskip	dur	1500.00000000000000	0.10000000000000	-0.00707925000000	0.00001647000000	100.00000000000000	1.00000000000000	-0.99955324000000	-1.00028375000000	-0.00222159000000	-2.36201596260071	0.00308917625807	3.87075614929199
outskip	inskip	dur	1500.00000000000000	0.42500000000000	1.35061680000000	0.00000000000000	-4.50746268737000	-1.00000000000000	2.49240000000000	0.93000000000000	1.00000000000000	-22.28662665000000	0.00950660800000	-22.28615760000000
outskip	inskip	dur	1024.00000000000000	0.05000000000000	0.00667000000000	0.00065100000000	10.00000000000000	-1.00000000000000	0.85600000000000	1.10000000000000	0.06000000000000	-20.20059013366700	0.17253932356834	-4.07686233520508

cmix.ffi_cmd_l_15("LUAINST", "CHUA", 25, outskip, 0, dur, 1500, .1, -1, -1, -0.00707925, 0.00001647, 100, 1, -0.99955324, -1.00028375, 1, -0.00222159, 204.8, -2.36201596260071, 3.08917625807226e-03, 3.87075614929199, 7, 0.4, 0.004, 1, 86, 30)

-- Heteroclinic orbit.

outskip = outskip + 21
cmix.ffi_cmd_l("LUAINST", "CHUA", 25, outskip, 0, dur, 1500, .425,  0, -1,  1.3506168,  0, -4.50746268737, -1, 2.4924, .93, 1, 1, 0, -22.28662665, .009506608, -22.2861576, 32, 10, 2, 20, 86, 30)

-- Periodic attractor (torus breakdown route).

outskip = outskip + 21
cmix.ffi_cmd_l("LUAINST", "CHUA", 25, outskip, 0, dur, 1024, .05,  -1, -1,  0.00667, 0.000651, 10, -1, .856, 1.1, 1, .06, 51.2, -20.200590133667, .172539323568344, -4.07686233520508, 2.5, 10, .2, 1, 66, 81)

-- Torus attractor (torus breakdown route).

outskip = outskip + 21
cmix.ffi_cmd_l("LUAINST", "CHUA", 25, outskip, 0, dur, 1024, 0.05, -1, -1, 0.00667, 0.000651, 10, -1, 0.856, 1.1, 1, 0.1, 153.6, 21.12496758, 0.03001749, 0.515828669, 2.5, 10, 0.2, 1, 66, 81)
--]]
print[[

Press [Ctrl-C] to exit...

]]

while true do
      ffi.C.sleep(1)
end



