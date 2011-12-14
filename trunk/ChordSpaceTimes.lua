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
local voicesToTest = 7

print([[

U N I T   T E S T S   F O R   C H O R D S P A C E

We generate all chords in R and test the consistency of the formulas for
identifying (iseE) and generating (eE) each of the equivalence classes (E)
O, P, T, I, OP, OPT, OPI, and OPTI with respect to their representative or
"normal" fundamental domains.

If the formulas for the fundamental domains identify or produce duplicates,
then the duplicates must be removed or accounted for in the tests. This
could happen e.g. if Chord:iseE() identifies more than one chord as the
equivalent, but Chord:eE() sends all equivalent chords to one element of that
class.

In addition, 3-dimensional graphics of iseE(R) and eE(R) for trichords must
look correct for OP, OPI, OPT, and OPTI.

]])

function pass(message)
    if printPass then
        print()
        print('PASSED:', message)
        print()
    end
end

function fail(message)
    print('========================================================================')
    print('FAILED:', message)
    print('========================================================================')
    failureCount = failureCount + 1
    if failExits and (failureCount > exitAfterFailureCount) then
        os.exit()
    end
end

function result(expression, message)
    if expression then
        pass(message)
    else
        fail(message)
    end
end

for voices = 2, voicesToTest do
    local began = os.clock()
    local chordSpaceGroup = ChordSpaceGroup:new()
    chordSpaceGroup:initialize(voices, 48)
    local ended = os.clock()
    print(string.format('ChordSpaceGroup of %2d voices took %9.4f seconds to create.', voices, (ended - began)))
    --chordSpaceGroup:list()
end