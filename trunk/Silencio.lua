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
        else
            result, osname = pcall(os.capture, 'uname')
            if osname then
                platform = osname
            end
        end
    end
end

do
    if platform == 'Windows' then
        result, cwd = pcall(os.capture, 'cd')
    else
        result, cwd = pcall(os.capture, 'pwd')
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

It is possible to embed a Csound orchestra in a Score object. If Csound is present, the Score 
object will save this orchestra along with the score in Csound .sco format, and shell out to 
render the piece using Csound. This enables compositions to be edited and auditioned 
on a phone, then rendered using Csound on a computer.

Thanks to Peter Billam for the Lua MIDI package
(http://www.pjb.com.au/comp/lua/MIDI.html).
]]
print(string.format("Platform: %s\n", platform))
print('Current directory:', cwd)
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

-- Translates this Event to a Csound score "i" statement.
-- Note that MIDI channels are zero-based, Csound instrument numbers are one-based.

function Event:csoundIStatement()
    istatement = string.format("i %g %g %g %g %g %g %g %g %g %g %g", self[CHANNEL] + 1, self[TIME], self[DURATION], self[KEY], self[VELOCITY], self[PAN], self[DEPTH], self[HEIGHT], self[PHASE], self[STATUS], self[HOMOGENEITY])
    return istatement
end

function Event:midiScoreEvent()
    tipe = 'note'
    return {tipe, self[TIME] * TICKS_PER_BEAT, self[DURATION] * TICKS_PER_BEAT, self[CHANNEL], self[KEY], self[VELOCITY]}
end

function Event:fomusNote()
    -- Time in Silencio is in absolute seconds.
    -- Default time in Fomus is in quarter-note beats.
    -- 'beat' in Fomus is type of note per durational unit, e.g. 1/4 for ordinary 4/4.
    -- We assume MM 120 and 4/4, which is 8 16th notes per second. 
    -- But we pre-quantize to 64th notes at that tempo, so we set the beat to 64/2.
    local noteString = string.format("time %g part %g dur %g pitch %g;", self[TIME] * 32, self[CHANNEL] + 1, self[DURATION] * 32, self[KEY]) 
    return noteString
end

function Event:midiScoreEventString()
    local event = self:midiScoreEvent()
    local eventString = string.format("{%s, %d, %d, %g, %g, %g}", event[1], event[2], event[3], event[4], event[5], event[6]) 
    return eventString
end

Score = {}

function Score:new(o)
    o = o or {title = "MyScore", artist = '', orchestra = '', copyright = '', album = ''}
    setmetatable(o, self)
    self.__index = self
    if platform == 'Android' then
        self.prefix = '/sdcard/sl4a/scripts/'
    else
        self.prefix = ''
    end
    return o
end

function Score:getTitle()
    return self.title
end

function Score:setTitle(value)
    self.title = value
end

function Score:getArtist()
    return self.artist
end

function Score:setArtist(value)
    self.artist = value
end

function Score:getCopyright()
    return self.copyright
end

function Score:setCopyright(value)
    self.copyright = value
end

function Score:getAlbum()
    return self.album
end

function Score:setAlbum(value)
    self.album = value
end

function Score:getFomusFilename()
    return string.format('%s%s.fms', self.prefix, self.title)
end

function Score:getMidiFilename()
    return string.format('%s%s.mid', self.prefix, self.title)
end

function Score:getScoFilename()
    return string.format('%s%s.sco', self.prefix, self.title)
end

function Score:getOrcFilename()
    return string.format('%s%s.orc', self.prefix, self.title)
end

function Score:getOutputSoundfileName()
    return string.format('%s%s.wav', self.prefix, self.title)
end

function Score:getMp3SoundfileName()
    return string.format('%s%s.mp3', self.prefix, self.title)
end

function Score:append(time_, duration, status, channel, key, velocity, pan, depth, height, phase)
    event = Event:new{time_, duration, status, channel, key, velocity, pan, depth, height, phase, 1}
    table.insert(self, event)
end

function Score:saveSco()
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

function Score:saveFomus(namesForChannels, header)
    print(string.format("Saving \"%s\" as Fomus music notation file...", self:getFomusFilename()))
    file = io.open(self:getFomusFilename(), "w")
    file:write(string.format("title = \"%s\"\n", self.title))
    if self.artist:len() > 1 then
        file:write(string.format("author = \"%s\"\n", self.artist))
    end
    file:write("beat = 1/64\n")
    file:write("timesig (4 4)\n")
    file:write("lily-papersize = 11x17\n")
    if namesForChannels then
        for part, name in ipairs(namesForChannels) do
            file:write(string.format("part <id = %s name = %s>\n", part, name))
        end
    end
    if header then
        file:write(header..'\n')
    end
    for i, event in ipairs(self) do
        file:write(event:fomusNote().."\n")
    end
    file:close()
    print("Running Fomus...")
    os.execute(string.format('fomus -i %s -o %s.ly', self:getFomusFilename(), self.title))
    print("Running Lilypond...")
    os.execute(string.format('lilypond -fpdf %s.ly', self.title))
end

function Score:playMidi(inBackground)
    local background = ''
    if inBackground then
        background = '&'
    end
    print(string.format('Playing \"%s\" on %s...', self:getMidiFilename(), platform))
    if platform == 'Linux' then
        assert(os.execute(string.format("timidity -idvvv %s -Os %s", self:getMidiFilename(), background)))
    end
    if platform == 'Android' then
        android.startActivity('android.intent.action.VIEW', 'file:///'..self:getMidiFilename(), 'audio/mid')
    end
    if platform == 'Windows' then
        local command = string.format("wmplayer.exe \"%s\\%s\"", cwd, self:getMidiFilename())
        print (command)
        assert(os.execute(command, background))
    end
end

function Score:playWav(inBackground)
    print(string.format('Playing \"%s\" on %s...', self:getOutputSoundfileName(), platform))
    local background = ''
    if inBackground then
        background = '&'
    end
    if platform == 'Linux' then
        assert(os.execute(string.format("audacity %s %s", self:getOutputSoundfileName(), background)))
    end
    if platform == 'Android' then
        android.startActivity('android.intent.action.VIEW', 'file:///'..self:getOutputSoundfileName(), 'audio/x-wav')
    end
end

function Score:setOrchestra(orchestra)
    self.orchestra = orchestra
end

function Score:saveOrc()
    print(string.format("Saving \"%s\" as Csound orchestra file...", self:getOrcFilename()))
    orcfile = io.open(self:getOrcFilename(), 'w')
    orcfile:write(self.orchestra)
    orcfile:close()
end

function Score:renderCsound()
    print(string.format("Rendering \"%s\" with Csound...", self:getOutputSoundfileName()))
    self:saveMidi()
    self:saveOrc()
    self:saveSco()
    local command = string.format('csound --old-parser -g -m163 -W -f -R -K -r 48000 -k 375 --midi-key=4 --midi-velocity=5 -o %s %s %s', self:getOutputSoundfileName(), self:getOrcFilename(), self:getScoFilename())
    os.execute(command)
end

function Score:findScale(dimension)
    local minimum = 0
    local maximum = 0
    for i, event in ipairs(self) do
        local value = event[dimension]
        if i == 1 then
            minimum = value
            maximum = value
        end
        if value < minimum then
            minimum = value
        end
        if value > maximum then
            maximum = value
        end
    end
    range = maximum - minimum
    return {minimum, range}
end

function Score:findScales()
    local minima = Event:new()
    local ranges = Event:new()
    for i = 1, HOMOGENEITY do
        local scale = self:findScale(i)
        minima[i] = scale[1]
        ranges[i] = scale[2] 
    end
    return {minima, ranges}
end

function Score:setScale(dimension, minimum, range)
end

