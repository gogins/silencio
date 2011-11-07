local sr = csoundApi.csoundGetSr(csound)
local ksmps = csoundApi.csoundGetKsmps(csound)
csoundApi.csoundMessage(csound, "Samples per second: %8d\n", sr)
csoundApi.csoundMessage(csound, "Frames per kperiod: %8d\n", ksmps)

