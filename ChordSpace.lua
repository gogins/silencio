ChordSpace = {}

function ChordSpace.help()
print [[
'''
C H O R D S P A C E

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
by fractions.

A chord is simply a set of voices heard at the same time or, 
what is the same thing, a point in a chord space having one dimension of 
pitch for each voice in the chord.

For the purposes of algorithmic composition in Silencio, a score is  
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
and induce different orbifolds. Equivalence classes can be combined 
(Callendar, Quinn, and Tymoczko, "Generalized Voice-Leading Spaces,"
_Science_ 320, 2008), and the more equivalence classes are combined, 
the more abstract is the resulting orbifold compared to the parent space.
 
C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}.
        We never assume cardinality equivalence here, because we are 
        working in chord spaces of fixed dimensionality; e.g. we represent
        the note middle C not as {60}, but as {60, 60, ..., 60}.
        Retaining cardinality ensures that there is a proto-metric in
        plain chord space that is inherited by all child chord spaces.
        
O       Octave equivalence. The fundamental domain is defined by the 
        pitches in a chord spanning an octave or less and
        summing to 0. The corresponding orbifold is a hyperprism one 
        octave long whose base is identified with its top, modulo a twist 
        by one cyclical permutation of voices.

P       Permutational equivalence.

T       Transpositional equivalence, e.g. {1, 2} == {7, 8}.
        Represented by the chord always having a sum of pitches equal to 0, 
        or a positive sum as close as possible to 0 within equal temperament
        (see below).

I       Inversional equivalence. Represented as the inversion having the 
        first interval between voices be smaller than or equal to the final 
        interval (recursing for chords of more than 3 voices). Care is needed 
        to distinguish the mathematician's sense 
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

TODO: Implement various scales found in 20th and 21st century harmony
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
T moves a chord up and down the orthogonal orientation of the prism.

VOICE-LEADING

Those operations that are defined only in OP can be extended to
R or RP by revoicing the results (projecting from one point in OP to several 
points in R or RP).
            
The closest voice-leadings are between the closest chords in the space.
The 'best' voice-leadings are closest first by 'smoothness,'
and then by 'parsimony.' See Dmitri Tymoczko, 
_The Geometry of Musical Chords_, 2005 (Princeton University).

This concept of voice-leading applies in all equivalence classes, not 
only to root progressions of chords, and the meaning of 'well-formed 
voice-leading' changes according to the equivalence class. In OP it means 
well-formed harmonic progression, in r or rp it also means well-formed 
contrapuntal voice-leading.

Or, to make it really simple, OP is harmony and RP is counterpoint.
    
We do bijective contrapuntal voiceleading by connecting a chord in R or RP 
with one OP to another of the several chords in R or RP with a different OP 
by choosing the shortest path through R or RP, optionally avoiding 
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
beginning with 'e', e.g. 'eOP' for pitch class set or 'eOPTI' for 
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
    local voices = math.min(#self, #other)
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

-- Gives chords value semantics for sets.

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

function Chord:origin()
    local chord = self:clone()
    for voice = 1, #chord do
        chord[voice] = 0
    end
    return chord
end

-- Returns all the 'inversions' (in the musician's sense) 
-- or revoicings of the chord.

function Chord:voicings()
    local chord = self:ep()
    local voicings = {}
    voicings[1] = chord
    for i = 2, #self do
        chord = chord:v()
        voicings[i] = chord
    end
    return voicings
end

function Chord:minimumVoicing()
    local voicings = self:voicings()
    local voicing = voicings[1]
    local minimumSum = voicing:sum()
    for i = 2, #voicings do
        local sum = voicings[i]:sum()
        if sum < minimumSum then
            minimumSum = sum
            voicing = voicings[i]
        end
    end
    return voicing
end

-- Returns the number of times the pitch occurs in the chord,
-- under an optional range equivalence (defaulting to the octave).

function Chord:count(pitch, range)
    range = range or OCTAVE
    local n = 0
    for voice, value in ipairs(self) do
        if er(value, range) == pitch then
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
    while direction > 0 do
        chord = chord:cycle(-1)
        chord[#chord] = chord[#chord] + OCTAVE   
        direction = direction - 1
    end
    while direction < 0 do
        chord = chord:cycle(1)
        chord[1] = chord[1] - OCTAVE
        direction = direction + 1
    end
    return chord
end

-- Returns the ith arpeggiation, current voice, and corresponding revoicing 
-- of the chord. Positive arpeggiations start with the lowest voice of the 
-- chord and revoice up; negative arpeggiations start with the highest voice
-- of the chord and revoice down.

function Chord:a(arpeggiation)
    local chord = self:v(arpeggiation)
    if arpeggiation < 0 then
        return chord[#chord], #chord, chord
    end
    return chord[1], 1, chord
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
    if not (self:max() <= (self:min() + range)) then
        return false
    end
    local layer = self:sum()
    if not (0 <= layer) then
        return false
    end
    if not (layer < range) then
        return false
    end
    return true
end

function Chord:iseO()
    return self:iseR(OCTAVE)
end

function Chord:iseP()
    for voice = 2, #self do
        if self[voice - 1] > self[voice] then
            return false
        end
    end
    return true
end

function Chord:iseT(g)
    g = g or 1
    local ep = self:eP()
    if not (ep == ep:eT(g)) then
        return false
    end
    return true
end

function Chord:iseI()
    local ep = self:eP()
    local lowerVoice = 2
    local upperVoice = #self
    while lowerVoice <= #self do
        local lowerDelta = ep[lowerVoice] - ep[lowerVoice - 1]
        local upperDelta = ep[upperVoice] - ep[upperVoice - 1]
        if lowerDelta < upperDelta then
            return true
        end
        if lowerDelta > upperDelta then
            return false
        end
        lowerVoice = lowerVoice + 1
        upperVoice = upperVoice - 1
    end
    return true
end

function Chord:iseRP(range) 
    if not self:iseP(range) then
        return false
    end
    if not self:iseR(range) then
        return false
    end
    return true
end

function Chord:iseOP()
    return self:iseRP(OCTAVE)
end

function Chord:iseRT(range, g)
    range = range or OCTAVE
    g = g or 1
    if not self:iseR(range) then
        return false
    end
    if not self:iseT(g) then
        return false
    end
    return true
end

function Chord:iseOT()
    return self:iseRT(OCTAVE)
end

function Chord:iseRI(range)
    if not self:iseR(range) then
        return false
    end
    if not self:iseI() then
        return false
    end
    return true
end

function Chord:iseOI()
    return self:isRI(OCTAVE)
end

function Chord:isePT(g)
    g = g or 1
    if not self:iseP() then
        return false
    end
    if not self:iseT(g) then
        return false
    end
    return true
end

function Chord:isePI()
    if not self:iseP() then
        return false
    end
    if not self:iseI() then
        return false
    end
    return true
end

function Chord:iseTI(g)
    g = g or 1
    if not self:isEI() then
        return false
    end
    if not self:isET(g) then
        return false
    end
    return true
end

function Chord:iseRPT(range, g)
    range = range or OCTAVE
    g = g or 1
    local eRPT = self:eRPT(range, g)
    if not (self == eRPT) then
        return false
    end
    return true
end

function Chord:iseOPT(g)
    g = g or 1
    return self:iseRPT(OCTAVE, g)
end

function Chord:iseRPI(range)
    if not self:iseRP(range) then
        return false
    end
    if not self:iseI() then
        return false
    end
    return true
end

function Chord:iseOPI()
    return self:iseRPI(OCTAVE)
end

function Chord:iseRPTI(range)
    if not self:iseRPT(range) then
        return false
    end
    if not self:iseI() then
        return false
    end
    return true
end

function Chord:iseOPTI()
    return self:iseRPTI(OCTAVE)
end

-- Returns whether the chord is in the fundamental domain
-- of V (voicing) equivalence.

function Chord:eR(range)
    local chord = self:clone()
    -- The clue here is that at least one voice must be >= 0,
    -- but no voice can be > range.
    -- Move all pitches inside the interval [0, range] 
    -- (which is not the same as the fundamental domain).
    for voice, pitch in ipairs(chord) do
        chord[voice] = pitch % range
    end
    -- Reflect voices that are outside of the fundamental domain
    -- back into it, which will revoice the chord, i.e. 
    -- the sum of pitches is in [0, range).
    while chord:sum() >= range do
        local maximumPitch, maximumVoice = chord:max()
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
    local chord = self:clone()
    table.sort(chord)
    return chord
end

Chord.ep = Chord.eP

function Chord:eRP(range)
    return self:eR(range):eP()
end

function Chord:eOP()
    return self:eRP(OCTAVE)
end

-- Returns the chord transposed such that its layer is 0 or,
-- under transposition, the positive layer closest to 0.
-- g is the generator of transposition.
-- NOTE: Does NOT return the result under any other equivalence class.

function Chord:eT(g)
    g = g or 1
    local iterator = self:clone()
    -- Transpose down to layer 0 or just below.
    while iterator:sum() > 0 do
        iterator = iterator:T(-g)
    end
    -- Transpose up to layer 0 or just above.
    while iterator:sum() < 0 do
        iterator = iterator:T(g)
    end
    return iterator
end

function Chord:er(range)
    range = range or OCTAVE
    chord = self:clone()
    for voice, pitch in ipairs(chord) do
        chord[voice] = pitch % range
    end
    return chord
end

function Chord:eo()
    return self:er(OCTAVE)
end

function Chord:eop()
    return self:eo():ep()
end

function Chord:et()
    local min = self:min()
    return self:T(-min)
end

function Chord:ept()
    return self:et():ep()
end

function Chord:eopt()
    return self:eOPT():eop():et()
end

-- Is this wrong for {-6, 0, 6}?

function Chord:iseV(range, g)
    range = range or OCTAVE
    g = g or 1
    for voice = 1, #self - 1 do
        if not ((self[1] + range - self[#self]) <= (self[voice + 1] - self[voice])) then
            return false
        end
    end
    return true
end

-- This doesn't give the eopt of Tymoczko.
-- We have 067 058 066 068 etc, we have 35 instead of 31.
-- With range = OCTAVE * N, we have many columns, but only 1 is eV.

function Chord:eRPT(range, g)
    range = range or OCTAVE
    g = g or 1
    erp = self:eRP(range)
    --print('Chord:eRPT: range', range, 'g', g)
    local voicings = erp:voicings()
    for i, voicing in ipairs(voicings) do
        local et = voicing:eT(g)
        --print('Chord:eRPT: et', i, et, et:iseV(range, g), et:sum())
        if et:iseV(range, g) then
            return et
        end
    end
end

function Chord:eOPT(g)
    g = g or 1
    return self:eRPT(OCTAVE, g)
end

function Chord:eI()
    if self:iseI() then
        return self:clone()
    else
        return self:I()
    end
end

function Chord:eOPI()
    if self:iseOPI() then
        return self:clone()
    end
    return self:eI():eOP()
end
 
function Chord:eOPTI(range, g)
    range = range or OCTAVE
    g = g or 1
    --print('Chord:eOPTI: range', range, 'g', g)
    return self:eOPI(g):eOPT()
end

-- Move 1 voice of the chord,
-- optionally under range equivalence
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:move(voice, interval)
    local chord = self:clone()
    chord[voice] = T(chord[voice], interval)
    return chord
end

-- Performs the neo-Riemannian Lettonwechsel transformation.
-- NOTE: Does NOT return the result under any equivalence class.

function Chord:nrL()
    local cv = self:closestVoicing()
    local cvt = self:closestVoicing():e()
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
    return self:eep():T(-7)
end

-- Returns the chord inverted by the sum of its first two voices.
-- NOTE: Does NOT return the result under any equivalence class.
  
function Chord:K(range)
    range = range or OCTAVE
    local chord = self:clone()
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
    local iterator = self:clone()
    local zero = self:eOP()
    -- Enumerate the next voicing by counting voicings in RP.
    -- iterator[1] is the most significant voice, 
    -- iterator[self.N] is the least significant voice.
    while iterator[1] < range do
        iterator[#self] = iterator[#self] + OCTAVE
        local unorderedIterator = iterator:ep()
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
    local iterator = self:clone()
    local zero = self:eOP()
    -- Enumerate the next voicing by counting voicings in RP.
    -- iterator[1] is the most significant voice, 
    -- iterator[self.N] is the least significant voice.
    voicings[1] = zero:clone()
    while iterator[1] < range do
        iterator[#self] = iterator[#self] + OCTAVE
        local unorderedIterator = iterator:ep()
        if unorderedIterator:iseRP(range) then
            voicings[#voicings + 1] = unorderedIterator
        end
        -- "Carry" octaves.
        for voice = #self, 2, -1 do
            if iterator[voice] >= range then
                iterator[voice] = zero[voice]
                iterator[voice - 1] = iterator[voice - 1] + OCTAVE
            end
        end
    end
    return voicings
end

-- Returns the voice-leading between chords a and b,
-- i.e. what you have to add to a to get b, as a 
-- chord of directed intervals.

function ChordSpace.voiceleading(a, b)
    local voiceleading = a:clone()
    for voice = 1, #voiceleading do
        voiceleading[voice] = b[voice] - a[voice]
    end
    return voiceleading
end

-- Returns whether the voiceleading 
-- between chords a and b contains a parallel fifth.

function ChordSpace.parallelFifth(a, b)
    local v = ChordSpace.voiceleading(a, b)
    if v:count(7) > 1 then
        return true
    else
        return false
    end
end

-- Returns the smoothness of the voiceleading between 
-- chords a and b by L1 norm.

function ChordSpace.voiceleadingSmoothness(a, b)
    local L1 = 0
    for voice = 1, #a do
        L1 = L1 + math.abs(b[voice] - a[voice])
    end
    return L1
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the smoother (shortest moves), optionally avoiding parallel fifths.

function ChordSpace.voiceleadingSmoother(source, d1, d2, avoidParallels, range)
    range = range or OCTAVE
    if avoidParallels then
        if ChordSpace.parallelFifth(source, d1) then
            return d2
        end
        if ChordSpace.parallelFifth(source, d2) then
            return d1
        end
    end
    local s1 = ChordSpace.voiceleadingSmoothness(source, d1)
    local s2 = ChordSpace.voiceleadingSmoothness(source, d2)
    if s1 <= s2 then
        return d1
    else
        return d2
    end
end

-- Returns which of the voiceleadings (source to d1, source to d2)
-- is the simpler (fewest moves), optionally avoiding parallel fifths.

function ChordSpace.voiceleadingSimpler(source, d1, d2, avoidParallels)
    avoidParallels = avoidParallels or false
    if avoidParallels then
        if ChordSpace.parallelFifth(source, d1) then
            return d2
        end
        if ChordSpace.parallelFifth(source, d2) then
            return d1
        end
    end
    local v1 = ChordSpace.voiceleading(source, d1):ep()
    local v2 = ChordSpace.voiceleading(source, d2):ep()
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

function ChordSpace.voiceleadingCloser(source, d1, d2, avoidParallels)
    avoidParallels = avoidParallels or false
    if avoidParallels then
        if ChordSpace.parallelFifth(source, d1) then
            return d2
        end
        if ChordSpace.parallelFifth(source, d2) then
            return d1
        end
    end
    local s1 = ChordSpace.voiceleadingSmoothness(source, d1)
    local s2 = ChordSpace.voiceleadingSmoothness(source, d2)
    if s1 < s2 then
        return d1
    end
    if s1 > s2 then
        return d2
    end
    return ChordSpace.voiceleadingSimpler(source, d1, d2, avoidParallels)
end

-- Returns which of the destinations has the closest voice-leading
-- from the source, optionally avoiding parallel fifths.

function ChordSpace.voiceleadingClosest(source, destinations, avoidParallels)
    local d = destinations[1]
    for i = 2, #destinations do
        d = ChordSpace.voiceleadingCloser(source, d, destinations[i], avoidParallels)
    end
    return d
end

-- Returns the voicing of the destination which has the closest voice-leading
-- from the source within the range, optionally avoiding parallel fifths.
-- TODO: Do not collect all voicings, but test them individually in a loop 
-- as in the body of Voicings.

function ChordSpace.voiceleadingClosestRange(source, destination, range, avoidParallels)
    local destinations = destination:Voicings(range)
    local closest = ChordSpace.voiceleadingClosest(source, destinations, range, avoidParallels)
    return closest
end

-- Returns a label for a chord.

function Chord:label()
    local chordName = nil
    if self ~= nil then
        local eOP = self:eOP()
        if eOP ~= nil then
            chordName = ChordSpace.namesForChords[eOP:__hash()]
        end
    end
    if chordName == nil then
        chordName = 'Chord'
    end
    local C = self:__tostring()
    local eop = self:eop()
    local eOP = self:eOP():__tostring()
    local iseOP = self:iseOP()
    local eOPI = self:eOPI():__tostring()
    local iseOPI = self:iseOPI()
    local eOPT = self:eOPT():__tostring()
    local ept = self:ept()
    local eopt = self:eopt()
    local iseOPT = self:iseOPT()
    local eOPTI = self:eOPTI():__tostring()
    local iseOPTI = self:iseOPTI()
    return string.format([[%s: 
pitches: %s
eop:     %s
ept:     %s
eopt:    %s
eOP:     %s  iseOP:   %s
eOPI:    %s  iseOPI:  %s
eOPT:    %s  iseOPT:  %s
eOPTI:   %s  iseOPTI: %s
layer:       %-5.2f]], 
chordName,
C, 
tostring(eop),
tostring(ept),
tostring(eopt),
eOP, 
tostring(iseOP), 
eOPI, 
tostring(iseOPI), 
eOPT, 
tostring(iseOPT), 
eOPTI, 
tostring(iseOPTI), 
self:sum())
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
            local closestPitchClass = chordPitchClass
            local minimumDistance = distance
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

function ChordSpace.insert(score, chord, time_, duration, channel, velocity, pan)
    -- print(score, chord, time_, duration, channel, velocity, pan)
    for voice = 1, #chord do
        local event = chord:note(voice, time_, duration, channel, velocity, pan)
        table.insert(score, event)
    end
end

-- For all the notes in the score
-- beginning at or later than the start time, 
-- and up to but not including the end time,
-- moves the pitch of the note to belong to the chord, using the 
-- conformToChord function. 

function ChordSpace.apply(score, chord, start, end_, octaveEquivalence)
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

-- Returns all the chords with the specified number of voices that exist 
-- within the fundamental domain of the specified octave-based equivalence 
-- class that is generated by the interval g, which of course must evenly 
-- divide the octave. The chords are returned in a zero-based table, 
-- such that the indexes of the chords form an additive cyclic group 
-- representing the chords. Note: these chords are related to op not OP.

function ChordSpace.allOfEquivalenceClass(voices, equivalence, g)
    g = g or 1    
    local equivalenceMapper = nil
    if equivalence == 'OP' then
        equivalenceMapper = Chord.iseOP
    end
    if equivalence == 'OT' then
        equivalenceMapper = Chord.iseOT
    end
    if equivalence == 'OI' then
        equivalenceMapper = Chord.iseOI
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
    local chordset = {}
    local odometer = Chord:new()
    odometer:resize(voices)
    while odometer[1] < OCTAVE do
        local fundamentalChord = nil
        fundamentalChord = odometer:eOP()
        chordset[fundamentalChord:__hash()] = fundamentalChord
        odometer[voices] = odometer[voices] + g
        -- "Carry" octaves.
        for voice = voices, 2, -1 do
            if odometer[voice] >= OCTAVE then
                odometer[voice] = 0
                odometer[voice - 1] = odometer[voice - 1] + g
            end
        end
    end
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
        print('index', index, 'chord', chord, 'layer', chord:sum())
        table.insert(zeroBasedChords, index, chord)
        index = index + 1
    end
    return zeroBasedChords
 end

-- Orthogonal additive groups for unordered chords of given arity under range 
-- equivalence (RP): prime form or P, inversion or I, transposition or T, and 
-- voicing or V. P x I x T = OP, P x I x T x V = RP. There is a bijective 
-- mapping between chords in RP and values of P, I, T, V. Therefore, an 
-- operation on P, I, T, or V may be used to independently transform the 
-- respective symmetry of any chord. Some of these operations will reflect 
-- in RP.

ChordSpaceGroup = {}

-- N is the number of voices in the chord space, g is the generator of 
-- transposition, range is the size of chord space, 
-- optis is an ordered table of all OPTI chords for g, 
-- voicings is an ordered table of all octavewise permutations in RP.

function ChordSpaceGroup:new(o)
    local o = o or {optisForIndexes = {}, indexesForOptis = {}, voicingsForIndexes = {}, indexesForVoicings = {}}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Returns all permutations of octaves for the indicated
-- number of voices within the indicated range.

function ChordSpace.octavewisePermutations(voices, range)
    range = range or OCTAVE
    local voicings = {}
    local zero = Chord:new()
    zero:resize(voices)
    local odometer = zero:clone()
    -- Enumerate the permutations.
    -- iterator[1] is the most significant voice, and
    -- iterator[N] is the least significant voice.
    voicing = 0
    while odometer[1] <= range do
        voicings[voicing] = odometer:clone()
        odometer[voices] = odometer[voices] + OCTAVE
         -- "Carry" octaves.
        for voice = voices, 2, - 1 do
            if odometer[voice] > range then
                odometer[voice] = zero[voice]
                odometer[voice - 1] = odometer[voice - 1] + OCTAVE
            end
        end
        voicing = voicing + 1
    end
    return voicings
end

function ChordSpaceGroup:initialize(voices, range, g)
    self.voices = voices or 3
    self.range = range or 60
    self.g = g or 1
    if #self.optisForIndexes == 0 then
        self.optisForIndexes = ChordSpace.allOfEquivalenceClass(self.voices, 'OPTI', self.g)
        for index, opti in pairs(self.optisForIndexes) do
            self.indexesForOptis[opti:__hash()] = index
        end
    end
    if #self.voicingsForIndexes == 0 then
        self.voicingsForIndexes = ChordSpace.octavewisePermutations(voices, range)
        for index, voicing in pairs(self.voicingsForIndexes) do
            self.indexesForVoicings[voicing:__hash()] = index
        end
    end
end

-- Returns the chord for the indices of prime form, inversion, 
-- transposition, and voicing. The chord is not in rp; rather, the
-- chord is considered to be in op, but then each voice may have
-- zero or more octaves added to it.

function ChordSpaceGroup:toChord(P, I, T, V)
    P = P % #self.optisForIndexes
    I = I % 2
    T = T % OCTAVE
    V = V % #self.voicingsForIndexes
    print('P', P, 'I', I, 'T', T, 'V', V)
    local opti = self.optisForIndexes[P]
    print('opti', opti)
    local ei = nil
    if I == 0 then
        opt = opti:eOP()
    else
        opt = opti:I():eOP()
    end
    print('opt', opt)
    local op = opt:T(T):eOP()
    print('op', op)
    local voicing = self.voicingsForIndexes[V]
    print('voicing', voicing)
    for voice = 1, #voicing do
        voicing[voice] = voicing[voice] + op[voice]
    end
    return voicing:eR(self.range), opti, op, voicing
end

-- Returns the indices of prime form, inversion, transposition, 
-- and voicing for a chord. The chord is not in RP; rather, the
-- chord is considered to be in OP, but then each voice may have
-- zero or more octaves added to it.

function ChordSpaceGroup:fromChord(chord)
    local opti = chord:eOPTI()
    print('opti', opti, 'hash', opti:__hash())
    local P = self.indexesForOptis[opti:__hash()]
    print('P', P)
    local I = nil
    if chord:iseI() then
        I = 0
    else
        I = 1
    end
    print('I', I)
    local T = 0
    local opt = chord:eOPT()
    local op = chord:eOP()
    for t = 0, OCTAVE - 1, self.g do
        if opt:T(t):eOP() == op then
            T = t
            break
        end
    end
    print('T', T)
    local r = chord:eR(self.range)
    local voicing = r:clone()
    local o = r:eO()
    for voice = 1, #r do
        voicing[voice] = r[voice] - o[voice]
    end
    local V = self.indexesForVoicings[voicing:__hash()]
    print('V', V)
    return P, I, T, V
end

function ChordSpaceGroup:list()
    for index, opti in pairs(self.optisForIndexes) do
        print('index', index, 'opti', opti, self.indexesForOptis[opti:__hash()])
    end
    for index = 0, #self.optisForIndexes - 1 do
        print('opti', self.optisForIndexes[index], 'index', index)
    end
    for index, voicing in pairs(self.voicingsForIndexes) do
        print('voicing', index, voicing, self.indexesForVoicings[voicing:__hash()])
    end
end

pitchClassesForNames = {}

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

ChordSpace.chordsForNames = {}
ChordSpace.namesForChords = {}

local function fill(rootName, rootPitch, typeName, typePitches)             
    local chordName = rootName .. typeName
    local chord = Chord:new()
    local splitPitches = Silencio.split(typePitches)
    chord:resize(#splitPitches)
    for voice, pitchName in ipairs(splitPitches) do
        local pitch = pitchClassesForNames[pitchName]
        chord[voice] = rootPitch + pitch
    end
    chord = chord:eOP()
    ChordSpace.chordsForNames[chordName] = chord
    ChordSpace.namesForChords[chord:__hash()] = chordName
end

for rootName, rootPitch in pairs(pitchClassesForNames) do
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

return ChordSpace
