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
local voicesToTest = 4

print([[

T I M I N G   T E S T S   F O R   C H O R D S P A C E G R O U P

It is critical that PITV be performant for 7 voices in 5 octaves.
To achieve this speed, it is necessary to precompute the groups one time, save them,
and load them for later uses.
]])

for voices = 2, voicesToTest do
    local began = os.clock()
    local chordSpaceGroup = ChordSpaceGroup:new()
    chordSpaceGroup:initialize(voices, 48, timeit)
    local ended = os.clock()
    print(string.format('ChordSpaceGroup of %2d voices took %9.4f seconds to create.', voices, (ended - began)))
    local began1 = os.clock()
    local filename = string.format('ChordSpaceGroup_V%d_R%d_g%.5f.lua', chordSpaceGroup.voices, chordSpaceGroup.range, chordSpaceGroup.g)
    print('Saving:', filename)
    chordSpaceGroup:save(filename)
    local ended1 = os.clock()
    local began2 = os.clock()
    print(string.format('ChordSpaceGroup of %2d voices took %9.4f seconds to serialize.', voices, (ended1 - began1)))
    local deserialized = ChordSpaceGroup.load(filename)
    local ended2 = os.clock()
    print(string.format('ChordSpaceGroup of %2d voices took %9.4f seconds to deserialize.', voices, (ended2 - began2)))
    deserialized:list()
    print()
end
