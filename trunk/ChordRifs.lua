ChordRifs = {}

function ChordRifs.help()
print [[
C H O R D   R I F S

Copyright (C) 2010 by Michael Gogins
This software is licensed under the terms
of the GNU Lesser General Public License.

This package implements a recurrent iterated function system (RIFS) in chord
space. The dimensions of chord space are:

(1) Time within a specified interval.
(2) Zero-based index of octave, permutational, transposition, and inversional
    equivalence (set-class).
(3) Inversion.
(4) Transposition.
(5) Zero-based index of octavewise revoicings within a specified range.

A deterministic RIFS is iterated a specified number of times, accumulating a
list of transformed timed chords. This list is then "quantized" by time, and
within each quantum of time, any chords that exist are replaced by their mean.
In this way, a RIFS can be used to compute any sequence of chords as a
function of time.

One objective of this system is to enable the evolution of pieces by encoding
their RIFS parameters with Hilbert indexes and exploring the resulting
parameter space.
]]
end

require("Silencio")
require("jit")
require("ffi")


return ChordRifs
