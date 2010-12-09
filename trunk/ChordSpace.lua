ChordSpace = {}

function ChordSpace.help()
print [[
'''
Copyright 2005 by Michael Gogins.

A geometric approach to common operations
in neo-Riemannian music theory,
for use in score generating algorithms.

When run as a standalone program,
displays a model of the voice-leading space
for trichords and can orbit a chord through
the space, playing the results using Csound.

Voice-leading space is an orbifold of chords
with one dimension per voice, voices ordered by pitch,
pitch measured in tones per octave,
and a modulus equal to the range of the voices.
Root progressions are motions more or less 
up and down the 'columns' of identically 
structured chords. The closest voice-leadings are 
between the closest chords in the space.
The 'best' voice-leadings are closest first 
by 'smoothness,' and then  by 'parsimony.' 
See Dmitri Tymoczko, 
_The Geometry of Musical Chords_, 2005
(Princeton University).

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

TODO:

Rigorously define terminology to avoid confusion
and ambiguity... actually the hardest part.

Ensure operations are overloaded by equivalence class, i.e. 
that an operation works 'the same' under range equivalence 
as it does under octave equivalence. If they can't or shouldn't
be overloaded, distinguish them rigorously by name.

Implement non-bijective voiceleading using Tymoczko's dynamic
programming algorithm.

Implement applications of operations with arpeggiations (projections
to subspaces and iterations through projections to subspaces).

Find some way to associate instruments and dynamics with voices.

Implement applications of all these operations to slices of scores, i.e.
create a new set of notes from a chord, or apply a chord to an 
existing set of notes.
]]
end

-- A chord is a numeric vector of pitches
-- implemented as a regular Lua table with 
-- value comparison semantics.

Chord = {}

function Chord:new(o)
    o = o or {}
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
    table.sort(self)
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

Orbifold = {}

-- The Orbifold class represents a voice-leading space
-- under either octave or range equivalence, with any number
-- of independent voices.

function Orbifold:new(o)
    o = o or {voiceCount=3, octaveCount=3, tonesPerOctave=12, isCube=false, isPrism=False, isNormalPrism = False, debug=False}
    setmetatable(o, self)
    self.__index = self
    self.N = voiceCount
    self.R = self.tonesPerOctave * self.octaveCount
    self.NR = self.N * self.R
    self.cubeTessitura = self.tonesPerOctave * self.cubeOctaveCount
    self.cubeRadius = 0.07
    self.prismRadius = self.cubeRadius * 2.0
    self.normalPrismRadius = self.prismRadius
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
    local c = self:copyChord(chord)
    for i = 1, self.N do
        c[i] = c[i] % self.tonesPerOctave
    end
    return self:sortChord(c)
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
    local inversions = self:rotations(chord)
    local inversionsForDistances = {}
    local minimumDistance = 0
    origin = self:newChord()
    for k, inversions in ipairs(inversions) do
        local zi = self:zeroForm(inversion)
        local d = self:euclidean(zi, origin)
        if d < minimumDistance then
            d = minimumDistance
        end
        inversionsForDistances[d] = inversion
        print(string.format('Distance %f zero-form %s inversion %s.', d, zi, inversion))
    end
    return inversionsForDistances[minimumDistance]
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
    local tones = self:tones(chord)
    local iterating_chords = self:rotations(tones)
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
    for i = 1, self.N do
        if v:count(v[i]) > 1 then
            for j = 1, self.N do
                if i ~= j then
                    if math.abs(a[i] - a[j]) == 7 and math.abs(b[i] - b[j]) == 7 then
                        print(string.format('a: %s b: %s v: %s: parallel fifth', a, b, v))
                        return true
                    end
                end
            end
        end
    end
    return false
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
    for i = 1, n do
        tail = table.remove(c)
        table.insert(1, c)
    end
    return c
end

-- Returns a copy of the chord 'inverted' in the musician's sense,
-- i.e. by rotating it and adding an octave to the highest indexed voice.
-- TODO: Handle slicing?

function Orbifold:invert(chord)
   chord = chord:rotate()
   chord[#chord] = chord[#chord] + 12    
end

-- Returns all the 'inversions' (in the musician's sense) of the chord.

function Orbifold:rotations(chord)
    local t = self:tones(chord)
    local rotations = {}
    table.insert(rotations, t)
    for i = 2, self.N do
        t = self:invert(t)
        table.insert(rotations, t)
    end
    return rotations
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

function Orbifold:pitchclasses(chord)
    local c = chord:copy()
    for i, v in ipairs(c) do
        c[i] = v % self.tonesPerOctave
    end
    return c
end

-- Returns the pitchclass of the pitch.

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
    return pc(pitch + n)
end

-- Returns the chord transposed by n.

function Orbifold:T(chord, n)
    local chord_ = chord:copy()
    for i, pitch in ipairs(chord) do
        chord_[i] = pc(pitch + n)
    end
end

-- Inverts the pitch by n.
  
  local function I( p,  n)
    return pc((12 - pc(p)) + n);
  end
  
-- Returns the inversion of the chord by n.

function Orbifold:I(chord, n)
    chord_ = chord:new()
    for i, pitch in ipairs(chord_) do
        chord_[i] = I(chord[i], n)
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
