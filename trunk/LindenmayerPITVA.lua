local Silencio = require("Silencio")
local ChordSpace = require("ChordSpace")

LindenmayerPITVA = {}

function LindenmayerPITVA.help()
print [[

L I N D E N M A Y E R   P I T V A

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms
of the GNU Lesser General Public License.

The LindenmayerPITVA class implements a context-free Lindenmayer system that
performs operations on five additive cyclical groups P, I, T, V, and A which
represent respectively set-class, inversion, transposition, octavewise
revoicing, and arpeggiation of chords. Time (t), duration (d), instrument
choice (i), and dynamic level or MIDI velocity (v) also are represented.

An earlier version of this class was found too complex for use. This version
is intended to expose the basic symmetries of chord space to programmatic
manipulation as clearly and simply as possible.

The turtle state consists of the numbers P, I, T, V, A, t, d, i, and v.
These are the targets of operations. All turtle commands are of the form
target [operation [operand] ].

Operations are arithmetical +, -, and assignment =.

Operands are signed real numbers. The results of operations on P, I, T, V,
and A wrap around their equivalence class. The results of operations on t, d,
i, and v do not wrap around and may need to be rescaled to be musically
meaningful.

The syntax of turtle commands (target:operation:operand) is:

P o n       Operate on the zero-based index of set-class (prime form).
P = name    Assign the set-class index from a Jazz-style chord name. This may
            involve replacing the chord with its equivalent under
            transpositional and/or inversional equivalence.
I o n       Operate on the zero-based index of inversional equivalence, where
            inversion is reflection in chord {n,..n} on the unison diagonal
            of chord space.
T o n       Operate on the zero-based index of transposition within octave
            equivalence.
V o n       Operate on the zero-based index of octavewise revoicings within
            the permitted range of pitches.
V o n       Operate on the zero-based index of arpeggiation within
            the permitted range of pitches.
t o n       Operate on the time of the chord.
d o n       Operate on the duration of the chord.
i o n       Operate on the instrument assignment for the chord.
v o n       Operate on the loudness of the chord (represented as MIDI velocity
            in the interval [0, 127].
C           Write the current turtle state into the score as a chord; t is
            advanced by d.
L           Write the current turtle state into the score as a chord; or
            rather, use a geometric voice-leading algorithm to find the PITV
            that has the PIT of the current chord which is as close as possible
            to the PITV of the prior chord; t is advanced by d.
N           Write the note representing the current arpeggiation state of the
            chord into the score; t is advanced by d.
[           Push the current state of the turtle onto the top of a stack.
]           Pop the current state of the turtle off the top of the stack.
]]
end

Turtle = {}

function Turtle:new(o)
    o = o or {t = 0, d = 0, i = 0, v = 0, P = 0, I = 0, T = 0, V = 0, A = 0}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Turtle:__tostring()
    return string.format('t: %9.4f  d: %9.4f  v: %9.4f  P: %9.4f  I: %9.4f  T: %9.4f  V: %9.4f', self.t, self.d, self.v, self.P, self.I, self.T, self.V)
end

function LindenmayerPITVA:new(o)
    if not o then
        o = {}
        o.score = Score:new()
        o.axiom = ''
        o.rules = {}
        o.turtle = Turtle:new()
        o.priorTurtle = self.turtle
        o.stack = {}
        o.iterations = 3
        o.tieOverlaps = true
        o.avoidParallelFifths = false
        o.currentProduction = ''
        o.priorProduction = ''
        o.octaves = 5
        o.targets = {}
        o.targets['t'] = self.target_t
        o.targets['d'] = self.target_d
        o.targets['i'] = self.target_i
        o.targets['v'] = self.target_v
        o.targets['P'] = self.target_P
        o.targets['I'] = self.target_I
        o.targets['T'] = self.target_T
        o.targets['V'] = self.target_V
        o.targets['A'] = self.target_A
        o.targets['C'] = self.target_C
        o.targets['L'] = self.target_L
        o.targets['N'] = self.target_N
        o.targets['['] = self.target_push
        o.targets[']'] = self.target_pop
        o.operations = {}
        o.operations['='] = self.operation_assign
        o.operations['+'] = self.operation_add
        o.operations['-'] = self.operation_subtract
        o.chordSpaceGroup = ChordSpaceGroup:new()
        o.duration = 120
        o.bass = 36
        o.countA = 1
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

function LindenmayerPITVA:initialize(voices, range, g)
    print('LindenmayerPITVA:initialize...')
    self.chordSpaceGroup = ChordSpace.load(voices, range, g)
    self.countA = voices *  math.floor(range / ChordSpace.OCTAVE + 0.5)
end

function LindenmayerPITVA:operation_assign(y, x)
    y = x
    return y
end

function LindenmayerPITVA:operation_add(y, x)
    y = y + x
    return y
end

function LindenmayerPITVA:operation_subtract(y, x)
    y = y - x
    return y
end

function LindenmayerPITVA:target_t(target, operation, operand)
    local function_ = self.operations[operation]
    self.turtle.t = function_(self, self.turtle.t, operand)
end

function LindenmayerPITVA:target_d(target, operation, operand)
    local function_ = self.operations[operation]
    self.turtle.d = function_(self, self.turtle.d, operand)
end

function LindenmayerPITVA:target_i(target, operation, operand)
    local function_ = self.operations[operation]
    self.turtle.i = function_(self, self.turtle.i, operand)
end

function LindenmayerPITVA:target_v(target, operation, operand)
    local function_ = self.operations[operation]
    self.turtle.v = function_(self, self.turtle.v, operand)
end

function LindenmayerPITVA:target_P(target, operation, operand)
    if type(operand) == 'string' then
        local p, i, t, v = self.chordSpaceGroup.fromChord(operand)
        self.turtle.P = p
    else
        local function_ = self.operations[operation]
        self.turtle.P = function_(self, self.turtle.P, operand) % self.chordSpaceGroup.countP
    end
end

function LindenmayerPITVA:target_I(target, operation, operand)
    if type(operand) == 'string' then
        local p, i, t, v = chordSpaceGroup.fromChord(operand)
        self.turtle.I = i
    else
        local function_ = self.operations[operation]
        self.turtle.I = function_(self, self.turtle.I, operand) % self.chordSpaceGroup.countI
    end
end

function LindenmayerPITVA:target_T(target, operation, operand)
    if type(operand) == 'string' then
        local p, i, t, v = chordSpaceGroup.fromChord(operand)
        self.turtle.T = t
    else
        local function_ = self.operations[operation]
        self.turtle.T = function_(self, self.turtle.T, operand) % self.chordSpaceGroup.countT
    end
end

function LindenmayerPITVA:target_V(target, operation, operand)
    if type(operand) == 'string' then
        local p, i, t, v = chordSpaceGroup.fromChord(operand)
        self.turtle.V = v
    else
        local function_ = self.operations[operation]
        self.turtle.V = function_(self, self.turtle.V, operand) % self.chordSpaceGroup.countV
    end
end

function LindenmayerPITVA:target_A(target, operation, operand)
    local function_ = self.operations[operation]
    self.turtle.A = function_(self, self.turtle.A, operand) % self.countA
end

function LindenmayerPITVA:target_C(target, operation, operand)
    if self.chord == nil then
        self.priorChord = self.chord
    end
    local p = math.floor(self.turtle.P + 0.5)
    local i = math.floor(self.turtle.I + 0.5)
    local t = math.floor(self.turtle.T + 0.5)
    local v = math.floor(self.turtle.V + 0.5)
    self.chord = self.chordSpaceGroup:toChord(p, i, t, v)
    for i = 1, #self.chord do
        self.chord.channel[i] = i - 1
    end
    self.chord:setDuration(self.turtle.d)
    self.chord:setVelocity(self.turtle.v)
    local oldsize = #self.score
    ChordSpace.insert(self.score, self.chord, self.turtle.t)
    local newsize = #self.score
    print(string.format('C: %s', self.chord:eOP():name()))
    for i = oldsize, newsize do
        print(tostring(self.score[i]))
    end

    self.turtle.t = self.turtle.t + self.turtle.d
end

function LindenmayerPITVA:target_L(target, operation, operand)
    if self.chord == nil then
        self.priorChord = self.chord
    end
    local p = math.floor(self.turtle.P + 0.5)
    local i = math.floor(self.turtle.I + 0.5)
    local t = math.floor(self.turtle.T + 0.5)
    local v = math.floor(self.turtle.V + 0.5)
    self.chord = self.chordSpaceGroup:toChord(p, i, t, v)
    if self.priorChord ~= nil then
        self.chord = ChordSpace.voiceleadingClosestRange(self.priorChord, self.chord, self.octaves * ChordSpace.OCTAVE, true)
    end
    for i = 1, #self.chord do
        self.chord.channel[i] = i - 1
    end
    self.chord:setDuration(self.turtle.d)
    self.chord:setVelocity(self.turtle.v)
    local oldsize = #self.score
    ChordSpace.insert(self.score, self.chord, self.turtle.t)
    local newsize = #self.score
    for i = oldsize, newsize do
        print(tostring(self.score[i]))
    end
    print(string.format('L: %s', self.chord:eOP():name()))
    self.turtle.t = self.turtle.t + self.turtle.d
end

function LindenmayerPITVA:target_N(target, operation, operand)
    if self.chord == nil then
        self.priorChord = self.chord
    end
    local p = math.floor(self.turtle.P + 0.5)
    local i = math.floor(self.turtle.I + 0.5)
    local t = math.floor(self.turtle.T + 0.5)
    local v = math.floor(self.turtle.V + 0.5)
    self.chord = self.chordSpaceGroup:toChord(p, i, t, v)
    local voice = (self.turtle.A % self.chordSpaceGroup.voices) + 1
    --print('voice:', voice)
    local octave = math.floor(self.turtle.A / self.chordSpaceGroup.voices)
    --print('octave:', octave)
    local key = self.chord[voice] + (octave * ChordSpace.OCTAVE)
    local note = Event:new{self.turtle.t, self.turtle.d, 144, self.turtle.i, key, self.turtle.v, 0, 0, 0, 0, 1}
    self.score:append(note)
    print(string.format('N:\n%s', tostring(self.score[#self.score])))
    self.turtle.t = self.turtle.t + self.turtle.d
end

function LindenmayerPITVA:target_push(target, operation, operand)
    table.insert(self.stack, Silencio.clone(self.turtle))
end

function LindenmayerPITVA:target_pop(target, operation, operand)
    self.turtle = table.remove(self.stack)
end

-- Beginning with the axiom,
-- the current production is created by replacing each word
-- in the prior production either with itself, or with its replacement
-- from the dictionary of rules.

function LindenmayerPITVA:produce()
    print('LindenmayerPITVA:produce...')
    print('axiom:', self.axiom)
    for iteration = 1, self.iterations do
        print(string.format('Iteration: %4d', iteration))
        if iteration == 1 then
            self.priorProduction = self.axiom
        else
            self.priorProduction = self.currentProduction
        end
        self.currentProduction = {}
        local words = Silencio.split(self.priorProduction, ' ')
        for index, word in pairs(words) do
            local replacement = self.rules[word]
            if replacement == nil then
                table.insert(self.currentProduction, word)
            else
                table.insert(self.currentProduction, replacement)
            end
        end
        self.currentProduction = table.concat(self.currentProduction, ' ')
    end
end

function LindenmayerPITVA:parseCommand(command)
    local target = string.sub(command, 1, 1)
    if target == '[' or target == ']' or target == 'C' or target == 'L' or target == 'N' then
        return target, nil, nil
    end
    return target, string.sub(command, 2, 2), string.sub(command, 3, -1)
end

function LindenmayerPITVA:interpret()
    print('LindenmayerPITVA:interpret...')
    local commands = Silencio.split(self.currentProduction, ' ')
    for index, command in ipairs(commands) do
        target, opcode, operand = self:parseCommand(command)
        local function_ = self.targets[target]
        if function_ ~= nil then
            local value = nil
            if operand ~= nil then
                value = tonumber(operand)
                if value == nil then
                    value = operand
                end
            end
            function_(self, target, opcode, value)
            --print(self.turtle)
        end
    end
end

function LindenmayerPITVA:generate()
    print('LindenmayerPITVA:generate...')
    self:produce()
    self:interpret()
    local bass, range = self.score:findScale(KEY)
    self.score:setScale(KEY, self.bass, range)
    if self.tieOverlaps == true then
        print('LindenmayerPITVA:tieing notes...')
        self.score:tieOverlaps(true)
    end
    self.score:setDuration(self.duration)
end

if false then
    lindenmayer = LindenmayerPITVA:new()
    score = lindenmayer.score
    lindenmayer:initialize(5, 48, 1)
    --lindenmayer.chordSpaceGroup:printChords()
    lindenmayer.axiom = 'P=8 v=25 V=88 d=1 I+1 T+5 A+4 a '
    lindenmayer.rules['a'] = 'a C B B L L a C L C C L v+4 C a C v-4 C I+1 L V+1 C V-12 L C C L T+2 V-1 C C L I=0 P=71 L L T-7 B B C L L L L I+1 '
    --lindenmayer.rules['C'] = 'C d+.25 B d-.25 '
    lindenmayer.rules['B'] = '[ t+2 A+6 N N N N B B ] N N A+1 N N A+2 N N A+1 N N A+2 B B '

    lindenmayer.axiom = 'P=8 v=40 V=88 d=1 I+1 T+5 A+4 a '
    lindenmayer.rules['a'] = 'a  B B   a      v+4  a  v-4  I+1  C V+1  C V-12     T+2 V-1    I=0 P=71   T-7 B B   L L   I+1 '
    --lindenmayer.rules['C'] = ' d+.25 B d-.25 '
    lindenmayer.rules['B'] = '[ t+2 A+6 N N N N B B ] N N A+1 N N A+2 N N A+1 N N A+2 B B '

    lindenmayer.iterations = 3
    lindenmayer.duration = 300
    lindenmayer:generate()
    print("Generated score:")
    lindenmayer.score:print()
    lindenmayer.score:setArtist('Michael_Gogins')
    lindenmayer.score:setCopyright('Copr_2010_Michael_Gogins')
    lindenmayer.score:setAlbum('Silencio')
    lindenmayer.score:setMidiPatches({{'patch_change', 1, 0,16},{'patch_change', 1, 1,1}, {'patch_change', 1, 2,1} })
    lindenmayer.score:setFomusParts({'Cembalom', 'Gong', 'Fife'})
    start, scoretime = lindenmayer.score:findScale(TIME)
    print('start:', start, 'scoretime:', scoretime)
    score:renderMidi()
    score:playPianoteq()
end

return LindenmayerPITVA
