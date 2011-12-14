require "Silencio"
ChordSpace = require("ChordSpace")
local matrix = require("matrix")
local os = require("os")

local printPass = false
local failExits = true
local exitAfterFailureCount = 3
local failureCount = 0
local printOP = false
local printChordSpaceGroup = true
local voicesToTest = 5

print([[

T I M I N G   T E S T S   F O R   C H O R D S P A C E

It is critical that PITV be performant for 7 voices in 5 octaves.

It may be necessary to precompute and load the group elements.
]])

for voices = 2, voicesToTest do
    local began = os.clock()
    local chordSpaceGroup = ChordSpaceGroup:new()
    chordSpaceGroup:initialize(voices, 48, timeit)
    local ended = os.clock()
    print(string.format('ChordSpaceGroup of %2d voices took %9.4f seconds to create.', voices, (ended - began)))
    local began1 = os.clock()
    chordSpaceGroup:save('ChordSpaceGroup' .. tostring(voices) .. '.txt')
    local ended1 = os.clock()
    print(string.format('ChordSpaceGroup of %2d voices took %9.4f seconds to serialize.', voices, (ended1 - began1)))
    --chordSpaceGroup:list()
end
