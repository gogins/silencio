# Introduction #

Contemporary music theorists have convincingly demonstrated that a considerable part of what actual musicians consider "theory" is covered by one simple concept: a chord is a single point in a multi-dimensional space with one dimension per voice of the chord, and many common operations and symmetries of music theory are represented by group structures in this chord space that are generated under different equivalence classes: octave equivalence, order equivalence, set-class equivalence, and the like.

More to the point, these operations are mathematically simple, lend themselves to computerization, and can be used to ensure that algorithmically generated scores obey many of the rules of "well-formedness" that composers learn, including good voice-leading and chord progression.

Note: a bare beginning of terminology: pitches are numbers and the octave is 12.

Silencio contains a ChordSpace package that implements these concepts. The glossary here attempts to define terms that can be used without confusion.

For example, "transpose" (T) means one thing under octave equivalence, where 0 T 13 = 1, but another thing otherwise, where 0 T 13 = 13.

For another example, "invert" (I) means one thing to mathematicians where {0, 4, 7} I 1 = {3, 6, 11}, but another thing to jazzers the first inversion of C major is {4, 7, 12}.

# Glossary #

  * itch*** hord**
  * ctave equivalence*** ange equivalence**
  * ermutational equivalence