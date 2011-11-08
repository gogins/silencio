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

for i = 1, 2000 do
    scoretime = scoretime + interval
    y1 = c * y * (1 - y) * 4
    y = y1
    local key = math.floor(36 + y * 60)
    local velocity = 80
    score:append(scoretime, duration, 144.0, 0.0, key, velocity, 0.0, 0.0, 0.0, 0.0)
end
score:toCsound()
}}

    lua_opdef   "postprocess", {{
local ffi = require("ffi")
local math = require("math")
local string = require("string")
local csoundApi = ffi.load('csound64.dll.5.2')
ffi.cdef[[
    int csoundGetKsmps(void *);
    double csoundGetSr(void *);
    struct postprocess_t {
      const char *basename;
    };
]]

local postprocess_ct = ffi.typeof('struct postprocess_t *')

function postprocess_init(csound, opcode, carguments)
    local p = ffi.cast(postprocess_ct, carguments)
    
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
            
</CsInstruments>

<CsScore>
e 4.0
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>398</width>
 <height>479</height>
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
