local Silencio = require("Silencio")
local Som = require("Som")

--[[
The Lindenmayer class implements a context-free Lindenmayer system that 
performs operations on chords, voicings of chords, arpeggiations of chords,
and individual voices of chors.
]]

Turtle = {}

function Turtle:new(o)
    o = o or {modality = Chord:new(), chord = Chord:new(), voicing = 0, arpeggiation = 0, onset = 1, channel = 1, pan = 1, octaves = 3, intervalSize = 1}
    setmetatable(o, self)
    self.__index = self
    return o
end

Lindenmayer = ScoreSource:new()

function Lindenmayer:new()
    if not o then
        o = ScoreSource:new()
        self.axiom = ''
        self.rules = {}
        self.turtle = Turtle:new()
        self.priorTurtle = self.turtle
        self.stack = {}
        self.iterations = 3
        self.merge = true
        self.tie = true
        self.avoidParallelFifths = false
        self.rescaleTimes = false
        self.currentProduction = ''
        self.priorProduction = ''
        self.actions = {}
        self.actions['['] = self.actionPush
        self.actions[']'] = self.actionPop
        self.actions['P'] = self.actionParallel
        self.actions['L'] = self.actionLettonwechsel
        self.actions['R'] = self.actionRelative
        self.actions['D'] = self.actionDominant
        self.actions['W'] = self.actionWrite
        self.actions['L'] = self.actionWriteVoiceleading
        self.actions['T'] = self.actionTranspose
        self.actions['I'] = self.actionInvert
        self.actions['K'] = self.actionContexualInversion
        self.actions['Q'] = self.actionContextualTransposition
        self.actions['='] = self.actionAssign
        self.actions['*'] = self.actionMultiply
        self.actions['/'] = self.actionDivide
        self.actions['+'] = self.actionAdd
        self.actions['-'] = self.actionSubtract
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
        return chord:eRP(self.octaves * OCTAVE)
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
        return chord:eOPT()
    end
    if equivalence == 'OPI' then
        return chord:eOPI()
    end
    if equivalence == 'OPTI' then
        return chord:eOPTI()
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
    if target == 'M' then
    end
    if target == 'I' then
    end
end

function Lindenmayer:actionWriteVoiceleading(target, opcode, equivalence, operand, index)
    if target == 'M' then
    end
    if target == 'I' then
    end
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

function Lindenmayer:actionAssign(target, opcode, equivalence, operand, index)
    if index ~= nil then
        -- DCPI    :=*/+-     :            :x       :i
        if target == 'D' then
            self.turtle.chord.duration[index] = operand
        end
        if target == 'C' then
            self.turtle.chord.channel[index] = operand
        end
        if target == 'P' then
            self.turtle.chord.pan[index] = operand
        end
        if target == 'I' then
            self.turtle.chord[index] = operand
        end
    else        
        -- DCPVATG :=*/+-     :            :x
        if target == 'D' then
            self.turtle.chord.setDuration(operand)
        end
        if target == 'C' then
            self.turtle.chord.setChannel(operand)
        end
        if target == 'P' then
            self.turtle.chord.setPan(operand)
        end
        if target == 'V' then
            self.turtle.voicing = operand
        end
        if target == 'A' then
            self.turtle.arpeggiation = operand
        end
        if target == 'T' then
            self.turtle.onset = operand
        end
        if target == 'G' then
            self.turtle.intervalSize = operand
        end
    end
end

function Lindenmayer:actionMultiply(target, opcode, equivalence, operand, index)
    if index ~= nil then
        -- DCPI    :=*/+-     :            :x       :i
        if target == 'D' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] * operand
        end
        if target == 'C' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] * operand
        end
        if target == 'P' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] * operand
        end
        if target == 'I' then
            self.turtle.chord[index] = self.turtle.chord[index] * operand
        end
    else        
        -- DCPVATG :=*/+-     :            :x
        if target == 'D' then
            self.turtle.chord.setDuration(self.turtle.chord.getDuration() * operand)
        end
        if target == 'C' then
            self.turtle.chord.setChannel(self.turtle.chord.getChannel() * operand)
        end
        if target == 'P' then
            self.turtle.chord.setPan(self.turtle.chord.getPan() * operand)
        end
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
    end
end

function Lindenmayer:actionDivide(target, opcode, equivalence, operand, index)
    if index ~= nil then
        -- DCPI    :=*/+-     :            :x       :i
        if target == 'D' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] / operand
        end
        if target == 'C' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] / operand
        end
        if target == 'P' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] / operand
        end
        if target == 'I' then
            self.turtle.chord[index] = self.turtle.chord[index] / operand
        end
    else        
        -- DCPVATG :=*/+-     :            :x
        if target == 'D' then
            self.turtle.chord.setDuration(self.turtle.chord.getDuration() / operand)
        end
        if target == 'C' then
            self.turtle.chord.setChannel(self.turtle.chord.getChannel() / operand)
        end
        if target == 'P' then
            self.turtle.chord.setPan(self.turtle.chord.getPan() / operand)
        end
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
    end
end

function Lindenmayer:actionAdd(target, opcode, equivalence, operand, index)
    if index ~= nil then
        -- DCPI    :=*/+-     :            :x       :i
        if target == 'D' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] + operand
        end
        if target == 'C' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] + operand
        end
        if target == 'P' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] + operand
        end
        if target == 'I' then
            self.turtle.chord[index] = self.turtle.chord[index] + operand
        end
    else        
        -- DCPVATG :=*/+-     :            :x
        if target == 'D' then
            self.turtle.chord.setDuration(self.turtle.chord.getDuration() + operand)
        end
        if target == 'C' then
            self.turtle.chord.setChannel(self.turtle.chord.getChannel() + operand)
        end
        if target == 'P' then
            self.turtle.chord.setPan(self.turtle.chord.getPan() + operand)
        end
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
    end
end

function Lindenmayer:actionSubtract(target, opcode, equivalence, operand, index)
    if index ~= nil then
        -- DCPI    :=*/+-     :            :x       :i
        if target == 'D' then
            self.turtle.chord.duration[index] = self.turtle.chord.duration[index] - operand
        end
        if target == 'C' then
            self.turtle.chord.channel[index] = self.turtle.chord.channel[index] - operand
        end
        if target == 'P' then
            self.turtle.chord.pan[index] = self.turtle.chord.pan[index] - operand
        end
        if target == 'I' then
            self.turtle.chord[index] = self.turtle.chord[index] - operand
        end
    else        
        -- DCPVATG :=*/+-     :            :x
        if target == 'D' then
            self.turtle.chord.setDuration(self.turtle.chord.getDuration() - operand)
        end
        if target == 'C' then
            self.turtle.chord.setChannel(self.turtle.chord.getChannel() - operand)
        end
        if target == 'P' then
            self.turtle.chord.setPan(self.turtle.chord.getPan() - operand)
        end
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
    end
end

-- Beginning with the axiom,
-- the current production is created by replacing each word
-- in the prior production either with itself, or with its replacement
-- from the dictionary of rules.

function Lindenmayer:produce()
    for iteration = 1, self.iterations do
        if iteration == 1 then
            self.priorProduction = axiom
        else
            self.priorProduction = self.currentProduction
        end
        self.currentProduction = {}
        local words = Silencio.split(self.priorProduction, ' ')
        for index, word in ipairs(words) do
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

--[[
The turtle commands have the following effective combinations of parts
(a colon without a part is permitted if the part is not used,
but the colons are always required except for trailing colons;
equivalence classes may be combined but only the order given):

target  :operation :equivalence :operand :index
S       :[]
MC      :PLRDKWL   :~ORPTI
MC      :TIQ       :~ORPTI      :x
I       :WL        :~ORPTI:     :        :i
DCPVATG :=*/+-     :            :x
DCPI    :=*/+-     :            :x       :i
]]

function Lindenmayer:parseCommand(command)
    local parts = Silencio.split(command, ':')
    local target = parts[1]
    local opcode = parts[2]
    local equivalence = parts[3]
    local operand = parts[4]
    local index = parts[5]
    return target, opcode, equivalence, operand, index
end

--[[
T   Targets:
    S   Entire turtle state.
    M   Modality.
    C   Chord.
    V   Voicing of chord.
    A   Arpeggiation of chord.
    T   Time.
    D   Duration.
    C   Channel.
    P   Pan.
    I   Individual voice.
    G   Interval size (1 = 12TET).
O   Operations:
    [   Push state onto stack.
    ]   Pop state from stack.
    P   Parallel Riemannian operation on chord (only guaranteed for major/minor triads).
    L   Lettonwechsel or leading-tone exchange Riemannian operation (only guaranteed for major/minor triads).
    R   Relative Riemannian operation (only guaranteed for major/minor triads).
    D   Dominant Riemannian operation.
    W   Write target C or I to score.
    L   Write target C or I that is the closest voice-leading from the prior state of the target.
    T   Transpose by operand semitones.
    I   Invert around operand semitones.
    K   Invert in context of modality.
    Q   Transpose in context of modality.
    =   Assign operand.
    *   Multiply by operand.
    /   Divide by operand.
    +   Add operand.
    -   Subtract operand.
E   Equivalence class:
    ~   No equivalence class (same as blank).
    O   Order.
    R   Range.
    P   Octave (pitch-class).
    T   Transposition.
    I   Inversion.
]]

function Lindenmayer:interpret()
    local commands = Silencio.split(self.currentProduction, ' ')
    for index, command in ipairs(commands) do
        target, opcode, equivalence, index, operand = self:parseCommand(command)
        local action = self.actions[opcode]
        if action ~= nil then
            action(self, target, opcode, equivalence, index, operand)
        end
    end
end

function Lindenmayer:write()
end

function Lindenmayer:generate()
    print('Lindenmayer: producing...')
    self:produce()
    print('Lindenmayer: interpreting...')
    self:interpret()
    print('Lindenmayer: writing...')    
    self:write()
end

testing = true
if testing then
    local a = Silencio.split('I:WL:~ORPTI::i', ':')
    local a = Silencio.split('VATDCPI:=*/+-::i:x', ':')
    local a = Silencio.split('V:+:OPT::3.5', ':')
    for k, v in pairs(a) do
        print(k, v)
    end
    print(a[2])
    lindenmayer = Lindenmayer:new()
    print(lindenmayer)
end
