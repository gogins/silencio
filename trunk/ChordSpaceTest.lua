require("ChordSpace")

print("CHORDSPACE UNIT TESTS")
print()

function test(chunk, ...)
    local result = assert(loadstring(chunk))()
    print(chunk)
    if result then 
        print('asserted:', result)
    end
end

function result(...)
    local args = {...}
    for i = 1, #args, 2 do
        print(string.format('\t%s:', args[i]), args[i + 1])
    end
end

test('a = Chord:new()')
result('a', a)
test('a:resize(3)')
result('a', a)
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
test('c:sort()')
result('c', c)
test('lt = (a < c)')
result('a', a, 'c', c, 'lt', lt)
test('lt = (c < a)')
result('a', a, 'c', c, 'lt', lt)
test('m = a:min()')
result('a', a, 'm', m)
test('m = a:max()')
result('a', a, 'm', m)
test('d = c:copy()')
result('c', c, 'd', d)
test('n = c:count(2)')
result('c', c, 'n', n)
test('n = a:count(0)')
result('a', a, 'n', n)
test('n = c:sum()')
result('c', c, 'n', n)
test('n = a:sum()')
result('a', a, 'n', n)
test('s = a:sort()')
result('a', a, 's', s)
test('o = Orbifold:new()')
result('o', o, 'o.N', o.N, 'o.R', o.R, 'o.octaves', o.octaves, 'o.NR', o.NR)
test('v = o:voiceleading(c, a)')
result('c', c, 'a', a, 'v', v)
test('c = Chord:new(); c:resize(6); d = o:copyChord(c);')
result('c', c, 'd', d)
test('e = Orbifold:T(b, 3)')
result('b', b, 'e', e)
test('c = Chord:new{19, 13, 14}; pcs = pitchclasses(c);')
result('c', c, 'pcs', pcs)
test('c = Chord:new{0, 4, 7}; d = o:I(c, 6);')
result('c', c, 'd', d)
test('c = Chord:new{24, 7, 16}; t = o:tones(c)')
result('c', c, 't', t)
test('c = Chord:new{0, 4, 7}; d = o:rotate(c, 1);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = o:rotate(c, -1);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = o:invert(c);')
result('c', c, 'd', d)
test('c = Chord:new{0, 16, 7}; d = o:inversions(c);')
result('c', c, 'd', d)
for i, inversion in ipairs(d) do
    print(i, inversion)
end
test('s = o:smoothness(c, b)')
result('c', c, 'b', b, 's', s)
test('s = o:smoothness(c, c)')
result('c', c, 'c', c, 's', s)
test('a = Chord:new{5, 5, 5}; b = Chord:new{19, 19, 19}; p = o:areParallel(a, b)')
result('a', a, 'b', b, 'p', p)
test('a = Chord:new{5, 5, 5}; b = Chord:new{12, 12, 12}; p = o:areParallel(a, b)')
result('a', a, 'b', b, 'p', p)
test('s = o:smoother(a, b, c, false)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:smoother(a, b, c, true)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:simpler(a, b, c, false)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:simpler(a, b, c, true)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('z = o:zeroForm(a)')
result('a', a, 'z', z)
test('z = o:zeroForm(c)')
result('c', c, 'z', z)
test('d = Chord:new{5, 8, 1}; z = o:zeroForm(d)')
result('d', d, 'z', z)
test('z = o:firstInversion(d)')
result('d', d, 'z', z)
test('z = o:zeroFormFirstInversion(d)')
result('d', d, 'z', z)
test('layer = o:layer(d)')
result('d', d, 'layer', layer)
test('s = d:sum()')
result('d', d, 's', s)
test('no = Chord:new{7, 4, 0}; inorder = o:isInOrder(no);')
result('no', no, 'inorder', inorder)
test('inlayer = o:isInLayer(c, 5)')
result('c', c, 'inlayer', inlayer, 'o:layer(c)', o:layer(c), 'o.R', o.R)
test('inlayer = o:isInLayer(z, 5)')
result('z', z, 'inlayer', inlayer, 'o:layer(z)', o:layer(z), 'o.R', o.R)
test('inside = o:keepInside(c)')
result('inside', inside, 'c', c)
test('p = o:nrP(z)')
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
for i = 0, 11 do
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








