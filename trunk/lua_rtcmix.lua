print('Hello, this is RTcmix from Lua.')
local jit = require('jit')
local ffi = require('ffi')
local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so')
-- Declare mangled C++ functions so they can be called as C.
-- They all seem to be static, and the RTcmix constructors don't do anything but 
-- call them, so that makes it easier.
ffi.cdef[[
//	static void RTcmix::init_globals(bool fromMain, const char *defaultDSOPath);
void _ZN6RTcmix12init_globalsEbPKc(bool fromMain, const char *defaultDSOPath);
//	void RTcmix::init(float, int, int, const char*, const char*, const char*);	// called by all constructors
void _ZN6RTcmix4initEfiiPKcS1_S1_(int, float, int, int, const char*, const char*, const char*);
]]
cmix._ZN6RTcmix12init_globalsEbPKc(false, "/home/mkg/RTcmix/shlib")
-- Pass 0 as 'this' pointer which is not actually used (otherwise, CRASH!).
cmix._ZN6RTcmix4initEfiiPKcS1_S1_(0, 44100, 2, 0, 'device = plughw:1', none, none)
print('Done.')




