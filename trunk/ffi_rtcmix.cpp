/**
 * FFI ORIENTED INTERFACE TO RTCMIX 
 * Michael Gogins
 * 16 January 2012
 *
 * This is a plain C calling convention interface to the public methods of RTcmix.
 * It is designed to simplify embedding RTcmix in Lua, Lisp, etc., using 
 * their C calling convention based foreign function interface facilities.
 *
 * This file should be #included at the bottom of RTcmix.cpp.
 */

#include <rt.h>
#include <stdarg.h>

static RTcmix *ffi_cmix = 0;

extern "C"
{
    
  // These declarations should be copied into your LuaJIT FFI cdefs.

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
  int LUA_EXEC(const char *luacode);
  int LUA_INTRO(const char *NAME, const char *luacode);

  /** 
   * The LuaInstrumentState structures 
   * holds basic performance state for the 
   * LUAINST Instrument and permits that state
   * to be passed to and from the actual 
   * Lua instrument code, e.g. it holds 
   * the frame count, input and output buffers, etc.
   * It also holds a pointer to additional
   * instance instrument state that may be defined
   * by the actual Lua instrument code.
   */
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

  void *ffi_create(double tsr, int tnchans, int bsize, const char *opt1, const char *opt2, const char *opt3)
  {
    if (ffi_cmix) {
      advise("ffi_create", "Deleting existing RTcmix object.\n");
      delete ffi_cmix;
      ffi_cmix = 0;
    }
    ffi_cmix = new RTcmix(tsr, tnchans, bsize, opt1, opt2, opt3);
    return ffi_cmix;
  }

  double ffi_cmdval(const char *name)
  {
    double p[MAXDISPARGS];
    double retval;
    retval = ::dispatch(name, p, 0, NULL);
    return(retval);
  }

  double ffi_cmdval_d(const char *name, int n_args, double p0, ...)
  {
    va_list ap;
    int i;
    double p[MAXDISPARGS];
    void   *retval;
    p[0] = p0;
    va_start(ap, p0); // start variable list after p0
    for (i = 1; i < n_args; i++) {
      p[i] = va_arg(ap, double);
    }
    va_end(ap);
    return ::dispatch(name, p, n_args, &retval);
  }

  double ffi_cmdval_s(const char *name, int n_args, const char* p0, ...)
  {
    va_list ap;
    int i;
    char st[MAXDISPARGS][100];
    double p[MAXDISPARGS];
    void *retval;
    strcpy(st[0], p0);
    p[0] = STRING_TO_DOUBLE(st[0]);
    va_start(ap, p0); // start variable list after p0
    for (i = 1; i < n_args; i++) {
      strcpy(st[i], va_arg(ap, char*));
      p[i] = STRING_TO_DOUBLE(st[i]);
    }
    va_end(ap);
    return ::dispatch(name, p, n_args, &retval);
  }

  void *ffi_cmd_d(const char *name, int n_args, double p0, ...)
  {
    va_list ap;
    int i;
    double p[MAXDISPARGS];
    void   *retval;
    p[0] = p0;
    va_start(ap, p0); // start variable list after p0
    for (i = 1; i < n_args; i++) {
      p[i] = va_arg(ap, double);
    }
    va_end(ap);
    (void) ::dispatch(name, p, n_args, &retval);
    return retval;
  }

  void *ffi_cmd_s(const char *name, int n_args, const char* p0, ...)
  {
    va_list ap;
    int i;
    char st[MAXDISPARGS][100];
    double p[MAXDISPARGS];
    void *retval;
    // this kludge dates from the olden days!
    strcpy(st[0], p0);
    p[0] = STRING_TO_DOUBLE(st[0]);
    va_start(ap, p0); // start variable list after p0
    for (i = 1; i < n_args; i++) {
      strcpy(st[i], va_arg(ap, char*));
      p[i] = STRING_TO_DOUBLE(st[i]);
    }
    va_end(ap);
    (void) ::dispatch(name, p, n_args, &retval);
    return retval;
  }

  void *ffi_cmd_l(const char *name, const char *luaname, int n_args, double p0, ...)
  {
    va_list ap;
    int i;
    double p[MAXDISPARGS];
    void   *retval;
    p[0] = STRING_TO_DOUBLE(luaname);
    va_start(ap, p0); // start variable list after p0
    for (i = 1; i < (n_args - 1); i++) {
      p[i] = va_arg(ap, double);
    }
    va_end(ap);
    (void) ::dispatch(name, p, n_args + 1, &retval);
    return retval;
  }

  void ffi_printOn()
  {
    ffi_cmix->printOn();
  }

  void ffi_printOff()
  {
    ffi_cmix->printOff();
  }

  void ffi_close()
  {
    ffi_cmix->close();
  }

  void ffi_destroy()
  {
    if (ffi_cmix) {
      ffi_close();
      delete ffi_cmix;
      ffi_cmix = 0;
    }
  }
}

/**
 * LUAINST -- WRITE RTCMIX INSTRUMENTS IN LUA
 * Michael Gogins
 * 18 January 2012
 *
 * LuaInstrument is a built-in Instrument class 
 * that enables users to define Instrument code in LuaJIT,
 * which is compiled just in time and runs nearly as fast as C.
 * LuaJIT has an FFI facility that enables such Lua 
 * instrument code to call any C function in the process
 * space. This includes most of the RTCmix functions.
 */
#include <Instrument.h>
#include <cstdio>
#include <cstring>
#include <map>
#include <omp.h>
#include <pthread.h>
#include <string>
#include <sys/types.h>
#include <sys/syscall.h>
#include <vector>

extern "C"
{
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
}

struct keys_t
{
  keys_t() : init_key(0), run_key(0) {}
  int init_key;
  int run_key;
};

keys_t &manageLuaReferenceKeys(const lua_State *L, const std::string &name)
{
  static std::map<const lua_State *, std::map<std::string, keys_t> > luaReferenceKeys;
  keys_t *keys = 0;
#pragma omp critical(lc_getrefkey)
  {
    keys = &luaReferenceKeys[L][name];
  }
  return *keys;
}

/**
 * Associate Lua states with threads.
 */
lua_State *manageLuaState()
{
  static std::map<int, lua_State *> luaStatesForThreads;
  lua_State *L = 0;
#pragma omp critical(lc_manageLuaState)
  {
    int threadId = pthread_self();
    if (luaStatesForThreads.find(threadId) == luaStatesForThreads.end())
      {
	L = lua_open();
	luaL_openlibs(L);
	luaStatesForThreads[threadId] = L;
	advise("LUAINST", "Created Lua state %p for thread %d\n.", L, threadId);
      }  
    else
      {
	L = luaStatesForThreads[threadId];
      }	    
  }
  return L;
}

extern "C" 
{
  /**
   * Execute any arbitrary Lua code using
   * the embedded LuaJIT virtual machine.
   * Such code can call back into RTcmix 
   * using the RTcmix FFI functions.
   * 
   * 'Long brackets' can be used to 
   * enclose multi-line strings. And,
   * multi-line strings can be enclosed
   * in other multi-line strings by nesting,
   * e.g. [[ Outer text [=[ Inner text ]=]]].
   * 
   * If the Lua virtual machine is passed, 
   * it is used; if 0 is passed, it will be 
   * created and associated with the calling 
   * thread.
   */
  int LUA_EXEC(const char *luacode)
  {
    static bool registered = false;
    if (!registered) {
      UG_INTRO("LUA_EXEC", LUA_EXEC);
      registered = true;
    }
    lua_State *L = manageLuaState();
    int result = luaL_dostring(L, luacode);
    if (result == 0)
      {
	advise("LUA_EXEC",  "Succeeded: %d\n", result);
      }
    else
      {
	rterror("LUA_EXEC",  "Failed with: %d\n", result);
      }
    return result;
  }

  double lua_exec(float *p, int n, double *pp)
  {
    const char *luacode = DOUBLE_TO_STRING(pp[0]);
    return (double) LUA_EXEC(luacode);
  }

  // Forward declaration.

  extern "C" Instrument *makeLUAINST();
  /**
   * Register a Lua instrument with RTcmix as NAME.
   * NAME must be defined in the Lua code and consists
   * of the following:
   * (1) A LuaJIT FFI cdef that declares the type of 
   *     a NAME C structure containing all state for the 
   *     the instrument. This can be as elaborate as one 
   *     likes, contain arrays and pointers, etc.
   * (2) A Lua NAME_init(LuaInstrumentState) function
   *     that creates and initializes an instance of 
   *     the NAME structure, then assigns its address
   *     to the LuaInstrumentState.instanceState pointer.
   *     This is what associates the Lua instrument 
   *     instance that does all the actual work, with 
   *     the RTCmix C++ LUAINST instance that is 
   *     created and managed by RTcmix.
   * (3) A Lua NAME_run(LuaInstrumentState) function
   *     that performs the same work as a regular 
   *     RTcmix Instrument::run function.
   * Note that any other Lua code in the text also will 
   * be executed. This can be used to install or require 
   * arbitrary Lua modules.
   */
  int LUA_INTRO(const char *NAME, const char *luacode)
  {
    static bool registered = false;
    if (!registered) {
      RT_INTRO("LUAINST", makeLUAINST);
      registered = true;
      advise("LUA_INTRO", "Registered makeLUAINST.\n");
    }
    lua_State *L = manageLuaState();
    advise("LUA_INTRO", "lua_State: %p.", L);
    advise("LUA_INTRO", "Executing Lua code:\n%s\n", luacode);
    int result = luaL_dostring(L, luacode);
    if (result == 0)
      {
	keys_t &keys = manageLuaReferenceKeys(L, NAME);
	advise("LUA_INTRO", "Registering instrument: %s...\n", NAME);
	char init_function[0x100];
	std::snprintf(init_function, 0x100, "%s_init", NAME);
	lua_getglobal(L, init_function);
	if (!lua_isnil(L, 1))
	  {
	    keys.init_key = luaL_ref(L, LUA_REGISTRYINDEX);
	    lua_pop(L, 1);
	  }
	else
	  {
	    rterror("LUA_INTRO", "Failed to register: %s.", init_function);
	  }
	char run_function[0x100];
	std::snprintf(run_function, 0x100, "%s_run", NAME);
	lua_getglobal(L, run_function);
	if (!lua_isnil(L, 1))
	  {
	    keys.run_key = luaL_ref(L, LUA_REGISTRYINDEX);
	    lua_pop(L, 1);
	  }
	else
	  {
	    rterror("LUA_INTRO", "Failed to register: %s.", run_function);
	  }
      }
    else
      {
	warn("LUA_INTRO", "Failed with: %d\n", result);
      }
    advise("LUA_INTRO", "Finished registering %s with result: %d", NAME, result);
    return result;
  }

  double lua_intro(float *p, int n, double *pp)
  {
    const char *NAME = DOUBLE_TO_STRING(pp[0]);
    const char *luacode = DOUBLE_TO_STRING(pp[1]);
    return (double) LUA_INTRO(NAME, luacode);
  }
}

/**
 * LUAINST is actually a wrapper around a Lua "class"
 * that defines a Lua cdef NAME structure containing 
 * instrument state, a NAME_init function that performs
 * the work of any other RTcmix Instrument::init function,
 * and a NAME_run function that performs the work of any 
 * other RTcix Instrument::run function. The actual 
 * Lua instrument state and functions are looked up by 
 * NAME. 
 *
 * The Lua cdef NAME, the NAME_init function, and the 
 * NAME_run function must be defined by calling LUA_INTRO
 * with a chunk of Lua source code.
 */
class LUAINST : public Instrument 
{
public:
  LUAINST() 
  {
    std::memset(&state, 0, sizeof(LuaInstrumentState));        
  }
  virtual ~LUAINST()
  {
    if (state.name) {
      free((void *)state.name);
      state.name = 0;
    }
    if (state.parameters) {
      delete[] state.parameters;
      state.parameters = 0;
    }
    if (state.input) {
      delete[] state.input;
      state.input = 0;
    }
    if (state.output) {
      delete[] state.output;
      state.output = 0;
    }
  }
  /**
   * p0 = Lua instrument name.
   * p1 = Output start time (outskip).
   * p2 = Input start time (inskip).
   * p3 = Input duration.
   * p4 = Audio output gain.
   * pN = User-defined optional parameters.
   */
  virtual int init(double *parameters, int parameterCount)
  {
    state.name = strdup(DOUBLE_TO_STRING(parameters[0]));
    advise("LUAINST::init", "Began...");
    state.parameters = new double[parameterCount];
    state.parameterCount = parameterCount;
    for (int parameterI = 0; parameterI < parameterCount; ++parameterI) {
      state.parameters[parameterI] = parameters[parameterI];
    }
    if (rtsetoutput((float) parameters[1], (float) parameters[2], this) == -1) {
      return DONT_SCHEDULE;
    }
    //if (rtsetinput(parameters[1], this) == -1) {
    //  return DONT_SCHEDULE;
    //}        
    //state.inputChannelCount = inputChannels();
    state.outputChannelCount = outputChannels();
    state.output = new float[outputChannels()];
    // Invoke Lua NAME_init(this->state)
    lua_State *L = manageLuaState();
    keys_t &keys = manageLuaReferenceKeys(L, state.name);
    lua_rawgeti(L, LUA_REGISTRYINDEX, keys.init_key);
    lua_pushlightuserdata(L, &state);
    if (lua_pcall(L, 1, 1, 0) != 0)
      {
	rterror("LUAINST", "Lua error in \"%s_init\": %s.\n", state.name, lua_tostring(L, -1));
      }
    int result = lua_tonumber(L, -1);
    lua_pop(L, 1);
    advise("LUAINST::init", "Ended.");
    return nSamps();
  }
  virtual int configure()
  {
    //state.input = new float[RTBUFSAMPS * inputChannels()];
    return 0;
  }
  virtual int run()
  {
    state.frameCount = framesToRun();
    const int frameCount = framesToRun();    
    //rtgetin(state.input, this, inputSampleCount);
    for (int i = 0; i < frameCount; ++i) {
      if (--state.branch <= 0) {
	doupdate();
	state.branch = getSkip();
      }
      // Invoke Lua NAME_run(this->state).
      lua_State *L = manageLuaState();
      keys_t &keys = manageLuaReferenceKeys(L, state.name);
      lua_rawgeti(L, LUA_REGISTRYINDEX, keys.run_key);
      lua_pushlightuserdata(L, &state);
      if (lua_pcall(L, 1, 1, 0) != 0)
	{
	  die("LUAINST", "Lua error in \"%s_run\": %s, state %p.\n", state.name, lua_tostring(L, -1), L);
	  exit(-1);
	}
      int result = lua_tonumber(L, -1);
      lua_pop(L, 1);
      rtaddout(state.output);
      increment();
    }
    return framesToRun();
  }
private:
  void doupdate()
  {
    //update(state.parameters, state.parameterCount);
  }
  LuaInstrumentState state;
};

/** 
 * Factory function called by RTcmix during 
 * performance to make new instances of a Lua instrument.
 */
Instrument *makeLUAINST()
{
  LUAINST *luainst = new LUAINST();
  luainst->set_bus_config("LUAINST");
  return luainst;
}
