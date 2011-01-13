ChordSpace = {}

function ChordSpace.help()
print [[
'''
Copyright 2010 by Michael Gogins.
This software is licensed under the terms 
of the GNU Lesser General Public License.

This package, part of Silencio, implements a geometric approach 
to some common operations in neo-Riemannian music theory 
for use in score generating programs:

--  Identifying whether a chord belongs to some equivalence class.

--  Causing chord progressions to move strictly within an orbifold induced 
    by some equivalence class.
    
--  Implementing chord progressions based on the L, P, R, D, K, and Q 
    operations of neo-Riemannian theory (thus implementing some aspects
    of "harmony").
    
--  Implementing chord progressions performed within a more abstract 
    equivalence class by means of the best-formed voice-leading within 
    a less abstract equivalence class (thus implementing some rudiments 
    of "counterpoint").

The associated ChordSpaceView package can display these
chord spaces and operations in an interactive 3-dimensional view.

DEFINITIONS

A voice is a distinct sound that is heard as having a pitch.

Pitch is the perception that a sound has a distinct frequency.
It is a logarithmic perception; octaves, which sound 'equivalent' 
in some sense, represent doublings or halvings of frequency.

Pitches and intervals are represented as real numbers. 
Middle C is 60 and the octave is 12. Our usual system of 12-tone 
equal temperament, as well as MIDI key numbers, are completely represented 
by the whole numbers, but any and all other pitches can be represented 
simply by using fractions.

A chord is simply a set of voices heard at the same time or, 
what is the same thing, a point in a chord space having one dimension of 
pitch for each voice in the chord.

For the purposes of algorithmic composition in Silencio, a score can be 
considered as a sequence of more or less fleeting chords. 

EQUIVALENCE CLASSES

An equivalence class is an operation that identifies elements of a 
set. Equivalence classes induce quotient spaces or orbifolds, where
the equivalence class identifies points on one face of the orbifold 
with points on an opposing face. The fundamental domain of the 
equivalence class is the space "within" the orbifold.

Plain chord space has no equivalence classes. Ordered chords are represented 
as vectors in braces {p1, ..., pN}. Unordered chords are represented as 
sorted vectors in parentheses (p1, ..., pN). Unordering is itself an 
equivalence class.

The following equivalence classes apply to pitches and chords, 
and induce different orbifolds. Classes with lower-case names arise from
atonal set theory, and classes with upper-case names arise from geometric
theory. Equivalence classes can be combined (Callendar, Quinn, and Tymoczko, 
"Generalized Voice-Leading Spaces,"_Science_ 320, 2008), and the more 
equivalence classes are combined, the more abstract is the resulting orbifold
compared to the original parent space.
 
C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}.
        We never assume cardinality equivalence here, because we are 
        working in chord spaces of fixed dimensionality; e.g. we represent
        the note middle C not as {60}, but as {60, 60, ..., 60}.
        Retaining cardinality ensures that there is a proto-metric in
        plain chord space that is inherited by all child chord spaces.
        
r       Range equivalence in scores, e.g. for range 60, 61 == 1. 
        Range equivalence is not actually used in either atonal theory or  
        geometric theory, but it is useful here for implementing voice-leading 
        between chords generated under other equivalence classes in 
        actual scores that span more than one octave.

o       Octave equivalence in atonal theory, e.g. 13 == 1 and -1 == 11.

p       Permutational equivalence in atonal theory, e.g. 
        {2, 3, 1} == {1, 2, 3}.
        
t       Transpositional equivalence in atonal theory, e.g.
        {5, 6, 7} == {0, 1, 2}.
        
i       Inversional equivalence in atonal theory, e.g.
        {0, 4, 7} == {0, 8, 5}.
        
op      Combining octave and permutational equivalence in atonal theory
        defines the "pitch-class sets."

opt     Combining octave, permutational, and transpositional equivalence 
        in atonal theory defines the "chord types."

opi     Combines octave, permutational, and inversional equivalence.

opti    Combining octave, permutational, transpositional, and inversional 
        equivalence in atonal theory defines the "prime forms" or 
        "set classes."
        
O       Octave equivalence in geometric theory. The fundamental domain 
        is defined by the pitches in a chord spanning an octave or less and
        summing to 0. The corresponding orbifold is a hyperprism one 
        octave long whose base is identified with its top, modulo a twist 
        by one cyclical permutation of voices.

P       Permutational equivalence in geometric theory, the same as p.

T       Transpositional equivalence in geometric theory, e.g. {1, 2} == {7, 8}.
        Represented by the chord always having a sum of pitches as close as 
        possible to 0 (see below).

I       Inversional equivalence in geometric theory, the same as i. 
        Represented as the inversion having the 
        first interval between voices be smaller than or equal to the final 
        interval. Care is needed to distinguish the mathematician's sense 
        of 'invert', which means to reflect around a center, from the 
        musician's sense of 'invert', which varies according to context but 
        in practice often means 'revoice by adding an octave to the lowest 
        tone of a chord.' Here, we use 'invert' and 'inversion' in the 
        mathematician's sense, and we use the terms 'revoice' and 'voicing' 
        for the musician's 'invert' and 'inversion'.

OP      Tymoczko's orbifold for chords; i.e. chords with a 
        fixed number of voices in a harmonic context.
        It forms a hyperprism one octave long with as many sides as voices and 
        the ends identified by octave equivalence and one cyclical permutation 
        of voices, modulo the unordering. In OP for trichords in 12TET, the 
        augmented triads run up the middle of the prism, the major and minor 
        triads are in 6 alternating columns around the augmented triads, the 
        two-pitch chords form the 3 sides, and the one-pitch chords form the 
        3 edges that join the sides.

OPI     The OP prism, modulo inversion, i.e. 1/2 of the OP prism.

OPT     Chord type; the layer of the OP prism as close as possible to the 
        origin, modulo the number of voices. Note that CM and Cm are 
        different OPT. Because the OP prism is canted down from the origin, 
        at least one pitch in each OPT chord (excepting the origin itself) 
        is negative.

OPTI    The OPT layer, modulo inversion, i.e. 1/2 of the OPT layer.
        Set-class; not the same pitches as 'prime form,' but the same 
        pitch-class sets. Note that CM and Cm are the same OPTI.

OPERATIONS

Each of the above equivalence classes is, of course, an operation that sends 
chords outside an orbifold to chords inside the orbifold. And we define the 
following additional operations:

T(p, x)         Translate p by x. 

I(p [, x])      Reflect p around x, by default the octave.

P               Send a major triad to the minor triad with the same root,      
                or vice versa (Riemann's parallel transformation).

L               Send a major triad to the minor triad one major third higher,
                or vice versa (Riemann's Leittonwechsel or leading-tone 
                exchange).

R               Send a major triad to the minor triad one minor third lower,
                or vice versa (Riemann's relative transformation)
                .
D               Send a triad to the next triad a perfect fifth lower
                (dominant transformation).
                
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
                
TODO: Implement Rachel Hall, "Linear Contextual Transformations," 2009, 
which seems to further generalize the Generalized Contextual Group, and to 
implement it using affine transformations in chord space, and 
Maxx Cho, "The Voice-Leading Automorphism and Riemannian Operators," 2009,
which may show that tonality arises from voice-leading automorphism in the 
Riemannian group.

                
MUSICAL MEANING AND USE

The chord space in most musicians' heads is a combination of OP, OPT, and OPTI
(actually, since analysts do in fact ignore unisons and doublings and so 
do not in fact ignore C, these are OPC, OPTC, and OPTIC).

In OP, root progressions are motions more or less up and down 
the 'columns' of identically structured chords. Changes of chord type are 
motions across the layers of differently structured chords.
P, L, and R send major triads to their nearest minor neighbors,
and vice versa. I reflects a chord across the middle of the prism.
T moves a chord up and down the orthogonal axis of the prism.

VOICE-LEADING

Those operations that are defined only in OP can be extended to
r or rp by revoicing the results (projecting from one point in OP to several 
points in r or rp).
            
The closest voice-leadings are between the closest chords in the space.
The 'best' voice-leadings are closest first by 'smoothness,'
and then  by 'parsimony.' See Dmitri Tymoczko, 
_The Geometry of Musical Chords_, 2005 (Princeton University).

This concept of voice-leading applies in all equivalence classes, not 
only to root progressions of chords, and the meaning of 'well-formed 
voice-leading' changes according to the equivalence class. In OP it means 
well-formed harmonic progression, in r or rp it also means well-formed 
contrapuntal voice-leading.

Or, to make it really simple, OP is harmony and r or rp is counterpoint.
    
We do bijective contrapuntal voiceleading by connecting a chord in r or rp 
with one OP to another of the several chords in r or rp with a different OP 
by choosing the shortest path through r or rp, optionally avoiding 
parallel fifths. This invariably produces a well-formed voice-leading.

PROJECTIONS

We select voices and sub-chords from chords by 
projecting the chord to subspaces of chord space. This can be 
done, e.g., to voice chords, arpeggiate them, or play scales.
The operation is performed by multiplying a chord by
a matrix whose diagonal represents the normal basis of the subspace,
and where each element of the basis may be either identity 
(1) or any multiple of the octave (12).

V(c [, n])      Iterates with optional stride n through all powers of the  
                basis of OP under rp, for the purpose of revoicing the chord.

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

Each function that identifies an equivalence class has a name
beginning with 'ise', e.g. 'iseO' for 'is in the fundamental 
domain for octave equivalence in geometric theory.'

Each function that implements an equivalence class has a name
beginning with 'e', e.g. 'eop' for pitch class or 'eOPTI' for 
set class.
]]
end

require("Silencio")

-- The size of the octave, defined to be consistent with 
-- 12 tone equal temperament and MIDI.

OCTAVE = 12

-- Middle C.

MIDDLE_C = 60
C4 = MIDDLE_C

function er(pitch, range)
    return pitch % range
end

function eo(pitch)
    return pitch % OCTAVE
end

-- NOTE: Does NOT return the result under any 
-- equivalence class.

function T(pitch, x)
    return pitch + x
end 

-- NOTE: Does NOT return the result under any 
-- equivalence class.

function I(pitch, x)
    x = x or OCTAVE
    return x - pitch
end    

-- Returns the Euclidean distance between chords a and b,
-- which must have the same number of voices.

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

-- Returns the minimum interval in the chord.

function Chord:minimumInterval()
    local minimumInterval = math.abs(self[1] - self[2])
    for v1 = 1, #self do
        for v2 = 1, #self do
            if v1 ~= v2 then
                local interval = math.abs(self[v1] - self[v2])
                if interval < minimumInterval then
                    minimumInterval = interval
                end
            end
        end
    end
    return minimumInterval
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

-- Returns the range of the pitches in the chord.

function Chord:range()
    return self:max() - self:min()
end

-- Returns a value copy of the chord.

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

function Chord:iser(r)
    if not self:range() < r then
        return false
    end
    if not self:min() >= 0 then
        return false
    end
    return true
end

function Chord:er(r)
    local chord = self:clone()
    for voice, pitch in ipairs(self) do
        chord[voice] = pitch % r
    end
    return chord
end

function Chord:iseo()
    return self:iser(OCTAVE)
end

function Chord:eo()
    return self:er(OCTAVE)
end

function Chord:isep()
    for i = 1, #self - 1 do
        if not (self[i] <= self[i + 1]) then
            return false
        end
    end
    return true
end

function Chord:ep()
    local chord = self:clone()
    table.sort(chord)
    return chord
end

function Chord:iset()
    if self:min() == 0 then
        return true
    else
        return false
    end
end

function Chord:et()
    local chord = self:clone()
    local minimum = self:min()
    for voice, pitch in ipairs(chord) do
        chord[voice] = pitch - minimum
    end
    return chord
end

function Chord:eot()
    return self:eo():et()
end

function Chord:isei()
    if ((self[2] - self[1]) <= (self[#self] - self[#self - 1])) then
        return true
    else
        return false
    end
end

function Chord:ei()
    local chord = self:clone()
    if chord:isei() then
        return chord
    else
        return chord:I()
    end
end

function Chord:eop()
    return self:eo():ep()
end

function Chord:eoi()
    return self:eo():ei()
end

function Chord:eopt()
    return self:et():eop()
end

function Chord:iseR(range)
    -- The chord must have a range less than or equal to the length
    -- of the fundamental domain.
    if not (self:max() <= (self:min() + range)) then
        return false
    end
    -- Then the chord must be on the correct layer of the fundamental domain.
    -- These layers are perpendicular to the orthogonal axis and 
    -- begin at the origin.
    local layer = self:sum()
    if not ((0 <= layer) and (layer <= range)) then
        return false
    end
    return true
end

function Chord:iseO()
    return self:iseR(OCTAVE)
end

function Chord:iseP()
    return self:isep()
end

function Chord:iseT()
    if (self:sum() == 0) then
        return true
    else
        return false
    end
end

function Chord:iseI()
    return self:isei()
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

function Chord:iseOP()
    return self:iseRP(OCTAVE)
end

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

function Chord:iseOT()
    return self:iseRT(OCTAVE)
end

function Chord:iseRI(range)
    if (self:iseR(range) and self:iseI()) then
        return true
    else
        return false
    end
end

function Chord:iseOI()
    return self:iseRI(OCTAVE)
end

function Chord:isePT()
    if (self:iseP() and self:iseT()) then
        return true
    else
        return false
    end
end

function Chord:isePI()
    if (self:iseP() and self:iseI()) then
        return true
    else
        return false
    end
end

function Chord:iseTI()
    if (self:iseT() and self:iseI()) then
        return true
    else
        return false
    end
end

function Chord:iseRPT(range)
    if self == self:eRPT(range) then
        return true
    else
        return false
    end
end

function Chord:origin()
    local chord = self:clone()
    for voice = 1, #chord do
        chord[voice] = 0
    end
    return chord
end

function Chord:distanceToOrthogonalAxis()
    local d = self:sum() / #self
    local intersection = self:clone()
    for voice = 1, #self do
        intersection[voice] = d
    end
    return euclidean(self, intersection)     
end

function Chord:closestVoicing()
    local voicings = self:voicings()
    local voicing = voicings[1]
    local minimumDistance = voicing:distanceToOrthogonalAxis()
    for i = 2, #voicings do
        local distance = voicings[i]:distanceToOrthogonalAxis()
        if distance < minimumDistance then
            minimumDistance = distance
            voicing = voicings[i]
        end
    end
    -- print(string.format('Chord: %s  closest voicing: %s  distance from origin: %f', tostring(self), tostring(voicing), minimumDistance))
    return voicing
end

function Chord:iseOPT(step)
    if not self:iseOP() then
        return false
    end
    local iterator = self:clone()
    while true do
        local sum = iterator:sum()
        if sum <= 0 then
            if sum < 0 then
                iterator = iterator:T(1)
            end
            break
        end
        iterator = iterator:T(-1)
    end
    if self == iterator then
        for voice = 1, #self - 1 do
            if not (self[1] + OCTAVE - self[#self] <= self[voice + 1] - self[voice]) then
                return false
            end
        end
        return true
    else
        return false
    end
end

function Chord:iseRPI(range)
    if self:iseRP(range) and self:iseI() then
        return true
    else
        return false
    end
end

function Chord:iseOPI()
    return self:iseRPI(OCTAVE)
end

function Chord:iseRPTI(range)
    if self:iseRPT(range) and self:iseI() then
        return true
    else
        return false
    end
end

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
    permutations[1] = chord
    for i = 2, #self do
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

function Chord:T(x)  
    local chord = self:clone()
    for voice, pitch in ipairs(self) do
        chord[voice] = T(pitch, x)
    end
    return chord
end

function Chord:I(x)
    x = x or OCTAVE
    local chord = self:clone()
    for voice, pitch in ipairs(self) do
        chord[voice] = I(pitch, x)
    end
    return chord
end

function Chord:eP()
    return self:ep()
end

function Chord:eR(range)
    local chord = self:eop()
    -- If the chord is above the orbifold,
    -- revoice it downwards until it is inside.
    while (chord:sum() > range) do
        chord = chord:V(-1)
    end
    return chord
end

function Chord:eRP(range)
    return self:eR(range):P()
end

function Chord:eO()
    return self:eR(OCTAVE)
end

function Chord:eOP()
    return self:eO():eP()
end

-- Returns the chord transposed such that its voices sum to 0.

function Chord:eT()
    local chord = self:eopt()
    return chord:eR()
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

function Chord:label()
    return string.format('C     %s\neo    %s\neop   %s\neoi   %s\neopt  %s\nsum   %f', tostring(self), tostring(self:eo()), tostring(self:eop()), tostring(self:eoi()), tostring(self:eopt()), self:sum())
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
