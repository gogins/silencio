local ChordSpace = {}

local Silencio = require("Silencio")

function ChordSpace.help()
print [[
C H O R D S P A C E

Copyright 2010 by Michael Gogins.

This software is licensed under the terms of the GNU Lesser General Public
License.

This package, part of Silencio, implements a geometric approach to some common
operations on chords in neo-Riemannian music theory for use in score
generating procedures:

--  Identifying whether a chord belongs to some equivalence class of music
    theory, or sending a chord to its equivalent within a representative
    fundamental domain of some equivalence class. The equivalence classes are
    octave (O), permutational (P), transpositional, (T), inversional (I), and
    their compounds OP, OPT (set-class or chord type), and OPTI (prime form).

--  Causing chord progressions to move strictly within an orbifold that
    generates some equivalence class.

--  Implementing chord progressions based on the L, P, R, D, K, and Q
    operations of neo-Riemannian theory (thus implementing some aspects of
    "harmony").

--  Implementing chord progressions performed within a more abstract
    equivalence class by means of the best-formed voice-leading within a less
    abstract equivalence class (thus implementing fundamentals of
    "counterpoint").

The associated ChordSpaceView package can display these chord spaces and
operations for trichords in an interactive 3-dimensional view.

DEFINITIONS

Pitch is the perception of a distinct sound frequency. It is a logarithmic
perception; octaves, which sound 'equivalent' in some sense, represent
doublings or halvings of frequency.

Pitches and intervals are represented as real numbers. Middle C is 60 and the
octave is 12. Our usual system of 12-tone equal temperament, as well as MIDI
key numbers, are completely represented by the whole numbers; any and all
other pitches can be represented simply by using fractions.

A voice is a distinct sound that is heard as having a pitch.

A chord is simply a set of voices heard at the same time or, what is the same
thing, a point in a chord space having one dimension of pitch for each voice
in the chord.

For the purposes of algorithmic composition in Silencio, a score is considered
as a sequence of more or less fleeting chords.

EQUIVALENCE CLASSES

An equivalence class identifies elements of a set. Operations that send one
equivalent point to another induce quotient spaces or orbifolds, where the
equivalence operation identifies points on one face of the orbifold with
points on an opposing face. The fundamental domain of the equivalence class
is the space "within" the orbifold.

Plain chord space has no equivalence classes. Ordered chords are represented
as vectors in parentheses (p1, ..., pN). Unordered chords are represented as
sorted vectors in braces {p1, ..., pN}. Unordering is itself an equivalence
class.

The following equivalence classes apply to pitches and chords, and exist in
different orbifolds. Equivalence classes can be combined (Callendar, Quinn,
and Tymoczko, "Generalized Voice-Leading Spaces," _Science_ 320, 2008), and
the more equivalence classes are combined, the more abstract is the resulting
orbifold compared to the parent space.

In most cases, a chord space can be divided into a number, possibly
infinite, of geometrically equivalent fundamental domains for the same
equivalence class. Therefore, we use the notion of 'representative'
fundamental domain. For example, the representative fundamental domain of
unordered sequences, out of all possible orderings, consists of all sequences
in their ordinary sorted order. It is important, in the following, to identify
representative fundamental domains that combine properly, e.g. such that the
representative fundamental domain of OP / the representative fundamental
domain of PI equals the representative fundamental domain of OPI. And this in
turn may require accounting for duplicate elements of the representative
fundamental domain caused by reflections or singularities in the orbifold.

C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}. _Not_ assuming
        cardinality equivalence ensures that there is a proto-metric in plain
        chord space that is inherited by all child chord spaces. Cardinality
        equivalence is never assumed here, because we are working in chord
        spaces of fixed dimensionality; e.g. we represent the note middle C
        not as {60}, but as {60, 60, ..., 60}.

O       Octave equivalence. The fundamental domain is defined by the pitches
        in a chord spanning the range of an octave or less, and summing to
        an octave or less.

P       Permutational equivalence. The fundamental domain is defined by a
        "wedge" of plain chord space in which the voices of a chord are always
        sorted by pitch.

T       Transpositional equivalence, e.g. {1, 2} == {7, 8}. The fundamental
        domain is defined as a plane in chord space at right angles to the
        diagonal of unison chords. Represented by the chord always having a
        sum of pitches equal to 0.

I       Inversional equivalence. Care is needed to distinguish the
        mathematician's sense of 'invert', which means 'pitch-space inversion'
        or 'reflect in a point', from the musician's sense of 'invert', which
        varies according to context but in practice often means 'registral
        inversion' or 'revoice by adding an octave to the lowest tone of a
        chord.' Here, we use 'invert' and 'inversion' in the mathematician's
        sense, and we use the terms 'revoice' and 'voicing' for the musician's
        'invert' and 'inversion'. The inversion point for any inversion lies
        on the unison diagonal. A fundamental domain is defined as any half of
        chord space that is bounded by a plane containing the inversion point.
        Represented as the chord having the first interval between voices be
        smaller than or equal to the final interval (recursing for chords of
        more than 3 voices).

PI      Inversional equivalence with permutational equivalence. The
        'inversion flat' of unordered chord space is a hyperplane consisting
        of all those unordered chords that are invariant under inversion. A
        fundamental domain is defined by any half space bounded by a
        hyperplane containing the inversion flat. It is represented as that
        half of the space on or lower than the hyperplane defined by the
        inversion flat and the unison diagonal.

OP      Octave equivalence with permutational equivalence. Tymoczko's orbifold
        for chords; i.e. chords with a fixed number of voices in a harmonic
        context. The fundamental domain is defined as a hyperprism one octave
        long with as many sides as voices and the ends identified by octave
        equivalence and one cyclical permutation of voices, modulo the
        unordering. In OP for trichords in 12TET, the augmented triads run up
        the middle of the prism, the major and minor triads are in 6
        alternating columns around the augmented triads, the two-pitch chords
        form the 3 sides, and the one-pitch chords form the 3 edges that join
        the sides.

OPT     The layer of the OP prism as close as possible to the origin, modulo
        the number of voices. Chord type. Note that CM and Cm are different
        OPT. Because the OP prism is canted down from the origin, at least one
        pitch in each OPT chord (excepting the origin itself) is negative.

OPI     The OP prism modulo inversion, i.e. 1/2 of the OP prism. The
        representative fundamental consits of those chords less than or equal
        to their inversions modulo OP.

OPTI    The OPT layer modulo inversion, i.e. 1/2 of the OPT layer.
        Set-class. Note that CM and Cm are the same OPTI.

OPERATIONS

Each of the above equivalence classes is, of course, an operation that sends
chords outside the fundamental domain to chords inside the fundamental domain.
And we define the following additional operations:

T(p, x)         Translate p by x.

I(p [, x])      Reflect p in x, by default the origin.

P               Send a major triad to the minor triad with the same root,
                or vice versa (Riemann's parallel transformation).

L               Send a major triad to the minor triad one major third higher,
                or vice versa (Riemann's Leittonwechsel or leading-tone
                exchange transformation).

R               Send a major triad to the minor triad one minor third lower,
                or vice versa (Riemann's relative transformation).

D               Send a triad to the next triad a perfect fifth lower
                (dominant transformation).

P, L, and R have been extended as follows, see Fiore and Satyendra,
"Generalized Contextual Groups", _Music Theory Online_ 11, August 2008:

K(c)            Interchange by inversion;
                K(c) := I(c, c[1] + c[2]).
                This is a generalized form of P; for major and minor triads,
                it is exactly the same as P, but it also works with other
                chord types.

Q(c, n, m)      Contexual transposition;
                Q(c, n, m) := T(c, n) if c is a T-form of m,
                or T(c, -n) if c is an I-form of M. Not a generalized form
                of L or R; but, like them, K and Q generate the T-I group.

TODO: Implement Rachel Hall, "Linear Contextual Transformations," 2009,
which seems to further extend the Generalized Contextual Group using
affine transformations in chord space, and Maxx Cho, "The Voice-Leading
Automorphism and Riemannian Operators," 2009, which may show that tonality
arises from a voice-leading automorphism in the Riemannian group.

TODO: Implement various scales found in 20th and 21st century harmony
along with 'splitting' and 'merging' operations.

LOG

2011-Sep-07

Redoing this package from scratch using GVLS formulas.

2011-Sep-09

There are definite problems with side effects in these tests. The first test
passes, but not when in series with another test.

Is there a bug in "~=" for Lua and/or LuaJIT?

2011-Sep-10

There is definitely one or more bugs in LuaJIT vs. Lua. Tests run to 4 or 5
voices in Lua that do not work in LuaJIT. There appear to be false temporaries
or something in LuaJIT.

2011-Sep-11

I am going to redo the equivalence formulas in sets: vanilla GVLS, GVLS with
my modifies, and mine. This seems like the only way of sorting out the mess.

]]
end

ChordSpace.help()

-- Returns n!

function ChordSpace.factorial (n)
	if n == 0 then
		return 1
	else
		return n * ChordSpace.factorial(n - 1)
	end
end

-- For taking numerical errors into account.

ChordSpace.EPSILON = 1

while true do
    ChordSpace.EPSILON = ChordSpace.EPSILON / 2
    local nextEpsilon = ChordSpace.EPSILON / 2
    local onePlusNextEpsilon = 1 + nextEpsilon
    if onePlusNextEpsilon == 1 then
        print(string.format('ChordSpace.EPSILON: %g', ChordSpace.EPSILON))
        break
    end
end

function ChordSpace.eq_epsilon(a, b, factor)
    factor = factor or 20
    if (math.abs(a - b) < (ChordSpace.EPSILON * factor)) then
        return true
    end
    return false
end

function ChordSpace.gt_epsilon(a, b, factor)
    factor = factor or 20
    local eq = ChordSpace.eq_epsilon(a, b, factor)
    if eq then
        return false
    end
    if a > b then
        return true
    end
    return false
end

function ChordSpace.lt_epsilon(a, b, factor)
    factor = factor or 20
    local eq = ChordSpace.eq_epsilon(a, b, factor)
    if eq then
        return false
    end
    if a < b then
        return true
    end
    return false
end

function ChordSpace.gte_epsilon(a, b, factor)
    factor = factor or 20
    local eq = ChordSpace.eq_epsilon(a, b, factor)
    if eq then
        return true
    end
    if a > b then
        return true
    end
    return false
end

function ChordSpace.lte_epsilon(a, b, factor)
    factor = factor or 20
    local eq = ChordSpace.eq_epsilon(a, b, factor)
    if eq then
        return true
    end
    if a < b then
        return true
    end
    return false
end

-- The size of the octave, defined to be consistent with
-- 12 tone equal temperament and MIDI.

ChordSpace.OCTAVE = 12

-- Middle C.

ChordSpace.MIDDLE_C = 60
ChordSpace.C4 = ChordSpace.MIDDLE_C

-- Returns the pitch transposed by semitones, which may be any scalar.
-- NOTE: Does NOT return the result under any equivalence class.

local function T(pitch, semitones)
    return pitch + semitones
end

-- Returns the pitch reflected in the center, which may be any pitch.
-- NOTE: Does NOT return the result under any equivalence class.

local function I(pitch, center)
    center = center or 0
    return center - pitch
end

-- Returns the Euclidean distance between chords a and b,
-- which must have the same number of voices.

local function euclidean(a, b)
    local sumOfSquaredDifferences = 0
    for voice = 1, #a do
        sumOfSquaredDifferences = sumOfSquaredDifferences + math.pow((a[voice] - b[voice]), 2)
    end
    return math.sqrt(sumOfSquaredDifferences)
end

-- Chords represent simultaneously sounding pitches.
-- The pitches are represented as semitones with 0 at the origin
-- and middle C as 60.

Chord = {}

-- Returns a new chord object with no voices.

function Chord:new(o)
    o = o or {duration = {}, channel = {}, velocity = {}, pan = {}}
    if not o.duration then
        o.duration = {}
    end
    if not o.channel then
        o.channel = {}
    end
    if not o.velocity then
        o.velocity = {}
    end
    if not o.pan then
        o.pan = {}
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Returns a string representation of the chord.
-- Quadratic complexity, but short enough not to matter.

function Chord:__tostring()
    local buffer = '{'
    for voice = 1, #self do
        buffer = buffer .. string.format('%9.4f', self[voice])
    end
    buffer = buffer .. '}'
    return buffer
end

-- Resizes a chord to the specified number of voices.
-- Existing voices are not changed. Extra voices are removed.
-- New voices are initialized to 0.

function Chord:resize(voices)
    while #self < voices do
        table.insert(self, 0)
        table.insert(self.duration, 0)
        table.insert(self.channel, 0)
        table.insert(self.velocity, 0)
        table.insert(self.pan, 0)
    end
    while #self > voices do
        table.remove(self)
        table.remove(self.duration)
        table.remove(self.channel)
        table.remove(self.velocity)
        table.remove(self.pan)
    end
end

function Chord:setDuration(value)
    for i = 1, #self do
        self.duration[i] = value
    end
end

function Chord:getDuration(voice)
    voice = voice or 1
    return self.duration[voice]
end

function Chord:setChannel(value)
    for i = 1, #self do
        self.channel[i] = value
    end
end

function Chord:getChannel(voice)
    voice = voice or 1
    return self.channel[voice]
end

function Chord:setVelocity(value)
    for i = 1, #self do
        self.velocity[i] = value
    end
end

function Chord:getVelocity(voice)
    voice = voice or 1
    return self.velocity[voice]
end

function Chord:setPan(value)
    for i = 1, #self do
        self.pan[i] = value
    end
end

function Chord:getPan(voice)
    voice = voice or 1
    return self.pan[voice]
end

-- Redefines the metamethod to implement value semantics
-- for ==, for the pitches in this only.

function Chord:__eq(other)
    if not (#self == #other) then
        return false
    end
    for voice = 1, #self do
        if not (self[voice] == other[voice]) then
            return false
        end
    end
    return true
end

function Chord:__eqlog(other)
    print(string.format('#self: %d  #other: %d', #self, #other))
    if not (#self == #other) then
        return false
    end
    for voice = 1, #self do
        print(string.format('%3d: %9.4f, %9.4f', voice, self[voice], other[voice]))
        if not (self[voice] == other[voice]) then
            print('not equal')
            return false
        end
    end
    print('equal')
    return true
end

-- This hash function is used to give chords value semantics for sets.

function Chord:__hash()
    local buffer = ''
    local comma = ','
    for voice = 1, #self do
        if voice == 1 then
            buffer = buffer .. tostring(self[voice])
        else
            buffer = buffer .. comma .. tostring(self[voice])
        end
    end
    return buffer
end

-- Redefines the metamethod to implement value semantics
-- for <, for the pitches in this only.

function Chord:__lt(other)
    local voices = math.min(#self, #other)
    for voice = 1, voices do
        if self[voice] < other[voice] then
            return true
        end
        if self[voice] > other[voice] then
            return false
        end
    end
    if #self < #other then
        return true
    end
    return false
end

-- Returns whether or not the chord contains the pitch.

function Chord:contains(pitch)
    for voice, pitch_ in ipairs(self) do
        if pitch_ == pitch then
            return true
        end
    end
    return false
end

-- Returns the lowest pitch in the chord,
-- and also its voice index.

function Chord:min()
    local lowestVoice = 1
    local lowestPitch = self[lowestVoice]
    for voice = 2, #self do
        if self[voice] < lowestPitch then
            lowestPitch = self[voice]
            lowestVoice = voice
        end
    end
    return lowestPitch, lowestVoice
end

-- Returns the minimum interval in the chord.

function Chord:minimumInterval()
    local minimumInterval = math.abs(self[1] - self[2])
    for v1 = 1, #self do
        for v2 = 1, #self do
            if t (v1 == v2) then
                local interval = math.abs(self[v1] - self[v2])
                if interval < minimumInterval then
                    minimumInterval = interval
                end
            end
        end
    end
    return minimumInterval
end

-- Returns the highest pitch in the chord,
-- and also its voice index.

function Chord:max()
    local highestVoice = 1
    local highestPitch = self[highestVoice]
    for voice = 2, #self do
        if self[voice] > highestPitch then
            highestPitch = self[voice]
            highestVoice = voice
        end
    end
    return highestPitch, highestVoice
end

-- Returns the maximum interval in the chord.

function Chord:maximumInterval()
    return self:max() - self:min()
end

-- Returns a value copy of the chord.

function Chord:clone()
    local clone_ = Chord:new()
    for voice, pitch in ipairs(self) do
        clone_[voice] = pitch
    end
    for voice, value in ipairs(self.duration) do
        clone_.duration[voice] = value
    end
    for voice, value in ipairs(self.channel) do
        clone_.channel[voice] = value
    end
    for voice, value in ipairs(self.velocity) do
        clone_.velocity[voice] = value
    end
    for voice, value in ipairs(self.pan) do
        clone_.pan[voice] = value
    end
    return clone_
end

-- Returns the origin of the chord's space.

function Chord:origin()
    local clone_ = self:clone()
    for voice = 1, #clone_ do
        clone_[voice] = 0
    end
    return clone_
end

-- Returns the maximally even chord in the chord's space,
-- e.g. the augmented triad for 3 dimensions.

function Chord:maximallyEven()
    local clone_ = self:clone()
    local g = ChordSpace.OCTAVE / #clone_
    for i = 1, #clone_ do
        clone_[i] = (i - 1) * g
    end
    return clone_
end

-- Returns the sum of the pitches in the chord.

function Chord:layer()
    local s = 0
    for voice, pitch in ipairs(self) do
        s = s + pitch
    end
    return s
end

-- Transposes the chord by the indicated interval (may be a fraction).
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:T(interval)
    local clone_ = self:clone()
    for voice = 1, #clone_ do
        clone_[voice] = T(clone_[voice], interval)
    end
    return clone_
end

-- Inverts the chord by another chord that is on the unison diagonal, by
-- default the origin. NOTE: Does NOT return the result under any equivalence
-- class.

function Chord:I(center)
    center = center or 0
    local inverse = self:clone()
    for voice = 1, #inverse do
        inverse[voice] = I(self[voice], center)
    end
    return inverse
end

-- Returns the equivalent of the pitch under pitch-class equivalence, i.e.
-- the pitch is in the interval [0, OCTAVE).

function ChordSpace.epc(pitch)
    while pitch < 0 do
        pitch = pitch + ChordSpace.OCTAVE
    end
    while pitch >= ChordSpace.OCTAVE do
        pitch = pitch - ChordSpace.OCTAVE
    end
    return pitch
end

-- Returns whether the chord is within the fundamental domain of
-- pitch-class equivalence, i.e. is a pitch-class set.

function Chord:isepcs()
    for voice = 1, #chord do
        if not (self[voice] == ChordSpace.epc(chord[voice])) then
            return false
        end
    end
    return true
end

-- Returns the equivalent of the chord under pitch-class equivalence,
-- i.e. the pitch-class set of the chord.

function Chord:epcs()
    local chord = self:clone()
    for voice = 1, #chord do
        chord[voice] = ChordSpace.epc(chord[voice])
    end
    return chord
end

-- Returns whether the chord is within the fundamental domain of
-- transposition to 0.

function Chord:iset()
    local et = self:et()
    if not (et == self) then
        return false
    end
    return true
end

-- Returns the equivalent of the chord within the fundamental domain of
-- transposition to 0.

function Chord:et()
    local min_ = self:min()
    return self:T(-min_)
end

-- Returns whether the chord is within the representative fundamental domain
-- of the indicated range equivalence.

function Chord:iseR(range)
    local gvls = true
    local gvls_modified = false
    local mkg = false
    if gvls then
        local max_ = self:max()
        local min_ = self:min()
        if not (max_ <= (min_ + range)) then
            return false
        end
        local layer_ = self:layer()
        if not ((0 <= layer_) and (layer_ <= range)) then
            return false
        end
        return true
    end
    if gvls_modified then
        local max_ = self:max()
        local min_ = self:min()
        if not (max_ < (min_ + range)) then
            return false
        end
        local layer_ = self:layer()
        if not ((0 <= layer_) and (layer_ <= range)) then
            return false
        end
        return true
    end
end

-- Returns whether the chord is within the representative fundamental domain
-- of octave equivalence.

function Chord:iseO()
    return self:iseR(ChordSpace.OCTAVE)
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of a range equivalence.

function Chord:eR(range)
    local chord = self:clone()
    if chord:iseR(range) then
        return chord
    end
    -- The clue here is that at least one voice must be >= 0,
    -- but no voice can be > range.
    -- First, move all pitches inside the interval [0, OCTAVE),
    -- which is not the same as the fundamental domain.
    chord = self:epcs()
    -- Then, reflect voices that are outside of the fundamental domain
    -- back into it, which will revoice the chord, i.e.
    -- the sum of pitches is in [0, OCTAVE].
    while chord:layer() > range do
        local maximumPitch, maximumVoice = chord:max()
        -- Because no voice is above the range,
        -- any voices that need to be revoiced will now be negative.
        chord[maximumVoice] = maximumPitch - ChordSpace.OCTAVE
    end
    return chord
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of octave equivalence.

function Chord:eO()
    return self:eR(ChordSpace.OCTAVE)
end

-- Returns whether the chord is within the representative fundamental domain
-- of permutational equivalence.

function Chord:iseP()
    for voice = 2, #self do
        if self[voice - 1] > self[voice] then
            return false
        end
    end
    return true
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of permutational equivalence.

function Chord:eP()
    clone_ = self:clone()
    table.sort(clone_)
    return clone_
end

-- Returns whether the chord is within the representative fundamental domain
-- of transpositional equivalence.

function Chord:iseT()
    local layer_ = self:layer()
    if not ChordSpace.eq_epsilon(layer_, 0) then
        return false
    end
    return true
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of transpositonal equivalence.

function Chord:eT()
    local layer_ = self:layer()
    local sumPerVoice = layer_ / #self
    return self:T(-sumPerVoice)
end

-- Returns whether the chord is within the representative fundamental domain
-- of inversional equivalence.

function Chord:iseI(inverse)
    -- GLVS:
    if false then
        local chord = self:clone()
        local lowerVoice = 2
        local upperVoice = #chord
        while lowerVoice < upperVoice do
            -- GVLS: tests only 1 interval: x[2] - x[1] <= x[#x] - x[#x - 1]
            local lowerInterval = chord[lowerVoice] - chord[lowerVoice - 1]
            local upperInterval = chord[upperVoice] - chord[upperVoice - 1]
            if lowerInterval < upperInterval then
                return true
            end
            if lowerInterval > upperInterval then
                return false
            end
            lowerVoice = lowerVoice + 1
            upperVoice = upperVoice - 1
        end
        return true
    end
    -- MKG:
    if true then
        inverse = inverse or self:I()
        if self > inverse then
            return false
        end
        return true
    end
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of inversional equivalence.

function Chord:eI()
    if self:iseI() then
        return self:clone()
    end
    return self:I()
end

-- Returns whether the chord is within the representative fundamental domain
-- of range and permutational equivalence.

function Chord:iseRP(range)
    for voice = 2, #self do
        if self[voice - 1] > self[voice] then
            return false
        end
    end
    if not (self[#self] <= (self[1] + range)) then
        return false
    end
    local layer_ = self:layer()
    if not ((0 <= layer_) and (layer_ <= range)) then
        return false
    end
    return true
end

-- Returns whether the chord is within the representative fundamental domain
-- of octave and permutational equivalence.

function Chord:iseOP()
    return self:iseRP(ChordSpace.OCTAVE)
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of range and permutational equivalence.

function Chord:eRP(range)
    return self:eR(range):eP()
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of octave and permutational equivalence.

function Chord:eOP()
    return self:eRP(ChordSpace.OCTAVE)
end

-- Returns a copy of the chord cyclically permuted by a stride, by default 1.
-- The direction of rotation is the same as musicians' first inversion, second
-- inversion, and so on.

function Chord:cycle(stride)
    stride = stride or 1
    local clone_ = self:clone()
    if stride < 0 then
        for i = 1, stride do
            local tail = table.remove(clone_)
            table.insert(clone_, 1, tail)
        end
        return chord
    end
    if stride > 0 then
        for i = 1, math.abs(stride) do
            local head = table.remove(clone_, 1)
            table.insert(clone_, head)
        end
    end
    return clone_
end

function Chord:permutations()
    local chord = self:clone()
    local permutations_ = {}
    permutations_[1] = chord
    for i = 2, #self do
        chord = chord:cycle()
        permutations_[i] = chord
    end
    return permutations_
end

-- Returns whether the chord is within the representative fundamental domain
-- of voicing equivalence.

function Chord:iseV()
    local eV = self:eV()
    --print(string.format('chord: %s  eV: %s', tostring(self), tostring(eV)))
    if not (self == eV) then
        return false
    end
    return true
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of voicing equivalence.

function Chord:eV()
    for index, voicing in ipairs(self:permutations()) do
        local wraparound = voicing[1] + ChordSpace.OCTAVE - voicing[#voicing]
        local iseV_ = true
        for voice = 1, #voicing - 1 do
            local inner = voicing[voice + 1] - voicing[voice]
            if not ChordSpace.gte_epsilon(wraparound, inner) then
            --if inner > wraparound then
                iseV_ = false
            end
        end
        if iseV_ then
            return voicing
        end
    end
end

-- Returns whether the chord is within the representative fundamental domain
-- of range, permutational, and transpositional equivalence.

function Chord:iseRPT(range)
    -- GVLS: failed to test for the origin.
    local origin_= self:origin()
    if origin_ == self then
        return true
    end
    -- GVLS: Failed to test for (range) and permutational equivalence.
    if not self:iseRP(range) then
        return false
    end
    -- GVLS: if not (self[#self] <= self[1] + ChordSpace.OCTAVE) then
    if not (ChordSpace.lte_epsilon(self[#self], (self[1] + range))) then
        return false
    end
    local layer_ = self:layer()
    -- GVLS: if not (layer_ == 0) then
    if not ChordSpace.eq_epsilon(layer_, 0) then
        return false
    end
    if #self <= 2 then
        return true
    end
    local wraparound = self[1] + range - self[#self]
    for voice = 1, #self - 1  do
        local inner = self[voice + 1] - self[voice]
        if not (ChordSpace.lte_epsilon(wraparound, inner)) then
            return false
        end
    end
    return true
end

-- Returns whether the chord is within the representative fundamental domain
-- of octave, permutational, and transpositional equivalence.

function Chord:iseOPT()
    return self:iseRPT(ChordSpace.OCTAVE)
end

-- Returns a copy of the chord 'inverted' in the musician's sense,
-- i.e. revoiced by cyclically permuting the chord and
-- adding (or subtracting) an octave to the highest (or lowest) voice.
-- The revoicing will move the chord up or down in pitch.
-- A positive direction is the same as a musician's first inversion,
-- second inversion, etc.

function Chord:v(direction)
    direction = direction or 1
    local chord = self:clone()
    while direction > 0 do
        chord = chord:cycle(1)
        chord[#chord] = chord[#chord] + ChordSpace.OCTAVE
        direction = direction - 1
    end
    while direction < 0 do
        chord = chord:cycle(-1)
        chord[1] = chord[1] - ChordSpace.OCTAVE
        direction = direction + 1
    end
    return chord
end

-- Returns all the 'inversions' (in the musician's sense)
-- or octavewise revoicings of the chord.

function Chord:voicings()
    local chord = self:clone()
    local voicings = {}
    voicings[1] = chord
    for i = 2, #self do
        chord = chord:v()
        voicings[i] = chord
    end
    return voicings
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of range, permutational, and transpositional equivalence; the same
-- as set-class type, or chord type.

function Chord:eRPT(range)
    if self:iseRPT(range) then
        return self:clone()
    end
    local permutations_ = self:eRP(range):permutations()
    for index, permutation in ipairs(permutations_) do
        et = permutation:et()
        if et:iseV() then
            return et:eT():eP()
        end
    end
    print('ERROR: Chord:eRPT() should not come here: ' .. tostring(self))
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of octave, permutational, and transpositional equivalence.

function Chord:eOPT()
    return self:eRPT(ChordSpace.OCTAVE)
end

-- Returns whether the chord is within the representative fundamental domain
-- of range, permutational, and inversional equivalence.

function Chord:iseRPI(range)
    if not self:iseP() then
        return false
    end
    if not (self[#self] <= (self[1] + range)) then
        return false
    end
    local layer_ = self:layer()
    if not ((0 <= layer_) and (layer_ <= range)) then
        return false
    end
    -- GVLS: tests only the outer intervals:
    --if not ((self[2] - self[1]) <= (self[#self] - self[#self - 1])) then
    --    return false
    --end
    if not self:iseI() then
        return false
    end
    return true
end

-- Returns whether the chord is within the representative fundamental domain
-- of octave, permutational, and inversional equivalence.

function Chord:iseOPI()
    return self:iseRPI(ChordSpace.OCTAVE)
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of range, permutational, and inversional equivalence.

function Chord:eRPI(range)
    if self:iseRPI(range) then
        return self:clone()
    end
    return self:I():eRP(range)
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of octave, permutational, and inversional equivalence.

function Chord:eOPI()
    return self:eRPI(ChordSpace.OCTAVE)
end

-- Returns whether the chord is within the representative fundamental domain
-- of range, permutational, transpositional, and inversional equivalence.

function Chord:iseRPTI(range)
    -- GVLS: failed to test for the origin.
    local origin_= self:origin()
    if origin_ == self then
        return true
    end
    -- GVLS: Failed to test for (range) and permutational equivalence.
    if not self:iseRP(range) then
        return false
    end
    -- GVLS: if not (self[#self] <= self[1] + ChordSpace.OCTAVE) then
    if not (ChordSpace.lte_epsilon(self[#self], (self[1] + range))) then
        return false
    end
    local layer_ = self:layer()
    -- GVLS: if not (layer_ == 0) then
    if not ChordSpace.eq_epsilon(layer_, 0) then
        return false
    end
    if #self <= 2 then
        return true
    end
    local wraparound = self[1] + range - self[#self]
    for voice = 1, #self - 1  do
        local inner = self[voice + 1] - self[voice]
        if not (ChordSpace.lte_epsilon(wraparound, inner)) then
            return false
        end
    end
    if not self:iseI() then
        return false
    end
    return true
end

-- Returns whether the chord is within the representative fundamental domain
-- of octave, permutational, transpositional, and inversional equivalence.

function Chord:iseOPTI()
    return self:iseRPTI(ChordSpace.OCTAVE)
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of range, permutational, transpositional, and inversional
-- equivalence.

function Chord:eRPTI(range)
    local rpt = self:eRPT(range)
    if rpt:iseRPTI(range) then
        return rpt
    end
    return rpt:I():eRPT(range)
end

-- Returns the equivalent of the chord within the representative fundamental
-- domain of range, permutational, transpositional, and inversional
-- equivalence.

function Chord:eOPTI()
    return self:eRPTI(ChordSpace.OCTAVE)
end

-- Returns a formatted string with information about the chord.

function Chord:information()
    local et = self:eT():et()
    local evt = self:eV():et()
    local eopt = self:eOPT():et()
    local epcs = self:epcs():eP()
    local eopti = self:eOPTI():et()
    local eOP = self:eOP()
    local chordName = ChordSpace.namesForChords[eOP:__hash()]
    if chordName == nil then
        chordName = ''
    end
    return string.format([[pitches:  %s  %s
I:        %s
eO:       %s  iseO:    %s
eP:       %s  iseP:    %s
eT:       %s  iseT:    %s
          %s
eI:       %s  iseI:    %s
eV:       %s  iseV:    %s
          %s
eOP:      %s  iseOP:   %s
pcs:      %s
eOPT:     %s  iseOPT:  %s
          %s
eOPI:     %s  iseOPI:  %s
eOPTI:    %s  iseOPTI: %s
          %s
layer:      %6.2f]],
tostring(self), chordName,
tostring(self:I()),
tostring(self:eO()),    tostring(self:iseO()),
tostring(self:eP()),    tostring(self:iseP()),
tostring(self:eT()),    tostring(self:iseT()),
tostring(et),
tostring(self:eI()),    tostring(self:iseI()),
tostring(self:eV()),    tostring(self:iseV()),
tostring(evt),
tostring(self:eOP()),   tostring(self:iseOP()),
tostring(epcs),
tostring(self:eOPT()),  tostring(self:iseOPT()),
tostring(eopt),
tostring(self:eOPI()),  tostring(self:iseOPI()),
tostring(self:eOPTI()), tostring(self:iseOPTI()),
tostring(eopti),
self:layer())
end

function ChordSpace.set(collection)
    local set_ = {}
    for key, value in pairs(collection) do
        set_[value:__hash()] = value
    end
    return set_
end

function ChordSpace.sortedSet(collection)
    local set_ = ChordSpace.set(collection)
    local sortedSet_ = {}
    for key, value in pairs(set_) do
        table.insert(sortedSet_, value)
    end
    table.sort(sortedSet_)
    return sortedSet_
end

function ChordSpace.setContains(setA, x)
    if setA[x:__hash()] == x then
        return true
    end
    return false
end

function ChordSpace.setInsert(setA, x)
    if not ChordSpace.setContains(setA, x) then
        setA[x:__hash()] = x
    end
end

function ChordSpace.sortedEquals(sortedA, sortedB)
    if not (#sortedA == #sortedB) then
        return false
    end
    for i = 1, #sortedA do
        if not (sortedA[i] == sortedB[i]) then
            return false
        end
    end
    return true
end

function ChordSpace.setIntersection(A, setB)
    local result = {}
    for index, value in pairs(A) do
        if ChordSpace.setContains(setB, value) then
            ChordSpace.setInsert(result, value)
        end
    end
    return result
end

function ChordSpace.union(A, B)
    local result = {}
    for index, value in pairs(A) do
        ChordSpace.setInsert(result, value)
    end
    for index, value in pairs(B) do
        ChordSpace.setInsert(result, value)
    end
    return result
end

ChordSpace.pitchClassesForNames = {}

ChordSpace.pitchClassesForNames["C" ] =  0
ChordSpace.pitchClassesForNames["C#"] =  1
ChordSpace.pitchClassesForNames["Db"] =  1
ChordSpace.pitchClassesForNames["D" ] =  2
ChordSpace.pitchClassesForNames["D#"] =  3
ChordSpace.pitchClassesForNames["Eb"] =  3
ChordSpace.pitchClassesForNames["E" ] =  4
ChordSpace.pitchClassesForNames["F" ] =  5
ChordSpace.pitchClassesForNames["F#"] =  6
ChordSpace.pitchClassesForNames["Gb"] =  6
ChordSpace.pitchClassesForNames["G" ] =  7
ChordSpace.pitchClassesForNames["G#"] =  8
ChordSpace.pitchClassesForNames["Ab"] =  8
ChordSpace.pitchClassesForNames["A" ] =  9
ChordSpace.pitchClassesForNames["A#"] = 10
ChordSpace.pitchClassesForNames["Bb"] = 10
ChordSpace.pitchClassesForNames["B" ] = 11

ChordSpace.chordsForNames = {}
ChordSpace.namesForChords = {}

local function fill(rootName, rootPitch, typeName, typePitches)
    local chordName = rootName .. typeName
    local chord = Chord:new()
    local splitPitches = Silencio.split(typePitches)
    chord:resize(#splitPitches)
    for voice, pitchName in ipairs(splitPitches) do
        local pitch = ChordSpace.pitchClassesForNames[pitchName]
        chord[voice] = rootPitch + pitch
    end
    chord = chord:eOP()
    ChordSpace.chordsForNames[chordName] = chord
    ChordSpace.namesForChords[chord:__hash()] = chordName
end

for rootName, rootPitch in pairs(ChordSpace.pitchClassesForNames) do
    fill(rootName, rootPitch, " minor second",     "C  C#                             ")
    fill(rootName, rootPitch, " major second",     "C     D                           ")
    fill(rootName, rootPitch, " minor third",      "C        Eb                       ")
    fill(rootName, rootPitch, " major third",      "C           E                     ")
    fill(rootName, rootPitch, " perfect fourth",   "C              F                  ")
    fill(rootName, rootPitch, " tritone",          "C                 F#              ")
    fill(rootName, rootPitch, " perfect fifth",    "C                    G            ")
    fill(rootName, rootPitch, " augmented fifth",  "C                       G#        ")
    fill(rootName, rootPitch, " sixth",            "C                          A      ")
    fill(rootName, rootPitch, " minor seventh  ",  "C                             Bb  ")
    fill(rootName, rootPitch, " major seventh",    "C                                B")
    -- Scales.
    fill(rootName, rootPitch, " major",            "C     D     E  F     G     A     B")
    fill(rootName, rootPitch, " minor",            "C     D  Eb    F     G  Ab    Bb  ")
    fill(rootName, rootPitch, " natural minor",    "C     D  Eb    F     G  Ab    Bb  ")
    fill(rootName, rootPitch, " harmonic minor",   "C     D  Eb    F     G  Ab       B")
    fill(rootName, rootPitch, " chromatic",        "C  C# D  D# E  F  F# G  G# A  A# B")
    fill(rootName, rootPitch, " whole tone",       "C     D     E     F#    G#    A#  ")
    fill(rootName, rootPitch, " diminished",       "C     D  D#    F  F#    G# A     B")
    fill(rootName, rootPitch, " pentatonic",       "C     D     E        G     A      ")
    fill(rootName, rootPitch, " pentatonic major", "C     D     E        G     A      ")
    fill(rootName, rootPitch, " pentatonic minor", "C        Eb    F     G        Bb  ")
    fill(rootName, rootPitch, " augmented",        "C        Eb E        G  Ab    Bb  ")
    fill(rootName, rootPitch, " Lydian dominant",  "C     D     E     Gb G     A  Bb  ")
    fill(rootName, rootPitch, " 3 semitone",       "C        D#       F#       A      ")
    fill(rootName, rootPitch, " 4 semitone",       "C           E           G#        ")
    fill(rootName, rootPitch, " blues",            "C     D  Eb    F  Gb G        Bb  ")
    fill(rootName, rootPitch, " bebop",            "C     D     E  F     G     A  Bb B")
    -- Major chords.
    fill(rootName, rootPitch, "M",                 "C           E        G            ")
    fill(rootName, rootPitch, "6",                 "C           E        G     A      ")
    fill(rootName, rootPitch, "69",                "C     D     E        G     A      ")
    fill(rootName, rootPitch, "69b5",              "C     D     E     Gb       A      ")
    fill(rootName, rootPitch, "M7",                "C           E        G           B")
    fill(rootName, rootPitch, "M9",                "C     D     E        G           B")
    fill(rootName, rootPitch, "M11",               "C     D     E  F     G           B")
    fill(rootName, rootPitch, "M#11",              "C     D     E  F#    G           B")
    fill(rootName, rootPitch, "M13",               "C     D     E  F     G     A     B")
    -- Minor chords.
    fill(rootName, rootPitch, "m",                 "C        Eb          G            ")
    fill(rootName, rootPitch, "m6",                "C        Eb          G     A      ")
    fill(rootName, rootPitch, "m69",               "C     D  Eb          G     A      ")
    fill(rootName, rootPitch, "m7",                "C        Eb          G        Bb  ")
    fill(rootName, rootPitch, "m#7",               "C        Eb          G           B")
    fill(rootName, rootPitch, "m7b5",              "C        Eb       Gb          Bb  ")
    fill(rootName, rootPitch, "m9",                "C     D  Eb          G        Bb  ")
    fill(rootName, rootPitch, "m9#7",              "C     D  Eb          G           B")
    fill(rootName, rootPitch, "m11",               "C     D  Eb    F     G        Bb  ")
    fill(rootName, rootPitch, "m13",               "C     D  Eb    F     G     A  Bb  ")
    -- Augmented chords.
    fill(rootName, rootPitch, "+",                 "C            E         G#         ")
    fill(rootName, rootPitch, "7#5",               "C            E         G#     Bb  ")
    fill(rootName, rootPitch, "7b9#5",             "C  Db        E         G#     Bb  ")
    fill(rootName, rootPitch, "9#5",               "C     D      E         G#     Bb  ")
    -- Diminished chords.
    fill(rootName, rootPitch, "o",                 "C        Eb       Gb              ")
    fill(rootName, rootPitch, "o7",                "C        Eb       Gb       A      ")
    -- Suspended chords.
    fill(rootName, rootPitch, "6sus",              "C              F     G     A      ")
    fill(rootName, rootPitch, "69sus",             "C     D        F     G     A      ")
    fill(rootName, rootPitch, "7sus",              "C              F     G        Bb  ")
    fill(rootName, rootPitch, "9sus",              "C     D        F     G        Bb  ")
    fill(rootName, rootPitch, "M7sus",             "C              F     G           B")
    fill(rootName, rootPitch, "M9sus",             "C     D        F     G           B")
    -- Dominant chords.
    fill(rootName, rootPitch, "7",                 "C            E       G        Bb  ")
    fill(rootName, rootPitch, "7b5",               "C            E    Gb          Bb  ")
    fill(rootName, rootPitch, "7b9",               "C  Db        E       G        Bb  ")
    fill(rootName, rootPitch, "7b9b5",             "C  Db        E    Gb          Bb  ")
    fill(rootName, rootPitch, "9",                 "C     D      E       G        Bb  ")
    fill(rootName, rootPitch, "9#11",              "C     D      E F#    G        Bb  ")
    fill(rootName, rootPitch, "13",                "C     D      E F     G     A  Bb  ")
    fill(rootName, rootPitch, "13#11",             "C     D      E F#    G     A  Bb  ")
end

table.sort(ChordSpace.chordsForNames)
table.sort(ChordSpace.namesForChords)

-- Returns all the chords with the specified number of voices that exist
-- within the fundamental domain of the specified octave-based equivalence
-- class that is generated by the interval g, which of course must evenly
-- divide the octave. The chords are returned in a zero-based table,
-- such that the indexes of the chords form an additive cyclic group
-- representing the chords.

function ChordSpace.allOfEquivalenceClassByOperation(voices, equivalence, g)
    g = g or 1
    local equivalenceMapper = nil
    if equivalence == 'OP' then
        equivalenceMapper = Chord.eOP
    end
    if equivalence == 'OPT' then
        equivalenceMapper = Chord.eOPT
    end
    if equivalence == 'OPI' then
        equivalenceMapper = Chord.eOPI
    end
    if equivalence == 'OPTI' then
        equivalenceMapper = Chord.eOPTI
    end
    -- Enumerate all chords in O.
    local chordset = ChordSpace.allChordsInRange(voices, -(ChordSpace.OCTAVE + 1), ChordSpace.OCTAVE + 1)
    -- Coerce all chords to the equivalence class.
    local equivalentChords = {}
    for hash, chord in pairs(chordset) do
        local equivalentChord = equivalenceMapper(chord)
        equivalentChords[equivalentChord:__hash()] = equivalentChord
    end
    -- Sort the chords and create a table with a zero-based index.
    table.sort(equivalentChords)
    local sortedChords = {}
    for key, chord in pairs(equivalentChords) do
        table.insert(sortedChords, chord)
    end
    table.sort(sortedChords)
    local zeroBasedChords = {}
    local index = 0
    for key, chord in pairs(sortedChords) do
        --print('index:', index, 'chord:', chord, chord:eop(), 'layer:', chord:sum())
        table.insert(zeroBasedChords, index, chord)
        index = index + 1
    end
    return zeroBasedChords, sortedChords
 end

function ChordSpace.allOfEquivalenceClass(voices, equivalence, g)
    g = g or 1
    local equivalenceMapper = nil
    if equivalence == 'OP' then
        equivalenceMapper = Chord.iseOP
    end
    if equivalence == 'OPT' then
        equivalenceMapper = Chord.iseOPT
    end
    if equivalence == 'OPI' then
        equivalenceMapper = Chord.iseOPI
    end
    if equivalence == 'OPTI' then
        equivalenceMapper = Chord.iseOPTI
    end
    -- Enumerate all chords in O.
    local chordset = ChordSpace.allChordsInRange(voices, -(ChordSpace.OCTAVE + 1), ChordSpace.OCTAVE + 1)
    -- Select only those O chords that are within the complete
    -- equivalence class.
    local equivalentChords = {}
    for hash, equivalentChord in pairs(chordset) do
        if equivalenceMapper(equivalentChord) then
            -- print(hash, chord, equivalentChord, equivalentChord:__hash())
            table.insert(equivalentChords, equivalentChord)
        end
    end
    -- Sort the chords and create a table with a zero-based index.
    table.sort(equivalentChords)
    local zeroBasedChords = {}
    local index = 0
    for key, chord in pairs(equivalentChords) do
        --print('index:', index, 'chord:', chord, chord:eop(), 'layer:', chord:sum())
        table.insert(zeroBasedChords, index, chord)
        index = index + 1
    end
    return zeroBasedChords, equivalentChords
end

-- Returns a chord with the specified number of voices all set to a first
-- pitch, useful as an iterator.

function ChordSpace.iterator(voices, first)
    local odometer = Chord:new()
    odometer:resize(voices)
    for voice = 1, voices do
        odometer[voice] = first
    end
    return odometer
end

-- Iterates to the next chord in R within the range [first, last);
-- returns true if there is a chord remaining or false otherwise.
-- g is the generator of transposition.

function ChordSpace.next(odometer, first, last, g)
    g = g or 1
    if odometer[1] < last then
        odometer[#odometer] = odometer[#odometer] + g
        -- "Carry" voices across range.
        for voice = #odometer, 2, -1 do
            if odometer[voice] >= last then
                odometer[voice] = first
                odometer[voice - 1] = odometer[voice - 1] + g
            end
        end
        return true
    end
    return false
end

-- Returns a collection of all chords for the specified number of voices in a
-- range, by default the octave. g is the generator of transposition, by default the
-- semitone.

function ChordSpace.allChordsInRange(voices, first, last, g)
    first = first or 0
    last = last or ChordSpace.OCTAVE
    g = g or 1
    -- Enumerate all chords in the range.
    local chordset = {}
    local odometer = ChordSpace.iterator(voices, first)
    while ChordSpace.next(odometer, first, last, g) do
        local chord = odometer:clone()
        chordset[chord:__hash()] = chord
    end
    return ChordSpace.sortedSet(chordset)
end

return ChordSpace
