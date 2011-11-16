local Silencio = require("Silencio")
local ChordSpace = require("ChordSpace")

LindenmayerPITV = {}

function Lindenmayer.help()
print [[
L I N D E N M A Y E R   P I T V

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms
of the GNU Lesser General Public License.

The LindenmayerPITV class implements a context-free Lindenmayer system that
performs operations on four additive cyclical groups P, I, T, and V that
represent respectively set-class, inversion, transposition, and octavewise
revoicing of chords. Chord duration (d) and dynamic level or MIDI velocity
(v) also are represented.

An earlier version of this class was found too complex for use. This version
is intended to expose the basic symmetries of chord space to manipulation
as clearly and simply as possible.

The turtle state consists of six numbers P, I, T, V, d, and v. These are the
targets of operations. Time is defined implicity; when the Lindenmayer
system is evaluated, the time is accmulated from the sequence of chords
and their durations.

All turtle commands are of the form: target:operation:operand

Operations are arithmetical +, -, *, / and assignment =.

Operands are signed real numbers. The results of operations on P, I, T, and V
wrap around their equivalence class. The results of operations on d and v
do not wrap around and may need to be rescaled to be musically meaningful.

The syntax of turtle commands (target:operation:operand) is:

P:o:n       Operate on the zero-based index of set-class (prime form).
P:=:name    Assign the set-class index from a Jazz-style chord name. This may
            involve replacing the chord with its equivalent under
            transpositional and/or inversional equivalence.
I:o:n       Operate on the zero-based index of inversional equivalence, where
            inversion is reflection in chord {n,..n} on the unison diagonal.
T:o:n       Operate on the zero-based index of transposition within octave
            equivalence.
V:o:n       Operate on the zero-based index of octavewise revoicings within
            the permitted range of pitches.
d:o:n       Operate on the duration of the chord.
v:o:n       Operate on the loudness of the chord (represented as MIDI velocity
            in the interval [0, 127].
C           Write the current turtle state into the score as a chord.
L           Write the current turtle state into the score as a chord; or
            rather, use a geometric voice-leading algorithm to find the PITV
            that has the PIT of the current chord as is as close as possible
            to the PITV of the prior chord.
[           Push the current state of the turtle onto the top of a stack.
]           Pop the current state of the turtle off the top of the stack.
]]
end

Turtle = {}

function Turtle:new(o)
    o = o or {modality = Chord:new(), chord = Chord:new(), voicing = 0, arpeggiation = 0, onset = 1, channel = 1, pan = 1, octaves = 3, intervalSize = 1}
    o.range = o.octaves * ChordSpace.OCTAVE
    setmetatable(o, self)
    self.__index = self
    return o
end

function Turtle:__tostring()
    local text = string.format('C: %s  M: %s  voicing: %f  arpeggiation: %f  onset: %f  channel: %f  loudness: %f  pan: %f',
    tostring(self.chord),
    tostring(self.modality),
    self.voicing,
    self.arpeggiation,
    self.onset,
    self.chord:getChannel() or -1,
    self.chord:getVelocity() or -1,
    self.chord:getPan() or -1)
    return text
end

function Lindenmayer:new(o)
    if not o then
        o = {}
        o.score = Score:new()
        o.axiom = ''
        o.rules = {}
        o.turtle = Turtle:new()
        o.priorTurtle = self.turtle
        o.stack = {}
        o.iterations = 3
        o.merge = true
        o.tieOverlaps = true
        o.avoidParallelFifths = false
        o.rescaleTimes = false
        o.currentProduction = ''
        o.priorProduction = ''
        o.octaves = 3
        o.actions = {}
        o.actions['['] = self.actionPush
        o.actions[']'] = self.actionPop
        o.actions['W'] = self.actionWrite
        o.actions['V'] = self.actionWriteVoiceleading
        o.actions['T'] = self.actionTranspose
        o.actions['I'] = self.actionInvert
        o.actions['K'] = self.actionContexualInversion
        o.actions['Q'] = self.actionContextualTransposition
        o.actions['='] = self.actionAssign
        o.actions['*'] = self.actionMultiply
        o.actions['/'] = self.actionDivide
        o.actions['+'] = self.actionAdd
        o.actions['-'] = self.actionSubtract
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

function Lindenmayer:equivalenceClass(chord, equivalence)
    if equivalence == 'R' then
        return chord:eR(self.octaves * OCTAVE)
    end
    if equivalence == 'O' then
        return chord:eO()
    end
    if equivalence == 'P' then
        return chord:eP()
    end
    if equivalence == 'T' then
        return chord:eT()
    end
    if equivalence == 'I' then
        return chord:eI()
    end
    if equivalence == 'RP' then
        return chord:eRP(self.octaves * ChordSpace.OCTAVE)
    end
    if equivalence == 'OP' then
        return chord:eOP()
    end
    if equivalence == 'OT' then
        return chord:eOT()
    end
    if equivalence == 'OI' then
        return chord:eOI()
    end
    if equivalence == 'OPT' then
        return chord:eOPTT()
    end
    if equivalence == 'OPI' then
        return chord:eOPI()
    end
    if equivalence == 'OPTI' then
        return chord:eOPTTI()
    end
end

function Lindenmayer:E(target, opcode, equivalence, operand, index)
    if target == 'C' or target == 'I' then
        self.turtle.chord = self:equivalenceClass(self.turtle.chord, equivalence)
    end
    if target == 'M' then
        self.turtle.modality = self:equivalenceClass(self.turtle.modality, equivalence)
    end
end

function Lindenmayer:actionPush(target, opcode, equivalence, operand, index)
    table.insert(self.stack, Silencio.clone(self.turtle))
end

function Lindenmayer:actionPop(target, opcode, equivalence, operand, index)
    self.turtle = table.remove(self.stack)
end

function Lindenmayer:actionParallel(target, opcode, equivalence, operand, index)
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:nrP()
    end
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:nrP()
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionLettonwechsel(target, opcode, equivalence, operand, index)
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:nrL()
    end
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:nrL()
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionRelative(target, opcode, equivalence, operand, index)
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:nrR()
    end
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:nrR()
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionDominant(target, opcode, equivalence, operand, index)
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:nrD()
    end
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:nrD()
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionWrite(target, opcode, equivalence, operand, index)
    local chord = self.turtle.chord:clone()
    print('C Pre: ', chord, self.turtle.voicing)
    chord = chord:v(self.turtle.voicing)
    if target == 'C' then
        chord = self:equivalenceClass(chord, 'RP')
        self.turtle.onset = self.turtle.onset + self.turtle.chord:getDuration()
        ChordSpace.insert(self.score, chord, self.turtle.onset, self.turtle.chord:getDuration() + 0.001, self.turtle.channel, self.turtle.pan)
    end
    if target == 'I' then
        chord = self:equivalenceClass(chord, 'RPI')
        self.turtle.onset = self.turtle.onset + self.turtle.chord:getDuration()
        ChordSpace.insert(self.score, chord, self.turtle.onset, self.turtle.chord:getDuration() + 0.001, self.turtle.channel, self.turtle.pan)
    end
    if target == 'A' then
        local p, v
        p, v, chord = chord:a(self.turtle.arpeggiation)
        self.turtle.onset = self.turtle.onset + self.turtle.chord:getDuration(v)
        chord = self:equivalenceClass(chord, 'RP')
        local note = chord:note(v, self.turtle.onset, self.turtle.duration, self.turtle.channel, self.turtle.pan)
        self.score[#self.score + 1] = note
    end
    print('C Post:', chord)
    print()
    self.priorChord = chord
end

function Lindenmayer:actionWriteVoiceleading(target, opcode, equivalence, operand, index)
    if self.priorChord == nil then
        return self:actionWrite(target, opcode, equivalence, operand, index)
    end
    local chord = self.turtle.chord:clone()
    print('V Pre: ', chord, self.turtle.voicing)
    chord = ChordSpace.voiceleadingClosestRange(self.priorChord, chord, self.octaves * ChordSpace.OCTAVE, true)
    if target == 'C' then
        chord = self:equivalenceClass(chord, 'RP')
        self.turtle.onset = self.turtle.onset + self.turtle.chord:getDuration()
        ChordSpace.insert(self.score, chord, self.turtle.onset, self.turtle.chord:getDuration() + 0.001, self.turtle.channel, self.turtle.pan)
    end
    if target == 'I' then
        chord = self:equivalenceClass(chord, 'RPI')
        self.turtle.onset = self.turtle.onset + self.turtle.chord:getDuration()
        ChordSpace.insert(self.score, chord, self.turtle.onset, self.turtle.chord:getDuration() + 0.001, self.turtle.channel, self.turtle.pan)
    end
    if target == 'A' then
        local p, v
        p, v, chord = chord:a(self.turtle.arpeggiation)
        self.turtle.onset = self.turtle.onset + self.turtle.chord:getDuration(v)
        chord = self:equivalenceClass(chord, 'RP')
        local note = chord:note(v, self.turtle.onset, self.turtle.duration, self.turtle.channel, self.turtle.pan)
        self.score[#self.score + 1] = note
    end
    print('V Post:', chord)
    print()
    self.priorChord = chord
end

function Lindenmayer:actionTranspose(target, opcode, equivalence, operand, index)
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:T(operand)
    end
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:T(operand)
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionInvert(target, opcode, equivalence, operand, index)
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:I(operand)
    end
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:I(operand)
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionContexualInversion(target, opcode, equivalence, operand, index)
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:K()
    end
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:K()
    end
    self:E(target, opcode, equivalence, operand, index)
end

function Lindenmayer:actionContextualTransposition(target, opcode, equivalence, operand, index)
    if target == 'M' then
        self.turtle.modality = self.turtle.modality:Q(operand, self.turtle.modality, self.intervalSize)
    end
    if target == 'C' then
        self.turtle.chord = self.turtle.chord:Q(operand, self.turtle.modality, self.intervalSize)
    end
    self:E(target, opcode, equivalence, operand, index)
end

-- dckvp    :=*/+-     :            :x       :i
-- VAGtdcvp :=*/+-     :            :x

function Lindenmayer:actionAssign(target, opcode, equivalence, operand, index, stringOperand)
    if index ~= nil then
        if target == 'd' then
            self.turtle.chord.duration[index] = operand
        end
        if target == 'c' then
            self.turtle.chord.channel[index] = operand
        end
        if target == 'k' then
            self.turtle.chord[index] = operand
        end
        if target == 'v' then
            self.turtle.chord.velocity[index] = operand
        end
        if target == 'p' then
            self.turtle.chord.pan[index] = operand
        end
    else
        if target == 'C' then
            self.turtle.chord = ChordSpace.chordsForNames[stringOperand]
        end
        if target == 'M' then
            self.turtle.modality = ChordSpace.chordsForNames[stringOperand]
        end
        if target == 'V' then
            self.turtle.voicing = operand
        end
        if target == 'A' then
            self.turtle.arpeggiation = operand
        end
        if target == 'G' then
            self.turtle.intervalSize = operand
        end
        if target == 't' then
            self.turtle.onset = operand
        end
        if target == 'd' then
            self.turtle.chord:setDuration(operand)
        end
        if target == 'c' then
            self.turtle.chord:setChannel(operand)
        end
        if target == 'v' then
            self.turtle.chord:setVelocity(operand)
        end
        if target == 'p' then
            self.turtle.chord:setPan(operand)
        end
    end
end

-- dckvp    :=*/+-     :            :x       :i
-- VAGtdcvp :=*/+-     :            :x

function Lindenmayer:actionMultiply(target, opcode, equivalence, operand, index)
    if index ~= nil then
        if target == 'd' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] * operand
        end
        if target == 'c' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] * operand
        end
        if target == 'k' then
            self.turtle.chord[index] = self.turtle.chord[index] * operand
        end
        if target == 'v' then
            self.turtle.chord.velocity[index] = self.turtle.chord.velocity[index] * operand
        end
        if target == 'p' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] * operand
        end
    else
        if target == 'V' then
            self.turtle.voicing = self.turtle.voicing * operand
        end
        if target == 'A' then
            self.turtle.arpeggiation = self.turtle.arpeggiation * operand
        end
        if target == 'T' then
            self.turtle.onset = self.turtle.onset * operand
        end
        if target == 'G' then
            self.turtle.intervalSize = self.turtle.intervalSize * operand
        end
        if target == 'd' then
            self.turtle.chord:setDuration(self.turtle.chord:getDuration() * operand)
        end
        if target == 'c' then
            self.turtle.chord:setChannel(self.turtle.chord:getChannel() * operand)
        end
        if target == 'v' then
            self.turtle.chord:setVelocity(self.turtle.chord:getVelocity() * operand)
        end
        if target == 'p' then
            self.turtle.chord:setPan(self.turtle.chord:getPan() * operand)
        end
    end
end

function Lindenmayer:actionDivide(target, opcode, equivalence, operand, index)
    if index ~= nil then
        if target == 'd' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] / operand
        end
        if target == 'c' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] / operand
        end
        if target == 'k' then
            self.turtle.chord[index] = self.turtle.chord[index] / operand
        end
        if target == 'v' then
            self.turtle.chord.velocity[index] = self.turtle.chord.velocity[index] / operand
        end
        if target == 'p' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] / operand
        end
    else
        if target == 'V' then
            self.turtle.voicing = self.turtle.voicing / operand
        end
        if target == 'A' then
            self.turtle.arpeggiation = self.turtle.arpeggiation / operand
        end
        if target == 'T' then
            self.turtle.onset = self.turtle.onset / operand
        end
        if target == 'G' then
            self.turtle.intervalSize = self.turtle.intervalSize / operand
        end
        if target == 'd' then
            self.turtle.chord:setDuration(self.turtle.chord:getDuration() / operand)
        end
        if target == 'c' then
            self.turtle.chord:setChannel(self.turtle.chord:getChannel() / operand)
        end
        if target == 'v' then
            self.turtle.chord:setVelocity(self.turtle.chord:getVelocity() / operand)
        end
        if target == 'p' then
            self.turtle.chord:setPan(self.turtle.chord:getPan() / operand)
        end
    end
end

function Lindenmayer:actionAdd(target, opcode, equivalence, operand, index)
    if index ~= nil then
        if target == 'd' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] + operand
        end
        if target == 'c' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] + operand
        end
        if target == 'k' then
            self.turtle.chord[index] = self.turtle.chord[index] + operand
        end
        if target == 'v' then
            self.turtle.chord.velocity[index] = self.turtle.chord.velocity[index] + operand
        end
        if target == 'p' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] + operand
        end
    else
        if target == 'V' then
            self.turtle.voicing = self.turtle.voicing + operand
        end
        if target == 'A' then
            self.turtle.arpeggiation = self.turtle.arpeggiation + operand
        end
        if target == 'T' then
            self.turtle.onset = self.turtle.onset + operand
        end
        if target == 'G' then
            self.turtle.intervalSize = self.turtle.intervalSize + operand
        end
        if target == 'd' then
            self.turtle.chord:setDuration(self.turtle.chord:getDuration() + operand)
        end
        if target == 'c' then
            self.turtle.chord:setChannel(self.turtle.chord:getChannel() + operand)
        end
        if target == 'v' then
            self.turtle.chord:setVelocity(self.turtle.chord:getVelocity() + operand)
        end
        if target == 'p' then
            self.turtle.chord:setPan(self.turtle.chord:getPan() + operand)
        end
    end
end

function Lindenmayer:actionSubtract(target, opcode, equivalence, operand, index)
    if index ~= nil then
        if target == 'd' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] - operand
        end
        if target == 'c' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] - operand
        end
        if target == 'k' then
            self.turtle.chord[index] = self.turtle.chord[index] - operand
        end
        if target == 'v' then
            self.turtle.chord.velocity[index] = self.turtle.chord.velocity[index] - operand
        end
        if target == 'p' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] - operand
        end
    else
        if target == 'V' then
            self.turtle.voicing = self.turtle.voicing - operand
        end
        if target == 'A' then
            self.turtle.arpeggiation = self.turtle.arpeggiation - operand
        end
        if target == 'T' then
            self.turtle.onset = self.turtle.onset - operand
        end
        if target == 'G' then
            self.turtle.intervalSize = self.turtle.intervalSize - operand
        end
        if target == 'd' then
            self.turtle.chord:setDuration(self.turtle.chord:getDuration() - operand)
        end
        if target == 'c' then
            self.turtle.chord:setChannel(self.turtle.chord:getChannel() - operand)
        end
        if target == 'v' then
            self.turtle.chord:setVelocity(self.turtle.chord:getVelocity() - operand)
        end
        if target == 'p' then
            self.turtle.chord:setPan(self.turtle.chord:getPan() - operand)
        end
    end
end

-- Beginning with the axiom,
-- the current production is created by replacing each word
-- in the prior production either with itself, or with its replacement
-- from the dictionary of rules.

function Lindenmayer:produce()
    print('Lindenmayer:produce...')
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
        -- print(self.currentProduction)
    end
end

function Lindenmayer:parseCommand(command)
    local parts = Silencio.split(command, ':')
    local target = parts[1]
    local opcode = parts[2]
    local equivalence = parts[3]
    local operand = tonumber(parts[4])
    local stringOperand = parts[4]
    local index = tonumber(parts[5])
    return target, opcode, equivalence, operand, index, stringOperand
end


function Lindenmayer:interpret()
    print('Lindenmayer:interpret...')
    local commands = Silencio.split(self.currentProduction, ' ')
    for index, command in ipairs(commands) do
        target, opcode, equivalence, operand, index, stringOperand = self:parseCommand(command)
        local action = self.actions[opcode]
        if action ~= nil then
            -- print(target, opcode, equivalence, operand, index, stringOperand)
            action(self, target, opcode, equivalence, operand, index, stringOperand)
        end
    end
end

function Lindenmayer:generate()
    print('Lindenmayer:generate...')
    self:produce()
    self:interpret()
    if self.tieOverlaps == true then
        print('Lindenmayer: tieing notes...')
        self.score:tieOverlaps(true)
    end
end
