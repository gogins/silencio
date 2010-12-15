ChordSpace = {}

function ChordSpace.help()
print [[
'''
Copyright 2005 by Michael Gogins.

This package implements a geometric approach to some common operations
in neo-Riemannian music theory, for use in score generating algorithms.

When this package is run as a standalone program, 
it displays a model of chord space
for trichords and can orbit a chord through
the space, playing the results using Csound.

This script also demonstrates the triadic 
neo-Riemannian transformations
of leading-tone exchange (press l), 
parallel (press p),  
relative (press r),
and dominant (press d) progression. 
See Alissa S. Crans, Thomas M. Fiore, and Raymon Satyendra, 
_Musical Actions of Dihedral Groups_, 2008 
(arXiv:0711.1873v2).

You can do plain old transpositions
by pressing 1, 2, 3, 4, 5, or 6.

You can move each voice independently with the arrow keys: 
up arrow to move voice 1 up 1 semitone (shift for down), 
right arrow to move voice 2 in the same way,
down arrow to move voice 3.

EQUIVALENCE CLASSES

Pitch is the perception that a sound has a distinct frequency.

Pitches are represented as real numbers. Middle C is 60 and the octave is 12. 
The integers are the same as MIDI key numbers and perfectly 
represent our usual system of 12-tone equal temperament, but
any and all pitches can be represented by using fractions.

A tone is a sound that is heard as having a pitch.

A chord is simply a set of tones heard at the same time or, 
what is the same thing, a point in a chord space having one dimension of 
pitch for each voice in the chord.

For the purposes of algorithmic composition, a score is a sequence
or more or less fleeting chords. A monophonic melody is a sequence
of one-voice chords.

An equivalence class is a property that identifies elements of a 
set. Equivalence classes induce quotient spaces or orbifolds, where
the equivalence class glues points on one face of the orbifold together
with points on an opposing face.

The following equivalence classes apply to chords, and induce 
different orbifolds in chord space:

O       Octave equivalence, e.g. 13 == 1.
        Represented by the chord always lying within the first octave.

P       Permutational equivalence, e.g. {1, 2} == {2, 1}.
        Represented by the chord always being sorted.

T       Translational equivalence, e.g. {1, 2} == {7, 8}.
        Represented by the chord always starting at 0 (C).

I       Inversional equivalence, e.g. for reflection around 7, 
        {0, 4, 7} == {6, 2, 11}.
        Represented by the OP that is closest to 
        the orthogonal axis of chord space.

R       Range equivalence, e.g. for range 60, 61 == 1.

C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}.

These equivalence classes may be combined, i.e. multiplied, as follows:

OPC     Pitch-class sets; chords in a harmonic context.

OP      Tymoczko's orbifold for chords; dimensionality is preserved 
        by using e.g. {0, 0, 0} for C instead of just {0}.

OPI     Similar to 'normal form.'
        This is a dart-shaped prism within the RP orbifold.

OPTI    Set-class or chord type, similar to 'prime form.'
        This is a dart-shaped layer at the base of the OP and RP orbifolds.

RP      The chord space used in scores;
        chords in a contrapuntal context.

OPERATIONS

Each of these equivalence classes is, of course, also an operation
that sends a chord to another chord. We also define the following 
additional operations, which may apply in one or more equivalence classes:

I(c, n) Reflect c around n.

T(c, n) Translate c by n.

P   Send a major triad to the minor triad twith the same root, 
    or vice versa.

L   Send a major triad to the minor triad one major third higher,
    or vice versa.

R   Send a major triad to the minor triad one minor third lower,
    or vice versa.
    
K(c)    Interchange by inversion;
        K(c):= I(c, c[1] + c[2]).
        
Q(c, n, m)  Contexual transposition;
            Q(c, n, m) := T(c, n) if c is a T-form of m,
            or T(c, -n) if c is an I-form of M.
            
MUSICAL MEANING AND USE

The chord space in most musicians' heads is a combination of OPC and PR, 
with occasional reference to OPI and OPTI.

In OP and RP, root progressions are motions more or less 
up and down the 'columns' of identically 
structured chords. Changes of chord type are motions
across the layers of differently structured chords.
P, L, and R send major triads to their nearest minor neighbors,
and vice versa. I reflects a chord between faces of the prism.
T moves a chord vertically up and down the prism.
The closest voice-leadings are between the closest chords in the space.
The 'best' voice-leadings are closest first by 'smoothness,'
 and then  by 'parsimony.' See Dmitri Tymoczko, 
_The Geometry of Musical Chords_, 2005
(Princeton University).
    
OTHER ATTRIBUTES OF CHORDS

Durations, instruments, dynamics, and so on can be attributed
to chords by expanding them from vectors to matrices,
or by extending the chord vector and the respective operator matrices 
by one block for each additional attribute (these are flattened tensors).

Because Lua lacks a tensor package, we use additional
blocks in the regular vectors and matrices, and the 
chord space operations are defined to operate only upon
the pitch-related blocks.

VOICE-LEADING

We do bijective voiceleading by connecting an RP
to an OP by the shortest path through RP,
optionally avoiding parallel fifths. This almost
invariably produces a well-formed voice-leading.

PROJECTIONS

We select voices and sub-chords from chords by 
projecting them to subspaces of chord space. This can be 
done, e.g., to arpeggiate chords or play scales.
The operation is performed by multiplying a chord by
a matrix whose diagonal represents the basis of the subspace,
and where each element of the basis may be an integer,
modulo R.

SCORE GENERATION

Results of any operation can be transformed into lists of notes 
for a Silencio score. If the chord tensor is incomplete,
missing elements are filled in from a template, or by defaults.

SCORE APPLICATION

Results of any operation can be applied to any time slice
of a Silencio score. 

SCORE TRANSFORMATION

Any time slice of a Silence score can be transformed into 
a chord tensor, then operated upon, and then either written over
or applied to that slice.

]]
end

-- A chord is a numeric vector of pitches
-- implemented as a regular Lua table with 
-- value comparison semantics.

Chord = {}

function Chord:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Chord:resize(n)
    while #self < n do
        table.insert(self, 0)
    end
    while #self > n do
        table.remove()
    end
end

function Chord:__eq(other)
    n = math.min(#self, #other)
    for i = 1, n do
        if self[i] ~= other[i] then
            return false
        end
    end
    if #self ~= #other then
        return false
    end
    return true
end

function Chord:__eq(other)
    n = math.min(#self, #other)
    for i = 1, n do
        if self[i] ~= other[i] then
            return false
        end
    end
    if #self ~= #other then
        return false
    end
    return true
end

function Chord:__lt(other)
    n = math.min(#self, #other)
    for i = 1, n do
        if self[i] < other[i] then
            return true
        end
        if self[i] > other[i] then
            return false
        end
    end
    if #self < #other then
        return true
    end
    return false
end

function Chord:min(n)
    n_ = n or #self
    local m = self[1]
    for i = 2, n_ do
        if self[i] < m then
            m = self[i]
        end
    end
    return m
end

function Chord:max(n)
    n_ = n or #self
    local m = self[1]
    for i = 2, n_ do
        if self[i] > m then
            m = self[i]
        end
    end
    return m
end

function Chord:copy()
    chord = Chord:new()
    for i, v in ipairs(self) do
        chord[i] = v
    end
    return chord
end

function Chord:sort()
    local c = self:copy()
    table.sort(c)
    return c
end

-- Quadratic complexity, but short enough not to matter.

function Chord:__tostring()
    local buffer = '{'
    for k, v in ipairs(self) do
        buffer = buffer .. string.format('%9.4f', v)
    end
    buffer = buffer .. '}'
    return buffer
end

-- Returns the count of pitch-class pc in this.

function Chord:count(pc)
    n = 0
    for k, v in ipairs(self) do
        if (v % 12) == pc then
            n = n + 1
        end
    end
    return n
end

function Chord:sum()
    s = 0
    for k, v in ipairs(self) do
        s = s + v
    end
    return s
end

-- The Orbifold class represents a voice-leading space
-- under either octave or range equivalence, with any number
-- of independent voices.

Orbifold = {}

function Orbifold:new(o)
    local o = o or {N = 3, R = 60, NR = 180, octaveCount = 3, tonesPerOctave = 12, cubeRadius = 0.07, prismRadius = 0.14, normalPrismRadius = 0.14}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Orbifold:copyChord(chord)
    local c = Chord:new()
    for i, v in ipairs(chord) do
        c[i] = chord[i]
    end
    return c
end

-- Returns a new chord that spans the orbifold.

function Orbifold:newChord()
    local chord = Chord:new()
    chord:resize(self.N)
    return chord
end

-- Returns the range, or tessitura, of the orbifold.

function Orbifold:getTessitura()
    if self.isCube then
        return self.cubeTessitura
    else
        return self.R
    end
end

-- Sorts only that portion of the chord
-- that spans the orbifold.

function Orbifold:sort(chord)
    local c = chord:copy()
    local d = chord:new()
    for i = 1, self.N do
        d[i] = i[i]
    end
    d:sort()
    for i = 1, self.N do
        c[i] = d[i]
    end
    return c
end

-- Move 1 voice of the chord within this chord space.

function Orbifold:move(chord, voice, interval)
    local c = chord:copy()
    print(string.format('Move %d by %f.', voice, interval))
    c[voice] = c[voice] + interval
    c = self:bounceInside(chord):copy()
    return c
end

-- Performs a root progression by tranposition.

function Orbifold:pT(chord, interval)
    local c = self:firstInversion(chord)
    print(string.format('Transpose by %f.', interval))
    for i = 1, self.N do
        c[i] = c[i] + interval
    end
    c = self:copyChord(self:bounceInside(c))
    return c
end

-- Performs the neo-Riemannian leading tone exchange transformation.
-- TODO: Make this work under range equivalence.

function Orbifold:nrL(chord)
    print 'Leading-tone exchange transformation.'
    local c = self:firstInversion(chord)
    local z1 = self:zeroFormFirstInversion(c)
    if z1[2] == 4.0 then
        c[1] = c[1] - 1
    else
        if z1[2] == 3.0 then
            c[3] = c[3] + 1
        end
    end
    c = self:keepInside(c):copy()
    return c
end

-- Performs the neo-Riemannian parallel transformation.

function Orbifold:nrP(chord)
    print 'Parallel transformation.'
    local c = self:firstInversion(chord)
    local z1 = self:zeroFormFirstInversion(c)
    if z1[2] == 4.0 then
        c[2] = c[2] - 1
    else
        if z1[2] == 3.0 then
            c[2] = c[2] + 1
        end
    end
    c = self:keepInside(c):copy()
    return c
end

-- Performs the neo-Riemannian relative transformation.

function Orbifold:nrR(chord)
    print 'Relative transformation.'
    local c = self:firstInversion(chord)
    z1 = self:zeroFormFirstInversion(c)
    if  z1[2] == 4.0 then
        c[3] = c[3] + 2
    else 
        if z1[2] == 3.0 then
            c[1] = c[1] - 2 
        end
    end
    c = self:keepInside(c):copy()
    return c
end

-- Performs the neo-Riemannian dominant transformation.
-- TODO: Make this work under range equivalence.

function Orbifold:nrD(chord)
    print 'Dominant transformation.'
    c = self:firstInversion(chord)
    c[1] = c[1] - 7
    c[2] = c[2] - 7
    c[3] = c[3] - 7
    c = self:keepInside(c):copy()
    return c
end

-- Returns the non-ordered (represented as sorted)
-- pitch-class sets in the chord.

function Orbifold:tones(chord)
    local c = pitchclasses(chord)
    return c:sort()
end

function Orbifold:zeroFormModulus(chord)
    local c = chord:copy()
    for i = 1, self.N do
        c[i] = c[i] % self.tonesPerOctave
    end
    local m = c:min(self.N)
    for i = 1, self.N do
        c[i] = c[i] - m
    end
    return c
end

-- Returns the chord transposed so its minimum pitch is 0.

function Orbifold:zeroForm(chord)
    local c = chord:copy()
    local m = c:min(self.N)
    for i = 1, self.N do
        c[i] = c[i] - m
    end
    return c
end

-- Returns the range of the chord.

function Orbifold:chordRange(chord)
    return chord:max(self.N) - chord:min(self.N)
end

-- Returns the 'first inversion' of the chord, 
-- i.e. the one closest to the origin of the chord space.
-- Similar to 'normal form' in atonal set theory.

function Orbifold:firstInversion(chord)
    local inversions_ = self:inversions(chord)
    local inversionsForDistances = {}
    local minimumDistance = 0
    local origin = self:newChord()
    local minimumInversion = inversions_[1]
    for i = 1, #inversions_ do
        local inversion = inversions_[i]
        local zi = self:zeroForm(inversion)
        local d = self:euclidean(zi, origin)
        if d < minimumDistance then
            d = minimumDistance
            minimumInversion = inversion
        end
        --print(string.format('Distance %f zero-form %s inversion %s.', d, tostring(zi), tostring(inversion)))
    end
    return minimumInversion
end

-- Returns the 'first inversion' of the chord 
-- transposed such that its first voice is at the origin.
-- Similar to 'prime form' in atonal set theory.

function Orbifold:zeroFormFirstInversion(chord)
    return self:zeroForm(self:firstInversion(chord))
end

-- Returns whether two chords have equal tones.

function Orbifold:equalTones(a, b)
    local atones = self:tones(a)
    local btones = self:tones(b)
    for i = 1, #atones do
        if atones[i] ~= btones[i] then
            return false
        end
    end
    if #a ~= #b then
        return false
    end
    return true
end

-- Returns, in the argument, all inversions of the tones
-- that fit within the orbifold.

function Orbifold:inversions_(tones, iterating_chord, voice, inversions)
    if voice >= self.N then
        return
    end
    local beginning = 0
    local end_ = 0
    if self.isPrism then
        beginning = - self:getTessitura() * 2
        end_ = self.getTessitura() * 2
    else
        if self.isCube then
            beginning = - self:getTessitura()
            end_ = self:getTessitura()
        end
    end
    local p = beginning
    local increment = 1
    while p < end_ do
        if self:pitchclass(p) == tones[voice] then
            iterating_chord[voice] = p
            local si = self:sort(iterating_chord)
            if self:isInside(si, self:getTessitura()) then
                local ci = self:copy(si)
                -- Table acts as set since chords compare by value.
                inversions[ci] = ci
            end
            self:inversions_(tones, iterating_chord, voice + 1, inversions)
        end
        p = p + increment
    end
end

-- Returns all inversions of the chord that lie within
-- the range of this chord space.

function Orbifold:inversions(chord)
    local inversions = {}
    local ts = self:tones(chord)
    local iterating_chords = self:inversions(ts)
    for k, iterating_chord in ipairs(iterating_chords) do
        local voice = 0
        self:inversions_(tones, iterating_chord, voice, inversions)
    end
    return inversions
end

-- Returns the Euclidean distance between chords a and b.

function Orbifold:euclidean(a, b)
    local ss = 0
    for i = 1, self.N do
        ss = ss + math.pow((a[i] - b[i]), 2)
    end
    return math.sqrt(ss)
end

-- Returns the voice-leading between chords a and b.

function Orbifold:voiceleading(a, b)
    local v = Chord:new()
    for i = 1, self.N do
        v[i] = b[i] - a[i]
    end
    return v
end

-- Returns whether the voiceleading 
-- between chords a and b contains a parallel fifth.

function Orbifold:areParallel(a, b)
    v = self:voiceleading(a, b)
    if v:count(7) > 1 then
        return true
    else
        return false
    end
end

-- Returns the smoothness of the voiceleading between 
-- chords a and b by L1 norm.

function Orbifold:smoothness(a, b)
    local L1 = 0
    for i = 1, self.N do
        L1 = L1 + math.abs(b[i] - a[i])
    end
    return L1
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the smoother (shortest moves), optionally avoiding parallel fifths.

function Orbifold:smoother(source, d1, d2, avoidParallels)
    if avoidParallels then
        if self:areParallel(source, d1) then
            return d2
        end
        if self:areParallel(source, d2) then
            return d1
        end
    end
    local s1 = self:smoothness(source, d1)
    local s2 = self:smoothness(source, d2)
    if s1 <= s2 then
        return d1
    else
        return d2
    end
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the simpler (fewest moves), optionally avoiding parallel fifths.

function Orbifold:simpler(source, d1, d2, avoidParallels)
    if avoidParallels then
        if self:areParallel(source, d1) then
            return d2
        end
        if self:areParallel(source, d2) then
            return d1
        end
    end
    local v1 = self:voiceleading(source, d1)
    v1:sort()
    local v2 = self:voiceleading(source, d2)
    v2:sort()
    for i = self.N, 1, -1 do
        if v1[i] < v2[i] then
            return d1
        end
        if v2[i] < v1[i] then
            return d2
        end
    end
    return d1
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the closer (first smoother, then simpler), optionally avoiding parallel fifths.

function Orbifold:closer(source, d1, d2, avoidParallels)
    if avoidParallels then
        if self:areParallel(source, d1) then
            return d2
        end
        if self:areParallel(source, d2) then
            return d1
        end
    end
    local s1 = self:smoothness(source, d1)
    local s2 = self:smoothness(source, d2)
    if s1 < s2 then
        return d1
    end
    if s1 > s2 then
        return d2
    end
    return self:simpler(source, d1, d2, avoidParallels)
end

-- Returns which of the destinations has the closest voice-leading
-- from the source, optionally avoiding parallel fifths.

function Orbifold:closest(source, destinations, avoidParallels)
    local d = destinations[1]
    for i = 2, #destinations do
        d = self:closer(source, d, destinations[i], avoidParallels)
    end
end

-- Returns whether this chord is in its first inversion.

function Orbifold:isFirstInversion(chord)
    local z = self:zeroForm(chord)
    local z1 = self:zeroFormFirstInversion(chord)
    return z == z1
end

-- Returns a copy of the chord 'rotated' or permuted.

function Orbifold:rotate(chord, n)
    n = n or 1
    local c = chord:copy()
    if n > 0 then
        for i = 1, n do
            tail = table.remove(c)
            table.insert(c, 1, tail)
        end
        return c
    end
    if n < 0 then
        for i = 1, math.abs(n) do
            head = table.remove(c, 1)
            table.insert(c, head)
        end
    end
    return c
end

function Orbifold:rotations(chord)
    local c = self:tones(chord)
    local result = {}
    result[1] = c
    for i = 2, self.N do
        c = self:rotate(c)
        result[i] = c
    end
    return result
end

-- Returns a copy of the chord 'inverted' in the musician's sense,
-- i.e. by adding an octave to the lowest voice and rotating it.

function Orbifold:invert(chord)
   local c = self:rotate(chord, -1)
   c[#c] = c[#c] + 12    
   return c
end

-- Returns all the 'inversions' (in the musician's sense) of the chord.

function Orbifold:inversions(chord)
    local c = self:tones(chord)
    local result = {}
    result[1] = c
    for i = 2, self.N do
        c = self:invert(c)
        result[i] = c
    end
    return result
end

-- Returns whether the chord is within the space.

function Orbifold:isInside(chord, range)
    if self.isPrism then
        return self:isInFundamentalDomain(chord)
    else
        return self.isInsideCube(chord, range)
    end
end

-- Returns whether the chord is inside a hypercube of a certain size.

function Orbifold:isInsideCube(chord, range)
    for i = 1, self.N do
        if chord[i] < - range / 2 then
            return false
        end
        if chord[i] >   range / 2 then
            return false
        end
    end
    return true
end

-- Returns whether the chord is inside a normal prism of a certain size.

function Orbifold:isInsideNormalPrism(chord, range)
    if not self:isInsidePrism(chord, range) then
        return false
    end
    if self:isFirstInversion(chord) then
        return true
    end
    return false
end

-- Returns the layer of the orbifold to which the chord belongs.

function Orbifold:layer(chord)
    local sum = chord[1]
    for i = 2, self.N do
        sum  = sum + chord[i]
    end
    return sum 
end

-- Returns whether the chord is inside the orbifold

function Orbifold:isInsidePrism(chord, range)
    if chord[1] < - range then
        return false
    end
    if chord[1] >   range then
        return false
    end
    for i = 1, self.N do
        if chord[i] > chord[1] + range then
            return false
        end
        if chord[i] < chord[1] then
            return false
        end
    end
    local s = self:layer(chord)
    if 0 <= s and s <= range then
        return true
    end
    return false
end

-- Returns whether the chord is in the fundamental domain of the group.

function Orbifold:isInFundamentalDomain(chord)
    if self:isInLayer(chord) and self:isInOrder(chord) then
        print(string.format('Chord %s is in F.', chord))
        return true
    else
        print(string.format('Chord %s is not in F.', chord))
    end
end

function Orbifold:isInLayer(chord)
    local L = self:layer(chord)
    if not (0 <= L and L <= self.R) then
        return false
    end
    return true
end

function Orbifold:isInOrder(chord)
    for i = 1, self.N - 1 do
        if not chord[i] <= chord[i + 1] then
            return false
        end
    end
    if not chord[self.N] <= (chord[1] + self.R) then
        return false
    end
    return true
end

function Orbifold:O(chord)
    local r = {}
    for i = 2, self.N do
        table.insert(r, chord[i] - (self.R / self.N))
    end
    table.insert(r, chord[1] - (self.R / self.N))
    for i, v in r do
        chord[i] = v
    end
    return chord
end

-- Keeps the chord inside the orbifold by reflecting off the sides.

function Orbifold:bounceInside(chord)
    local inversions = self:inversions(chord)
    for i, inversion in ipairs(inversions) do
        if self.trichords[inversion] ~= nil then
            return inversion
        end
    end
    return nil
end

function Orbifold:keepInside(chord)
    if self:isInFundamentalDomain(chord) then
        return chord
    end
    local inversions = self:inversions(chord)
    for i, inversion in ipairs(inversions) do
        if self:isInOrder(inversion) then
            local c = inversion:copy()
            for i = 1, self.N do
                if self.isInLayer then
                    return c:copy()
                end
                c = self:O(c)
            end
        end
    end
    return nil
end

function Orbifold:stayInside(chord)
    if self:isInside(chord, self:getTessitura()) then
        return chord
    end
    chord = self:sort(chord)
    if self.isPrism then
        local inversions = self:inversions(chord)
        local distances = {}
        local maximumDistance = inversions[1]
        for i, inversion in ipairs(inversions) do
            distance = self:euclidean(chord, inversion)
            distances[distance] = inversion
            if maximumDistance > distance then
                maximumDistance = distance
            end
            return distances[maximumDistance]
        end
    else
        local c = chord:copy()
        for i = 1, self.N do
            while c[i] < -self:getTessitura() / 2 do
                c[i] = c[i] + self:getTessitura()
            end
            while c[i] >  self:getTessitura() / 2 do
                c[i] = c[i] - self:getTessitura()
            end
        end
        c = self:sort(c)
        return c
    end
end

-- Returns the pitch-classes in the chord.

function pitchclasses(chord)
    local c = chord:copy()
    for i, v in ipairs(c) do
        c[i] = v % 12
    end
    return c
end

-- Returns the pitchclass of the pitch.
function pitchclass(pitch)
    return pitch % 12
end

function Orbifold:pitchclass(pitch)
    return pitch % self.tonesPerOctave
end

-- Returns the best bijective voice-leading,
-- first by smoothness then by parsimony,
-- optionally avoiding parallel fifths,
-- from a given source chord of pitches
-- to a new chord of pitches
-- that belong to the pitch-class set of a target chord,
-- and lie within a specified range.
-- The algorithm makes an exhaustive search
-- of potential target chords in the space.

function Orbifold:voicelead(a, b, avoidParallels)
    return self:closest(a, self:inversions(b), avoidParallels)
end

-- Returns a label for a chord.

function Orbifold:label(chord)
    return string.format('C   %s\nT   %s\n0   %s\n1   %s\n0-1 %s\nSum %f', self:tones(c), self:zeroForm(c), self:firstInversion(c), self:zeroFormFirstInversion(chord), chord:sum())
end

-- Returns the pitch transposed by n.

function T(pitch, n)
    return pitchclass(pitch + n)
end

-- Returns the chord transposed by n.

function Orbifold:T(chord, n)
    local chord_ = chord:copy()
    for i, pitch in ipairs(chord) do
        chord_[i] = pitchclass(pitch + n)
    end
    return chord_
end

-- Inverts the pitch by n.
  
  local function I( p,  n)
    return pitchclass((12 - pitchclass(p)) + n);
  end
  
-- Returns the inversion of the chord by n.

function Orbifold:I(chord, n)
    chord_ = Chord:new()
    for i, pitch in ipairs(chord) do
        chord_[i] = I(pitch, n)
    end
    chord_:sort()
    return chord_
end

-- Returns the chord inverted by the sum of its first two voices.
  
function Orbifold:K(chord)
    if chord:size() < 2 then
        return chord
    end
    local n = chord[1] + chord[2]
    return self:I(chord, n)
end

-- Returns whether chord X is a transpositional form of Y with minimum interval size g.

function Orbifold:Tform(X, Y, g)
    local i = 0
    while i < 12 do
        local ty = self:T(Y, i)
        local pcsty = self:pitchclasses(ty)
        if pcsx == pcsty then
            return true
        end
        i = i + g
    end
    return false
end

-- Returns whether chord X is an inversional form of Y with minimum interval size g.

function Orbifold:Iform(X, Y, g)
    local i = 0
    pcsx = self:pitchclasses(X)
    while i < 12 do
        local iy = self:I(Y, i)
        local pcsiy = self:pitchclasses(iy)
        if pcsx == pcsiy then
            return true
        end
        i = i + g
    end
    return false
end
  
-- Returns the contextual transposition of the chord by n with respect to g.

function Orbifold:Q(chord, n, s, g)
    if self:Tform(chord, s, g) then
        return self:T(chord,  n)
    end
    if self:Iform(chord, s, g) then
        return self:T(chord, -n)
    else
        return chord
    end
end
        
return ChordSpace
