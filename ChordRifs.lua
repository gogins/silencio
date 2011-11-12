ChordRifs = {}

function ChordRifs.help()
print [[

C H O R D   R I F S

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms
of the GNU Lesser General Public License.

This package implements a recurrent iterated function system (RIFS) in chord
group space. The dimensions of chord group space are:

(1) Time (t).
(2) Zero-based index of octave, permutational, transposition, and inversional
    equivalence (set-class) (P).
(3) Zero-based index of inversion (reflection in the origin) (I).
(4) Zero-based index of transposition (within octave equivalence) (T).
(5) Zero-based index of octavewise revoicings within a specified range (V).
(6) Homogeneity.

Zero-based indexes that wrap around due to an equivalence class are additive 
cyclical groups, and they can be considered "control knobs" for some symmetry 
in chord space.

A deterministic RIFS is iterated a specified number of times, accumulating a
list of transformed timed chords. This list is then "quantized" by time, and
within each quantum of time, any chords that exist are replaced by their mean.
In this way, a RIFS can be used to compute any sequence of chords as a
function of time.

One objective of this system is to enable the evolution of pieces by encoding
their RIFS parameters with Hilbert indexes and exploring the resulting
parameter space.

For the purposes of this software, a musical score is considered to be a 
temporal sequence of more or less fleeting chords.
]]
end

ChordRifs.help()

local Silencio = require("Silencio")
local ChordSpace = require("ChordSpace")
local matrix = require("matrix")
local jit = require("jit")
local ffi = require("ffi")

ChordRifs.t           =  1
ChordRifs.P           =  2
ChordRifs.I           =  3
ChordRifs.T           =  4
ChordRifs.V           =  5
ChordRifs.HOMOGENEITY =  6

function ChordRifs:new(o)
    o = o or {iterations = 3, transitions = {}, transformations = {}, attractor = {}, timesteps = 1000}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ChordRifs:initialize(voices, range, g)
    self.chordSpaceGroup = ChordSpaceGroup:new()
    self.chordSpaceGroup:initialize(voices, range, g)
end

function ChordRifs:resize(newsize)
    local oldsize = #self.transformations
    if newsize < oldsize then
        for i = newsize, oldsize do
            table.remove(self.transformations)
        end
        self.transitions = self.transitions:subm(1, 1, newsize, newsize)
    end
    if newsize > oldsize then
        -- If adding, insert identity transformations as required.
        for i = oldsize, newsize do
            table.insert(self.transformations, matrix:new(ChordSpace.HOMOGENEITY, 'I'))
        end
        local oldtransitions = self.transitions
        self.transitions = matrix:new(newsize, newsize)
        for i = 1, oldsize do
            for j = 1, oldsize do
                self.transitions[i][j] = oldtransitios[i][j]
            end
        end
    end
end

function ChordRifs:getTransition(i, j)
    return self.transitions[i][j]
end

function ChordRifs:setTransition(i, j, x)
    self.transitions[i][j] = x
end

-- Returns the ith transformation in this.

function ChordRifs:__index(i)
    return self.transformations[i]
end

function ChordRifs:iterate(chord, depth, priorIndex)
    if depth == 0 then
        return
    end
    depth = depth - 1
    for currentIndex = 1, #self.transitions do
        if self.transitions[currentIndex] ~= 0 then
            local newchord = self[currentIndex]:mul(chord)
            table.insert(self.attractor, newchord)
            self:iterate(newchord, depth, currentIndex)
        end
    end
end

function chordComparator(a, b)
    if a[1] < b[1] then
        return true
    end
    return false
end

function ChordRifs:collect()
    table.sort(self.attractor, chordComparator)
    self.collected = {}
    local minimumTime = self.attractor[1][1]
    local maximumTime = self.attractor[#self.attractor][1]
    self.timeSlice = (maximumTime - minimumTie) / self.timeSlices
    local index = 1
    for currentSlice = 1, self.timeSlices do
        local slice = {}
        local sliceBegin = (currentSlice - 1) * self.timeSlice
        local sliceEnd = currentSlice * self.timeSlice
        while true do
            local chord = self.attractor[index]
            local chordTime = chord[1]
            if chordTime >= sliceBegin and chordTime < sliceEnd then
                table.insert(slice, chord)
            else
                break
            end
        end
        if #slice > 0 then
            local collector = matrix:new{sliceBegin, 0, 0, 0, 0, 1}
            for key, value in ipairs(slice) do
                for i = 2, 5 do
                    collector[i] = collector[i] + value[i]
                end
            end
            for i = 2, 5 do
                collector[i] = collector[i] / #slice
            end        
            table.insert(self.collected, collector)
        end
    end
end

function ChordRifs:translate()
    for timeslice, tPITV in self.collected do
        local time_ = (timeslice - 1) * self.timeSlice
        local duration = self.timeSlice
        local chord = self.chordSpaceGroup:toChord(tPITV[2], tPITV[3], tPITV[4], tPITV[5])
        ChordSpace.insert(self.score, chord, time_, duration)
    end
    self.score:tieOverlaps()
end

function ChordRifs:generate()
    self.attractor = {}
    local chord = matrix:new{0, 0, 0, 0, 0, 1}
    self:iterate(chord, self.iterations, 1)
    self:collect()
    self:translate()
end

chordRifs = ChordRifs:new()
chordRifs:initialize(4, 48, 1)
print(chordRifs.chordSpaceGroup.g)
chordRifs.chordSpaceGroup:list()

return ChordRifs
