<CsoundSynthesizer>

<CsInstruments>

sr      = 48000
ksmps   = 100
nchnls  = 2

; Lua code to generate a score in the orchestra header.

lua_exec {{
local ffi = require("ffi")
local math = require("math")
local string = require("string")
local silencio = require("silencio")
local csoundApi = ffi.load('csound64.dll.5.2')
-- Declare the parts of the Csound API that we need.
-- You must declare MYFLT as double or float as the case may be.
ffi.cdef[[
    int csoundGetKsmps(void *);
    double csoundGetSr(void *);
    int csoundInputMessage(void *, const char *);
    int csoundScoreEvent(void *, char type, const double *, int);
    int csoundMessage(void *, const char *, ...);
]]
csoundApi.csoundMessage(csound, "package.path:      %s\\n", package.path)
csoundApi.csoundMessage(csound, "csound:            0x%08x\\n", csound)
local framesPerSecond = csoundApi.csoundGetSr(csound)
csoundApi.csoundMessage(csound, "frames per second: %8d\\n", framesPerSecond)
local framesPerTick = csoundApi.csoundGetKsmps(csound)
csoundApi.csoundMessage(csound, "frames per tick:   %8d\\n", framesPerTick)

-- Compute a score using the logistic equation.

local c = .93849
local y = 0.5
local y1 = 0.5
local interval = 0.25
local duration = 0.5
local insno = 1
local scoretime = 0.5
local score = Score:new()
score:setCsound(csound, csoundApi)
score:setTitle('lua_scoregen_silencio')
score:setDirectory('D:/Dropbox/music')

for i = 1, 10 do
    scoretime = scoretime + interval
    y1 = c * y * (1 - y) * 4
    y = y1
    local key = math.floor(36 + y * 60)
    local velocity = 80
    score:append(scoretime, duration, 144.0, 0.0, key, velocity, 0.0, 0.0, 0.0, 0.0)
end
score:append(scoretime + 5, 1.0, 144.0, 1.0)
score:sendToCsound()
}}

    lua_opdef   "moogladder", {{
local ffi = require("ffi")
local math = require("math")
local string = require("string")
local csoundApi = ffi.load('csound64.dll.5.2')
ffi.cdef[[
    int csoundGetKsmps(void *);
    double csoundGetSr(void *);
    struct moogladder_t {
      double *out;
      double *inp;
      double *freq;
      double *res;
      double *istor;
      double sr;
      double ksmps;
      double thermal;
      double f;
      double fc;
      double fc2;
      double fc3;
      double fcr;
      double acr;
      double tune;
      double res4;
      double input;
      double i;
      double j;
      double k;
      double kk;
      double stg[6];
      double delay[6];
      double tanhstg[6];
    };
]]

local moogladder_ct = ffi.typeof('struct moogladder_t *')

function moogladder_init(csound, opcode, carguments)
    local p = ffi.cast(moogladder_ct, carguments)
    p.sr = csoundApi.csoundGetSr(csound)
    p.ksmps = csoundApi.csoundGetKsmps(csound)
    if p.istor[0] == 0 then
        for i = 0, 5 do
            p.delay[i] = 0.0
        end
        for i = 0, 3 do
            p.tanhstg[i] = 0.0
        end
    end
    return 0
end

function moogladder_kontrol(csound, opcode, carguments)
    local p = ffi.cast(moogladder_ct, carguments)
    -- transistor thermal voltage
    p.thermal = 1.0 / 40000.0
    if p.res[0] < 0.0 then
        p.res[0] = 0.0
    end
    -- sr is half the actual filter sampling rate
    p.fc = p.freq[0] / p.sr
    p.f = p.fc / 2.0
    p.fc2 = p.fc * p.fc
    p.fc3 = p.fc2 * p.fc
    -- frequency & amplitude correction
    p.fcr = 1.873 * p.fc3 + 0.4955 * p.fc2 - 0.6490 * p.fc + 0.9988
    p.acr = -3.9364 * p.fc2 + 1.8409 * p.fc + 0.9968
    -- filter tuning
    p.tune = (1.0 - math.exp(-(2.0 * math.pi * p.f * p.fcr))) / p.thermal
    p.res4 = 4.0 * p.res[0] * p.acr
    -- Nested 'for' loops crash, not sure why.
    -- Local loop variables also are problematic.
    -- Lower-level loop constructs don't crash.
    p.i = 0
    while p.i < p.ksmps do
        p.j = 0
        while p.j < 2 do
            p.k = 0
            while p.k < 4 do
                if p.k == 0 then
                    p.input = p.inp[p.i] - p.res4 * p.delay[5]
                    p.stg[p.k] = p.delay[p.k] + p.tune * (math.tanh(p.input * p.thermal) - p.tanhstg[p.k])
                else
                    p.input = p.stg[p.k - 1]
                    p.tanhstg[p.k - 1] = math.tanh(p.input * p.thermal)
                    if p.k < 3 then
                        p.kk = p.tanhstg[p.k]
                    else
                        p.kk = math.tanh(p.delay[p.k] * p.thermal)
                    end
                    p.stg[p.k] = p.delay[p.k] + p.tune * (p.tanhstg[p.k - 1] - p.kk)
                end
                p.delay[p.k] = p.stg[p.k]
                p.k = p.k + 1
            end
            -- 1/2-sample delay for phase compensation
            p.delay[5] = (p.stg[3] + p.delay[4]) * 0.5
            p.delay[4] = p.stg[3]
            p.j = p.j + 1
        end
        p.out[p.i] = p.delay[5]
        p.i = p.i + 1
    end
    return 0
end
}}


            instr       1
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ; Simple FM instrument.
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
khz         =           cpsmidinn(p4)
kamplitude  =           ampdb(p5) * 0.1
kcarrier    =           3
kmodulator  =           0.44
            ; Intensity sidebands.
kindex      line        0, p3, 20	
isine       ftgenonce   1, 0, 16384, 10, 1
asignal     foscili     kamplitude, khz, kcarrier, kmodulator, kindex, isine
            outs        asignal, asignal
            endin
            
            instr 	2
            	print p1, p2, p3
            	prints "Post-processing...\n"
            	/* lua_iopcall "postprocess" */
            endin
            
</CsInstruments>

<CsScore>
i 2 51 2
e 4.0
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider1</objectName>
  <x>5</x>
  <y>5</y>
  <width>20</width>
  <height>100</height>
  <uuid>{89b5f0f0-2a91-4bd5-b64d-f9ba35e57494}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
