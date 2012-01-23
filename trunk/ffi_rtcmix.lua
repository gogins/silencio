print()
print('H E L L O ,   T H I S   I S   R T C M I X   F R O M   L U A .')
print('Example code by Michael Gogins')
print('16 January 2012')
print()

-- Load the just-in-time compiler
-- and the foreign function interface library.

local jit = require('jit')
local ffi = require('ffi')

-- Declare to LuaJIT's FFI library the functions that we need,
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
  int LUA_EXEC(const char *luacode);
  int LUA_INTRO(const char *NAME, const char *luacode);

  struct LuaInstrumentState
 {
    char *name;
    double *parameters;
    int parameterCount;
    int frameCount;
    int inputChannelCount;
    float *input;
    int outputChannelCount;
    float *output;
    int branch;
    // This points to a C structure, declared as a LuaJIT FFI cdef in Lua code,
    // which contains state that specifically belongs to an instance of a Lua 
    // instrument. If such state exists, the NAME_init function must declare 
    // and define an instance of a C structure containing all elements of that 
    // state, and set this pointer to the address of that structure.
    void *instanceState;
  };

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
-- to indicate that they they have a string or a double first vararg.

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

cmix.LUA_EXEC([=[
print[[

This is a string, printed by executing a multi-line chunk of Lua code inside RTcmix.

And, it should be a multi-line string. This is done by nesting different levels of 'long brackets.'
]]]=])
print()

print('Now for the piece de resistance -- a synthesizer written in Lua!')

cmix.LUA_INTRO("LUA_OSC", [=[
local ffi = require('ffi')
-- The Lua virtual machine used by Instruments is not the same as the 
-- one that is running the RTcmix performance, so stuff has to be declared again.
ffi.cdef[[

// RTCmix types.

  void *ffi_create(double tsr, int tnchans, int bsize, const char *opt1, const char *opt2, const char *opt3);
  double ffi_cmdval(const char *name);
  double ffi_cmdval_d(const char *name, int n_args, double p0, ...);
  double ffi_cmdval_s(const char *name, int n_args, const char* p0, ...);
  void *ffi_cmd_d(const char *name, int n_args, double p0, ...);
  void *ffi_cmd_s(const char *name, int n_args, const char* p0, ...);
  void ffi_printOn();
  void ffi_printOff();
  void ffi_close();
  void ffi_destroy();
  int LUA_EXEC(const char *luacode);
  int LUA_INTRO(const char *NAME, const char *luacode);

  struct LuaInstrumentState
 {
    char *name;
    double *parameters;
    int parameterCount;
    int frameCount;
    int inputChannelCount;
    float *input;
    int outputChannelCount;
    float *output;
    int branch;
    // This points to a C structure, declared as a LuaJIT FFI cdef in Lua code,
    // which contains state that specifically belongs to an instance of a Lua 
    // instrument. If such state exists, the NAME_init function must declare 
    // and define an instance of a C structure containing all elements of that 
    // state, and set this pointer to the address of that structure.
    void *instanceState;
  };

// Operating system and runtime library functions.

unsigned int sleep(unsigned int seconds);

]]
local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so', true)
print('RTcmix again, from inside RTcmix:', cmix)
print('Hello from inside Lua code being registered.')

function LUA_OSC_init(state)
	print('Hello from inside LUA_OSC_init()...')
	return 0
end

function LUA_OSC_run(state)
	 return 0
end
print('End of Lua code being registered.')
]=])

cmix.ffi_cmd_l("LUAINST", "LUA_OSC", 6, 8.0, 1.0, 0.1, 1.0, 53.0, 25.0)

-- Give the RTcmix performance thread time to do its work.

ffi.C.sleep(17)
print()



