require "Silencio"
require("ChordSpace")

print("CHORDSPACE UNIT TESTS")
print()
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
volume1 = ChordSpace.volume(chords)
print('volume:', volume1)
chords = {}
table.insert(chords, Chord:new{-3, 0, 0, 0})
table.insert(chords, Chord:new{0, 0, 0, 0})
table.insert(chords, Chord:new{3, -3, 0, 0})
table.insert(chords, Chord:new{0, 0, -3, 0})
volume2 = ChordSpace.volume(chords)
print('volume:', volume2)
result(math.abs(volume1) == math.abs(volume2), "Volume of same simplex in space and in subspace must be equal.")



voiceCount = 3
print('All of OP')
local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OP')
for index, chord in pairs(chords) do
    print(string.format('OP: %5d', index))
    print(chord:label())
    if chord:iseOP() == false then
        fail('Each chord in OP must return iseOP true.')
    end
    print()
end
pass('Each chord in OP must return iseOP true.')

print('All of OPI')
local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPI')
for index, chord in pairs(chords) do
    print(string.format('OPI: %5d', index))
    print(chord:label())
    if chord:iseOPI() == false then
        fail('Each chord in OPI must return iseOPI true.')
    end
    if chord:eOPI() ~= chord then
        fail('Each chord in OPI must be eOPI.')
    end
    print()
end
pass('Each chord in OPI must return iseOPI true.')
pass('Each chord in OPI must be eOPI.')

print('All of OPT')
local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPT')
for index, chord in pairs(chords) do
    print(string.format('OPT: %5d', index))
    print(chord:label())
    if chord:iseOPT() == false then
        fail('Each chord in OPT must return iseOPT true.')
    end
    if chord:eOPT() ~= chord then
        fail('Each chord in OPT must be eOPT.')
    end
    print()
end
pass('Each chord in OPT must return iseOPT true.')
pass('Each chord in OPT must be eOPT.')

print('All of OPTI')
local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPTI')
for index, chord in pairs(chords) do
    print(string.format('OPTI: %5d', index))
    print(chord:label())
    if chord:iseOPTI() == false then
        fail('Each chord in OPTI must return iseOPTI true.')
    end
    if chord:eOPTI() ~= chord then
        fail('Each chord in OPTI must be eOPTI.')
    end
    print()
end
pass('Each chord in OPTI must return iseOPTI true.')
pass('Each chord in OPTI must be eOPTI.')

for arity = 2, 4 do
    local ops = ChordSpace.allOfEquivalenceClass(arity, 'OP')
    for key, chord in pairs(ops) do
        local inversion = chord:I():eOP()
        local reinversion = inversion:I():eOP()
        local flat = chord:inversionFlat()
        local reflection = chord:reflect(flat):eOP()
        local rereflection = reflection:reflect(flat):eOP()
        print(string.format('chord %5d:  %s', key, tostring(chord)))
        print(string.format('inversion:    %s', tostring(inversion)))
        print(string.format('reinversion:  %s', tostring(reinversion)))
        print(string.format('flat:         %s', tostring(flat)))
        print(string.format('reflection:   %s', tostring(reflection)))
        print(string.format('rereflection: %s', tostring(rereflection)))
        print(string.format('is flat:      %s', tostring(chord:isInversionFlat())))
        print(string.format('iseOPI:       %s', tostring(chord:iseOPI())))
        print(string.format('iseOPI(I):    %s', tostring(inversion:iseOPI())))
        print(string.format('eOPI:         %s', tostring(chord:eOPI())))
        print(string.format('eOPI(I):      %s\n', tostring(inversion:eOPI())))
         if not (inversion == reflection) then
            fail('Reflection in the inversion flat must be the same as inversion in the origin.')
        end
        if not(reinversion == rereflection) then
            fail('Re-inversion must be the same as re-reflection.')
        end
        if not(reinversion == chord) then
            fail('Re-inversion and re-reflection must be the same as the original chord.')
        end
    end
    pass('Reflection in the inversion flat must be the same as inversion in the origin.')
    pass('Re-inversion must be the same as re-reflection.')
    pass('Re-inversion and re-reflection must be the same as the original chord.')
    print(string.format('All chords in inversion flat for %d voices:', arity))
    for key, chord in pairs(ops) do
        if chord:isInversionFlat() then
            print(string.format('flat: %s  midpoint: %s', tostring(chord), tostring(chord:inversionMidpoint())))
        end
    end
end

function testIsEquivalenceEqualsEquivalence(arity, equivalence, dump)
    dump = dump or false
    local isees, iseesSet = ChordSpace.allOfEquivalenceClass(arity, equivalence)
    local ees, eesSet = ChordSpace.allOfEquivalenceClassByOperation(arity, equivalence)
    local passes = true
    local union = {}
    local intersection = {}
    for key, value in pairs(iseesSet) do
        union[key] = value
    end
    for key, value in pairs(eesSet) do
        union[key] = value
    end
    for key, value in pairs(union) do
        if iseesSet[key] and eesSet[key] then
            table.insert(intersection, tostring(value) .. ' matches')
        end
        if iseesSet[key] and not eesSet[key] then
            table.insert(intersection, tostring(value) .. ' isees only')
            passes = false
        end
        if not iseesSet[key] and eesSet[key] then
            table.insert(intersection, tostring(value) .. ' ees only')
            passes = false
        end
    end
    print()
    --table.sort(intersection)
    if passes then
        pass(string.format('isees must == ees FOR %d voice %s\n', arity, equivalence))
    else
         if not dump then
            testIsEquivalenceEqualsEquivalence(arity, equivalence, true)
        else
            for key, value in pairs(intersection) do
                print_(key, value)
            end
            fail(string.format('isees must == ees FOR %d voice %s', arity, equivalence))
        end
    end
    return passes
end

for arity = 2, 3 do
    testIsEquivalenceEqualsEquivalence(arity, 'OP')
    testIsEquivalenceEqualsEquivalence(arity, 'OPI')
    testIsEquivalenceEqualsEquivalence(arity, 'OPT')
    testIsEquivalenceEqualsEquivalence(arity, 'OPTI')
end

function printVoicings(chord)
    print(chord:label())
    local voicings = chord:voicings()
    for i, voicing in ipairs(voicings) do
        print('voicing', i, voicing, 'iseV', voicing:iseV(), voicing:distanceToUnisonDiagonal())
        print('eOP', i, voicing:eOP())
        print('et', i, voicing:et())
        print('eop', i, voicing:eop())
        print('eopt', i, voicing:eopt())
        print('eOPI', i, voicing:eOPI())
        print('eOPT', i, voicing:eOPT(),'iseOPT', voicing:iseOPT())
    end
end

local c3333 = Chord:new{3,3,3,3}
printVoicings(c3333)
print()
local chord = ChordSpace.chordsForNames['CM9']
printVoicings(chord)
print()

--os.exit()

print('c3333', c3333:label())
local ic3333 = c3333:I():eOP()
print('ic3333', ic3333:label())

local Caug = ChordSpace.chordsForNames['C+']
local areeV = 0
for t = 0, 11 do
    local chord = Caug:T(t):eOP()
    print('C+ t', t, chord:label())
    print(chord:iseV())
    if chord:iseV() then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print()

local CM = ChordSpace.chordsForNames['CM']
local areeV = 0
for t = 0, 11 do
    local chord = CM:T(t):eOP()
    print('CM t', t, chord:label())
    print(chord:iseV())
    if chord:iseV() then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print()

local CM7 = ChordSpace.chordsForNames['CM7']
local areeV = 0
for t = 0, 11 do
    local chord = CM7:T(t):eOP()
    print('CM7 t', t, chord:label())
    print(chord:iseV())
    if chord:iseV() then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print()

local CM9 = ChordSpace.chordsForNames['CM9']
local areeV = 0
for t = 0, 11 do
    local chord = CM9:T(t):eOP()
    print('CM9 t', t, chord:label())
    print(chord:iseV())
    if chord:iseV() then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print()

--os.exit()

print ('Does OPTI U OPTI:I():eOP() == OPT?')
local arity = 3
local OPTIs = ChordSpace.allOfEquivalenceClass(arity, 'OPTI')
local chordset = {}
for i, OPTI in pairs(OPTIs) do
    chordset[OPTI:__hash()] = OPTI
    local IOPTI = OPTI:I():eOP()
    chordset[IOPTI:__hash()] = IOPTI
    print(i, 'OPTI', OPTI, 'OPTI:I():eOP()', IOPTI)
end
local sortedchordset = {}
for index, chord in pairs(chordset) do
    table.insert(sortedchordset, chord)
end
table.sort(sortedchordset)
local shouldbeOPT = {}
for index, chord in pairs(sortedchordset) do
    table.insert(shouldbeOPT, index - 1, chord)
end
local OPT = ChordSpace.allOfEquivalenceClass(arity, 'OPT')
for i = 0, math.max(#OPT, #shouldbeOPT) do
    print (i, 'OPTI U OPTI:I():eOP()', shouldbeOPT[i], 'OPT', OPT[i])
end

os.exit()

local chord = Chord:new{-3,1,4,8}
print(chord:label())
local chord = Chord:new{-2,1,5,6}
print(chord:label())

-- os.exit()

print(chord:label())
print('ChordSpaceGroup')
local chordSpaceGroup = ChordSpaceGroup:new()
chordSpaceGroup:initialize(4, 60)
chordSpaceGroup:list()
local GM7 = ChordSpace.chordsForNames['GM7']
GM7[2] = GM7[2] + 12
GM7[4] = GM7[4] + 24
print('GM7')
print(GM7:label())
local P, I, T, V = chordSpaceGroup:fromChord(GM7)
print('fromChord:            P', P, 'I', I, 'T', T, 'V', V)
local shouldBeGM7 = chordSpaceGroup:toChord(P, I, T, V)
print('toChord: shouldBeGM7:', shouldBeGM7)
local P, I, T, V = chordSpaceGroup:fromChord(shouldBeGM7)
print('fromChord again:      P', P, 'I', I, 'T', T, 'V', V)
print()
local IofGM7 = ChordSpace.chordsForNames['GM7']:I():eOP()
print('IofGM7')
print(IofGM7:label())
IofGM7[2] = IofGM7[2] + 12
IofGM7[4] = IofGM7[4] + 24
print('IofGM7')
print(IofGM7:label())
local P, I, T, V = chordSpaceGroup:fromChord(IofGM7)
print('fromChord:            P', P, 'I', I, 'T', T, 'V', V)
local shouldBeIofGM7 = chordSpaceGroup:toChord(P, I, T, V)
print('toChord: shouldBeIofGM7:')
print(shouldBeIofGM7:label())
local P, I, T, V = chordSpaceGroup:fromChord(shouldBeIofGM7)
print('fromChord again:      P', P, 'I', I, 'T', T, 'V', V)
print()

os.exit()

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
print()
test('c = Chord:new{0, 4, 7}; voicings = c:voicings()')
for i = 1, #voicings do
    voicing = voicings[i]
    print('voicing:', voicing, 'voicing:iseI():', voicing:iseI(), 'voicing:iseV()', voicing:iseV())
end
print()
test('c = Chord:new{0, 4, 7, 10, 14}; voicings = c:voicings()')
for i = 1, #voicings do
    voicing = voicings[i]
    print('voicing:', voicing, 'voicing:iseI():', voicing:iseI(), 'voicing:iseV()', voicing:iseV())
end
print()
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
print()
for i = 1, 12 do
    snippet = string.format('cn = Chord:new{0, 4, 7}; cnt = cn:T(%d); copt = o:eOPT(cnt); copti = o:eOPTI(cnt);', i)
    test(snippet)
    result('cn', cn, 'cnt', cnt, 'copt', copt, 'copti', copti)
end
print()
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
print()
test('k = o:K(z)')
result('z', z, 'k', k)
test('r = o:nrR(z)')
result('z', z, 'r', r)
test('m7 = Chord:new{0, 3, 7, 10}; k7 = o:K(m7)')
result('m7', m7, 'k7', k7)
print()
test('p = o:nrP(z)')
result('z', z, 'p', p)
test('l = o:nrL(z)')
result('z', z, 'l', l)
test('d = o:nrD(z)')
result('z', z, 'd', d)
print()
test('m = Chord:new{0, 3, 7}; m1 = o:nrR(c):eOP()')
result('m', m, 'm1', m1)
print()
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
print()
test('voicings = o:voicings(c)')
result('c', c)
for i, voicing in ipairs(voicings) do
    result('voicing', voicing, 'voicing:eO()', voicing:eO())
end
print()








