print[[

=============================================================
H E L L O ,   T H I S   I S   R T C M I X   F R O M   L U A .
Example code by Michael Gogins
16 January 2012
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
void *ffi_cmd_l(const char *name, const char *luaname, int n_args, double p0, ...);
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
-- to indicate that they they have string or double varargs.

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

==============================================================
Next, the piece de resistance -- a synthesizer written in Lua!
==============================================================

]]

cmix.ffi_cmd_s("load", 1, "LUAINST")
--[[
The next line is key. We are registering the Lua instrument
LUA_OSC's Lua code, using the lua_intro function that has been 
loaded into RTcmix.

The double brackets enclose Lua multi-line string constants;
zero or more equals signs within the brackets denote zero or 
more levels of nesting.
]]
cmix.ffi_cmd_s("lua_intro", 2, "LUA_OSC", [=[
local ffi = require('ffi')
local math = require('math')
local m = ffi.load('m')
ffi.cdef[[
  double sin(double);
  int advise(const char*, const char *,...);
  struct LuaInstrumentState
  {
    char *name;
    double *parameters;
    int parameterCount;
    int frameI;
    int frameCount;
    int inputChannelCount;
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
]]

-- Obtain a cdef for the LuaInstrumentState struct,
-- for greater efficiency.

local LuaInstrumentState_ct = ffi.typeof("struct LuaInstrumentState *");
print('LuaInstrumentState_ct:', LuaInstrumentState_ct)

-- We may, if we wish, load RTcmix into the symbol table for the Lua instrument.

local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so', true)

cmix.advise('LUA', 'Hello from inside Lua code being registered.')

function LUA_OSC_init(state)
	local luastate = ffi.cast(LuaInstrumentState_ct, state)
	cmix.advise('LUA', string.format('outskip: %9.4f  inskip: %9.4f  dur: %9.4f  amp: %9.4f  freq: %9.4f', luastate.parameters[0], luastate.parameters[1], luastate.parameters[2], luastate.parameters[3], luastate.parameters[4]))
	return 0
end

function LUA_OSC_run(state)
	 local luastate = ffi.cast(LuaInstrumentState_ct, state)
	 --print(string.format('run: frame %5d of %5d  branch: %5d', luastate.currentFrame, luastate.frameCount, luastate.branch))
	 local t = (luastate.currentFrame / 44100.0)
	 local x = 2.0 * math.pi * t * luastate.parameters[5]
	 local signal = m.sin(t) * luastate.parameters[4]
	 --print(signal)
	 luastate.output[0] = signal
	 luastate.output[1] = signal
	 return 0
end

print('End of Lua code being registered.')
]=])

cmix.ffi_cmd_l("LUAINST", "LUA_OSC", 5, 8.0, 0.0, 5.0, 4000.0, 440.0)

-- Give the RTcmix performance thread time to do its work.

ffi.C.sleep(17)
print()



