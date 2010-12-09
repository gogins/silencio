require("ChordSpace")

print("CHORDSPACE UNIT TESTS")       
print()

function test(chunk)
    assert(loadstring(chunk))()
    return chunk
end

print(test('a = Chord:new()'), a)
print(test('a:resize(3)'), a)
print(test('a[1] = 2'), a)
print(test('b = Chord:new()'), b)
print(test('b:resize(3)'), b)
print(test('equals = (a == b)'), equals)
print(test('b[1] = 2'), b)
print(test('equals = (a == b)'), equals)
print(test('c = Chord:new{3, 2, 1}'), c)
print(test('c:sort()'), c)
print(test('lt = (a < c)'), a, c, lt)
print(test('lt = (c < a)'), a, c, lt)
print(test('m = a:min()'), a, m)
print(test('m = a:max()'), a, m)
print(test('d = c:copy()'), d, c)
print(test('n = c:count(2)'), c, n)
print(test('n = a:count(0)'), a, n)
print(test('n = c:sum()'), c, n)
print(test('n = a:sum()'), a, n)






