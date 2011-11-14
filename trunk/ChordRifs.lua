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
ChordRifs.v           =  6
ChordRifs.HOMOGENEITY =  7

function ChordRifs:new(o)
    o = o or {iterations = 3, transitions = {}, transformations = {}, attractor = {}, tie = true, voicelead = false, timesteps = 120 * 32}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ChordRifs:initialize(voices, range, g)
    self.score = Score:new()
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
        if oldsize == 0 then
            oldsize = 1
        end
        for i = oldsize, newsize do
            table.insert(self.transformations, matrix:new(ChordRifs.HOMOGENEITY, 'I'))
        end
        local oldtransitions = self.transitions
        oldsize = #oldtransitions
        -- Transitions are on by default.
        self.transitions = matrix:new(newsize, newsize, 1)
        for i = 1, oldsize do
            for j = 1, oldsize do
                self.transitions[i][j] = oldtransitions[i][j]
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

function ChordRifs:iterate(chord, depth, priorIndex)
    if depth == 0 then
        return
    end
    depth = depth - 1
    for currentIndex = 1, #self.transitions do
        if self.transitions[currentIndex] ~= 0 then
            local newchord = self.transformations[currentIndex]:mul(chord)
            table.insert(self.attractor, newchord)
            self:iterate(newchord, depth, currentIndex)
        end
    end
end

function chordComparator(a, b)
    if a[1][1] < b[1][1] then
        return true
    end
    return false
end

function ChordRifs:collect()
    table.sort(self.attractor, chordComparator)
    self.collected = {}
    local minimumTime = self.attractor[1][1][1]
    local maximumTime = self.attractor[#self.attractor][1][1]
    self.timeSlice = (maximumTime - minimumTime) / self.timesteps
    local index = 1
    for timestep = 1, self.timesteps do
        local slice = {}
        local sliceBegin = (timestep - 1) * self.timeSlice
        local sliceEnd = timestep * self.timeSlice
        while index < #self.attractor do
            local chord = self.attractor[index]
            local chordTime = chord[1][1]
            if chordTime >= sliceEnd then
                break
            end
            table.insert(slice, chord)
            index = index + 1
        end
        if #slice > 0 then
            local collector = self:newchord()
            collector[1][1] = sliceBegin
            for key, value in ipairs(slice) do
                for i = 2, 5 do
                    collector[i][1] = collector[i][1] + value[i][1]
                end
            end
            for i = 2, 5 do
                collector[i][1] = collector[i][1] / #slice
            end
            collector[6][1] = 50 + #slice * 2
            table.insert(self.collected, collector)
        end
    end
    print("Collected: " .. #self.collected .. " distinct chords.")
end

function ChordRifs:findSize()
    print('Finding size of attractor...')
    self.minima = self:newchord()
    self.maxima = self:newchord()
    self.ranges = self:newchord()
    for index = 1, #self.collected do
        chord = self.collected[index]
        if index == 1 then
            for dimension = 1, ChordRifs.HOMOGENEITY do
                value = chord[dimension][1]
                self.minima[dimension][1] = value
                self.maxima[dimension][1] = value
            end
        else
            for dimension = 1, ChordRifs.HOMOGENEITY do
                value = chord[dimension][1]
                if self.minima[dimension][1] > value then
                    self.minima[dimension][1] = value
                end
                if self.maxima[dimension][1] < value then
                    self.maxima[dimension][1] = value
                end
            end
        end
    end
    for dimension = 1, ChordRifs.HOMOGENEITY do
        self.ranges[dimension][1] = self.maxima[dimension][1] - self.minima[dimension][1]
    end
    print("Minima:")
    self.minima:print()
    print("Maxima:")
    self.maxima:print()
    print("Ranges:")
    self.ranges:print()
end

function ChordRifs:translate()
    -- Initial translation is for 2 minutes.
    local duration = (((self.ranges[1][1]) * 120) / self.timesteps) * 4
    local priorChord = nil
    local chord = nil
    for timeslice, tPITV in ipairs(self.collected) do
        local time_ = (timeslice - 1) * self.timeSlice
        -- Each dimension must be moved to the origin, normalized,
        -- rescaled to fit the size of the group, and then rounded to an integer.
        local t =            ((tPITV[1][1] - self.minima[1][1]) / self.ranges[1][1]) * 120
        local P = math.floor(((tPITV[2][1] - self.minima[2][1]) / self.ranges[2][1]) * self.chordSpaceGroup.countP)
        local I = math.floor(((tPITV[3][1] - self.minima[3][1]) / self.ranges[3][1]) * 2)
        local T = math.floor(((tPITV[4][1] - self.minima[4][1]) / self.ranges[4][1]) * 12)
        local V = math.floor(((tPITV[5][1] - self.minima[5][1]) / self.ranges[5][1]) * self.chordSpaceGroup.countV)
        priorChord = chord
        chord = self.chordSpaceGroup:toChord(P, I, T, V, false)
        if priorChord ~= nil and self.voicelead == true then
            chord = ChordSpace.voiceleadingClosestRange(priorChord, chord, self.chordSpaceGroup.range, true)
        end
        local velocity = tPITV[6][1]
        print(string.format('Time: %9.4f  P: %6d  I: %6d  T: %6d  V: %6d  velocity: %9.4f %s', t, P, I, T, V, velocity, chord:name()))
        ChordSpace.insert(self.score, chord, t, duration, 0.0, velocity)
    end
    print(string.format('Before tieing overlaps: %8d notes.', #self.score))
    if self.tie == true then
        self.score:tieOverlaps()
        print(string.format('After tieing overlaps:  %8d notes.', #self.score))
    end
end

function ChordRifs:generate(iterations)
    print('Generating...')
    self.iterations = iterations or self.iterations
    self.attractor = {}
    local chord = self:newchord()
    print('Iterating ' .. self.iterations .. ' times...')
    self:iterate(chord, self.iterations, 1)
    print('Generated: ' .. #self.attractor .. ' distinct chords.')
    print('Merging chords within time slices...')
    self:collect()
    print('Collected: ' .. #self.collected .. ' distinct chords.')
    self:findSize()
    print('Translating collected chords to score...')
    self:translate()
    print('Finished generating.')
end

function ChordRifs:list()
    for index, transformation in ipairs(self.transformations) do
        print(string.format("Transformation %4d:", index))
        transformation:print()
    end
    print("Transition matrix:")
    self.transitions:print()
end

function ChordRifs:newchord()
    local chord = matrix:new(ChordRifs.HOMOGENEITY, 1, 0)
    chord[ChordRifs.HOMOGENEITY][1] = 1
    return chord
end

if true then

rifs = ChordRifs:new()
rifs:initialize(4, 48, 1)
rifs:resize(3)

-- Time.
rifs.transformations[1][1][1] = 0.5
rifs.transformations[2][1][1] = 0.5
rifs.transformations[3][1][1] = 0.5
rifs.transformations[1][1][ChordRifs.HOMOGENEITY] = 0
rifs.transformations[2][1][ChordRifs.HOMOGENEITY] = 1
rifs.transformations[3][1][ChordRifs.HOMOGENEITY] = 2
-- Set-class.
rifs.transformations[1][2][2] = 1
rifs.transformations[2][2][2] = 1
rifs.transformations[3][2][2] = 0.95
rifs.transformations[2][2][ChordRifs.HOMOGENEITY] = .1
-- Inversion.
rifs.transformations[1][3][3] = 1
rifs.transformations[2][3][3] = 0
rifs.transformations[3][3][3] = -.1
rifs.transformations[3][3][ChordRifs.HOMOGENEITY] = .1
-- Transposition.
rifs.transformations[1][4][4] = 1
rifs.transformations[2][4][4] = .1
rifs.transformations[3][4][4] = 1
rifs.transformations[1][4][ChordRifs.HOMOGENEITY] = .2
rifs.transformations[2][4][ChordRifs.HOMOGENEITY] = .5
rifs.transformations[3][4][ChordRifs.HOMOGENEITY] = -.7
-- Revoicing.
rifs.transformations[1][5][5] = 1
rifs.transformations[2][5][5] = 1
rifs.transformations[3][5][5] = 1
rifs.transformations[1][5][ChordRifs.HOMOGENEITY] = .2
rifs.transformations[2][5][ChordRifs.HOMOGENEITY] = .3
rifs.transformations[3][5][ChordRifs.HOMOGENEITY] = -.3

local chord = ChordRifs:newchord()
chord:print()
chord = rifs.transformations[1]:mul(chord)
chord:print()
rifs:list()
--rifs.voicelead = true
rifs:generate(7)
for index, chord in ipairs(rifs.score) do
    chord[KEY] = chord[KEY] + 36
end
rifs.score:setDuration(240.0)
rifs.score:setScale(VELOCITY, 80, 20)
rifs.score:print()
rifs.score:renderMidi()
rifs.score:playMidi()

end

return ChordRifs
