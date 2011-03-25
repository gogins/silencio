ChordSpace = {}

function ChordSpace.help()
print [[
'''
Copyright 2010 by Michael Gogins.
This software is licensed under the terms 
of the GNU Lesser General Public License.

This package, part of Silencio, implements a geometric approach 
to some common operations on chords in neo-Riemannian music theory 
for use in score generating programs:

--  Identifying whether a chord belongs to some equivalence class,
    or moving a chord inside the fundamental domain of some 
    equivalence class.
    
--  Causing chord progressions to move strictly within an orbifold induced 
    by some equivalence class.
    
--  Implementing chord progressions based on the L, P, R, D, K, and Q    
    operations of neo-Riemannian theory (thus implementing some aspects
    of "harmony").
    
--  Implementing chord progressions performed within a more abstract 
    equivalence class by means of the best-formed voice-leading within 
    a less abstract equivalence class (thus implementing rudiments 
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
as vectors in parentheses (p1, ..., pN). Unordered chords are represented as 
sorted vectors in braces {p1, ..., pN}. Unordering is itself an equivalence 
class.

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
        of 'invert', which means 'pitch-space inversion' or 'reflect around a 
        fixed point', from the musician's sense of 'invert', which varies 
        according to context but in practice often means 'registral inversion' 
        or 'revoice by adding an octave to the lowest tone of a chord.' Here, 
        we use 'invert' and 'inversion' in the mathematician's sense, and we 
        use the terms 'revoice' and 'voicing' for the musician's 'invert' and 
        'inversion'.

OP      Tymoczko's orbifold for chords; i.e. chords with a 
        fixed number of voices in a harmonic context.
        It forms a hyperprism one octave long with as many sides as voices and 
        the ends identified by octave equivalence and one cyclical permutation 
        of voices, modulo the unordering. In OP for trichords in 12TET, the 
        augmented triads run up the middle of the prism, the major and minor 
        triads are in 6 alternating columns around the augmented triads, the 
        two-pitch chords form the 3 sides, and the one-pitch chords form the 
        3 edges that join the sides.

OPI     The OP prism modulo inversion, i.e. 1/2 of the OP prism.

OPT     The layer of the OP prism as close as possible to the 
        origin, modulo the number of voices. Chord type. Note that CM and 
        Cm are different OPT. Because the OP prism is canted down from the 
        origin, at least one pitch in each OPT chord (excepting the origin 
        itself) is negative.

OPTI    The OPT layer modulo inversion, i.e. 1/2 of the OPT layer.
        Set-class. Note that CM and Cm are the same OPTI.

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
                or vice versa (Riemann's relative transformation).

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
which seems to further extend the Generalized Contextual Group using 
affine transformations in chord space, and Maxx Cho, "The Voice-Leading 
Automorphism and Riemannian Operators," 2009, which may show that tonality 
arises from a voice-leading automorphism in the Riemannian group.

TODO: Implement various scales found on 20th and 21st century harmony
along with 'splitting' and 'merging' operations.
                
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

local Silencio = require("Silencio")

-- The size of the octave, defined to be consistent with 
-- 12 tone equal temperament and MIDI.

OCTAVE = 12

-- Middle C.

MIDDLE_C = 60
C4 = MIDDLE_C

pitchClassesForNames["C" ] =  0
pitchClassesForNames["C#"] =  1
pitchClassesForNames["Db"] =  1
pitchClassesForNames["D" ] =  2
pitchClassesForNames["D#"] =  3
pitchClassesForNames["Eb"] =  3
pitchClassesForNames["E" ] =  4
pitchClassesForNames["F" ] =  5
pitchClassesForNames["F#"] =  6
pitchClassesForNames["Gb"] =  6
pitchClassesForNames["G" ] =  7
pitchClassesForNames["G#"] =  8
pitchClassesForNames["Ab"] =  8
pitchClassesForNames["A" ] =  9
pitchClassesForNames["A#"] = 10
pitchClassesForNames["Bb"] = 10
pitchClassesForNames["B" ] = 11

function er(pitch, range)
    return pitch % range
end

function eo(pitch)
    return pitch % OCTAVE
end

-- NOTE: Does NOT return the result under any equivalence class.

function T(pitch, x)
    return pitch + x
end 

-- NOTE: Does NOT return the result under any equivalence class.

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

function Chord:contains(pitch)
    for voice, pitch_ in ipairs(self) do
        if pitch_ == pitch then
            return true
        end
    end
    return false
end

-- Returns the lowest pitch in the chord.
-- and also its voice index.

function Chord:min()
    local lowest = self[1]
    local lowestVoice = 1
    for voice = 2, #self do
        if self[voice] < lowest then
            lowest = self[voice]
            lowestVoice = voice
        end
    end
    return lowest, lowestVoice
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

-- Returns the highest pitch in the chord,
-- and also its voice index.

function Chord:max()
    local highest = self[1]
    local highestVoice = 1
    for voice = 2, #self do
        if self[voice] > highest then
            highest = self[voice]
            highestVoice = voice
        end
    end
    return highest, highestVoice
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

function Chord:er(r)
    local chord = self:clone()
    for voice, pitch in ipairs(self) do
        chord[voice] = pitch % r
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

function Chord:eo()
    return self:er(OCTAVE)
end

function Chord:iseo()
    return self:iser(OCTAVE)
end

function Chord:ep()
    local chord = self:clone()
    table.sort(chord)
    return chord
end

function Chord:isep()
    for i = 1, #self - 1 do
        if not (self[i] <= self[i + 1]) then
            return false
        end
    end
    return true
end

function Chord:et()
    local chord = self:clone()
    local minimum = self:min()
    for voice, pitch in ipairs(chord) do
        chord[voice] = pitch - minimum
    end
    return chord
end

function Chord:iset()
    if self:min() == 0 then
        return true
    else
        return false
    end
end

function Chord:eot()
    return self:eo():et()
end

function Chord:iseot()
    local eot = self:eot()
    if self == eot then
        return true
    else
        return false
    end
end

-- Probably wrong.

function Chord:ei()
    local chord = self:clone()
    if chord:isei() then
        return chord
    else
        return chord:I()
    end
end

function Chord:isei()
    if ((self[2] - self[1]) <= (self[#self] - self[#self - 1])) then
        return true
    else
        return false
    end
end

function Chord:eop()
    return self:eo():ep()
end

function Chord:iseop()
    local chord = self:eop()
    if self == chord then
        return true
    else
        return false
    end
end

function Chord:eoi()
    return self:eo():ei()
end

function Chord:iseoi()
    local chord = self:eoi()
    if self == chord then
        return true
    else
        return false
    end
end

function Chord:eopi()
    return self:eoi():ep()
end

function Chord:iseopi()
    local chord = self:eopi()
    if self == chord then
        return true
    else
        return false
    end
end

function Chord:eopt()
    return self:et():eop()
end

function Chord:iseopt()
    local chord = self:eopt()
    if self == chord then
        return true
    else
        return false
    end
end

function Chord:eopti()
    return self:eopt():closestVoicing()
end

function Chord:iseopti()
    local chord = self:eopti()
    if self == chord then
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

-- Returns all the 'inversions' (in the musician's sense) 
-- or revoicings of the chord.

function Chord:voicings()
    local chord = self:eP()
    local voicings = {}
    voicings[1] = chord
    for i = 2, #self do
        chord = chord:v()
        voicings[i] = chord
    end
    return voicings
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

function Chord:v(direction)
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

-- NOTE: Does NOT return the result under any equivalence class.

function Chord:T(x)  
    local chord = self:clone()
    for voice, pitch in ipairs(chord) do
        chord[voice] = T(pitch, x)
    end
    return chord
end

-- NOTE: Does NOT return the result under any equivalence class.

function Chord:I(x)
    x = x or OCTAVE
    local chord = self:clone()
    for voice, pitch in ipairs(chord) do
        chord[voice] = I(pitch, x)
    end
    return chord
end

function Chord:iseR(range)
    -- The chord must have a range less than or equal to that 
    -- of the fundamental domain.
    if self:range() > range then
        return false
    end
    -- Then the chord must be on a layer of the fundamental domain.
    -- These layers are perpendicular to the orthogonal axis and 
    -- begin at the origin.
    local layer = self:sum()
    if ((0 <= layer) and (layer <= range)) then
        return true
    else
        return false
    end
end

function Chord:iseO()
    return self:iseR(OCTAVE)
end

function Chord:iseP()
    return self:isep()
end

function Chord:iseT()
    if self == self:eT() then
        return true
    else
        return false
    end
end

function Chord:iseI()
    return self:isei()
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
    if not self:iseR(range) then
        return false
    end
    if not self:iseT() then
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
    if (self:iseRP(range) and self:iseT()) then
        return true
    else
        return false
    end
end

function Chord:iseRPT(range, step)
    step = step or 1
    if not self:iseRP(range) then
        return false
    end
    local chord = self:eT()
    if self == chord then
        for voice = 1, #self - 1 do
            if not (self[1] + range - self[#self] <= self[voice + 1] - self[voice]) then
                return false
            end
        end
        return true
    else
        return false
    end
end

function Chord:iseOPT(step)
    step = step or 1
    return self:iseRPT(OCTAVE, step)
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

function Chord:eR(range)
    local chord = self:clone()
    -- Return a copy of this if it is already in the fundamental domain.
    if chord:iseR(range) then
        return chord
    end
    -- The clue here is that at least one voice must be >= 0,
    -- but no voice can be > range.
    -- Move all pitches inside the interval [0, range] 
    -- (which is not the same as the fundamental domain).
    for i = 1, #chord do
        local pitch = chord[i]
        while pitch < 0 do
            pitch = pitch + range
        end
        while pitch > range do
            pitch = pitch - range
        end
        chord[i] = pitch
    end
    -- Reflect voices that are outside of the fundamental domain
    -- back into it, which will revoice the chord.
    while true do
        local layer = chord:sum()
        if 0 <= layer and layer <= range then
            break
        end
        maximumPitch, maximumVoice = chord:max()
        -- Because no voice is above the range,
        -- any voices that need to be revoiced will now be negative.
        chord[maximumVoice] = maximumPitch - range
    end
    return chord
end

function Chord:eO()
    return self:eR(OCTAVE)
end

function Chord:eP()
    return self:ep()
end

function Chord:eRP(range)
    return self:eR(range):eP()
end

function Chord:eOP()
    return self:eO():eP()
end

-- Returns the chord transposed such that its 
-- O sums as close to 0 as possible in equal temperament.
-- NOTE: Does NOT return the result under any other equivalence class.

function Chord:eT(divisionsPerOctave)
    divisionsPerOctave = divisionsPerOctave or 12
    local increment = 12 / divisionsPerOctave
    local iterator = self:clone()
    while true do
        local sum = iterator:sum()
        if sum <= 0 then
            if sum < 0 then
                iterator = iterator:T(increment)
            end
            break
        end
        iterator = iterator:T(-increment)
    end
    return iterator
end

function Chord:eOPT()
    return self:eO():eT():eP()
end

function Chord:eI()
    if self:iseI() then
        return self
    else
        return self:I()
    end
end

function Chord:eOPI()
    local chord = self:eOP()
    if chord:iseOPI() then
        return chord
    end
    chord = chord:eI()
    return chord
end
 
function Chord:eOPTI()
    return self:eOP():eI():eT():eP()
end

-- Move 1 voice of the chord,
-- optionally under range equivalence
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:move(voice, interval)
    chord = self:clone()
    chord[voice] = T(chord[voice], interval)
    return chord
end

-- Performs the neo-Riemannian Lettonwechsel transformation.
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:nrL()
    local cv = self:closestVoicing()
    local cvt = self:closestVoicing():et()
    if cvt[2] == 4 then
        cv[1] = cv[1] - 1
    else
        if cvt[2] == 3 then
            cv[3] = cv[3] + 1
        end
    end
    return cv
end

-- Performs the neo-Riemannian parallel transformation.
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:nrP()
    local cv = self:closestVoicing()
    local cvt = self:closestVoicing():et()
    if cvt[2] == 4 then
        cv[2] = cv[2] - 1
    else
        if cvt[2] == 3 then
            cv[2] = cv[2] + 1
        end
    end
    return cv
end

-- Performs the neo-Riemannian relative transformation.
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:nrR()
    local cv = self:closestVoicing()
    local cvt = self:closestVoicing():et()
    if cvt[2] == 4 then
        cv[3] = cv[3] + 2
    else
        if cvt[2] == 3 then
            cv[1] = cv[1] - 2
        end
    end
    return cv
end

-- Performs the neo-Riemannian dominant transformation.
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:nrD()
    return self:eopi():T(-7)
end

-- Returns the chord inverted by the sum of its first two voices.
-- NOTE: Does NOT return the result under any equivalence class.
  
function Chord:K(range)
    range = range or OCTAVE
    if #chord < 2 then
        return chord
    end
    local ep = chord:ep()
    local x = ep[1] + ep[2]
    return self:I(x)
end

-- Returns whether the chord is a transpositional form of Y with interval size g.
-- Only works in equal temperament.

function Chord:Tform(Y, g)
    local eopx = self:eop()
    local i = 0
    while i < OCTAVE do
        local ty = Y:T(i)
        local eopty = ty:eop()
        if eopx == eopty then
            return true
        end
        i = i + g
    end
    return false
end

-- Returns whether the chord is an inversional form of Y with interval size g.
-- Only works in equal temperament.

function Chord:Iform(Y, g)
    local eopx = self:eop()
    local i = 0
    while i < OCTAVE do
        local iy = Y:I(i)
        local eopiy = iy:eop()
        if eopx == eopiy then
            return true
        end
        i = i + g
    end
    return false
end
  
-- Returns the contextual transposition of the chord by x with respect to m
-- with minimum interval size g.
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:Q(x, m, g)
    g = g or 1
    if self:Tform(m, g) then
        return self:T(x)
    end
    if self:Iform(m, g) then
        return self:T(-x)
    end
    return self:clone()
end
        
-- Returns the next voicing of the chord that is under RP, 
-- or nil if the chord is higher than RP.

function Chord:V(range)
    range = range or OCTAVE
    iterator = chord:clone()
    -- Enumerate the next voicing by counting voicings in RP.
    -- iterator[1] is the most significant voice, 
    -- iterator[self.N] is the least significant voice.
    while iterator[1] < range do
        iterator[#self] = iterator[#self] + OCTAVE
        local unorderedIterator = iterator:eP()
        if unorderedIterator:iseRP(range) then
            return unorderedIterator
        end
        -- "Carry" octaves.
        for voice = #self, 2, -1 do
            if iterator[voice] >= range then
                iterator[voice] = zero[voice]
                iterator[voice - 1] = iterator[voice - 1] + OCTAVE
            end
        end
    end
    return nil
end

-- Returns all voicings of the chord under RP.

function Chord:Voicings(range)
    range = range or OCTAVE
    local voicings = {}
    local zero = self:eOP()
    -- Ensure that iteration starts below the lowest layer.
    for voice = 1, #self do
        zero[voice] = zero[voice] - (range + OCTAVE)
    end
    local iterator = zero:clone()
    while true do
        local iterator = iterator:V(range)
        if iterator == nil then
            break
        else
            if iterator:iseRP(range) then
                table.insert(voicings, iterator)
            end
        end
    end
    return voicings
end

-- Returns the voice-leading between chords a and b,
-- i.e. what you have to add to a to get b, as a 
-- chord of directed intervals.

function voiceleading(a, b)
    local voiceleading = a:clone()
    for voice = 1, #voiceleading do
        voiceleading[voice] = b[voice] - a[voice]
    end
    return voiceleading
end

-- Returns whether the voiceleading 
-- between chords a and b contains a parallel fifth.

function parallelFifth(a, b)
    local v = voiceleading(a, b)
    if v:count(7) > 1 then
        return true
    else
        return false
    end
end

-- Returns the smoothness of the voiceleading between 
-- chords a and b by L1 norm.

function voiceleadingSmoothness(a, b)
    local L1 = 0
    for voice = 1, #a do
        L1 = L1 + math.abs(b[voice] - a[voice])
    end
    return L1
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the smoother (shortest moves), optionally avoiding parallel fifths.

function voiceleadingSmoother(source, d1, d2, avoidParallels, range)
    range = range or OCTAVE
    if avoidParallels then
        if parallelFifth(source, d1) then
            return d2
        end
        if parallelFifth(source, d2) then
            return d1
        end
    end
    local s1 = voiceleadingSmoothness(source, d1)
    local s2 = voiceleadingSmoothness(source, d2)
    if s1 <= s2 then
        return d1
    else
        return d2
    end
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the simpler (fewest moves), optionally avoiding parallel fifths.

function voiceleadingSimpler(source, d1, d2, avoidParallels)
    avoidParallels = avoidParallels or false
    if avoidParallels then
        if parallelFifth(source, d1) then
            return d2
        end
        if parallelFifth(source, d2) then
            return d1
        end
    end
    local v1 = voiceleading(source, d1):eP()
    local v2 = voiceleading(source, d2):eP()
    for voice = #v1, 1, -1 do
        if v1[voice] < v2[voice] then
            return d1
        end
        if v2[voice] < v1[voice] then
            return d2
        end
    end
    return d1
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the closer (first smoother, then simpler), optionally avoiding parallel fifths.

function voiceleadingCloser(source, d1, d2, avoidParallels)
    avoidParallels = avoidParallels or false
    if avoidParallels then
        if parallelFifth(source, d1) then
            return d2
        end
        if parallelFifth(source, d2) then
            return d1
        end
    end
    local s1 = voiceleadingSmoothness(source, d1)
    local s2 = voiceleadingSmoothness(source, d2)
    if s1 < s2 then
        return d1
    end
    if s1 > s2 then
        return d2
    end
    return voiceleadingSimpler(source, d1, d2, avoidParallels)
end

-- Returns which of the destinations has the closest voice-leading
-- from the source, optionally avoiding parallel fifths.

function voiceleadingClosest(source, destinations, avoidParallels)
    avoidParallels = avoidParallels or false
    local d = destinations[1]
    for i = 2, #destinations do
        d = voiceleadingCloser(source, d, destinations[i], avoidParallels)
    end
end

-- Returns a label for a chord.

function Chord:label()
    local C = self:__tostring()
    local eop = self:eop():__tostring()
    local eOP = self:eOP():__tostring()
    local eopi = self:eopi():__tostring()
    local eOPI = self:eOPI():__tostring()
    local eopt = self:eopt():__tostring()
    local eOPT = self:eOPT():__tostring()
    local eopti = self:eopti():__tostring()
    local eOPTI = self:eOPTI():__tostring()
    return string.format([[Chord: %s
eop:   %s
eOP:   %s
eopi:  %s
eOPI:  %s
eopt:  %s
eOPT:  %s
eopti: %s
eOPTI: %s
sum:       %f]], C, eop, eOP, eopi, eOPI, eopt, eOPT, eopti, eOPTI, self:sum())
end

-- Creates a complete Silencio "note on" event for the 
-- indicated voice of the chord. The other parameters are used
-- if the internal duration, channel, velocity, and pan of the 
-- chord are nil.

function Chord:note(voice_, time_, duration_, channel_, velocity_, pan_)
    time_ = time_ or 0
    duration_ = duration_ or 0.25
    channel_ = channel_ or 1
    velocity_ = velocity_ or 80
    pan_ = pan_ or 0
    local note_ = Event:new()
    note_[TIME] = time_
    note_[DURATION] = self.duration[voice_] or duration_
    note_[CHANNEL] = self.channel[voice_] or channel_
    note_[KEY] = self[voice_]
    note_[VELOCITY] = self.velocity[voice_] or velocity_
    note_[PAN] = self.pan[voice_] or pan_
    return note_
end

-- Returns an individual note for each voice of the chord.
-- The chord's duration, instrument, and loudness are used if present,
-- if not the specified values are used.

function Chord:notes(time_, duration_, channel_, velocity_, pan_)
    local notes_ = Score:new()
    for voice, key in ipairs(self) do
        table.insert(notes_, self:note(voice, time_, duration_, channel_, velocity_, pan_))
    end
    return notes_
end

-- If the event is a note, moves its pitch
-- to the closest pitch of the chord. 
-- If octaveEquivalence is true (the default),
-- the pitch-class of the note is moved to the closest pitch-class 
-- of the chord; otherwise, the pitch of the note is moved to the closest 
-- absolute pitch of the chord.

function conformToChord(event, chord, octaveEquivalence)
    octaveEquivalence = octaveEquivalence or true
    if event[STATUS] ~= 144 then
        return
    else
        local pitch = event[KEY]
        if octaveEquivalence then
            local pitchClass = pitch % OCTAVE
            local octave = pitch - pitchClass
            local chordPitchClass = chord[1] % OCTAVE
            local distance = math.abs(chordPitchClass - pitchClass)
            closestPitchClass = chordPitchClass
            minimumDistance = distance
            for voice = 2, #chord do
                chordPitchClass = chord[voice] % OCTAVE
                distance = math.abs(chordPitchClass - pitchClass)
                if distance < minimumDistance then
                    minimumDistance = distance
                    closestPitchClass = chordPitchClass
                end
            end
            event[KEY] = octave + closestPitchClass
        else
            local chordPitch = chord[1]
            local distance = math.abs(chordPitch - pitch)
            local closestPitch = chordPitch
            local minimumDistance = distance
            for voice = 2, #chord do
                chordPitch = chord[voice]
                distance = math.abs(chordPitch - pitch)
                if distance < minimumDistance then
                    minimumDistance = distance
                    closestPitch = chordPitch
                end
            end
            event[KEY] = closestPitch
        end
    end
end

-- Inserts the notes of the chord into the score at the specified time.
-- The internal duration, instrument, and loudness are used if present,
-- if not the specified values are used.

function insert(score, chord, time_, duration, channel, velocity, pan)
    for voice = 1, #score do
        table.insert(score, chord:note(voice, time_, duration, channel, velocity, pan))
    end
end

-- For all the notes in the score
-- beginning at or later than the start time, 
-- and up to but not including the end time,
-- moves the pitch of the note to belong to the chord, using the 
-- conformToChord function. 

function apply(score, chord, start, end_, octaveEquivalence)
    octaveEquivalence = octaveEquivalence or true
    local slice = score:slice(start, end_)
    for index, event in ipairs(slice) do
        conformToChord(event, chord, octaveEquivalence)
    end
end

-- Returns a chord containing all the pitches of the score 
-- beginning at or later than the start time, 
-- and up to but not including the end time.

function gather(score, start, end_)
    local chord = Chord:new()
    local slice = score:slice(start, end_)
    for index, event in ipairs(slice) do
        local pitch = event[KEY]
        if not chord:contains(pitch) then
            table.insert(chord, pitch)
        end
    end
    return chord
end

return ChordSpace
