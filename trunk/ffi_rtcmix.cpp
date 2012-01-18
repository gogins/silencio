/**
 * F F I   O R I E N T E D   I N T E R F A C E   T O   C M I X
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

#define FFI_MODEL 1

extern "C"
{
    
  // These declarations can be copied into your LuaJIT FFI cdefs.

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

  void *ffi_create(double tsr, int tnchans, int bsize, const char *opt1, const char *opt2, const char *opt3)
  {
    if (ffi_cmix) {
      printf("Deleting existing RTcmix object.\n");
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
 * LuaInstrument is a built-in Instrument class 
 * that enables users to define Instrument code in LuaJIT,
 * which is compiled just in time and runs nearly as fast as C.
 * LuaJIT has an FFI facility that enables such Lua 
 * instrument code to call any C function in the process
 * space. This includes most of the RTCmix functions.
 * This struct must be re-declared, possibly with additional 
 * data members, in an ffi.cdef.
 */
#include <Instrument.h>
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

keys_t &manageLuaReferenceKeys(const lua_State *L, const std::string &opcode, char operation = 'O')
{
    static std::map<const lua_State *, std::map<std::string, keys_t> > luaReferenceKeys;
    keys_t *keys = 0;
#pragma omp critical(lc_getrefkey)
    {
        switch(operation)
        {
        case 'O':
        {
            keys = &luaReferenceKeys[L][opcode];
        }
        break;
        case 'C':
        {

            luaReferenceKeys.erase(L);
        }
        break;
        }
    }
    return *keys;
}

/**
 * Associate Lua states with threads.
 */
lua_State *manageLuaState(char operation = 'O')
{
    static std::map<int, lua_State *> luaStatesForThreads;
    lua_State *L = 0;
#pragma omp critical(lc_manageLuaState)
    {
        int threadId = pthread_self();
        switch(operation)
        {
        case 'O':
        {
            if (luaStatesForThreads.find(threadId) == luaStatesForThreads.end())
            {
                L = lua_open();
                luaL_openlibs(L);
                luaStatesForThreads[threadId] = L;
            }
            else
            {
                L = luaStatesForThreads[threadId];
            }
        }
        break;
        case 'C':
        {
            L = luaStatesForThreads[threadId];
            if (L)
            {
                manageLuaReferenceKeys(L, "", 'C');
            }
            luaStatesForThreads.erase(threadId);
        }
        break;
        }
    }
    return L;
}

struct LuaInstrumentState
{
    double *parameters;
    int parameterCount;
    int frameCount;
    int inputChannelCount;
    float *input;
    int outputChannelCount;
    float *output;
    int branch;
    // This points to a C structure, declared in Lua and defined in NAME_init,
    // which contains instance-specific state. NAME_init must set this pointer 
    // to the address of that structure.
    void *instanceState;
};

int LUA_INTRO(const char *name, const char *luacode)
{
    // LUAINST will use this to look up the 
    // runtime state and methods to call for the 
    // named instrument.
    return 0;
}


class LUAINST : public Instrument 
{
public:
	LUAINST() 
    {
        std::memset(&state, 0, sizeof(state));        
    }
	virtual ~LUAINST()
    {
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
     * p0 = Output start time (outskip).
     * p1 = Input start time (inskip).
     * p2 = Input duration.
     * p3 = Gain.
     * p4 = Lua instrument name.
     */
	virtual int init(double *parameters, int parameterCount)
    {
        state.parameters = new double[parameterCount];
        state.parameterCount = parameterCount;
        for (int parameterI = 0; parameterI < parameterCount; ++parameterI) {
            state.parameters[parameterI] = parameters[parameterI];
        }
        if (rtsetoutput(parameters[0], parameters[2], this) == -1) {
            return DONT_SCHEDULE;
        }
        if (rtsetinput(parameters[1], this) == -1) {
            return DONT_SCHEDULE;
        }        
        const char *name = (const char *)(size_t) parameters[4];
        state.inputChannelCount = inputChannels();
        state.outputChannelCount = outputChannels();
        state.output = new float[outputChannels()];
        // Invoke Lua NAME_init(this->state)
        return nSamps();
    }
	virtual int configure()
    {
        state.input = new float[RTBUFSAMPS * inputChannels()];
        return 0;
    }
	virtual int run()
    {
        state.frameCount = framesToRun();
        const int inputSampleCount = framesToRun() * inputChannels();
        rtgetin(state.input, this, inputSampleCount);
        for (int i = 0; i < inputSampleCount; i += inputChannels()) {
            if (--state.branch <= 0) {
                doupdate();
                state.branch = getSkip();
            }
            // Invoke Lua run.
            rtaddout(state.output);
            increment();
        }
        return framesToRun();
    }
private:
	void doupdate()
    {
        update(state.parameters, state.parameterCount);
    }
    LuaInstrumentState state;
};

Instrument *makeLUAINST()
{
	LUAINST *luainst = new LUAINST();
	luainst->set_bus_config("LUAINST");
	return luainst;
}

//void rtprofile()
//{
//	RT_INTRO("LUAINST", makeLUAINST);
//}

