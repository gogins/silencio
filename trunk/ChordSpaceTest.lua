require "Silencio"
require("ChordSpace")
local matrix = require("matrix")

print("CHORDSPACE UNIT TESTS")
print('')
print('package.path:', package.path)
print('package.cpath:', package.cpath)

print_ = print

verbose = false

function print(message)
    if verbose then
        print_(message)
    end
end

function pass(message)
    print_()
    print_('PASSED:', message)
    print_()
end

function fail(message)
    print_()
    print_('FAILED:', message)
    print_()
    os.exit()
end

function result(expression, message)
    if expression then
        pass(message)
    else
        fail(message)
    end
end

for n = 0, 12 do
	local f = ChordSpace.factorial(n)
	print(string.format('%2d factorial is: %9d.', n, f))
end

print_('How does operator % behave?')
for pitch = -24, 23, 1 do
    local pc = pitch % ChordSpace.OCTAVE
    print_(string.format('%9.4f = %9.4f %% ChordSpace.OCTAVE', pc, pitch))
end
print_('')

local a = Chord:new{3, 3, 6}
local b = Chord:new{3, 3, 6}
print(a:__hash())
print(b:__hash())
result(a == b, 'Chord hash codes for identical values must be identical.')

chords = {}
table.insert(chords, Chord:new{-3, 0, 0})
table.insert(chords, Chord:new{0, 0, 0})
table.insert(chords, Chord:new{0, -3, 0})
table.insert(chords, Chord:new{0, 0, -3})
volume1 = ChordSpace.volumeSquared(chords)
print_('volume: ' .. tostring(volume1))
chords = {}
table.insert(chords, Chord:new{-3, 0, 0, 0})
table.insert(chords, Chord:new{0, 0, 0, 0})
table.insert(chords, Chord:new{3, -3, 0, 0})
table.insert(chords, Chord:new{0, 0, -3, 0})
volume2 = ChordSpace.volumeSquared(chords)
print_('volume: ' .. tostring(volume2))
result(math.abs(volume1) == math.abs(volume2), "Volumes of same simplex in space and in subspace must be equal.")
for i = 3, 12 do
    print_(string.format('CHORDS OF %d VOICES...', i))
    local chord = Chord:new()
    chord:resize(i)
    local maximallyEven = chord:maximallyEven()
    print_(string.format('maximallyEven for %2d voices: %s', i, tostring(maximallyEven)))
    local cyclicalRegion = chord:cyclicalRegion(ChordSpace.OCTAVE)
    print_('cyclical region:\n' .. matrix:new(cyclicalRegion):tostring())
    local homogeneous = ChordSpace.homogeneousSimplex(cyclicalRegion)
    print_('homogeneous:\n' .. homogeneous:tostring())
    local invariant = ChordSpace.invariantSimplex(homogeneous)
    print_('invariant:\n' .. invariant:tostring())
    local transposed = invariant:transpose()
    print_('transposed:\n' .. transposed:tostring())
    local squared = matrix.mul(transposed, invariant)
    print_('squared:\n' .. squared:tostring())
    for j = 1, #cyclicalRegion do
        local point = cyclicalRegion[j]
        print_(tostring(point) .. '  BC: ' .. tostring(ChordSpace.barycentricCoordinates(point, cyclicalRegion)))
    end
    local normalRegion = chord:normalRegion(ChordSpace.OCTAVE)
    for j = 1, #normalRegion do
        local point = normalRegion[j]
        print_(tostring(point) .. '  BC: ' .. tostring(ChordSpace.barycentricCoordinates(point, normalRegion)))
    end
    local targetCoordinates = chord:origin()
    if ChordSpace.backwards then
        targetCoordinates[1] = 1
    else
        targetCoordinates[#targetCoordinates] = 1
    end
    local coordinates = ChordSpace.barycentricCoordinates(chord, cyclicalRegion)
    if coordinates == targetCoordinates then
        passes = true
    else
        passes = false
    end
    result(passes, string.format('Barycentric coordinates of %s are %s must be %s.', tostring(chord), tostring(coordinates), tostring(targetCoordinates)))
    local outsideChord = chord:clone()
    outsideChord[1] = -100
    local coordinates = ChordSpace.barycentricCoordinates(outsideChord, cyclicalRegion)
    result(true, string.format('Barycentric coordinates of %s are %s.', tostring(outsideChord), tostring(coordinates)))
end
-- One and only one of the cyclical permutations of a chord must be in the normal region.
-- If the chord is equal to the cyclical permutation that is in the normal region, it is
-- in the representative fundamental domain of voicing equivalence.
local chordTypes = {'CM', 'Cm', 'C7', 'CM7', 'Cm7', 'Co7', 'C9', 'CM9', 'Cm9'}
for k, chordType in pairs(chordTypes) do
    local chord = ChordSpace.chordsForNames[chordType]
    local normalRegion = chord:normalRegion()
    for j = 1, #normalRegion do
        local point = normalRegion[j]
        print_(string.format('Normal region %2d: %s  layer: %6.2f', j, tostring(point), tostring(point:sum())))
    end
    local permutations = chord:cyclicalPermutations()
    local insideCount = 0
    for i, permutation in pairs(permutations) do
        local isInside = permutation:isInSimplex(normalRegion) 
        if isInside then
            insideCount = insideCount + 1
        end
        print_(string.format('%5s permutation %d: %s  inside: %s', chordType, i, tostring(permutation), tostring(isInside)))
    end
    result(insideCount == 1, "One and only one of the cyclical permutations of a chord must be in the normal region: actually inside: " .. tostring(insideCount))
end
os.exit(0)

function iseOPIeOPI(voiceCount)
    dump = dump or false
    local chords = ChordSpace.allChordsInRange(voiceCount, ChordSpace.OCTAVE)
    local passes = true
    local chord = nil
    local opi = nil
    for i = 1, #chords do
        chord = chords[i]
        if chord:iseOP() then
            opi = chord:eOPI()
            if chord == opi then
                if chord:iseOPI() == false or opi:iseOPI() == false then
                    passes = false
                    break
                end
            else
                if chord:iseOPI() == opi:iseOPI() then
                    passes = false
                    break
                end
                if chord:iseOPI() and chord ~= opi then
                    passes = false
                    break
                end
                if opi:iseOPI() and chord == opi then
                    passes = false
                    break
                end
            end
        end
    end
    if passes == false then
        print_(chord:label())
        print_(opi:label())
    end
    result(passes, string.format('eOPI must equate to iseOPI for %d voices.', voiceCount))
end

function printVoicings(chord)
    print(chord:label())
    local voicings = chord:voicings()
    for i, voicing in ipairs(voicings) do
        print(string.format('voicing: %d %s iseV %s %f', i, tostring(voicing), tostring(voicing:iseV(ChordSpace.OCTAVE)), voicing:distanceToUnisonDiagonal()))
        print(string.format('eOP:     %d %s', i, tostring(voicing:eOP())))
        print(string.format('et:      %d %s', i, tostring(voicing:et())))
        print(string.format('eop:     %d $s', i, tostring(voicing:eop())))
        print(string.format('eopt:    %d %s', i, tostring(voicing:eopt())))
        print(string.format('eOPI:    %d %s', i, tostring(voicing:eOPI())))
        print(string.format('eOPT:    %d %s iseOPT %s', i, tostring(voicing:eOPT()), tostring(voicing:iseOPT())))
    end
end

--[[
print('ChordSpaceGroup')
local chordSpaceGroup = ChordSpaceGroup:new()
chordSpaceGroup:initialize(4, 60)
chordSpaceGroup:list()

local GbM7 = ChordSpace.chordsForNames['GbM7']
print('GbM7:')
print(GbM7:label())
local P, I, T, V = chordSpaceGroup:fromChord(GbM7)
print(string.format('GbM7:             P: %d  I: %s  T: %s  V: %s', P, I, T, V))
GbM7[2] = GbM7[2] + 12
GbM7[4] = GbM7[4] + 24
print('GbM7 revoiced:')
print(GbM7:label())
P, I, T, V = chordSpaceGroup:fromChord(GbM7)
print(string.format('GbM7 revoiced:    P: %d  I: %s  T: %s  V: %s', P, I, T, V))

local shouldBeGbM7 = chordSpaceGroup:toChord(P, I, T, V)
print('shouldBeGbM7:')
print(shouldBeGbM7:label())
P, I, T, V = chordSpaceGroup:fromChord(shouldBeGbM7)
print(string.format('shouldBeGbM7:     P: %d  I: %s  T: %s  V: %s', P, I, T, V))
result(shouldBeIofGbM7 == IofGbM7, 'ChordSpaceGroup: GbM7 must be the same from and to PITV')

local IofGbM7 = ChordSpace.chordsForNames['GbM7']:I():eOP()
print('IofGbM7:')
print(IofGbM7:label())
P, I, T, V = chordSpaceGroup:fromChord(IofGbM7)
print(string.format('IofGbM7:          P: %d  I: %s  T: %s  V: %s', P, I, T, V))
IofGbM7[2] = IofGbM7[2] + 12
IofGbM7[4] = IofGbM7[4] + 24
print('IofGbM7 revoiced:')
print(IofGbM7:label())
P, I, T, V = chordSpaceGroup:fromChord(IofGbM7)
print(string.format('IofGbM7 revoiced: P: %d  I: %s  T: %s  V: %s', P, I, T, V))

local shouldBeIofGbM7 = chordSpaceGroup:toChord(P, I, T, V)
print('shouldBeIofGbM7:')
print(shouldBeIofGbM7:label())
P, I, T, V = chordSpaceGroup:fromChord(shouldBeIofGbM7)
print(string.format('shouldBeIofGbM7:  P: %d  I: %s  T: %s  V: %s', P, I, T, V))
result(shouldBeIofGbM7 == IofGbM7, 'ChordSpaceGroup: IofGbM7 must be the same from and to PITV')
print('')

G7 = ChordSpace.chordsForNames['G7']
print_(G7:label())
P, I, T, V = chordSpaceGroup:fromChord(G7)
for T = 0, 11 do
    chord = chordSpaceGroup:toChord(P, I, T, V)
    print_(chord:label())
    chord = chordSpaceGroup:toChord(P, I+1, T, V)
    print_(chord:label())
end
]]
for voiceCount = 3, 4 do

    if false then

    passes = true
    chordSpaceGroup = ChordSpaceGroup:new()
    chordSpaceGroup:initialize(voiceCount, 48)
    chordSpaceGroup:list()
    for P = 0, chordSpaceGroup.countP - 1 do
        for I = 0, 1 do
            for T = 0, ChordSpace.OCTAVE - 1 do
                for V = 0, chordSpaceGroup.countV - 1 do
                    local fromPITV = chordSpaceGroup:toChord(P, I, T, V)
                    print_(string.format("toChord  (P: %f  I: %f  T: %f  V: %f) = %s", P, I, T, V, tostring(fromPITV)))
                    local p, i, t, v = chordSpaceGroup:fromChord(fromPITV)
                    local frompitv = chordSpaceGroup:toChord(p, i, t, v)
                    print_(string.format("fromChord(P: %f  I: %f  T: %f  V: %f) = %s", p, i, t, v, tostring(frompitv)))
                    if (fromPITV ~= frompitv) or (p ~= P) or (i ~= I) or (t ~= T) or (v ~= V) then
                        --print_(string.format("toChord  (P: %f  I: %f  T: %f  V: %f) = %s", P, I, T, V, tostring(fromPITV)))
                        --print_(string.format("fromChord(P: %f  I: %f  T: %f  V: %f) = %s", p, i, t, v, tostring(frompitv)))
                        passes = false
                        result(passes, string.format('All of P, I, T, V for %d voices must translate back and forth.', voiceCount))
                    end
                    print_('')
                end
            end
        end
    end
    result(passes, string.format('All of P, I, T, V for %d voices must translate back and forth.', voiceCount))
    print('All of OP')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OP')
    for index, chord in pairs(chords) do
        print(string.format('OP: %5d', index))
        print(chord:label())
        if chord:iseOP() == false then
            fail(string.format('Each chord in OP must return iseOP true for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OP must return iseOP true for %d voices.', voiceCount))

    end

    print('All of OPT')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPT')
    for index, chord in pairs(chords) do
        print(string.format('OPT: %5d', index))
        print(chord:label())
        if chord:iseOPT() == false then
            fail(string.format('Each chord in OPT must return iseOPT true for %d voices.', voiceCount))
        end
        if chord:eOPT() ~= chord then
            fail(string.format('Each chord in OPT must be eOPT for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OPT must return iseOPT true for %d voices.', voiceCount))
    pass(string.format('Each chord in OPT must be eOPT for %d voices.', voiceCount))

    print('All of OPI')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPI')
    for index, chord in pairs(chords) do
        print(string.format('OPI: %5d', index))
        print(chord:label())
        if chord:iseOPI() == false then
            fail(string.format('Each chord in OPI must return iseOPI true for %d voices.', voiceCount))
        end
        if chord:eOPI() ~= chord then
            fail(string.format('Each chord in OPI must be eOPI for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OPI must return iseOPI true for %d voices.', voiceCount))
    pass(string.format('Each chord in OPI must be eOPI for %d voices.', voiceCount))

    print('All of OPTI')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPTI')
    for index, chord in pairs(chords) do
        print(string.format('OPTI: %5d', index))
        print(chord:label())
        if chord:iseOPTI() == false then
            fail(string.format('Each chord in OPTI must return iseOPTI true for %d voices.', voiceCount))
        end
        if chord:eOPTI() ~= chord then
            print_('Normal:' .. chord:label())
            print_('eOPTI: ' .. chord:eOPTI():label())
            fail(string.format('Each chord in OPTI must be eOPTI for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OPTI must return iseOPTI true for %d voices.', voiceCount))
    pass(string.format('Each chord in OPTI must be eOPTI for %d voices.', voiceCount))

    local ops = ChordSpace.allOfEquivalenceClass(voiceCount, 'OP')
    local flatset ={}
    for key, chord in pairs(ops) do
        local inversion = chord:I():eOP()
        local reinversion = inversion:I():eOP()
        local flat = chord:flatP()
        local reflection = chord:reflect(flat)
        local opreflection = reflection:eOP()
        local rereflection = reflection:reflect(flat):eOP()
        print(string.format('chord %5d:  %s', key, tostring(chord)))
        print(string.format('inversion:    %s', tostring(inversion)))
        print(string.format('reinversion:  %s', tostring(reinversion)))
        print(string.format('flat:         %s', tostring(flat)))
        print(string.format('reflection:   %s', tostring(reflection)))
        print(string.format('opreflection: %s', tostring(opreflection)))
        print(string.format('rereflection: %s', tostring(rereflection)))
        print(string.format('is flat:      %s', tostring(chord:isFlatP())))
        print(string.format('iseOPI:       %s', tostring(chord:iseOPI())))
        print(string.format('iseOPI(I):    %s', tostring(inversion:iseOPI())))
        print(string.format('eOPI:         %s', tostring(chord:eOPI())))
        print(string.format('eOPI(I):      %s\n', tostring(inversion:eOPI())))
        if not (inversion == opreflection) then
            fail(string.format('Reflection in the inversion flat must be the same as inversion in the origin for %d voices.', voiceCount))
        end
        if not(reinversion == rereflection) then
            fail(string.format('Re-inversion must be the same as re-reflection for %d voices.', voiceCount))
        end
        if not(reinversion == chord) then
            fail(string.format('Re-inversion and re-reflection must be the same as the original chord for %d voices.', voiceCount))
        end
    end
    pass(string.format('Reflection in the inversion flat must be the same as inversion in the origin for %d voices.', voiceCount))
    pass(string.format('Re-inversion must be the same as re-reflection for %d voices.', voiceCount))
    pass(string.format('Re-inversion and re-reflection must be the same as the original chord for %d voices.', voiceCount))
    pass(string.format('Re-inversion and re-reflection must be the same as the original chord for %d voies.', voiceCount))
    print(string.format('All chords in inversion flat for %d voices:', voiceCount))
    flats = ChordSpace.flatsP(3, ChordSpace.OCTAVE)
    for key, flat in pairs(flats) do
        print(string.format('flat: %s', tostring(flat)))
    end
    iseOPIeOPI(voiceCount)
    passes = true
    local chord
    local inverseop
    for i = 1, #ops do
        chord = ops[i]
        inverseop = chord:I():eOP()
        if chord:iseOPI() == true and inverseop:iseOPI() == true then
            if chord ~= inverseop then
                passes = false
                break
            end
        end
        if chord:iseOPI() == false and inverseop:iseOPI() == false then
            passes = false
            break
        end
    end
    if not passes then
        print_(chord)
        print_(inverseop)
    end
    result(passes, string.format('Chord/Inverse must be, if not a fixed point, one inside/one outside the representative fundamental domain of inversional equivalence for %d voices.', voiceCount))
end

--os.exit()

local c3333 = Chord:new{3,3,3,3}
printVoicings(c3333)
print('')
local chord = ChordSpace.chordsForNames['CM9']
printVoicings(chord)
print('')

--os.exit()

print('c3333', c3333:label())
local ic3333 = c3333:I():eOP()
print('ic3333', ic3333:label())

local Caug = ChordSpace.chordsForNames['C+']
local areeV = 0
for t = 0, 11 do
    local chord = Caug:T(t):eOP()
    print('C+ t', t, chord:label())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

local CM = ChordSpace.chordsForNames['CM']
local areeV = 0
for t = 0, 11 do
    local chord = CM:T(t):eOP()
    print('CM t', t, chord:label())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

local CM7 = ChordSpace.chordsForNames['CM7']
local areeV = 0
for t = 0, 11 do
    local chord = CM7:T(t):eOP()
    print('CM7 t', t, chord:label())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

local CM9 = ChordSpace.chordsForNames['CM9']
local areeV = 0
for t = 0, 11 do
    local chord = CM9:T(t):eOP()
    print('CM9 t', t, chord:label())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

verbose = true

for voices = 2, 6 do
    local passes = true
    local dummy, ops = ChordSpace.allOfEquivalenceClass(voices, 'OP')
    local op = nil
    local opt = nil
    local opti = nil
    local opti_i = nil
    for i = 1, #ops do
        op = ops[i]
        opt = op:eOPT()
        opt_i = opt:I()
        opt_i_op = opt_i:eOP()
        opt_i_opt = opt_i:eOPT()
        opti = op:eOPTI()
        opti_i = opti:I()
        opti_i_op = opti_i:eOP()
        opti_i_opt = opti_i:eOPT()
        if (op == opti) or (op == opti_i) then
            if op ~= opt then
                passes = false
                print_('If it is OPTI or OPTI:I:OPT it must be OPT.')
                break
            end
        end
        if op == opt then
            if not ((op == opti) or (op == opti_i_opt)) then
                ChordSpace.bing = true
                passes = false
                print_('If it is OPT it must be either OPTI or OPTI:I:OPT.')
                local voicings = op:voicings()
                for key, voicing in pairs(voicings) do
                    print_(tostring(voicing:et()) .. '  iseV: ' .. tostring(voicing:iseV(ChordSpace.OCTAVE)) .. ' To unisons: ' .. tostring(voicing:et():distanceToUnisonDiagonal()))
                end
                break
            end
        end
    end
    if passes == false then
        print_('op:        ' .. tostring(op))
        print_('opt:       ' .. tostring(opt))
        print_('opt_i:     ' .. tostring(opt_i))
        print_('opt_i_op:  ' .. tostring(opt_i_op))
        print_('opt_i_opt: ' .. tostring(opt_i_opt))
        print_('opti:      ' .. tostring(opti))
        print_('opti_i:    ' .. tostring(opti_i))
        print_('opti_i_op: ' .. tostring(opti_i_op))
        print_('opti_i_opt:' .. tostring(opti_i_opt))
        result(passes, string.format('OPTI U OPTI:I():eOPT() == OPT for %d voices.', voices))
    end
end

test('a = Chord:new()')
result('a', a)
test('a = Chord:new(); a:resize(3)')
result('a', a, 'a.channel[3]', a.channel[3])
result('a[1]', a[1])
test('a[1] = 2')
result('a', a)
test('b = Chord:new()')
result('b', b)
test('b:resize(3)')
result('b', b)
test('equals = (a == b)')
result('a', a, 'b', b, 'equals', equals)
test('b[1] = 2', b)
test('equals = (a == b)')
result('a', a, 'b', b, 'equals', equals)
test('c = Chord:new{3, 2, 1}')
result('c', c)
test('s = c:eP()')
result('c', c, 's', s)
test('lt = (a < c)')
result('a', a, 'c', c, 'lt', lt)
test('lt = (c < a)')
result('a', a, 'c', c, 'lt', lt)
test('m = a:min()')
result('a', a, 'm', m)
test('m = a:max()')
result('a', a, 'm', m)
test('d = c:clone()')
result('c', c, 'd', d)
test('n = c:count(2)')
result('c', c, 'n', n)
test('n = a:count(0)')
result('a', a, 'n', n)
test('n = c:sum()')
result('c', c, 'n', n)
test('n = a:sum()')
result('a', a, 'n', n)
test('s = a:eP()')result('a', a, 's', s)
print('')
test('c = Chord:new{0, 4, 7}; voicings = c:voicings()')
for i = 1, #voicings do
    voicing = voicings[i]
    print('voicing:', voicing, 'voicing:iseI():', voicing:iseI(), 'voicing:iseV(ChordSpace.OCTAVE)', voicing:iseV(ChordSpace.OCTAVE))
end
print('')
test('c = Chord:new{0, 4, 7, 10, 14}; voicings = c:voicings()')
for i = 1, #voicings do
    voicing = voicings[i]
    print('voicing:', voicing, 'voicing:iseI():', voicing:iseI(), 'voicing:iseV(ChordSpace.OCTAVE)', voicing:iseV(ChordSpace.OCTAVE))
end
print('')
test('o = Orbifold:new()')
result('o', o, 'o.N', o.N, 'o.R', o.R, 'o.octaves', o.octaves, 'o.NR', o.NR)
test('v = o:voiceleading(c, a)')
result('c', c, 'a', a, 'v', v)
test('e = o:T(c, 3)')
result('c', c, 'e', e)
test('c1 = Chord:new{19, 13, 14}; c1o = c1:eO(); c1op = c1:eO():eP()')
result('c1', c1, 'c1o', c1o, 'c1op', c1op)
test('c = Chord:new{0, 4, 7}; d = c:I(6, 12);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = o:I(c, 6);')
result('c', c, 'd', d)
test('c = Chord:new{4, 4, 4}; d = c:I(5, 12);')
result('c', c, 'd', d)
test('c = Chord:new{4, 4, 4}; d = o:I(c, 5);')
result('c', c, 'd', d)
test('c = Chord:new{24, 7, 16}; t = c:eOP(c)')
result('c', c, 't', t)
test('c = Chord:new{0, 4, 7}; d = c:cycle(1);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = c:cycle(-1);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = c:V();')
result('c', c, 'd', d)
test('c = Chord:new{0, 16, 7}; d = c:voicings();')
result('c', c, 'd', d)
for i, voicing in ipairs(d) do
    result('voicing', voicing)
end
test('s = o:smoothness(c, b)')
result('c', c, 'b', b, 's', s)
test('s = o:smoothness(c, c)')
result('c', c, 'c', c, 's', s)
test('a = Chord:new{5, 5, 5}; b = Chord:new{19, 19, 19}; p = o:parallelFifth(a, b)')
result('a', a, 'b', b, 'p', p)
test('a = Chord:new{5, 5, 5}; b = Chord:new{12, 12, 12}; p = o:parallelFifth(a, b)')
result('a', a, 'b', b, 'p', p)
test('s = o:smoother(a, b, c, false)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:smoother(a, b, c, true)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:simpler(a, b, c, false)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:simpler(a, b, c, true)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('z = a:eT()')
result('a', a, 'z', z, 'z:sum()', z:sum())
test('z = c:eT()')
result('c', c, 'z', z, 'z:sum()', z:sum())
test('d = Chord:new{5, 8, 1}; z = d:eT()')
result('d', d, 'z', z, 'z:sum()', z:sum())
test('vs = o:voicings(d)')
vs = o:voicings(d)
for i = 1, #vs do
    result('i', i, 'vs[i]', vs[i])
end
print('')
for i = 1, 12 do
    snippet = string.format('cn = Chord:new{0, 4, 7}; cnt = cn:T(%d); copt = o:eOPT(cnt); copti = o:eOPTI(cnt);', i)
    test(snippet)
    result('cn', cn, 'cnt', cnt, 'copt', copt, 'copti', copti)
end
print('')
test('o:setOctaves(2)')
test('vs = o:voicings(d)')
vs = o:voicings(d)
for i = 1, #vs do
    result('i', i, 'vs[i]', vs[i])
end
test('o:setOctaves(1)')
test('z = o:eOPI(d)')
result('d', d, 'z', z)
test('z = o:eOPTI(d)')
result('d', d, 'z', z)
test('layer = d:sum()')
result('d', d, 'layer', layer)
test('s = d:sum()')
result('d', d, 's', s)
test('no = Chord:new{7, 4, 0}; inorder = no:iseP();')
result('no', no, 'inorder', inorder)
test('inside = o:eRP(c)')
result('inside', inside, 'c', c)
test('z = Chord:new{0, 4, 7}; p = o:nrP(z)')
result('z', z, 'p', p)
test('l = o:nrL(z)')
result('z', z, 'l', l)
test('r = o:nrR(z)')
result('z', z, 'r', r)
test('d = o:nrD(z)')
result('z', z, 'd', d)
test('k = o:K(z)')
result('z', z, 'k', k, 'note', 'same pcs as R, different order')
test('c0 = Chord:new{0, 4, 7}; c5 = o:T(c0, 5); tform = o:Tform(c0, c5, 1)')
result('c0', c0, 'c5', c5, 'tform', tform)
test('c0 = Chord:new{0, 4, 7}; c5 = o:T(c0, 5); iform= o:Iform(c0, c5, 1)')
result('c0', c0, 'c5', c5, 'iform', iform)
test('c0 = Chord:new{0, 4, 7}; c5 = o:I(c0, 5); iform= o:Iform(c0, c5, 1)')
result('c0', c0, 'c5', c5, 'iform', iform)
test('m = o:nrP(z); q = o:Q(z, 1, z, 1)')
result('z', z, 'm', m, 'q', q)
test('q = o:Q(z, -1, z, 1)')
result('z', z, 'q', q)
print('')
test('k = o:K(z)')
result('z', z, 'k', k)
test('r = o:nrR(z)')
result('z', z, 'r', r)
test('m7 = Chord:new{0, 3, 7, 10}; k7 = o:K(m7)')
result('m7', m7, 'k7', k7)
print('')
test('p = o:nrP(z)')
result('z', z, 'p', p)
test('l = o:nrL(z)')
result('z', z, 'l', l)
test('d = o:nrD(z)')
result('z', z, 'd', d)
print('')
test('m = Chord:new{0, 3, 7}; m1 = o:nrR(c):eOP()')
result('m', m, 'm1', m1)
print('')
for i = 0, 12 do
    test(string.format('q = o:Q(z,  %s, z, 1)', i))
    result('z', z, 'q', q)
    test(string.format('q = o:Q(z, -%s, m, 1)', i))
    result('z', z, 'q', q)
    test(string.format('q = o:Q(z,  %s, z, 1)', i))
    result('z', z, 'q', q)
    test(string.format('q = o:Q(z, -%s, m, 1)', i))
    result('z', z, 'q', q)
end
print('')
test('voicings = o:voicings(c)')
result('c', c)
for i, voicing in ipairs(voicings) do
    result('voicing', voicing, 'voicing:eO()', voicing:eO())
end
print('')
