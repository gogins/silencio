ChordSpace = {}

function ChordSpace.help()
print [[
'''
Copyright 2010 by Michael Gogins.
This software is licensed under the terms 
of the GNU Lesser General Public License.

This package, part of Silencio, implements a geometric approach 
to some common operations in neo-Riemannian music theory 
for use in score generating algorithms.

The associated ChordSpaceView package can display these
chord spaces in an interactive 3-dimensional view.

DEFINITIONS

Pitch is the perception that a sound has a distinct frequency.
It is a logarithmic perception; octaves, which sound 'equivalent' 
in some sense, represent doublings or halvings of frequency.

Pitches and intervals are represented as real numbers. 
Middle C is 60 and the octave is 12. The integers are the same 
as MIDI key numbers and perfectly represent our usual system 
of 12-tone equal temperament, but any and all other pitches 
can also be represented, using fractions.

A tone is a sound that is heard as having a pitch.

A chord is simply a set of tones heard at the same time or, 
what is the same thing, a point in a chord space having one dimension of 
pitch for each voice in the chord.

For the purposes of algorithmic composition in Silencio, a score can be 
considered as a sequence of more or less fleeting chords. 

EQUIVALENCE CLASSES

An equivalence class is a property that identifies elements of a 
set. Equivalence classes induce quotient spaces or orbifolds, where
the equivalence class glues points on one face of the orbifold together
with points on an opposing face.

Plain chord space has no equivalence classes, and plain chords
are represented as vectors in braces {p1, ..., pN}. 

The following equivalence classes apply to pitches and chords, 
and induce different orbifolds in chord space:

R       Range equivalence, e.g. for range 60, 61 == 1.

O       Octave equivalence, e.g. 13 == 1.
        This is a special case of range equivalence.
        Represented by the chord always lying within the first octave.

P       Permutational equivalence, e.g. {1, 2} == {2, 1}.
        Represented by the chord always being sorted.

T       Translational equivalence, e.g. {1, 2} == {7, 8}.
        Represented by the chord always having a sum of pitches
        as close as possible to 0 (see below).

I       Inversional equivalence, e.g.  {0, 4, 7} == {0, -4, -7}.
        Represented as the inversion having the first interval between 
        voices being smaller than or equal to the final interval.
        Care is needed to distinguish the mathematician's sense of 'invert',
        which means to reflect around a center, from the musician's sense of 
        'invert', which varies according to context but in practice often 
        means 'revoice by adding an octave to the lowest tone of a chord.' 
        Here, we use 'invert' and 'inversion' in the mathematician's sense, 
        and we use the terms 'revoice' and 'voicing' for the musician's 
        'invert' and 'inversion'.

C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}.
        We never not assume cardinality equivalence here, because we are 
        working in chord spaces of fixed dimensionality; e.g. we represent
        the note C not as {0}, but as {0, 0, ..., 0}.
        
The equivalence classes may be combined as follows,
and sometimes we distinguish them with different kinds of brackets;
see Callendar, Quinn, and Tymoczko, "Generalized Voice-Leading Spaces,"
_Science_ 320, 2008.

OP      Tymoczko's orbifold for chords; i.e. chords with a 
        fixed number of voices in a harmonic context.
        It forms a hyperprism with as many sides as voices and 
        the ends identified by octave equivalence and a twist of 
        voicing. In OP for trichords in 12TET, the augmented triads run up 
        the middle of the prism, the two-pitch chords form the sides, and 
        the one-pitch chords form the edges that join the sides.
        Represented as vectors in parentheses (p1,...,pN);

OPC     Pitch-class set; i.e. chords with varying numbers of voices
        in a harmonic context; represented as vectors in brackets [p1,...,pN].
        
OPT     Chord type; base layer of the OP prism, where the sum of each chord's 
        pitches are as close as possible to 0. Note that CM and Cm are 
        different OPT. Because the OP prism is canted down from the origin, 
        at least one pitch in each OPT chord (excepting the origin itself) 
        is negative.

OPI     Normal voicing; not the same as 'normal form' 
        but used for some of the same purposes.
        In OP for trichords, OPI is the 1/3 of OP bounded by the 
        orthogonal axis and the column of augmented triads.
        Represented as vectors in angle brackets <p1,...,pN>

OPTI    Set-class, not the same as 'prime form' but used for some of the same
        purposes. Note that CM and Cm are the same OPTI.
        In OP for trichords, OPTI is the 1/6 of the OPT layer 
        bounded by the origin and the augmented triad at the center.
        Represented as vectors in slash brackets, /p1,...,pN\.

RP      The chord space used in scores; chords with a fixed number of voices
        in a contrapuntal context. Represented as vectors 
        in double parentheses ((p1,...,pN)). Note that there exists 
        RPC as well as OPC, RPT as well as OPT, and so on; if R is an 
        integral multiple of the octave then these operations sound similar to 
        the analogous operations under octave equivalence, but there are 
        more choices of voice-leadings for a given progression.

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
                
D               Send any triad to the next triad a perfect fifth lower.
                
P, L, and R have been extended as follows, see Fiore and Satyendra, 
"Generalized Contextual Groups", _Music Theory Online_ 11, August 2008:
    
K(c)            Interchange by inversion;
                K(c):= I(c, c[1] + c[2]).
                This is a generalized form of P; for major and minor triads,
                it is exactly the same as P, but it also works with other
                chord types.
        
Q(c, n, m)      Contexual transposition;
                Q(c, n, m) := T(c, n) if c is a T-form of m,
                or T(c, -n) if c is an I-form of M. Not a generalized form
                of L or R; but, like them, K and Q generate the T-I group.
                
MUSICAL MEANING AND USE

The chord space in most musicians' heads is a combination of OP and RP, 
with reference to OPI and OPTI (actually, since harmonic analysts do in fact
ignore unisons and doublings and so do not in fact ignore C, 
these are OPC, RPC, OPCI, and OPCTI).

In OP, root progressions are motions more or less up and down 
the 'columns' of identically structured chords. Changes of chord type are 
motions across the layers of differently structured chords.
P, L, and R send major triads to their nearest minor neighbors,
and vice versa. I reflects a chord across a layer of the prism.
T moves a chord up and down the orthogonal axis of the prism.

VOICE-LEADING

Those operations that are defined only in OP can be extended to
RP by revoicing the results (projecting from OP to RP).
            
The closest voice-leadings are between the closest chords in the space.
The 'best' voice-leadings are closest first by 'smoothness,'
and then  by 'parsimony.' See Dmitri Tymoczko, 
_The Geometry of Musical Chords_, 2005 (Princeton University).

This concept of voice-leading applies in all equivalence classes, not 
only to root progressions of chords, and the meaning of 'well-formed 
voice-leading' changes according to the equivalence class. In OP it means 
well-formed harmonic progression, in RP it also means well-formed 
contrapuntal voice-leading.

Or, to make it really simple, OP is harmony and RP is counterpoint.
    
We do bijective contrapuntal voiceleading by connecting a chord in RP
to a chord with a different OP by choosing the shortest path 
through RP, optionally avoiding parallel fifths. 
This invariably produces a well-formed voice-leading.

PROJECTIONS

We select voices and sub-chords from chords by 
projecting the chord to subspaces of chord space. This can be 
done, e.g., to voice chords, arpeggiate them, or play scales.
The operation is performed by multiplying a chord by
a matrix whose diagonal represents the normal basis of the subspace,
and where each element of the basis may be either identity 
(1) or any multiple of the octave (12).

V(c [, n])      Iterates with optional stride n through all powers of the  
                basis of OP under RP, for the purpose of revoicing the chord.

S(c, v)         Projects the chord to the subspace defined by the basis
                vector v, e.g. for trichords v := [0, 1, 0] picks the 
                second voice. 

A(c, v [, n])   Iterates through all cyclical permutations of v in S(c, v),
                with optional stride n.
                
V, S, and A may be used in combination to produce any regular arpeggiation.
                

SCORE GENERATION

Durations, instruments, dynamics, and so on can be attributed
to chords by expanding them from vectors to tensors. 

Because Lua lacks a tensor package, and because the [] operator
cannot truly be overridden, and because the () operator 
cannot return an lvalue, the Chord class contains auxiliary tables to 
represent the duration, channel, velocity, and pan of each voice. 
These attributes are not sorted or manipulated along with the pitches,
they are associated with the numerical order of the voices;
but they can still be very useful in score generation.

Any Chord object can be written to any time slice of a Silence score.

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

All functions that take a single Chord parameter are 
implemented as member functions of Chord.

All functions that take more than one Chord parameter,
and some that take one Chord but refer to R, are
implemented as member functions of Orbifold.

Each function that implements an equivalence class has a name
beginning with 'e', e.g. 'eO' for octave equivalence (pitch class)
and 'eOPTI' for OPTI equivalence (set class).

Each function that identifies an equivalence class has a name
beginning with 'ise', e.g. 'iseO' for 'is in the fundamental 
domain for octave equivalence.'
]]
end

require("Silencio")

-- The size of the octave, defined to be consistent with 
-- 12 tone equal temperament and MIDI.

OCTAVE = 12

-- Returns the pitch under range equivalence.

function eR(pitch, range)
    if range then
        return pitch % range
    else
        return pitch
    end
end

-- Returns the pitch under octave equivalence,
-- i.e. returns the pitch-class of the pitch.

function eO(pitch)
    return eR(pitch, OCTAVE)
end

-- Returns the pitch translated by x, by default
-- under octave equivalence, optionally under
-- range equivalence.

function T(pitch, x, range)
    range = range or OCTAVE
    return eR(pitch + x, range)
end 

-- Returns the pitch reflected by x, by default
-- under octave equivalence, optionally under 
-- range equivalence.

function I(pitch, x, range)
    range = range or OCTAVE
    return eR((range - eR(pitch, range)) + x, range)
end    

-- Returns the Euclidean distance between chords a and b.

function euclidean(a, b)
    local sumOfSquaredDifferences = 0
    for voice = 1, #a do
        sumOfSquaredDifferences = sumOfSquaredDifferences + math.pow((a[voice] - b[voice]), 2)
    end
    return math.sqrt(sumOfSquaredDifferences)
end

-- Chords mainly represent pitches, but have auxiliary tables to represent 
-- duration, channel (instrument), velocity (loudness), and pan.

Chord = {}

function Chord:new(o)
    local o = o or {duration = {}, channel = {}, velocity = {}, pan = {}}
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

-- Redefines the metamethod to implement value semantics
-- for ==, for the pitches in this only.

function Chord:__eq(other)
    voices = math.min(#self, #other)
    for voice = 1, voices do
        if self[voice] ~= other[voice] then
            return false
        end
    end
    if #self ~= #other then
        return false
    end
    return true
end

-- Redefines the metamethod to implement value semantics
-- for <, for the pitches in this only.

function Chord:__lt(other)
    voices = math.min(#self, #other)
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

-- Returns the lowest pitch in the chord.

function Chord:min()
    local lowest = self[1]
    for voice = 2, #self do
        if self[voice] < lowest then
            lowest = self[voice]
        end
    end
    return lowest
end

-- Returns the highest pitch in the chord.

function Chord:max()
    local highest = self[1]
    for voice = 2, #self do
        if self[voice] > highest then
            highest = self[voice]
        end
    end
    return highest
end

-- Returns the range of the chord.

function Chord:range()
    return self:max() - self:min()
end

function Chord:clone()
    local chord = Chord:new()
    for voice, value in ipairs(self) do
        chord[voice] = value
    end
    for voice, value in ipairs(self.duration) do
        chord.duration[voice] = value
    end
    for voice, value in ipairs(self.channel) do
        chord.channel[voice] = value
    end
    for voice, value in ipairs(self.velocity) do
        chord.velocity[voice] = value
    end
    for voice, value in ipairs(self.pan) do
        chord.pan[voice] = value
    end
    return chord
end

-- Returns whether the chord is in the fundamental domain
-- of R (range) equivalence.

function Chord:iseR(range)
    -- The chord must have a range less than or equal to the range.
    if not (self:range() <= range) then
        return false
    end
    -- Then the chord must be on the right layer of the range orbifold.
    -- The layers are perpendicular to the orthogonal axis.
    local layer = self:sum()
    if not ((0 <= layer) and (layer <= range)) then
        return false
    end
    return true
end

-- Returns whether the chord is in the fundamental domain
-- of O (octave) equivalence.

function Chord:iseO()
    return self:iseR(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- or P (permutational) equivalence.

function Chord:iseP()
    for i = 1, #self - 1 do
        if not (self[i] <= self[i + 1]) then
            return false
        end
    end
    return true
end

-- Returns whether the chord is in the fundamental domain
-- of T (transpositional) equivalence.

function Chord:iseT()
    if (self:sum() == 0) then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of I (inversional) equivalence.

function Chord:iseI()
    if ((self[2] - self[1]) <= (self[#self] - self[#self - 1])) then
        return true
    else
        return false
    end
end

function Chord:distanceToOrthogonalAxis()
    local layer = self:sum()
    local distancePerVoice = layer / #self
    local orthogonalChord = Chord:new()
    for voice = 1, #self do
        orthogonalChord[voice] = distancePerVoice
    end
    local distanceToOrthogonalAxis = euclidean(self, orthogonalChord)
    -- print(distanceToOrthogonalAxis)
    return distanceToOrthogonalAxis
end

-- Returns whether the chord is in the fundamental domain
-- of V (voicing) equivalence.

function Chord:iseV()
    local distanceToOrthogonalAxis = self:distanceToOrthogonalAxis()
    local voicings = self:voicings()
    for i, voicing in ipairs(voicings) do
        if voicing:distanceToOrthogonalAxis() < distanceToOrthogonalAxis then
            return false
        end
    end
    return true
end

-- Returns whether the chord is in the fundamental domain
-- of RP equivalence.

function Chord:iseRP(range) 
    for i = 1, #self - 1 do
        if not (self[i] <= self[i + 1]) then
            return false
        end
    end
    if not (self[#self] <= (self[1] + range)) then
        return false
    end
    local layer = self:sum()
    if not (0 <= layer and layer <= range) then
        return false
    end
    return true
end

-- Returns whether the chord is in the fundamental domain
-- of OP equivalence.

function Chord:iseOP()
    return self:iseRP(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- of RT equivalence.

function Chord:iseRT(range)
    if not (self:min() == self[1]) then
        return false
    end
    if not (self:max() <= (self[1] + range)) then
        return false
    end
    if not (self:sum() == 0) then
        return false
    end
    return true
end

-- Returns whether the chord is in the fundamental domain
-- of OT equivalence.

function Chord:iseOT()
    return self:iseRT(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- of RI equivalence.

function Chord:iseRI(range)
    if (self:iseR(range) and self:iseI()) then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of OI equivalence.

function Chord:iseOI()
    return self:iseRI(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- of PT equivalence.

function Chord:isePT()
    if (self:iseP() and self:iseT()) then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of PI equivalence.

function Chord:isePI()
    if (self:iseP() and self:iseI()) then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of TI equivalence.

function Chord:iseTI()
    if (self:iseT() and self:iseI()) then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of RPT equivalence.

function Chord:iseRPT(range)
    if not (self[#self] <= (self[1] + range)) then
        return false
    end
    if not (self:sum() == 0) then
        return false
    end
    for i = 1, #self - 1 do
        if not ((self[1] + range - self[#self]) <= (self[i + 1] - self[i])) then
            return false
        end
    end
    return true
end

-- Returns whether the chord is in the fundamental domain
-- of OPT equivalence.

function Chord:iseOPT()
    return self:iseRPT(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- of RPI equivalence.

function Chord:iseRPI(range)
    if self:iseRP(range) and self:iseI() then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of OPI equivalence.

function Chord:iseOPI()
    return self:iseRPI(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- of RPTI equivalence.

function Chord:iseRPTI(range)
    if self:iseRPT(range) and self:iseI() then
        return true
    else
        return false
    end
end

-- Returns whether the chord is in the fundamental domain
-- of OPTI equivalence.

function Chord:iseOPTI()
    return self:iseRPTI(OCTAVE)
end

-- Returns the number of times the pitch occurs in the chord,
-- under an optional range equivalence (defaulting to the octave).

function Chord:count(pitch, range)
    range = range or OCTAVE
    n = 0
    for voice, value in ipairs(self) do
        if eR(value, range) == pitch then
            n = n + 1
        end
    end
    return n
end

-- Returns the sum of the pitches in the chord.

function Chord:sum()
    local s = 0
    for voice, pitch in ipairs(self) do
        s = s + pitch
    end
    return s
end

-- Returns a copy of the chord cyclically permuted by stride n.

function Chord:cycle(stride)
    stride = stride or 1
    local chord = self:clone()
    if stride > 0 then
        for i = 1, stride do
            local tail = table.remove(chord)
            table.insert(chord, 1, tail)
        end
        return chord
    end
    if stride < 0 then
        for i = 1, math.abs(stride) do
            local head = table.remove(chord, 1)
            table.insert(chord, head)
        end
    end
    return chord
end

function Chord:cyclicalPermutations()
    local chord = self:eOP()
    local permutations = {}
    permutations[1] = c
    for i = 2, self.N do
        chord = chord:cycle()
        permutations[i] = chord
    end
    return permutations
end

-- Returns a copy of the chord 'inverted' in the musician's sense,
-- i.e. revoiced by cyclically permuting the chord and 
-- adding (or subtracting) an octave to the highest (or lowest) voice. 
-- The revoicing will move the chord up or down in pitch.

function Chord:V(direction)
    direction = direction or 1
    local chord = self:clone()
    if direction > 0 then
        chord = chord:cycle(-1)
        chord[#chord] = chord[#chord] + OCTAVE   
    end
    if direction < 0 then
        chord = chord:cycle(1)
        chord[1] = chord[1] - OCTAVE
    end
    return chord
end

-- Returns all the 'inversions' (in the musician's sense) 
-- or revoicings of the chord.

function Chord:voicings()
    local chord = self:eP()
    local voicings = {}
    voicings[1] = chord
    for i = 2, #self do
        chord = chord:V()
        voicings[i] = chord
    end
    return voicings
end

-- Returns a copy of the chord transposed by x. 

function Chord:T(x)  
    chord = self:clone()
    for voice, pitch in ipairs(self) do
        chord[voice] = T(pitch, x)
    end
    return chord
end

-- Returns a copy of the chord reflected around x.

function Chord:I(x)
    chord = self:clone()
    for voice, pitch in ipairs(self) do
        chord[voice] = I(pitch, x)
    end
    return chord
end

-- Returns the chord under permutational equivalence,
-- i.e. sorted.

function Chord:eP()
    local chord = self:clone()
    table.sort(chord)
    return chord
end

-- Returns a copy of the chord under range equivalence.

function Chord:eR(range)
    local chord = self:clone()
    -- First bring each voice inside the range.
    -- This ensures the chord is close enough to the orthogonal axis.
    for voice, pitch in ipairs(self) do
        chord[voice] = eR(pitch, range)
    end
    -- If the chord is then already inside the orbifold, return it.
    if chord:iseR(range) then
        return chord
    end
    -- If the chord is below the orbifold, 
    -- revoice it upwards until it is inside.
    local sum = chord:sum()
    while (sum < 0) do
        chord = chord:V(1)
        sum = chord:sum()
        print(sum, chord)
    end
    -- If the chord is above the orbifold,
    -- revoice it downwards until it is inside.
    while (sum > range) do
        chord = chord:V(-1)
        sum = chord:sum()
        print(sum, chord)
    end
    return chord
end

-- Returns a copy of the cord both under range equivalence and 
-- under permutational equivalence, i.e. sorted.

function Chord:eRP(range)
    return self:eR(range):P()
end

-- Returns a copy of the chord under octave equivalence,
-- i.e. the pitch-classes in this.

function Chord:eO()
    return self:eR(OCTAVE)
end

-- Returns a copy of the chord both under octave equivalence and
-- under permutational equivalence, i.e. sorted.

function Chord:eOP()
    return self:eO():eP()
end

-- Returns the chord transposed stepwise such that its voices sum to
-- as little greater than 0 as possible.

function Chord:eT(step)
    step = step or 1
    local distancePerVoice = self:sum() / #self
    local fraction = math.fmod(distancePerVoice, step)
    -- Round off to the size of the pitch step.
    local distancePerVoice = distancePerVoice - fraction
    local chord = self:clone()
    for voice, pitch in ipairs(chord) do
        chord[voice] = pitch - distancePerVoice
    end
    return chord
end

-- Move 1 voice of the chord,
-- optionally under range equivalence

function Chord:move(voice, interval, range)
    chord = self:clone()
    chord[voice] = T(chord[voice], interval, range)
    return self:eRP(range)
end

-- The Orbifold class represents a voice-leading space
-- under either octave or range equivalence, with any 
-- fixed number of independent voices.

Orbifold = {}

function Orbifold:new(o)
    local o = o or {N = 3, R = OCTAVE, NR = 36, octaves = 1, prismRadius = 0.14}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Orbifold:setOctaves(octaves)
    self.octaves = octaves
    self.R = self.octaves * OCTAVE
    self.NR = self.N * self.R
end

function Orbifold:setVoices(voices)
    self.N = voices
    self.NR = self.N * self.R
end

-- Returns a new chord that spans the orbifold.

function Orbifold:newChord()
    local chord = Chord:new()
    chord:resize(self.N)
    return chord
end

-- Move 1 voice of the chord within the orbifold,
-- i.e. under RP equivalence

function Orbifold:move(chord, voice, interval)
    local movedChord = chord:move(interval, self.R)
    return self:eRP(movedChord)
end

-- Transposes the chord by the interval within the orbifold,
-- i.e. under RP equivalence.

function Orbifold:T(chord, interval)
    local transposedChord = chord:T(interval, self.R)
    return self:eRP(transposedChord)
end

-- Reflects the chord around the interval within the orbifold,
-- i.e. under RP equivalence.

function Orbifold:I(chord, interval)
    local invertedChord = chord:I(interval, self.R)
    return self:eRP(invertedChord)
end

-- Performs the neo-Riemannian leading tone exchange transformation,
-- keeping the result within the orbifold, i.e. under RP equivalence.

function Orbifold:nrL(chord)
    local opi = self:eOPI(chord)
    local opti = self.eOPTI(opi)
    if opti[2] == 4 then
        opi[1] = opi[1] - 1
    else
        if opti[2] == 3 then
            opi[3] = opi[3] + 1
        end
    end
    return opi
end

-- Performs the neo-Riemannian parallel transformation.

function Orbifold:nrP(chord)
    local opi = self:eOPI(chord)
    local opti = self:eOPTI(opi)
    if opti[2] == 4 then
        opi[2] = opi[2] - 1
    else
        if opti[2] == 3 then
            opi[2] = opi[2] + 1
        end
    end
    return opi
end

-- Performs the neo-Riemannian relative transformation.

function Orbifold:nrR(chord)
    local opi = self:eOPI(chord)
    local opti = self.eOPTI(opi)
    if opti[2] == 4 then
        opi[3] = opi[3] + 2
    else
        if opti[2] == 3 then
            opi[1] = opi[1] - 2
        end
    end
    return opi
end

-- Performs the neo-Riemannian dominant transformation.

function Orbifold:nrD(chord)
    opi = self:eOPI(chord)
    opi[1] = opi[1] - 7
    opi[2] = opi[2] - 7
    opi[3] = opi[3] - 7
    return self:eRP(opi)
end

-- Returns the voicing within the orbifold that is closest 
-- to the orthogonal axis of the chord space.
-- Not the same as 'normal form' in atonal set theory,
-- but used for some of the same purposes.

function Orbifold:eOPI(chord)
    local s = chord:sum()
    local distancePerVoice = s / #chord
    local orthogonalProjection = self:newChord()
    for voice = 1, self.N do
        orthogonalProjection[voice] = distancePerVoice
    end
    local voicings = chord:voicings()
    local orthogonalVoicing = voicings[1]
    local minimumDistance = euclidean(orthogonalProjection, orthogonalVoicing)
    for i = 2, #voicings do
        voicing = voicings[i]
        local voicingDistance = euclidean(orthogonalProjection, voicing)
        if voicingDistance < minimumDistance then
            minimumDistance = voicingDistance
            orthogonalVoicing = voicing
        end
    end
    return orthogonalVoicing
end
 
function Orbifold:eOPT(chord)
    return chord:eOP():eT()
end

function Orbifold:eOPTI(chord)
    return chord:eOPI(chord):eT()
end

-- Returns the next voicing of the chord that is under RP, 
-- or nil if the chord is higher than RP.

function Orbifold:V(chord, iterator, zero)
    if base == nil then
        zero = chord:eOP()
        -- Ensure that iteration starts below the lowest layer.
        for voice = 1, self.N do
            zero[voice] = zero[voice] - (self.R + OCTAVE)
        end
    end
    if iterator == nil then
        iterator = chord:clone()
    end
    -- Enumerate the next voice by counting voicings in RP.
    -- iterator[1] is the most significant voice, 
    -- iterator[self.N] is the least significant voice.
    while iterator[1] < self.R do
        iterator[self.N] = iterator[self.N] + OCTAVE
        local unorderedIterator = iterator:eP()
        if unorderedIterator:iseRP(self.R) then
            return unorderedIterator
        end
        -- "Carry" octaves.
        for voice = self.N, 2, -1 do
            if iterator[voice] >= self.R then
                iterator[voice] = zero[voice]
                iterator[voice - 1] = iterator[voice - 1] + OCTAVE
            end
        end
    end
    return nil
end

-- Returns all voicings of the chord under RP.

function Orbifold:voicings(chord)
    local voicings = {}
    local zero = chord:eOP()
    -- Ensure that iteration starts below the lowest layer.
    for voice = 1, self.N do
        zero[voice] = zero[voice] - (self.R + OCTAVE)
    end
    iterator = zero:clone()
    while true do
        local voicing = self:V(chord, iterator, zero)
        if voicing == nil then
            break
        else
            table.insert(voicings, voicing)
        end
    end
    return voicings
end

-- Returns the voice-leading between chords a and b,
-- i.e. what you have to add to a to get b.

function Orbifold:voiceleading(a, b)
    local voiceleading = Chord:new()
    for voice = 1, self.N do
        voiceleading[voice] = b[voice] - a[voice]
    end
    return voiceleading
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
    local v1 = self:voiceleading(source, d1):eP()
    local v2 = self:voiceleading(source, d2):eP()
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

function Orbifold:eRP(chord)
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

function Orbifold:eRP(chord)
    if chord:iseRP(self.R) == true then
        return chord:clone()
    end
    local voicings = self:voicings(chord)
    for i, voicing in ipairs(voicings) do
        if voicing:iseP() then
            local c = voicing:clone()
            for i = 1, self.N do
                if c:iseRP(self.R) then
                    return c:clone()
                end
                c = self:O(c)
            end
        end
    end
    return nil
end

function Orbifold:stayInside(chord)
    if self:isInside(chord) then
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
    return string.format('C   %s\nT   %s\n0   %s\n1   %s\n0-1 %s\nSum %f', self:tones(c), self:eT(c), self:eOPI(c), self:eOPTI(chord), chord:sum())
end

-- Returns the chord inverted by the sum of its first two voices.
  
function Orbifold:K(chord)
    local c = chord:eP()
    if #chord < 2 then
        return chord
    end
    local n = c[1] + c[2]
    return self:eRP(c:I(n, self.R))
end

-- Returns whether chord X is a transpositional form of Y with interval size g.
-- Only works in equal temperament.

function Orbifold:Tform(X, Y, g)
    local pcsx = X:eOP()
    local i = 0
    while i < OCTAVE do
        local ty = self:T(Y, i)
        local pcsty = ty:eOP()
        if pcsx == pcsty then
            return true
        end
        i = i + g
    end
    return false
end

-- Returns whether chord X is an inversional form of Y with interval size g.
-- Only works in equal temperament.

function Orbifold:Iform(X, Y, g)
    pcsx = X:eOP()
    local i = 0
    while i < OCTAVE do
        local iy = self:I(Y, i)
        local pcsiy = iy:eOP()
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
        return self:T(chord,  n):eP()
    end
    if self:Iform(chord, m, g) then
        return self:T(chord, -n):eP()
    end
    return chord
end
        
return ChordSpace
