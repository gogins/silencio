Silencio = {}

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

do
    platform = 'Unknown'
    result, android = pcall(require, 'android')
    if result then
        platform = 'Android'
    else
        local osname = os.getenv('WINDIR')
        if osname then 
            platform = 'Windows'
        end
        osname = os.capture('uname')
        if osname then
            platform = osname
        end
    end
end

function Silencio.help()
print [[
S I L E N C I O

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms of the GNU Lesser General Public License.

Silencio is a simple system for doing algorithmic composition in Lua.
Silencio runs not only on Android smartphones, but also on personal computers. 
It will output scores as MIDI sequence files or as Csound score files.

There are also convenience functions to simplify algorithmic composition, including
rescaling scores, splitting and combining scores, and applying matrix arithmetic operations
to scores.

A score is a matrix in which the rows are events.

An event is a homogeneous vector with the following dimensions:

 1 Time in seconds from start of performance.
 2 Duration in seconds.
 3 MIDI status (actually, only the most significant nybble, e.g. 144 for 'NOTE ON').
 4 MIDI channel (actually, any real number >= 0, fractional part ties succeeding events).
 5 MIDI key number from 0 to 127, 60 is middle C (actually, a real number not an integer).
 6 MIDI velocity from 0 to 127, 80 is mezzo-forte (actually, a real number not an integer).
 7 Pan, 0 is the origin.
 8 Depth, 0 is the origin.
 9 Height, 0 is the origin.
10 Phase, in radians.
11 Homogeneity, normally always 1.

Thanks to Peter Billam for the Lua MIDI package
(http://www.pjb.com.au/comp/lua/MIDI.html).
]]
print(string.format("Platform: %s\n", platform))
end

MIDI = require("MIDI")

TIME        =  1
DURATION    =  2
STATUS      =  3
CHANNEL     =  4
KEY         =  5
VELOCITY    =  6
PAN         =  7
DEPTH       =  8
HEIGHT      =  9
PHASE       = 10
HOMOGENEITY = 11

TICKS_PER_BEAT = 96000

Event = {}

function Event:new(o)
    o = o or {0,0,144,1,0,0,0,0,0,0,1}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Event:csoundIStatement()
    istatement = string.format("i %g %g %g %g %g %g %g %g %g %g %g", self[CHANNEL], self[TIME], self[DURATION], self[STATUS], self[KEY], self[VELOCITY], self[PAN], self[DEPTH], self[HEIGHT], self[PHASE], self[HOMOGENEITY])
    return istatement
end

function Event:midiScoreEvent()
    tipe = 'note'
    return {tipe, self[TIME] * TICKS_PER_BEAT, self[DURATION] * TICKS_PER_BEAT, self[CHANNEL], self[KEY], self[VELOCITY]}
end

function Event:midiScoreEventString()
    local event = self:midiScoreEvent()
    local eventString = string.format("{%s, %d, %d, %g, %g, %g}", event[1], event[2], event[3], event[4], event[5], event[6]) 
    return eventString
    end

Score = {}

function Score:new(o)
    o = o or {title = "MyScore"}
    setmetatable(o, self)
    self.__index = self
    if platform == 'Android' then
        self.prefix = '/sdcard/sl4a/scripts/'
    else
        self.prefix = ''
    end
    return o
end

function Score:getMidiFilename()
    return string.format('%s%s.mid', self.prefix, self.title)
end

function Score:getScoFilename()
    return string.format('%s%s.sco', self.prefix, self.title)
end

function Score:append(time_, duration, status, channel, key, velocity, pan, depth, height, phase)
    event = Event:new{time_, duration, status, channel, key, velocity, pan, depth, height, phase, 1}
    table.insert(self, event)
end

function Score:saveCsound()
    print(string.format("Saving \"%s\" as Csound score file...", self:getScoFilename()))
    file = io.open(self:getScoFilename(), "w")
    for i, event in ipairs(self) do
        file:write(event:csoundIStatement().."\n")
    end
    file:close()
end

-- Save the score as a format 0 MIDI sequence.
-- The optional patch changes are an array of 
-- {'patch_change', dtime, channel, patch}.
function Score:saveMidi(patchChanges)
    print(string.format("Saving \"%s\" as MIDI sequence file...", self:getMidiFilename()))
    -- Time resolution is 96000 ticks per beat (i.e. per second), 
    -- i.e. sample precision at 96 KHz. 
    local track = {}
    if patchChanges then
        print ('Patch changes:', patchChanges)
        for i, patchChange in ipairs(patchChanges) do
            table.insert(track, i, patchChange)
        end
    end
    for i, event in ipairs(self) do
        local midiscoreevent = event:midiScoreEvent()
        local channel = midiscoreevent[4]
        table.insert(track, i, midiscoreevent)
    end
    local midiscore = {TICKS_PER_BEAT, track}
    midisequence = MIDI.score2midi(midiscore)    
    file = io.open(self:getMidiFilename(), "w")
    file:write(midisequence)
    file:close()
end

function Score:playMidi()
    print(string.format('Playing \"%s\" on %s...', self:getMidiFilename(), platform))
    if platform == 'Linux' then
        assert(os.execute(string.format("timidity -idvvv %s -Od", self:getMidiFilename())))
    end
    if platform == 'Android' then
        android.startActivity('android.intent.action.VIEW', 'file:///'..self:getMidiFilename(), 'audio/mid')
    end
end

function Silencio.newScore()
    return Score:new()
end


