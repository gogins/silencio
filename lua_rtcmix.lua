print('Hello, this is RTcmix from Lua.')

local jit = require('jit')
local ffi = require('ffi')
local cmix = ffi.load('/home/mkg/RTcmix/lib/librtcmix.so')
print('cmix:', cmix)
ffi.cdef[[
void ff_create();
void ff_create2(double tsr, int tnchans);
void ff_create6(double tsr, int tnchans, int bsize, const char *opt1, const char *opt2, const char *opt3);
double ff_cmdval(const char *name);
double ff_cmdval_d(const char *name, int n_args, double p0, ...);
double ff_cmdval_s(const char *name, int n_args, const char* p0, ...);
void *ff_cmd_d(const char *name, int n_args, double p0, ...);
void *ff_cmd_s(const char *name, int n_args, const char* p0, ...);
void ff_printOn();
void ff_printOff();
void ff_run();
void ff_close();
void ff_destroy();
unsigned int sleep(unsigned int seconds);
]]

cmix.ff_create6(44100, 2, 128, "device=hw:1", nil, nil)
ffi.C.sleep(1)
cmix.ff_printOn()
cmix.ff_cmd_s("load", 1, "STRUM")
cmix.ff_cmd_d("makegen", 7, 1.0, 24.0, 1000.0, 0.0, 1.0, 1.0, 1.0);
cmix.ff_cmd_d("makegen", 11, 2.0, 24.0, 1000.0, 0.0, 0.0, 0.05, 1.0, 0.95, 1.0, 1.0, 0.0);
cmix.ff_cmd_d("STRUM", 7, 0.0, 1.0, 0.1, 106.0, 25.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 1.0, 1.0, 0.1, 95.0, 21.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 2.0, 1.0, 0.1, 89.0, 19.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 3.0, 1.0, 0.1, 75.0, 19.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 4.0, 1.0, 0.1, 70.0, 15.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 5.0, 1.0, 0.1, 67.0, 16.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 6.0, 1.0, 0.1, 56.0, 17.0, 5000.0, 0.5);
cmix.ff_cmd_d("STRUM", 7, 7.0, 1.0, 0.1, 53.0, 25.0, 5000.0, 0.5);
ffi.C.sleep(8)
print('Done.')




