<CsoundSynthesizer>
<CsOptions>
-d -RWfo D:/Dropbox/music/lua_scoregen_silencio.wav -m3
</CsOptions>
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

score = Score:new()
score:setCsound(csound, csoundApi)
score:setTitle('lua_scoregen_silencio')
score:setArtist('Michael_Gogins')
score:setDirectory('D:/Dropbox/music/')

-- Compute a score using the logistic equation.

local c = .93849
local y = 0.5
local y1 = 0.5
local interval = 0.25
local duration = 0.5
local insno = 1
local scoretime = 0.5

for i = 1, 200 do
    scoretime = scoretime + interval
    y1 = c * y * (1 - y) * 4
    y = y1
    local key = math.floor(36 + y * 60)
    local velocity = 80
    score:append(scoretime, duration, 144.0, 0.0, key, velocity, 0.0, 0.0, 0.0, 0.0)
end
-- This note invokes postprocessing.
-- It must be the last note in the piece and come after all sounds have died away.
score:append(scoretime + 5, 1.0, 144.0, 1.0)
score:sendToCsound()
}}

    lua_opdef "postprocess", {{
local ffi = require("ffi")
local csoundApi = ffi.load('csound64.dll.5.2')
-- Declare the parts of the Csound API that we need.
-- You must declare MYFLT as double or float as the case may be.
ffi.cdef[[
    int csoundMessage(void *, const char *, ...);
]]

function postprocess_init(csound, opcode, carguments)
    csoundApi.csoundMessage(csound, 'Post-processing...\\n')
    score:postProcess()
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
S4          getcfg	4
iresult     strcmp     S4, "1"
            if iresult != 0 then
            prints "Off-line performance, post-processing will be performed.\n"
            lua_iopcall "postprocess"
            else
            prints "Real-time performance, no post-processing will be performed.\n"
            endif
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
 <x>696</x>
 <y>55</y>
 <width>650</width>
 <height>546</height>
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
