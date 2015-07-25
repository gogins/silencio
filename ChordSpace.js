/**
C H O R D S P A C E

Copyright (C) 2014 by Michael Gogins

This software is licensed under the terms of the 
GNU Lesser General Public License

Algorithmic music composition library in JavaScript for Csound.

DEVELOPMENT LOG

2015-07-15

Silencio.js was relatively easy, ChordSpace.js is going to be harder. The main 
problems are that JavaScript does not permit operator overloading, and it does 
not implement deep clones or deep value comparisons out of the box.

 I will omit the chord space group stuff because I have not been using it and 
it would be less efficient in JavaScript, plus I can do more or less 
everything it can do just by applying the transformations.

It is now clear that Lua (and especially LuaJIT) is a rather superior language 
but JavaScript should provide everything that I need.
*/

(function() {
    
// All JavaScript dependencies of ChordSpace.js:
// var Silencio = require("Silencio");
// var sprintf = require("sprintf");

var ChordSpace = {};

ChordSpace.print = function(text) {
    console.log(text);
};

ChordSpace.EPSILON = 1;
ChordSpace.epsilonFactor = 1000;

while (true) {
    ChordSpace.EPSILON = ChordSpace.EPSILON / 2;
    var nextEpsilon = ChordSpace.EPSILON / 2;
    var onePlusNextEpsilon = 1 + nextEpsilon;
    if (onePlusNextEpsilon == 1) {
        print('ChordSpace EPSILON: ' + ChordSpace.EPSILON);
        break;
    };
};

ChordSpace.help = function() {
  text = `

C H O R D S P A C E

Copyright 2010, 2011 by Michael Gogins.

This software is licensed under the terms of the GNU Lesser General Public
License.

This package, part of Silencio, implements a geometric approach to some common
operations on chords in neo-Riemannian music theory for use in score
generating procedures:

--  Identifying whether a chord belongs to some equivalence class of music
    theory, or sending a chord to its equivalent within a representative
    fundamental domain of some equivalence class. The equivalence classes are
    octave (O), permutational (P), transpositional, (T), inversional (I), and
    their compounds OP, OPT (set-class or chord type), and OPTI (prime form).

--  Causing chord progressions to move strictly within an orbifold that
    generates some equivalence class.

--  Implementing chord progressions based on the L, P, R, D, K, Q, and J
    operations of neo-Riemannian theory (thus implementing some aspects of
    "harmony").

--  Implementing chord progressions performed within a more abstract
    equivalence class by means of the best-formed voice-leading within a less
    abstract equivalence class (thus implementing some fundamentals of
    "counterpoint").

DEFINITIONS

Pitch is the perception of a distinct sound frequency. It is a logarithmic
perception; octaves, which sound 'equivalent' in some sense, represent
doublings or halvings of frequency.

Pitches and intervals are represented as real numbers. Middle C is 60 and the
octave is 12. Our usual system of 12-tone equal temperament, as well as MIDI
key numbers, are completely represented by the whole numbers; any and all
other pitches can be represented simply by using fractions.

A voice is a distinct sound that is heard as having a pitch.

A chord is simply a set of voices heard at the same time, represented here
as a point in a chord space having one dimension of pitch for each voice
in the chord.

For the purposes of algorithmic composition in Silencio, a score is considered
to be a sequence of more or less fleeting chords.

EQUIVALENCE CLASSES

An equivalence class identifies elements of a set. Operations that send one
equivalent point to another induce quotient spaces or orbifolds, where the
equivalence operation identifies points on one face of the orbifold with
points on an opposing face. The fundamental domain of the equivalence class
is the space "within" the orbifold.

Plain chord space has no equivalence classes. Ordered chords are represented
as vectors in parentheses (p1, ..., pN). Unordered chords are represented as
sorted vectors in braces {p1, ..., pN}. Unordering is itself an equivalence
class (P).

The following equivalence classes apply to pitches and chords, and exist in
different orbifolds. Equivalence classes can be combined (Callendar, Quinn,
and Tymoczko, "Generalized Voice-Leading Spaces," _Science_ 320, 2008), and
the more equivalence classes are combined, the more abstract is the resulting
orbifold compared to the parent space.

In most cases, a chord space can be divided into a number, possibly
infinite, of geometrically equivalent fundamental domains for the same
equivalence class. Therefore, here we use the notion of 'representative'
fundamental domain. For example, the representative fundamental domain of
unordered sequences, out of all possible orderings, consists of all sequences
in their ordinary sorted order. It is important, in the following, to identify
representative fundamental domains that combine properly, e.g. such that the
representative fundamental domain of OP / the representative fundamental
domain of PI equals the representative fundamental domain of OPI. And this in
turn may require accounting for duplicate elements of the representative
fundamental domain caused by reflections or singularities in the orbifold.

C       Cardinality equivalence, e.g. {1, 1, 2} == {1, 2}. _Not_ assuming
        cardinality equivalence ensures that there is a proto-metric in plain
        chord space that is inherited by all child chord spaces. Cardinality
        equivalence is never assumed here, because we are working in chord
        spaces of fixed dimensionality; e.g. we represent the note middle C
        not as {60}, but as {60, 60, ..., 60}.

O       Octave equivalence. The fundamental domain is defined by the pitches
        in a chord spanning the range of an octave or less, and summing to
        an octave or less.

P       Permutational equivalence. The fundamental domain is defined by a
        "wedge" of plain chord space in which the voices of a chord are always
        sorted by pitch.

T       Transpositional equivalence, e.g. {1, 2} == {7, 8}. The fundamental
        domain is defined as a plane in chord space at right angles to the
        diagonal of unison chords. Represented by the chord always having a
        sum of pitches equal to 0.

I       Inversional equivalence. Care is needed to distinguish the
        mathematician's sense of 'invert', which means 'pitch-space inversion'
        or 'reflect in a point', from the musician's sense of 'invert', which
        varies according to context but in practice often means 'registral
        inversion' or 'revoice by adding an octave to the lowest tone of a
        chord.' Here, we use 'invert' and 'inversion' in the mathematician's
        sense, and we use the terms 'revoice' and 'voicing' for the musician's
        'invert' and 'inversion'. The inversion point for any inversion lies
        on the unison diagonal. A fundamental domain is defined as any half of
        chord space that is bounded by a plane containing the inversion point.
        Represented as the chord having the first interval between voices be
        smaller than or equal to the final interval (recursing for chords of
        more than 3 voices).

PI      Inversional equivalence with permutational equivalence. The
        'inversion flat' of unordered chord space is a hyperplane consisting
        of all those unordered chords that are invariant under inversion. A
        fundamental domain is defined by any half space bounded by a
        hyperplane containing the inversion flat. It is represented as that
        half of the space on or lower than the hyperplane defined by the
        inversion flat and the unison diagonal.

OP      Octave equivalence with permutational equivalence. Tymoczko's orbifold
        for chords; i.e. chords with a fixed number of voices in a harmonic
        context. The fundamental domain is defined as a hyperprism one octave
        long with as many sides as voices and the ends identified by octave
        equivalence and one cyclical permutation of voices, modulo the
        unordering. In OP for trichords in 12TET, the augmented triads run up
        the middle of the prism, the major and minor triads are in 6
        alternating columns around the augmented triads, the two-pitch chords
        form the 3 sides, and the one-pitch chords form the 3 edges that join
        the sides.

OPT     The layer of the OP prism as close as possible to the origin, modulo
        the number of voices. Chord type. Note that CM and Cm are different
        OPT. Because the OP prism is canted down from the origin, at least one
        pitch in each OPT chord (excepting the origin itself) is negative.

OPI     The OP prism modulo inversion, i.e. 1/2 of the OP prism. The
        representative fundamental consists of those chords less than or equal
        to their inversions modulo OP.

OPTI    The OPT layer modulo inversion, i.e. 1/2 of the OPT layer.
        Set-class. Note that CM and Cm are the same OPTI.

TRANSFORMATIONS

Each of the above equivalence classes is, of course, a transformation that 
sends chords outside the fundamental domain to chords inside the fundamental 
domain. And we define the following additional transformations:

T(p, x)         Translate p by x.

I(p [, x])      Reflect p in x, by default the origin.

P               Send a major triad to the minor triad with the same root,
                or vice versa (Riemann's parallel transformation).

L               Send a major triad to the minor triad one major third higher,
                or vice versa (Riemann's Leittonwechsel or leading-tone
                exchange transformation).

R               Send a major triad to the minor triad one minor third lower,
                or vice versa (Riemann's relative transformation).

D               Send a triad to the next triad a perfect fifth lower
                (dominant transformation).

P, L, and R have been extended as follows, see Fiore and Satyendra,
"Generalized Contextual Groups", _Music Theory Online_ 11, August 2008:

K(c)            Interchange by inversion;
                K(c) := I(c, c[1] + c[2]).
                This is a generalized form of P; for major and minor triads,
                it is exactly the same as P, but it also works with other
                chord types.

Q(c, n, m)      Contexual transposition;
                Q(c, n, m) := T(c, n) if c is a T-form of m,
                or T(c, -n) if c is an I-form of M. Not a generalized form
                of L or R; but, like them, K and Q generate the T-I group.

J is from Jessica Rudman's dissertation.
J(c, n [, g [, i]])  Contextual inversion;
                J(c, n [, g [, i]]) returns all (or, optionally, the ith) 
                inversion(s) of chord c that preserve n pitch-classes of c. 
                The remaining pitches of c invert "around" the invariant 
                pitch-classes. The inversions need  not preserve any
                equivalence classes with respect to the inverted pitches. If 
                there is no such inversion, an empty list is returned. If 
                there is more than one such inversion, an ordered list of them 
                is returned. Algorithm: 
                (1) Create an empty list of inverted chords.
                (2) For each pitch-class from 0 to 6 step g (g is the 
                    generator of transposition, e.g. 1 in TET):
                    (a) Invert c in the pitch-class.
                    (b) Test if n pitch-classes of pc are preserved. 
                    (c) If so, add the inverted chord to the list of 
                        inversions.
                    (d) Sort the list of inversions.
                (3) Return the list of inversions (or, optionally, the ith
                    inversion in the list).
`
    return text;
};

// Returns n!
ChordSpace.factorial = function(n) {
  if (n == 0) {
    return 1;
  } else {
    return n * ChordSpace.factorial(n - 1);
  };
};

ChordSpace.eq_epsilon = function(a, b, factor) {
    factor = typeof factor !== 'undefined' ? factor : ChordSpace.epsilonFactor;
    if (Math.abs(a - b) < (ChordSpace.EPSILON * factor)) {
        return true;
    };
    return false;
};

ChordSpace.gt_epsilon = function(a, b, factor) {
    factor = typeof factor !== 'undefined' ? factor : ChordSpace.epsilonFactor;
    var eq = ChordSpace.eq_epsilon(a, b, factor);
    if (eq) {
        return false;
    };
    if (a > b) {
        return true;
    };
    return false;
};

ChordSpace.lt_epsilon = function(a, b, factor) {
    factor = typeof factor !== 'undefined' ? factor : ChordSpace.epsilonFactor;
    var eq = ChordSpace.eq_epsilon(a, b, factor);
    if (eq) {
        return false;
    };
    if (a < b) {
        return true;
    };
    return false;
};

ChordSpace.ge_epsilon = function(a, b, factor) {
    factor = typeof factor !== 'undefined' ? factor : ChordSpace.epsilonFactor;
    var eq = ChordSpace.eq_epsilon(a, b, factor);
    if (eq) {
        return true;
    };
    if (a > b) {
        return true;
    };
    return false;
};

ChordSpace.le_epsilon = function(a, b, factor) {
    factor = typeof factor !== 'undefined' ? factor : ChordSpace.epsilonFactor;
    var eq = ChordSpace.eq_epsilon(a, b, factor);
    if (eq) {
        return true;
    };
    if (a < b) {
        return true;
    };
    return false;
};

ChordSpace.compare_epsilon = function(a, b) {
    if (ChordSpace.lt_epsilon(a, b)) {
        return -1;
    };
    if (ChordSpace.gt_epsilon(a, b)) {
        return 1;
    };
    return 0;
};

// The size of the octave, defined to be consistent with
// 12 tone equal temperament and MIDI.
ChordSpace.OCTAVE = 12;

// Middle C.
ChordSpace.MIDDLE_C = 60;

// Returns the pitch transposed by semitones, which may be any scalar.
// NOTE: Does NOT return the result under any equivalence class.
ChordSpace.T = function(pitch, semitones) {
    return pitch + semitones;
};

// Returns the pitch reflected in the center, which may be any pitch.
// NOTE: Does NOT return the result under any equivalence class.
ChordSpace.I = function(pitch, center) {
    center = typeof center !== 'undefined' ? center : 0;
    return center - pitch;
};

// Returns the Euclidean distance between chords a and b,
// which must have the same number of voices.
ChordSpace.euclidean = function(a, b) {
    var sumOfSquaredDifferences = 0;
    for (var voice = 0; voice < a.data.length; voice++) {
        sumOfSquaredDifferences = sumOfSquaredDifferences + Math.pow((a.data[voice] - b.data[voice]), 2);
    };
    return Math.sqrt(sumOfSquaredDifferences);
};

// A chord is one point in a space with one dimension per voice.
// Pitches are represented as semitones with 0 at the origin
// and middle C as 60.
var Chord = function() {
    this.data = [];
    this.duration = [];
    this.channel = [];
    this.velocity = [];
    this.pan = [];
};
ChordSpace.Chord = Chord;

Chord.prototype.size = function() {
    return this.data.length;
};

// Resizes a chord to the specified number of voices.
// Existing voices are not changed. Extra voices are removed.
// New voices are initialized to 0.
Chord.prototype.resize = function(voices) {
    var original_length = this.data.length;
    this.data.length = voices;
    this.duration.length = voices;
    this.channel.length = voices;
    this.velocity.length = voices;
    this.pan.length = voices;
    for (var voice = original_length; voice < voices; voice++) {
        this.data[voice] = 0;
        this.duration[voice] = 0;
        this.channel[voice] = 0;
        this.velocity[voice] = 0;
        this.pan[voice] = 0;
    };
};

// Resizes the chord to the length of the array, and sets 
// the pitches from the values of the array.
Chord.prototype.set = function(array) {
    this.resize(array.length);
    for (var i = 0; i < this.size(); i++) {
        this.data[i] = array[i];
    };
};

Chord.prototype.setPitch = function(voice, value) {
    this.data[voice] = value;
};

Chord.prototype.getPitch = function(voice) {
    return this.data[voice];
};

Chord.prototype.setDuration = function(value) {
    for (var voice = 0; voice < this.data.length; voice++) {
        this.data[voice] = value;
    };
};

Chord.prototype.getDuration = function(voice) {
    voice = typeof voice !== 'undefined' ? voice : 0;
    return self.duration[voice];
};

Chord.prototype.setChannel = function(value) {
    for (var voice = 0; voice < this.data.length; voice++) {
        this.channel[voice] = value;
    };
};

Chord.prototype.getChannel = function(voice) {
    voice = typeof voice !== 'undefined' ? voice : 0;
    return self.channel[voice];
};

Chord.prototype.setVelocity = function(value) {
    for (var voice = 0; voice < this.data.length; voice++) {
        this.velocity[voice] = value;
    };
};

Chord.prototype.getVelocity = function(voice) {
    voice = typeof voice !== 'undefined' ? voice : 0;
    return self.velocity[voice];
};

Chord.prototype.setPan = function(value) {
    for (var voice = 0; voice < this.data.length; voice++) {
        this.pan[voice] = value;
    };
};

Chord.prototype.getPan = function(voice) {
    voice = typeof voice !== 'undefined' ? voice : 0;
    return self.pan[voice];
};

Chord.prototype.count = function(pitch) {
    var n = 0;
    for (var voice = 0; voice < this.data.length; voice++) {
        if (ChordSpace.eq_epsilon(this.data[voice], pitch)) {
            n++;
        };
    };
    return n;
};

// Returns a string representation of the chord.
// Quadratic complexity, but short enough not to matter.
Chord.prototype.toString = function() {
    var buffer = '[';
    for (var voice = 0; voice < this.data.length; voice++) {
        buffer = buffer + sprintf('%12.7f ', this.data[voice]);
    };
    buffer = buffer + ']';
    return buffer;
};

// Implements value semantics for ==, for the pitches in this only.
Chord.prototype.eq_epsilon = function(other) {
    if (this.data.length !== other.data.length) {
        return false;
    };
    for (var voice = 0; voice < this.data.length; voice++) {
       if (ChordSpace.eq_epsilon(this.data[voice], other.data[voice]) == false) {
            return false;
       };        
    }
    return true;
};

Chord.prototype.lt_epsilon = function(other) {
    var voices = Math.min(this.data.length, other.data.length);
    for (var voice = 0; voice < voices; voice++) {
        if (ChordSpace.lt_epsilon(this.data[voice], other.data[voice])) {
            return true;
        };
        if (ChordSpace.gt_epsilon(this.data[voice], other.data[voice])) {
            return false;
        };
    };
    if (this.data.length < other.data.length) {
        return true;
    };
    return true;
};

Chord.prototype.gt_epsilon = function(other) {
    var voices = Math.min(this.data.length, other.data.length);
    for (var voice = 0; voice < voices; voice++) {
        if (ChordSpace.gt_epsilon(this.data[voice], other.data[voice])) {
            return true;
        };
        if (ChordSpace.lt_epsilon(this.data[voice], other.data[voice])) {
            return false;
        };
    };
    if (this.data.length < other.data.length) {
        return false;
    };
    return true;
};


Chord.prototype.le_epsilon = function(other) {
    if (this.eq_epsilon(other)) {
        return true;
    };
    return this.lt_epsilon(other);
};

// Returns whether or not the chord contains the pitch.
Chord.prototype.contains = function(pitch) {
    for (var voice = 0; voice < this.data.length; voice++) {
        if (this.data[voice] === pitch) {
            return true;
        };
    };
    return false;
};

ChordSpace.chord_compare_epsilon = function(a, b) {
    if (a.lt_epsilon(b)) {
        return -1;
    };
    if (a.gt_epsilon(b)) {
        return 1;
    };
    return 0;    
}

// This hash function is used e.g. to give chords value semantics for sets.
Chord.prototype.hash = function() {
    var buffer = '';
    for (var voice = 0; voice < this.data.length; voice++) {
        var digit = this.data[voice].toString();
        if (voice === 0) {
            buffer = buffer.concat(digit);
        } else {
            buffer = buffer.concat(',', digit);
        };
    }
    return buffer;
};

// Returns the lowest pitch in the chord,
// and also its voice index.
Chord.prototype.min = function() {
    var lowestVoice = 0;
    var lowestPitch = this.data[lowestVoice];
    for (var voice = 1; voice < this.data.length; voice++) {
        if (ChordSpace.lt_epsilon(this.data[voice], lowestPitch) === true) {
            lowestPitch = this.data[voice];
            lowestVoice = voice;
        };
    };
    return [lowestPitch, lowestVoice];
};

// Returns the minimum interval in the chord.
Chord.prototype.minimumInterval = function() {
    var minimumInterval_ = Math.abs(this.data[1] - this.data[2])
    for (var v1 = 1; v1 < this.data.length; v1++) {
        for (var v2 = 1; v2 < this.data.length; v2++) {
            if (v1 == v2) {
                var interval = Math.abs(this.data[v1] - this.data[v2]);
                if (interval < minimumInterval_) {
                    minimumInterval_ = interval;
                };
            };
        };
    };
    return minimumInterval_;
};

// Returns the highest pitch in the chord,
// and also its voice index.
Chord.prototype.max = function() {
    var highestVoice = 1;
    var highestPitch = this.data[highestVoice];
    for(var voice = 1; voice < this.data.length; voice++) {
        if (this.data[voice] > highestPitch) {
            highestPitch = this.data[voice];
            highestVoice = voice;
        };
    };
    return [highestPitch, highestVoice]
};

// Returns the maximum interval in the chord.
Chord.prototype.maximumInterval = function() {
    var maximumInterval_ = Math.abs(this.data[1] - this.data[2]);
    for (var v1 = 0; v1 < this.data.length; v1++) {
        for (var v2 = 0; v2 < this.data.length; v2++) {
            if (v1 != v2) {
                var interval = Math.abs(this.data[v1] - this.data[v2]);
                if (interval > maximumInterval_) {
                    maximumInterval_ = interval;
                };
            };
        };
    };
    return maximumInterval_;
};

// Returns a value copy of the chord.
Chord.prototype.clone = function() {
    var clone_ = new Chord();
    clone_.resize(this.size());
    for (var voice = 0; voice < this.size(); voice++) {
        clone_.data[voice] = this.data[voice];
        clone_.duration[voice] = this.duration[voice];
        clone_.channel[voice] = this.channel[voice];
        clone_.velocity[voice] = this.velocity[voice];
        clone_.pan[voice] = this.pan[voice];
    };
    return clone_;
};

// Returns a new chord whose pitches are the floors of this chord's pitches.
Chord.prototype.floor = function() {
    var chord = this.clone()
    for (var voice = 0; voice < this.data.length; voice++) {
        chord.data[voice] = Math.floor(this.data[voice]);
    };
    return chord;
};

// Returns a new chord whose pitches are the ceilings of this chord's pitches.
Chord.prototype.ceil = function() {
    var chord = this.clone();
    for (var voice = 0; voice < this.data.length; voice++) {
        chord.data[voice] = Math.ceil(this.data[voice]);
    };
    return chord;
};

// Returns the origin of the chord's space.
Chord.prototype.origin = function() {
    var clone_ = this.clone();
    for (var voice = 0; voice < this.size(); voice++) {
        clone_.data[voice] = 0;
    };
    return clone_
};

Chord.prototype.distanceToOrigin = function() {
    var origin = this.origin();
    return ChordSpace.euclidean(this, origin);
};

// Returns the sum of the pitches in the chord.
Chord.prototype.layer = function() {
    var s = 0;
    for (var voice = 0; voice < this.size(); voice++) {
        s = s + this.data[voice];
    };
    return s
};

// Returns the Euclidean distance from this chord
// to the unison diagonal of its chord space.
Chord.prototype.distanceToUnisonDiagonal = function() {
    var unison = this.origin();
    var pitch = this.layer() / this.size();
    for (var voice = 0; voice < this.size(); voice++) {
        unison.data[voice] = pitch;
    };
    return ChordSpace.euclidean(this, unison)
};

// Returns the maximally even chord in the chord's space,
// e.g. the augmented triad for 3 dimensions.
Chord.prototype.maximallyEven = function() {
    var clone_ = this.clone();
    var g = ChordSpace.OCTAVE / clone_.size();
    for (var i = 0; i < clone_.size(); i++) {
        clone_.data[i] = i * g;
    };
    return clone_;
};

// Transposes the chord by the indicated interval (may be a fraction).
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.T = function(interval) {
    var clone_ = this.clone();
    for (var voice = 0; voice < this.size(); voice++) {
        clone_.data[voice] = ChordSpace.T(this.data[voice], interval);
    };
    return clone_;
};

// Inverts the chord by another chord that is on the unison diagonal, by
// default the origin.
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.I = function(center) {
    center = typeof center !== 'undefined' ? center : 0;
    var inverse = this.clone();
    for (var voice = 0; voice < this.size(); voice++) {
        inverse.data[voice] = ChordSpace.I(this.data[voice], center);
    };
    return inverse;
};

// Returns the remainder of the dividend divided by the divisor,
// according to the Euclidean definition.
ChordSpace.modulo = function(dividend, divisor) {
    var quotient = 0.0;
    if (divisor < 0.0) {
        quotient = Math.ceil(dividend / divisor);
    };
    if (divisor > 0.0) {
        quotient = Math.floor(dividend / divisor);
    };
    var remainder = dividend - (quotient * divisor);
    return remainder;
};

// Returns the equivalent of the pitch under pitch-class equivalence, i.e.
// the pitch is in the interval [0, OCTAVE).
ChordSpace.epc = function(pitch){
    var pc = ChordSpace.modulo(pitch, ChordSpace.OCTAVE);
    return pc;
};

// Returns whether the chord is within the fundamental domain of
// pitch-class equivalence, i.e. is a pitch-class set.
Chord.prototype.isepcs = function() {
    for (var voice = 0; voice < this.size(); voice++) {
        if (ChordSpace.eq_epsilon(this.data[voice], ChordSpace.epc(chord.data[voice])) === false) {
            return false;
        };
    };
    return true;
};

Chord.prototype.er = function(range) {
    var chord = this.clone();
    for (var voice = 0; voice < this.size(); voice++) {
        chord.data[voice] = ChordSpace.modulo(chord.data[voice], range);
    };
    return chord;
};

// Returns the equivalent of the chord under pitch-class equivalence,
// i.e. the pitch-class set of the chord.
Chord.prototype.epcs = function() {
    return this.er(ChordSpace.OCTAVE);
};

// Returns the equivalent of the chord within the fundamental domain of
// transposition to 0.
Chord.prototype.et = function() {
    var min_ = this.min();
    return this.T(-min_[0]);
};

// Returns whether the chord is within the fundamental domain of
// transposition to 0.
Chord.prototype.iset = function() {
    var et = this.et();
    if (et.eq_epsilon(this) === false) {
        return false;
    };
    return true;
};

// Returns whether the chord is within the representative fundamental domain
// of the indicated range equivalence.
Chord.prototype.iseR = function(range) {
    var max_ = this.max()[0];
    var min_ = this.min()[0];
    if (ChordSpace.le_epsilon(max_, (min_ + range)) === false) {
        return false;
    };
    var layer_ = this.layer();
    if (ChordSpace.le_epsilon(0, layer_) === false) {
        return false;
    };
    if (ChordSpace.le_epsilon(layer_, range) === false) {
        return false;
    };
    return true;
};

// Returns whether the chord is within the representative fundamental domain
// of octave equivalence.
Chord.prototype.iseO = function() {
    return this.iseR(ChordSpace.OCTAVE);
};

// Returns the equivalent of the chord within the representative fundamental
// domain of a range equivalence.
Chord.prototype.eR = function(range) {
    // The clue here is that at least one voice must be >= 0,
    // but no voice can be > range.
    // First, move all pitches inside the interval [0,  range),
    // which is not the same as the fundamental domain.
    var normal = this.er(range);
    // Then, reflect voices that are outside of the fundamental domain
    // back into it, which will revoice the chord, i.e.
    // the sum of pitches will then be in [0,  range].
    while (ChordSpace.lt_epsilon(normal.layer(), range) === false) {
        var max_ = normal.max();
        var maximumPitch = max_[0];
        var maximumVoice = max_[1];
        // Because no voice is above the range,
        // any voices that need to be revoiced will now be negative.
        normal.data[maximumVoice] = maximumPitch - range;
    };
    return normal;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of octave equivalence.
Chord.prototype.eO = function() {
    return this.eR(ChordSpace.OCTAVE);
};

// Returns whether the chord is within the representative fundamental domain
// of permutational equivalence.
Chord.prototype.iseP = function() {
    for (var voice = 1; voice < this.size(); voice++) {
         if (ChordSpace.le_epsilon(this.data[voice - 1], this.data[voice]) === false) {
            return false;
        };
    };
    return true;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of permutational equivalence.
// NB: Order is correct!
Chord.prototype.eP = function() {
    clone_ = this.clone();
    clone_.data.sort(ChordSpace.compare_epsilon);
    return clone_;
};

// Returns whether the chord is within the representative fundamental domain
// of transpositional equivalence.
Chord.prototype.iseT = function() {
    var layer_ = this.layer();
    if (ChordSpace.eq_epsilon(layer_, 0) == false) {
        return false;
    };
    return true;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of transpositonal equivalence.
Chord.prototype.eT = function(){
    var layer_ = this.layer();
    var sumPerVoice = layer_ / this.size();
    return this.T(-sumPerVoice);
};

// Returns the equivalent of the chord within the representative fundamental
// domain of transpositonal equivalence and the equal temperament generated
// by g. I.e., returns the chord transposed such that its layer is 0 or, under
// transposition, the positive layer closest to 0. NOTE: Does NOT return the
// result under any other equivalence class.
Chord.prototype.eTT = function(g) {
    g = typeof g !== 'undefined' ? g : 1;
    var normal = this.eT();
    var ng = Math.ceil(normal.data[0] / g);
    var transposition = (ng * g) - normal.data[0];
    normal = normal.T(transposition);
    return normal;
};

// Returns whether the chord is within the representative fundamental domain
// of translational equivalence and the equal temperament generated by g.
Chord.prototype.iseTT = function(g) {
    g = typeof g !== 'undefined' ? g : 1;
    var ep = this.eP()
    if (ep.eq_epsilon(ep.eTT(g)) === false) {
        return false;
    };
    return true;
};

// Returns whether the chord is within the representative fundamental domain
// of inversional equivalence.
Chord.prototype.iseI = function(inverse) {
    var lowerVoice = 1
    var upperVoice = this.size();
    while (lowerVoice < upperVoice) {
        var lowerInterval = this.data[lowerVoice] - this.data[lowerVoice - 1];
        var upperInterval = this.data[upperVoice] - this.data[upperVoice - 1];
        if (ChordSpace.lt_epsilon(lowerInterval, upperInterval)) {
            return true;
        };
        if (ChordSpace.gt_epsilon(lowerInterval, upperInterval)) {
            return false;
        };
        lowerVoice = lowerVoice + 1;
        upperVoice = upperVoice - 1
    };
    return true;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of inversional equivalence.
// FIXME: Do I need the "inverse" argument and would that work correctly?
Chord.prototype.eI = function() {
    if (this.iseI()) {
        return this.clone();
    };
    return this.I();
};

// Returns whether the chord is within the representative fundamental domain
// of range and permutational equivalence.
Chord.prototype.iseRP = function(range) {       
    for (var voice = 1; voice < this.size(); voice++) {
        if (ChordSpace.le_epsilon(this.data[voice - 1], this.data[voice]) === false) {
            return false;
        };
    };
    if (ChordSpace.le_epsilon(this.data[this.size() - 1], (this.data[0] + range)) === false) {
        return false;
    };
    var layer_ = this.layer();
    if (!(ChordSpace.le_epsilon(0, layer_) && ChordSpace.le_epsilon(layer_, range))) {
        return false;
    };
    return true;
};

// Returns whether the chord is within the representative fundamental domain
// of octave and permutational equivalence.
Chord.prototype.iseOP = function() {
    return this.iseRP(ChordSpace.OCTAVE);
};

// Returns the equivalent of the chord within the representative fundamental
// domain of range and permutational equivalence.
Chord.prototype.eRP = function(range) {
    return this.eR(range).eP();
};

// Returns the equivalent of the chord within the representative fundamental
// domain of octave and permutational equivalence.
Chord.prototype.eOP = function() {
    return this.eRP(ChordSpace.OCTAVE);
};

// Returns a copy of the chord cyclically permuted by a stride, by default 1.
// The direction of rotation is the same as musicians' first inversion, second
// inversion, and so on.
Chord.prototype.cycle = function(stride) {
    stride = typeof stride !== 'undefined' ? stride : 1;
    var permuted = this.clone();
    if (stride < 0) {
        for (var i = 0; i < Math.abs(stride); i++) {
            var tail = permuted.data.pop();
            permuted.data.unshift(tail);
        };
        return permuted;
    };
    if (stride > 0) {
        for (var i = 0; i < stride; i++) {
            var head = permuted.data.shift();
            permuted.data.push(head);
        };
    };
    return permuted;
};

// Returns the permutations of the pitches in a chord. The permutations from
// any particular permutation are always returned in the same order.
// FIXME: This is not thought through. It does what I said to do, but that may 
// not be what I meant.
Chord.prototype.permutations = function() {
    var permutation = this.clone();
    var permutations_ = [];
    permutations_.push(permutation);
    for (var i = 1; i < this.size(); i++) {
        permutation = permutation.cycle(1);
        permutations_.push(permutation);
    };
    permutations_.sort(ChordSpace.chord_compare_epsilon);
    return permutations_;
};

// Returns whether the chord is within the representative fundamental domain
// of voicing equivalence.
Chord.prototype.iseV = function(range) {
    range = typeof range !== 'undefined' ? range : ChordSpace.OCTAVE;
    var outer = this.data[0] + range - this.data[this.size() - 1];
    var isNormal = true;
    for (var voice = 0; voice < this.size() - 2; voice++) {
        var inner = this.data[voice + 1] - this.data[voice];
        if (ChordSpace.ge_epsilon(outer, inner) == false) {
            isNormal = false;
        };
    };
    return isNormal;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of voicing equivalence.
Chord.prototype.eV = function(range) {
    range = typeof range !== 'undefined' ? range : ChordSpace.OCTAVE;
    var permutations = this.permutations();
    for (var i = 0; i < this.size(); i++) {
        var permutation = permutations[i];
        if (permutation.iseV(range)) {
            return permutation;
        };
    };
};

// Returns whether the chord is within the representative fundamental domain
// of range, permutational, and transpositional equivalence.
Chord.prototype.iseRPT = function(range) {
    if (this.iseR(range) === false) {
        return false;
    };
    if (this.iseP() === false) {
        return false;
    };
    if (this.iseT() === false) {
        return false;
    };
    if (this.iseV() === false) {
        return false;
    };
    return true;
};

Chord.prototype.iseRPTT = function(range) {
    if (this.iseR(range) === false) {
        return false;
    };
    if (this.iseP() === false) {
        return false;
    };
    if (this.iseTT() === false) {
        return false;
    };
    if (this.iseV() === false) {
        return false;
    };
    return true;
};

// Returns whether the chord is within the representative fundamental domain
// of octave, permutational, and transpositional equivalence.
Chord.prototype.iseOPT = function() {
    return this.iseRPT(ChordSpace.OCTAVE);
};

Chord.prototype.iseOPTT = function() {
    return this.iseRPTT(ChordSpace.OCTAVE);
};

// Returns a copy of the chord 'inverted' in the musician's sense,
// i.e. revoiced by cyclically permuting the chord and
// adding (or subtracting) an octave to the highest (or lowest) voice.
// The revoicing will move the chord up or down in pitch.
// A positive direction is the same as a musician's first inversion,
// second inversion, etc.
// FIXME: Original is probably not correct.
Chord.prototype.v = function(direction) {
    direction = typeof direction !== 'undefined' ? direction : 1;
    var chord = this.clone();
    while (direction > 0) {
        chord.data[0] = chord.data[0] + ChordSpace.OCTAVE;
        chord = chord.cycle(1);
        direction = direction - 1;
    };
    var n = chord.size() - 1;
    while (direction < 0) {
        chord.data[n] = chord.data[n] - ChordSpace.OCTAVE;
        chord = chord.cycle(-1);
        direction = direction + 1;
    };
    return chord;
};

// Returns all the 'inversions' (in the musician's sense)
// or octavewise revoicings of the chord.
Chord.prototype.voicings = function() {
    var chord = this.clone();
    var voicings = [];
    voicings.push(chord);
    for (var i = 1; i < chord.size(); i++) {
        chord = chord.v();
        voicings.push(chord);
    };
    return voicings;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of range, permutational, and transpositional equivalence; the same
// as set-class type, or chord type.
// FIXME: Take g into account?
Chord.prototype.eRPT = function(range) {
    var erp = this.eRP(range);
    var voicings_ = erp.voicings();
    for (var i = 0; i < voicings_.length; i++) {
        var voicing = voicings_[i];
        if (voicing.iseV()) {
            return voicing.eT();
        };
    };
    console.log('ERROR: chord.eRPT() should not come here: ' + this);
};

Chord.prototype.eRPTT = function(range) {
    var erp = this.eRP(range);
    var voicings_ = erp.voicings();
    for (var i = 0; i < voicings_.length; i++) {
        var voicing = voicings_[i].eTT();
        if (voicing.iseV()) {
            return voicing;
        };
    };
    console.log('ERROR: chord.eRPTT() should not come here: ' + this);
};

// Returns the equivalent of the chord within the representative fundamental
// domain of octave, permutational, and transpositional equivalence.
Chord.prototype.eOPT = function() {
    return this.eRPT(ChordSpace.OCTAVE);
};

Chord.prototype.eOPTT = function() {
    return this.eRPTT(ChordSpace.OCTAVE);
};

// Returns whether the chord is within the representative fundamental domain
// of range, permutational, and inversional equivalence.
Chord.prototype.iseRPI = function(range) {
    if (this.iseRP(range) === false) {
        return false;
    };
    var inverse = this.I();
    var inverseRP = inverse.eRP(range);
    //assert(inverse, 'Inverse is nil.');
    if (this.le_epsilon(inverseRP) === true) {
        return true;
    };
    return false;
};

// Returns whether the chord is within the representative fundamental domain
// of octave, permutational, and inversional equivalence.
Chord.prototype.iseOPI = function() {
    return this.iseRPI(ChordSpace.OCTAVE);
};

// Returns the equivalent of the chord within the representative fundamental
// domain of range, permutational, and inversional equivalence.
Chord.prototype.eRPI = function(range) {
    if (this.iseRPI(range) === true) {
        return this.clone();
    };
    var normalRP = this.eRP(range);
    var normalRPInverse = normalRP.I();
    var normalRPInverseRP = normalRPInverse.eRP(range);
    if (normalRP.le_epsilon(normalRPInverseRP) === true) {
        return normalRP;
    } else {
        return normalRPInverseRP;
    };
};

// Returns the equivalent of the chord within the representative fundamental
// domain of octave, permutational, and inversional equivalence.
Chord.prototype.eOPI = function() {
    return this.eRPI(ChordSpace.OCTAVE);
};

// Returns whether the chord is within the representative fundamental domain
// of range, permutational, transpositional, and inversional equivalence.
Chord.prototype.iseRPTI = function(range) {
    if (this.iseP() === false) {
        return false;
    };
    if (this.iseR(range) === false) {
        return false;
    };
    if (this.iseT() === false) {
        return false;
    };
    if (this.iseV(range) === false) {
        return false;
    };
    return true;
};

Chord.prototype.iseRPTTI = function(range) {
    if (this.iseRPTT(range) === false) {
        return false;
    };
    var inverse = this.I();
    var normalRPTT = inverse.eRPTT(range);
    if (this.le_epsilon(normalRPTT) === true) {
        return true;
    };
    return false;
};

// Returns whether the chord is within the representative fundamental domain
// of octave, permutational, transpositional, and inversional equivalence.
Chord.prototype.iseOPTI = function() {
    return this.iseRPTI(ChordSpace.OCTAVE);
};
Chord.prototype.iseOPTTI = function() {
    return this.iseRPTTI(ChordSpace.OCTAVE);
};

// Returns the equivalent of the chord within the representative fundamental
// domain of range, permutational, transpositional, and inversional
// equivalence.
Chord.prototype.eRPTI = function(range) {
    var normalRPT = this.eRPT(range);
    if (normalRPT.iseI() === true) {
        return normalRPT;
    } else {
        var normalI = normalRPT.eRPI(range);
        var normalRPT_ = normalI.eRPT(range);
        return normalRPT_;
    };
};

Chord.prototype.eRPTTI = function(range) {
    var normalRPTT = this.eRPTT(range);
    var inverse = normalRPTT.I();
    var inverseNormalRPTT = inverse.eRPTT(range);
    if (normalRPTT.le_epsilon(inverseNormalRPTT) === true) {
        return normalRPTT;
    };
    return inverseNormalRPTT;
};

// Returns the equivalent of the chord within the representative fundamental
// domain of range, permutational, transpositional, and inversional
// equivalence.
Chord.prototype.eOPTI = function() {
    return this.eRPTI(ChordSpace.OCTAVE);
};
Chord.prototype.eOPTTI = function() {
    return this.eRPTTI(ChordSpace.OCTAVE);
};

var pitchClassesForNames = {};

pitchClassesForNames["C" ] =  0;
pitchClassesForNames["C#"] =  1;
pitchClassesForNames["Db"] =  1;
pitchClassesForNames["D" ] =  2;
pitchClassesForNames["D#"] =  3;
pitchClassesForNames["Eb"] =  3;
pitchClassesForNames["E" ] =  4;
pitchClassesForNames["F" ] =  5;
pitchClassesForNames["F#"] =  6;
pitchClassesForNames["Gb"] =  6;
pitchClassesForNames["G" ] =  7;
pitchClassesForNames["G#"] =  8;
pitchClassesForNames["Ab"] =  8;
pitchClassesForNames["A" ] =  9;
pitchClassesForNames["A#"] = 10;
pitchClassesForNames["Bb"] = 10;
pitchClassesForNames["B" ] = 11;
ChordSpace.pitchClassesForNames = pitchClassesForNames;

chordsForNames = {};
namesForChords = {};

var fill = function(rootName, rootPitch, typeName, typePitches) {
    typePitches = typePitches.trim();
    var chordName = rootName + typeName;
    var chord = new ChordSpace.Chord();
    // FIXME: re is incorrect.
    var splitPitches = typePitches.split(/\s+/g);
    if (typeof splitPitches !== 'undefined') {
        chord.resize(splitPitches.length);
        for (var voice = 0; voice < splitPitches.length; voice++) {
            var pitchName = splitPitches[voice];
            if (pitchName.length > 0) {
                var pitch = ChordSpace.pitchClassesForNames[pitchName];
                chord.data[voice] = rootPitch + pitch;
            }
        };
        chord = chord.eOP();
        chordsForNames[chordName] = chord;
        namesForChords[chord.hash()] = chordName;
    };
};

for (var rootName in pitchClassesForNames) {
    if (pitchClassesForNames.hasOwnProperty(rootName)) {
        var rootPitch = pitchClassesForNames[rootName];
        fill(rootName, rootPitch, " minor second",     "C  C#                             ");
        fill(rootName, rootPitch, " major second",     "C     D                           ");
        fill(rootName, rootPitch, " minor third",      "C        Eb                       ");
        fill(rootName, rootPitch, " major third",      "C           E                     ");
        fill(rootName, rootPitch, " perfect fourth",   "C              F                  ");
        fill(rootName, rootPitch, " tritone",          "C                 F#              ");
        fill(rootName, rootPitch, " perfect fifth",    "C                    G            ");
        fill(rootName, rootPitch, " augmented fifth",  "C                       G#        ");
        fill(rootName, rootPitch, " sixth",            "C                          A      ");
        fill(rootName, rootPitch, " minor seventh  ",  "C                             Bb  ");
        fill(rootName, rootPitch, " major seventh",    "C                                B");
        // Scales.
        fill(rootName, rootPitch, " major",            "C     D     E  F     G     A     B");
        fill(rootName, rootPitch, " minor",            "C     D  Eb    F     G  Ab    Bb  ");
        fill(rootName, rootPitch, " natural minor",    "C     D  Eb    F     G  Ab    Bb  ");
        fill(rootName, rootPitch, " harmonic minor",   "C     D  Eb    F     G  Ab       B");
        fill(rootName, rootPitch, " chromatic",        "C  C# D  D# E  F  F# G  G# A  A# B");
        fill(rootName, rootPitch, " whole tone",       "C     D     E     F#    G#    A#  ");
        fill(rootName, rootPitch, " diminished",       "C     D  D#    F  F#    G# A     B");
        fill(rootName, rootPitch, " pentatonic",       "C     D     E        G     A      ");
        fill(rootName, rootPitch, " pentatonic major", "C     D     E        G     A      ");
        fill(rootName, rootPitch, " pentatonic minor", "C        Eb    F     G        Bb  ");
        fill(rootName, rootPitch, " augmented",        "C        Eb E        G  Ab    Bb  ");
        fill(rootName, rootPitch, " Lydian dominant",  "C     D     E     Gb G     A  Bb  ");
        fill(rootName, rootPitch, " 3 semitone",       "C        D#       F#       A      ");
        fill(rootName, rootPitch, " 4 semitone",       "C           E           G#        ");
        fill(rootName, rootPitch, " blues",            "C     D  Eb    F  Gb G        Bb  ");
        fill(rootName, rootPitch, " bebop",            "C     D     E  F     G     A  Bb B");
        // Major chords.
        fill(rootName, rootPitch, "M",                 "C           E        G            ");
        fill(rootName, rootPitch, "6",                 "C           E        G     A      ");
        fill(rootName, rootPitch, "69",                "C     D     E        G     A      ");
        fill(rootName, rootPitch, "69b5",              "C     D     E     Gb       A      ");
        fill(rootName, rootPitch, "M7",                "C           E        G           B");
        fill(rootName, rootPitch, "M9",                "C     D     E        G           B");
        fill(rootName, rootPitch, "M11",               "C     D     E  F     G           B");
        fill(rootName, rootPitch, "M#11",              "C     D     E  F#    G           B");
        fill(rootName, rootPitch, "M13",               "C     D     E  F     G     A     B");
        // Minor chords.
        fill(rootName, rootPitch, "m",                 "C        Eb          G            ");
        fill(rootName, rootPitch, "m6",                "C        Eb          G     A      ");
        fill(rootName, rootPitch, "m69",               "C     D  Eb          G     A      ");
        fill(rootName, rootPitch, "m7",                "C        Eb          G        Bb  ");
        fill(rootName, rootPitch, "m#7",               "C        Eb          G           B");
        fill(rootName, rootPitch, "m7b5",              "C        Eb       Gb          Bb  ");
        fill(rootName, rootPitch, "m9",                "C     D  Eb          G        Bb  ");
        fill(rootName, rootPitch, "m9#7",              "C     D  Eb          G           B");
        fill(rootName, rootPitch, "m11",               "C     D  Eb    F     G        Bb  ");
        fill(rootName, rootPitch, "m13",               "C     D  Eb    F     G     A  Bb  ");
        // Augmented chords.
        fill(rootName, rootPitch, "+",                 "C            E         G#         ");
        fill(rootName, rootPitch, "7#5",               "C            E         G#     Bb  ");
        fill(rootName, rootPitch, "7b9#5",             "C  Db        E         G#     Bb  ");
        fill(rootName, rootPitch, "9#5",               "C     D      E         G#     Bb  ");
        // Diminished chords.
        fill(rootName, rootPitch, "o",                 "C        Eb       Gb              ");
        fill(rootName, rootPitch, "o7",                "C        Eb       Gb       A      ");
        // Suspended chords.
        fill(rootName, rootPitch, "6sus",              "C              F     G     A      ");
        fill(rootName, rootPitch, "69sus",             "C     D        F     G     A      ");
        fill(rootName, rootPitch, "7sus",              "C              F     G        Bb  ");
        fill(rootName, rootPitch, "9sus",              "C     D        F     G        Bb  ");
        fill(rootName, rootPitch, "M7sus",             "C              F     G           B");
        fill(rootName, rootPitch, "M9sus",             "C     D        F     G           B");
        // Dominant chords.
        fill(rootName, rootPitch, "7",                 "C            E       G        Bb  ");
        fill(rootName, rootPitch, "7b5",               "C            E    Gb          Bb  ");
        fill(rootName, rootPitch, "7b9",               "C  Db        E       G        Bb  ");
        fill(rootName, rootPitch, "7b9b5",             "C  Db        E    Gb          Bb  ");
        fill(rootName, rootPitch, "9",                 "C     D      E       G        Bb  ");
        fill(rootName, rootPitch, "9#11",              "C     D      E F#    G        Bb  ");
        fill(rootName, rootPitch, "13",                "C     D      E F     G     A  Bb  ");
        fill(rootName, rootPitch, "13#11",             "C     D      E F#    G     A  Bb  ");
    };
};

ChordSpace.namesForChords = namesForChords;
ChordSpace.chordsForNames = chordsForNames;

ChordSpace.nameForChord = function(chord) {
    return ChordSpace.namesForChords[chord.eOP().hash()];
}

// Move 1 voice of the chord.
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.move = function(voice, interval) {
    var chord = this.clone();
    chord.data[voice] = ChordSpace.T(chord.data[voice], interval);
    return chord;
};

// Performs the neo-Riemannian parallel transformation.
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.nrP = function() {
    var cv = this.eV();
    var cvt = this.eV().et();
    if (ChordSpace.eq_epsilon(cvt.data[1], 4) === true) {
        cv.data[1] = cv.data[1] - 1;
    } else if (ChordSpace.eq_epsilon(cvt.data[1], 3) === true) {
        cv.data[1] = cv.data[1] + 1;
    };
    return cv;
};

// Performs the neo-Riemannian relative transformation.
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.nrR = function() {
    var cv = this.eV();
    var cvt = this.eV().et();
    if (ChordSpace.eq_epsilon(cvt.data[1], 4) === true) {
        cv.data[2] = cv.data[2] + 2;
    } else if (ChordSpace.eq_epsilon(cvt.data[1], 3) === true) {
        cv.data[0] = cv.data[0] - 2;
    };
    return cv;
};
// Performs the neo-Riemannian Lettonwechsel transformation.
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.nrL = function() {
    var cv = this.eV();
    var cvt = this.eV().et();
    if (ChordSpace.eq_epsilon(cvt.data[1], 4) === true) {
        cv.data[0] = cv.data[0] - 1;
    } else if (ChordSpace.eq_epsilon(cvt.data[1], 3) === true) {
        cv.data[2] = cv.data[2] + 1;
    };
    return cv;
};

// Performs the neo-Riemannian dominant transformation.
// NOTE: Does NOT return the result under any equivalence class.
Chord.prototype.nrD = function() {
    return this.T(-7);
};


//////////////////////////////////////////////////////////////////////////////
// EXPORTS
//////////////////////////////////////////////////////////////////////////////

// Node: Export function
if (typeof module !== "undefined" && module.exports) {
    module.exports = ChordSpace;
}
// AMD/requirejs: Define the module
else if (typeof define === 'function' && define.amd) {
    define(function () {return ChordSpace;});
}
// Browser: Expose to window
else {
    window.ChordSpace = ChordSpace;
}

})();
