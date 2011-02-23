Som = {}

function Som.help()
print [[
S O M

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms 
of the GNU Lesser General Public License.

Som is a simple system for doing software sound synthesis in Lua.
Som is part of Silencio, a system for making music by programming in Lua.

Thanks to Mike Pall for his Lua Just-in-Time compiler (LuaJIT) and
native Foreign Function Interface (FFI) for Lua, which make the
thought of doing high-performance computing in a dynamic language
not only possible, but attractive (http:luajit.org).
]]

-- Remember to cache namespaces in local variables to let LuaJIT optimize.
local ffi = require("ffi")
local C = ffi.C
local Silencio = require("Silencio")
local sndfile = ffi.load('libsndfile.so')

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

-- A control event represents the state of a MIDI like control channel during one tick.
-- This includes event triggering, key and velocity, and MIDI controller numbers.

event_t = ffi.typeof('double[256]')

-- An audio signal buffer represents the state of one or more channels of audio during one tick.

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







