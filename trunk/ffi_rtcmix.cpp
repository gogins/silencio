/**
 * FFI ORIENTED INTERFACE TO RTCMIX 
 * Michael Gogins
 * 16 January 2012
 *
 * This is a plain C calling convention interface to the public methods of RTcmix.
 * It is designed to simplify embedding RTcmix in Lua, Lisp, etc., using 
 * their C calling convention based foreign function interface facilities.
 *
 * This file should be #included at the bottom of RTcmix.cpp. This file does
 * not require any linkage to Lua or to OpenMP.
 */

#include <rt.h>
#include <stdarg.h>
#include <map>
#include <string>

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
  void *ffi_cmd_l(const char *name, const char *luaname, int n_args, ...);
  void ffi_printOn();
  void ffi_printOff();
  void ffi_close();
  void ffi_destroy();
  int LUA_INTRO(const char *NAME, const char *luacode);
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

  void *ffi_cmd_l(const char *name, const char *luaname, int n_args, ...)
  {
    double p[MAXDISPARGS];
    void   *retval;
    p[0] = STRING_TO_DOUBLE(luaname);
    int i;
    va_list ap;
    va_start(ap, n_args);
    for (i = 0; i < n_args; i++) {
      p[i + 1] = va_arg(ap, double);
    }
    va_end(ap);
    n_args++;
    for (i = 0; i < n_args; i++) 
      {
	printf("ffi_cmd_l: p[%d] = %f\n", i, p[i]);
      }
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

