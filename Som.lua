Som = {}

function Som.help()
print [[
S O M

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms 
of the GNU Lesser General Public License.

Som is a user-programmable system for doing software sound synthesis in Lua.
Som is part of Silencio, a system for making music by programming in Lua.

Thanks to Mike Pall for his Lua Just-in-Time compiler (LuaJIT) and
native Foreign Function Interface (FFI) for LuaJIT, which make the
thought of doing high-performance computing in a dynamic language
not only possible, but attractive (http://luajit.org).

Basic idioms:

Cache C namespaces in local variables.

Cache C objects in local variables.

For Lua classes, use C structs instead of tables where possible; 
then in class methods, retrieve the struct into a local variable 
'this' (cf. 'self'): local this = self.cstruct.

Keep constants (any non-variable expression) inline.

]]

local ffi = require("ffi")
local C = ffi.C
local Silencio = require("Silencio")
local sndfile = ffi.load('libsndfile.so')

-- Forward declarations of core synthesizer classes.

ControlSignal = {}
AudioSignal = {}
Port = {}
Inlet = {}
ControlInlet = {}
AudioInlet = {}
FileAudioInlet = {}
RealtimeAudioInlet = {}
Outlet = {}
ControlOutlet = {}
AudioOutlet = {}
FileAudioOutlet = {}
RealtimeAudioOutlet = {}
Node = {}
Instrument = {}
Processor = {}
AudioPanner = {}
Polyphonic = {}
Graph = {}

-- A control signal represents the state of a MIDI-like control channel 
-- during one tick. This includes event triggering, key and velocity, 
-- and MIDI controller numbers.

ffi.cdef([[
struct ControlSignal
{
    int status;
    int channel;
    double value[256];
};
]])

function ControlSignal:new(o)
    o = o or {this = ffi.new('struct ControlSignal')}
end

function ControlSignal:isNote()
    local this = self.this
    if this.status == 144 or this.status == 128 then
        return true
    else
        return false
    end
end

function ControlSignal:isNoteOn()
    local this = self.this
    if this.status == 144 and this.value[1] > 0 then
        return true
    else
        return false
    end
end

function ControlSignal:isNoteOff()
    local this = self.this
    if (this.status == 144 and this.value[1] == 0) or this.status == 128 then
        return true
    else
        return false
    end
end

-- An audio signal buffer represents the state of one or more channels of 
-- audio during one tick.

sample_t = ffi.typeof('double[?]')

function AudioSignal:new(o)
    o = o or {channels = 1, frames = 64, buffer = nil}
    setmetatable(o, self)
    self.__index = self
    if self.buffer == nil then
       self.buffer = sample_t(self.channels * self.frames)
    return o
end

function AudioSignal:resize(channels, frames)
   self.channels = channels
   self.frames = frames
   self.buffer = sample_t(self.channels * self.frames)
end







