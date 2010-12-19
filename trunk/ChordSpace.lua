ChordSpace = {}

function ChordSpace.help()
print [[
'''
Copyright 2010 by Michael Gogins.
This software is licensed under the terms 
of the GNU Lesser General Public License.

This package, part of Silencio, implements a geometric approach 
to some common operations in neo-Riemannian music theory, 
for use in score generating algorithms.

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

DEFINITIONS

Pitch is the perception that a sound has a distinct frequency.
It is a logarithmic perception; octaves, which are 'equivalent' 
in some sense, represent doublings or halvings of frequency.

Pitches and intervals are represented as real numbers. 
Middle C is 60 and the octave is 12. The integers are the same 
as MIDI key numbers and perfectly represent our usual system 
of 12-tone equal temperament, but any and all other pitches 
can be represented by fractions.

A tone is a sound that is heard as having a pitch.

A chord is simply a set of tones heard at the same time or, 
what is the same thing, a point in a chord space having one dimension of 
pitch for each voice in the chord.

For the purposes of algorithmic composition in Silencio, a score can be 
considered as a sequence of more or less fleeting chords. A monophonic melody 
can be considered as a sequence of unison chords.

Care is needed to distinguish the mathematician's sense of 'invert', which 
means to reflect around a center, from the musician's sense of 'invert', which
varies according to context but in practice usually means 'revoice by 
adding an octave to the lowest tone of a chord.' Here, we use 'invert' and 
'inversion' in the mathematician's sense, and we use the terms 
'revoice' and 'voicing' for the musician's 'invert' and 'inversion'.

EQUIVALENCE CLASSES

An equivalence class is a property that identifies elements of a 
set. Equivalence classes induce quotient spaces or orbifolds, where
the equivalence class glues points on one face of the orbifold together
with points on an opposing face.

The following equivalence classes apply to pitches and chords, 
and induce different orbifolds in chord space:

R       Range equivalence, e.g. for range 60, 61 == 1.

O       Octave equivalence, e.g. 13 == 1.
        This is a special case of range equivalence.
        Represented by the chord always lying within the first octave.

P       Permutational equivalence, e.g. {1, 2} == {2, 1}.
        Represented by the chord always being sorted.

T       Translational equivalence, e.g. {1, 2} == {7, 8}.
        Represented by the chord always having a lowest pitch of 0 (C).

I       Inversional equivalence, e.g. for reflection around 7, 
        {0, 4, 7} == {6, 2, 11}.
        Represented by the OP (see below) that is closest to 
        the orthogonal axis of chord space.

C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}.
        Note that in the following cardinality equivalence is ignored,
        because we are working in chord spaces of fixed dimension.

These equivalence classes may be combined as follows,
and after this we distinguish them with different kinds of brackets:

        Plain chord space has no equivalence classes; chords are 
        represented as vectors in braces {p1, ..., pN}.

OP      Tymoczko's orbifold for chords; dimensionality is preserved 
        by using e.g. {0, 0, 0} for the note C instead of just {0},
        i.e. chords with a fixed number of voices in a harmonic context;
        represented as vectors in parentheses (p1,...,pN);

OPC     Pitch-class sets; i.e. chords with varying numbers of voices
        in a harmonic context; represented as vectors in brackets [p1,...,pN].

OPI     Similar to 'normal form.'
        This is a dart-shaped prism within the OP orbifold;
        represented as vectors in angle brackets <p1,...,pN>.

OPTI    Set-class or chord type, similar to 'prime form.'
        This is a dart-shaped layer at the base of the OP and RP orbifolds;
        represented as vectors in slash brackets, /p1,...,pN\.

RP      The chord space used in scores; chords with a fixed number of voices
        in a contrapuntal context; represented as vectors 
        in double parentheses ((p1,...,pN)).

OPERATIONS

Each of the above equivalence classes is, of course, also an operation
that sends chords outside an orbifold to chords inside the orbifold.
We also define the following additional operations in OP (some 
operations take an optional r parameter to apply in RP):

T(c, n [, r])   Translate c by n. 

I(c, n [, r])   Reflect c around n.

P               Send a major triad to the minor triad with the same root,      
                or vice versa.

L               Send a major triad to the minor triad one major third higher,
                or vice versa.

R               Send a major triad to the minor triad one minor third lower,
                or vice versa.
    
K(c)            Interchange by inversion;
                K(c):= I(c, c[1] + c[2]).
                This is a generalized form of P; for major and minor triads,
                it is exactly the same as P, but it also works with other
                chord types.
        
Q(c, n, m)      Contexual transposition;
                Q(c, n, m) := T(c, n) if c is a T-form of m,
                or T(c, -n) if c is an I-form of M. Not a generalized form
                of L or R; but, like them, K and Q generate the T-I group.
                
Those operations that are defined only in OP can be extended to
RP by voicing the results (projecting from OP to RP).
            
MUSICAL MEANING AND USE

The chord space in most musicians' heads is a combination of OP and RP, 
with reference to OPI and OPTI (actually, since musicians ignore doublings
and so do not in fact ignore C, these are OPC, RPC, OPCI, and OPCTI).

In OP and RP, root progressions are motions more or less up and down 
the 'columns' of identically structured chords. Changes of chord type are 
motions across the layers of differently structured chords.
P, L, and R send major triads to their nearest minor neighbors,
and vice versa. I reflects across a layer of the prism.
T moves a chord back and forth along the orthogonal axis of the prism.
The closest voice-leadings are between the closest chords in the space.
The 'best' voice-leadings are closest first by 'smoothness,'
and then  by 'parsimony.' See Dmitri Tymoczko, 
_The Geometry of Musical Chords_, 2005 (Princeton University).

The basic idea is that all _purely_ harmonic transformations of chords
can be performed in OP, but _all_ contrapuntal transformations of chords 
require RP or, to make it really simple, OP is harmony and RP is counterpoint.
    
VOICE-LEADING

We do bijective voiceleading by connecting a chord in RP
to another chord with a different OP by the shortest path through RP,
optionally avoiding parallel fifths. This invariably produces a 
well-formed voice-leading.

PROJECTIONS

We select voices and sub-chords from chords by 
projecting the chord to subspaces of chord space. This can be 
done, e.g., to voice chords, arpeggiate them, or play scales.
The operation is performed by multiplying a chord by
a matrix whose diagonal represents the normal basis of the subspace,
and where each element of the basis may be either identity 
(1) or any multiple of the octave (12).

An operation V is defined to iterate through all powers of 
the basis of OP under RP, for the purpose of revoicing chords.

An operation A is defined to iterate through all subspaces
V, for the purpose of arpeggiating a chord.

SCORE GENERATION

Durations, instruments, dynamics, and so on can be attributed
to chords by expanding them to tensors. 

Because Lua lacks a tensor package, and because the [] operator
cannot truly be overridden, and because the () operator 
cannot return an lvalue, Chords contain auxiliary tables that 
represent the channel, velocity, and pan of each voice. These
attributes are not sorted or manipulated along with the pitches,
they are associated with the numerical order of the voices;
but they can still be very useful in score generation.

Any Chord can be written to any time slice of a Silence score.

SCORE APPLICATION

Any chord can be applied under any equivalence class to any time slice
of a Silencio score. Notes already in the score in that slice will 
be conformed to the chord under the equivalence class.

SCORE TRANSFORMATION

Any time slice of a Silence score can be transformed into 
a Chord of any equivalence class, then operated upon, 
and then either written over or applied to that slice.

IMPLEMENTATION

Operations implemented as member functions of Chord  
do not operate upon self, but return a transformed copy of self.

All operations that take a single Chord are 
implemented as member functions of Chord.

All other operations that take two Chord objects are
implemented as member functions of Orbifold because they
assume the two chords have the same number of voices, i.e.
lie within the same chord space.

]]
end

require("Silencio")

-- Returns the pitch under range equivalence.

function R(pitch, range)
    if range then
        return pitch % range
    else
        return pitch
    end
end

-- Returns the pitch under octave equivalence,
-- i.e. returns the pitch-class of the pitch.

function O(pitch)
    return R(pitch, 12)
end

-- Returns the pitch translated by x, by default
-- under octave equivalence, optionally under
-- range equivalence r.

function T(pitch, x, r)
    r = r or 12
    return R(pitch + x, r)
end 

-- Returns the pitch reflected by x, by default
-- under octave equivalence, optionally under 
-- range equivalence r.

function I(pitch, x, r)
    r = r or 12
    return R((r - R(pitch, r)) + x, r)
end    

-- Chords mainly represent pitches, but have auxiliary tables
-- to represent channel (instrument), velocity (loudness), and pan.

Chord = {}

function Chord:new(o)
    local o = o or {channel = {}, velocity = {}, pan = {}}
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

function Chord:resize(n)
    while #self < n do
        table.insert(self, 0)
        table.insert(self.channel, 0)
        table.insert(self.velocity, 0)
        table.insert(self.pan, 0)
    end
    while #self > n do
        table.remove(self)
        table.remove(self.channel)
        table.remove(self.velocity)
        table.remove(self.pan)
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
    for i, v in ipairs(self.channel) do
        chord.channel[i] = v
    end
    for i, v in ipairs(self.velocity) do
        chord.velocity[i] = v
    end
    for i, v in ipairs(self.pan) do
        chord.pan[i] = v
    end
    return chord
end

-- Quadratic complexity, but short enough not to matter.

function Chord:__tostring()
    local buffer = '{'
    for i = 1, #self do
        buffer = buffer .. string.format('%9.4f', self[i])
    end
    buffer = buffer .. '}'
    return buffer
end

-- Returns a copy of the chord transposed by n, 
-- under equivalence class r. 

function Chord:T(n, r)  
    c = self:copy()
    for i, p in ipairs(self) do
        c[i] = T(p, n, r)
    end
    return c
end

-- Returns a copy of the chord reflected around n,
-- under equivalence class r.

function Chord:I(n, r)
    c = self:copy()
    for i, p in ipairs(self) do
        c[i] = I(p, n, r)
    end
    return c
end

-- Returns this under permutational equivalence,
-- i.e. sorted.

function Chord:P()
    local c = self:copy()
    table.sort(c)
    return c
end

-- Returns a copy of this under some pitch equivalence.

function Chord:R(equivalence)
    c = self:copy()
    for i, p in ipairs(self) do
        c[i] = R(p, equivalence)
    end
    return c
end

-- Returns a copy of this under both range equivalence and 
-- under permutational equivalence, i.e. sorted.

function Chord:RP(equivalence)
    return self:R(equivalence):P()
end

-- Returns a copy of this under octave equivalence,
-- i.e. the pitch-classes in this.

function Chord:O()
    return self:R(12)
end

-- Returns a copy of this under octave equivalence and
-- under permutational equivalence, i.e. sorted.

function Chord:OP()
    return self:O():P()
end

-- Returns the range of the chord.

function Chord:range()
    return self:max() - self:min()
end

-- Returns the count of the pitch in this,
-- under an optional equivalence class.

function Chord:count(pitch, equivalence)
    n = 0
    if equivalence then
        for k, v in ipairs(self) do
            if R(v, equivalence) == pitch then
                n = n + 1
            end
        end
    else
        for k, v in ipairs(self) do
            if (v % 12) == pitch then
                n = n + 1
            end
        end
    end
    return n
end

-- Returns the sum of the pitches in this.

function Chord:sum()
    s = 0
    for k, p in ipairs(self) do
        s = s + p
    end
    return s
end

-- The Orbifold class represents a voice-leading space
-- under either octave or range equivalence, with any number
-- of independent voices.

Orbifold = {}

function Orbifold:new(o)
    local o = o or {N = 3, R = 12, NR = 36, octaves = 1, prismRadius = 0.14}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Orbifold:setOctaves(n)
    self.octaves = n
    self.R = self.octaves * 12
    self.NR = self.N * self.R
end

function Orbifold:setVoices(n)
    self.N = n
    self.NR = self.N * self.R
end

-- Returns a new chord that spans the orbifold.

function Orbifold:newChord()
    local chord = Chord:new()
    chord:resize(self.N)
    return chord
end

-- Returns the range, or tessitura, of the orbifold.

function Orbifold:getTessitura()
    return self.R
end

-- Move 1 voice of the chord within this chord space,
-- optionally under equivalence class r.

function Chord:move(voice, interval, r)
    c = self:copy()
    c[voice] = T(c[voice], interval, r)
    return c
end

function Orbifold:move(chord, voice, interval)
    local c = chord:move(interval, self.R)
    c = self:keepInside(chord)
    return c
end

-- Transposes the chord by the interval, 
-- keeping the result within the orbifold
-- (OP or RP equivalence).

function Orbifold:T(chord, interval)
    local c = chord:T(interval, self.R)
    return self:keepInside(c)
end

-- Reflects the chord around the interval, 
-- keeping the result within the orbifold
-- (OP or RP equivalence).

function Orbifold:I(chord, interval)
    local c = chord:I(interval, self.R)
    return self:keepInside(c)
end

-- Performs the neo-Riemannian leading tone exchange transformation.

function Chord:nrL()
    local c = self:normalVoicing()
    local z1 = self:atOriginNormalVoicing()
    if z1[2] == 4.0 then
        c[1] = c[1] - 1
    else
        if z1[2] == 3.0 then
            c[3] = c[3] + 1
        end
    end
    return c
end

-- Performs the neo-Riemannian leading tone exchange transformation,
-- keeping the result within the orbifold
-- (OP or RP equivalence).

function Orbifold:nrL(chord)
    local c = self:normalVoicing(chord)
    local z1 = self:atOriginNormalVoicing(c)
    if z1[2] == 4.0 then
        c[1] = c[1] - 1
    else
        if z1[2] == 3.0 then
            c[3] = c[3] + 1
        end
    end
    return self:keepInside(c)
end

-- Performs the neo-Riemannian parallel transformation.

function Orbifold:nrP(chord)
    local c = self:normalVoicing(chord)
    local z1 = self:atOriginNormalVoicing(c)
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
    local c = self:normalVoicing(chord)
    z1 = self:atOriginNormalVoicing(c)
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

function Orbifold:nrD(chord)
    c = self:normalVoicing(chord)
    c[1] = c[1] - 7
    c[2] = c[2] - 7
    c[3] = c[3] - 7
    c = self:keepInside(c):copy()
    return c
end

-- Returns the chord transposed so its minimum pitch is 0.

function Orbifold:atOrigin(chord)
    local c = chord:copy()
    local m = c:min(self.N)
    for i = 1, self.N do
        c[i] = c[i] - m
    end
    return c
end

-- Returns the 'first inversion' of the chord, 
-- i.e. the inversion closest to the origin of the chord space.
-- Similar to 'normal form' in atonal set theory.

function Orbifold:normalVoicing(chord)
    local voicings_ = self:voicings(chord)
    local voicingsForDistances = {}
    local minimumDistance = 0
    local origin = self:newChord()
    local minimumInversion = voicings_[1]
    for i = 1, #voicings_ do
        local inversion = voicings_[i]
        local zi = self:atOrigin(inversion)
        local d = self:euclidean(zi, origin)
        if d < minimumDistance then
            d = minimumDistance
            minimumInversion = inversion
        end
        -- print(string.format('Distance %f zero-form %s inversion %s.', d, tostring(zi), tostring(inversion)))
    end
    return minimumInversion
end

-- Returns the 'first inversion' of the chord 
-- transposed such that its first voice is at the origin.
-- Similar to 'prime form' in atonal set theory.

function Orbifold:atOriginNormalVoicing(chord)
    return self:atOrigin(self:normalVoicing(chord))
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

-- Returns, in the argument, all voicings of the tones
-- that fit within the orbifold.

function Orbifold:voicings_(tones, iterating_chord, voice, voicings)
    if voice >= self.N then
        return
    end
    local beginning = 0
    local end_ = 0
    beginning = - self:getTessitura() * 2
    end_ = self.getTessitura() * 2
    local p = beginning
    local increment = 1
    while p < end_ do
        if self:pitchclass(p) == tones[voice] then
            iterating_chord[voice] = p
            local si = self:sort(iterating_chord)
            if self:isInside(si, self:getTessitura()) then
                local ci = self:copy(si)
                -- Table acts as set since chords compare by value.
                voicings[ci] = ci
            end
            self:voicings_(tones, iterating_chord, voice + 1, voicings)
        end
        p = p + increment
    end
end

-- Returns all voicings of the chord that lie within
-- the range of this chord space.

function Orbifold:voicings(chord)
    local voicings = {}
    local ts = self:tones(chord)
    local iterating_chords = self:voicings(ts)
    for k, iterating_chord in ipairs(iterating_chords) do
        local voice = 0
        self:voicings_(tones, iterating_chord, voice, voicings)
    end
    return voicings
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

function Orbifold:parallelFifth(a, b)
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
        if self:parallelFifth(source, d1) then
            return d2
        end
        if self:parallelFifth(source, d2) then
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
        if self:parallelFifth(source, d1) then
            return d2
        end
        if self:parallelFifth(source, d2) then
            return d1
        end
    end
    local v1 = self:voiceleading(source, d1):P()
    local v2 = self:voiceleading(source, d2):P()
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
        if self:parallelFifth(source, d1) then
            return d2
        end
        if self:parallelFifth(source, d2) then
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

-- Returns whether this chord is in its normal voicing.

function Orbifold:isFirstInversion(chord)
    local z = self:atOrigin(chord)
    local z1 = self:atOriginNormalVoicing(chord)
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
-- i.e. revoiced by adding an octave to the lowest voice and 
-- permuting the chord.

function Orbifold:revoice(chord)
   local c = self:rotate(chord, -1)
   c[#c] = c[#c] + 12    
   return c
end

-- Returns all the 'inversions' (in the musician's sense) 
-- or revoicings of the chord.

function Orbifold:voicings(chord)
    local c = chord:RP(self.R)
    local result = {}
    result[1] = c
    for i = 1, self.N do
        c = self:revoice(c)
        result[i] = c
    end
    return result
end

-- Returns whether the chord is within the space.

function Orbifold:isInside(chord, range)
    return self:isInFundamentalDomain(chord)
end

-- Returns the layer of the orbifold to which the chord belongs.

function Orbifold:layer(chord)
    return chord:sum()
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
        -- print(string.format('Chord %s is in F.', tostring(chord)))
        return true
    else
        -- print(string.format('Chord %s is not in F.', tostring(chord)))
        return false
    end
end

function Orbifold:isInLayer(chord)
    local L = self:layer(chord)
    if not ((0 <= L) and (L <= self.R)) then
        return false
    end
    return true
end

function Orbifold:isInOrder(chord)
    for i = 1, self.N - 1 do
        if not (chord[i] <= chord[i + 1]) then
            return false
        end
    end
    if not (chord[self.N] <= (chord[1] + self.R)) then
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
    for i, v in ipairs(r) do
        chord[i] = v
    end
    return chord
end

--[[
-- Keeps the chord inside the orbifold by reflecting off the sides.

function Orbifold:bounceInside(chord)
    local voicings_ = self:voicings(chord)
    for i, inversion in ipairs(voicings_) do
        if self.trichords[inversion] ~= nil then
            return inversion
        end
    end
    return nil
end
]]

function Orbifold:keepInside(chord)
    if self:isInFundamentalDomain(chord) == true then
        return chord
    end
    local voicings = self:voicings(chord)
    for i, inversion in ipairs(voicings) do
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
    chord = chord:sort()
    local voicings = self:voicings(chord)
    local distances = {}
    local maximumDistance = voicings[1]
    for i, inversion in ipairs(voicings) do
        distance = self:euclidean(chord, inversion)
        distances[distance] = inversion
        if maximumDistance > distance then
            maximumDistance = distance
        end
        return distances[maximumDistance]
    end
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
    return self:closest(a, self:voicings(b), avoidParallels)
end

-- Returns a label for a chord.

function Orbifold:label(chord)
    return string.format('C   %s\nT   %s\n0   %s\n1   %s\n0-1 %s\nSum %f', self:tones(c), self:atOrigin(c), self:normalVoicing(c), self:atOriginNormalVoicing(chord), chord:sum())
end

-- Returns the chord inverted by the sum of its first two voices.
  
function Orbifold:K(chord)
    local c = chord:P()
    if #chord < 2 then
        return chord
    end
    local n = c[1] + c[2]
    return self:keepInside(c:I(n, self.R))
end

-- Returns whether chord X is a transpositional form of Y with minimum interval size g.

function Orbifold:Tform(X, Y, g)
    local pcsx = X:OP()
    local i = 0
    while i < 12 do
        local ty = self:T(Y, i)
        local pcsty = ty:OP()
        if pcsx == pcsty then
            return true
        end
        i = i + g
    end
    return false
end

-- Returns whether chord X is an inversional form of Y with minimum interval size g.

function Orbifold:Iform(X, Y, g)
    pcsx = X:OP()
    local i = 0
    while i < 12 do
        local iy = self:I(Y, i)
        local pcsiy = iy:OP()
        if pcsx == pcsiy then
            return true
        end
        i = i + g
    end
    return false
end
  
-- Returns the contextual transposition of the chord by n with respect to m
-- with minimum interval size g.

function Orbifold:Q(chord, n, m, g)
    if self:Tform(chord, m, g) then
        return self:T(chord,  n):P()
    end
    if self:Iform(chord, m, g) then
        return self:T(chord, -n):P()
    end
    return chord
end
        
return ChordSpace
