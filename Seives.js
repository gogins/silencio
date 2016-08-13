/**
S I E V E S

Copyright (C) 2016 by Michael Gogins

This software is licensed under the terms of the
GNU Lesser General Public License

Part of Silencio, an HTML5 algorithmic music composition library for Csound.

This file implements Xenakis sieves using the concepts of Christopher Ariza.
The composition of residuals with logical operators can specify any finite 
sequence of natural numbers. A facility for deriving a sieve from a given 
sequence is not provided. These sieves operate only on the natural numbers.

The notation for a residual is from Ariza:

modulus[@shift] 

A sieve consists of one or more residuals combined using logical operators:

residual [[operator residual] ... ]

The operators are, in order of precedence, - (complement), & (intersection), 
and | (union).

Parentheses may be used for grouping.

An example of the notation for a sieve is:

(-(13@3 | 13@5 | 13@7 | 13@9) & 11@2) | (-(11@4 | 11@8) & 13@9) | (13@0 | 13@1 | 13@6)

*/

(function() {
    
/**
 * Returns a Python-type range as an array of integers.
 */
function range(start, stop, step) {
    if (typeof stop == 'undefined') {
        stop = start;
        start = 0;
    }
    if (typeof step == 'undefined') {
        step = 1;
    }
    if ((step > 0 && start >= stop) || (step < 0 && start <= stop)) {
        return [];
    }
    var result = [];
    for (var i = start; step > 0 ? i < stop : i > stop; i += step) {
        result.push(i);
    }
    return result;
}

function Residue(modulus, shift, complement_, range_) {
    this.modulus = modulus;
    if (typeof shift === 'undefined') {
        shift = 0;
    }
    if (this.modulus === 0) {
        this.shift = shift;
    } else {
        this.shift = shift % this.modulus;
    }
    if (typeof complement_ === 'undefined') {
        this.complement_ = false;
    } else {
        this.complement_ = complement_;
    }
    if (typeof range_ === 'undefined') {
        this.range_ = range(0, 100);
    } else {
        this.range_ == range_;
    }
}

Residue.prototype.clone = function() {
    // NOTE: range is copied as a reference, not as a value.
    other = new Residue(this.modulus, this.shift, this.complement_, this.range_);
    return other;
}

/**
 * Returns a subset of the sequence for this residue; if the range_ parameter 
 * is not used, then the default range (0, 100) is used.
 */
Residue.prototype.subset = function(n, range_) {
    if (typeof n === 'undefined') {
        n = 0;
    }
    if (typeof range_ === 'undefined') {
        range_ = this.range_;
    }
    var subset_ = [];
    if (self.modulus === 0) {
        return subset_;
    }
    n = (n + this.shift) % self.modulus;
    for (let value_ of range_) {
        if (n === value % self.modulus) {
            subset_.push(value);
        }
    }
    if (this.complement_) {
        var complement_subset = subset_.slice(0);
        for (let value_ of subset_) {
            let index_ = subset.indexOf(value_);
            if (index > -1) {
                complement_subset.splice(index_, 1);
            }        
        }
        return complement_subset;
    } else {
        return subset_;
    }
}

Residue.prototype.equal = function(other) {
    if (typeof other === 'undefined') {
        return false;
    }
    if (this.modulus !== other.modulus) {
        return false;
    }
    if (this.shift !== other.shift) {
        return false;
    }
    if (this.complement_ !== other.complement_) {
        return false;
    }
    return true;
}

Residue.prototype.not_equal = function(other) {
    if (this.equal(other) {
        return false;
    } else {
        return true;
    }
}

Residue.prototype.compare = function(other) {
    if (this.modulus < other.modulus) {
        return -1;
    }
    if (this.modulus > other.modulus) {
        return 1;
    }
    if (this.shift < other.shift) {
        return -1;
    }
    if (this.shift > other.shift) {
        return 1;
    }
    if (this.complement_ !== other.complement_) {
        if (this.complement_ === true) {
            return -1;
        } else {
            return 1;
        }
    }
    return 0;
}

Residue.prototype.compute_intersection = function(modulus_1, modulus_1, shift_1, shift_2) {
    let divisor = gcd(modulus_1, modulus_2);
    let c_1 = modulus_1 / divisor;
    let c_2 = modulus_2 / divisor;
    let modulus_3 = 0;
    let shift_3 = 0;
    if (modulus_1 !== 0 && modulus_2 !== 0) {
        shift_1 = shift_1 % modulus_1;
        shift_2 = shift_2 % modulus_2;
    } else {
        return {modulus: modulus_3, shift: shift_3};
    }
    if (divisor !== 1 && ((shift_1 - shift_2) % divisor === 0) && (shift_1 != shift_2) and (c_1 == c_2)) {
        modulus_3 = divisor;
        shift_3 = shift_1;
        return {modulus: modulus_3, shift: shift_3};
    } else {
        modulus_3 = c_1 * c_2 * divisor;
        let g = meziriac(c_1, c_2);
        shift_3 = (shift_1 + (g * (shift_2 - shift_1)) % modulus_3;
        return {modulus: modulus_3, shift: shift_3};
    }    
}
    
Residue.prototype.complement = function() {
    let complement_ = !this.complement_;
    return new Residue(this.modulus, this.shift, complement_, this.range_);
}

Residue.prototype.intersection = function(other) {
    if (this.complement_ || other.complement_) {
        throw "Error: Cannot compute an intersection with a complemented Residue."
    }
    let result = this.compute_itersection(self.modulus, other.modulus, self.shift, other.shift);
    let self_set = new Set(this.range_);
    let other_set = new Set(other.range_);
    let union_set = new Set([...self_set, ...other_set]);
    let union_range = [...union_set];
    return new Residue(result.modulus, result.shift, false, union_range);    
}

Residue.prototype.union = function(other) {
    // Don't think this can be computed.
}


/**
 * Returns the greatest common divisor of integers a and b.
 */
function gcd(a, b) {
    if (a < 0) {
        a = -a;
    }
    if (b < 0) {
        b = -b;
    }
    if (b > a) {
        var temp = a; 
        a = b; 
        b = temp;
    }
    while (true) {
        if (b === 0) {
            return a;
        }
        a %= b;
        if (a === 0) {
            return b;
        }
        b %= a;
    }
}

/**
 * Returns the least common multiple of integers a and b.
 */
function lcm(a, b) {
    return Math.abs(a * b) / gcd(a, b); 
}

function meziriac(a, b) {
    var n1 = 0;
    if (b === 1) {
        n1 = 1;
    } else if (a === b) {
        n1 = 0;
    } else {
        while (n1 < 100000) {
            var test = (n1 * a) % b;
            if (test === 1) {
                break;
            }
            n1 = n1 + 1;
        }
    }
    return n1;
}

var Sieve = function(definition, range_) {
    this.definition = definition;
    if (typeof range_ === 'undefined') {
        this.range_ = range(0, 100);
    }
    this.state = 'expression';
    this.expression_type = null;
    this.incompressible = true;
    this.residues_for_ids = {}
    this.residue_count = 0;
    
    
    
}

Sieve.LGROUP = '{'
Sieve.RGROUP = '}'
Sieve.AND = '&'
Sieve.OR = '|'
Sieve.XOR = '^'
Sieve.BOUNDS = [Sieve.LGROUP, Sieve.RGROUP, Sieve.AND, Sieve.OR, Sieve.XOR]
Sieve.NOT = '-'
Sieve.RESIDUAL = '0123456789@'.split('');

var Sieves = {
    Complement: Complement,
    gcd: gcd,
    lcm: lcm,
    meziriac: meziriac,
    range: range,
    Sieve: Sieve
};

// Node: Export function
if (typeof module !== "undefined" && module.exports) {
    module.exports = Sieves;
}
// AMD/requirejs: Define the module
else if (typeof define === 'function' && define.amd) {
    define(function () {return Sieves;});
}
// Browser: Expose to window
else {
    window.Sieves = Sieves;
}

})();
