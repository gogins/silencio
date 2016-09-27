/**
LINEAR CONGRUENTIAL GENERATOR

Copyright (C) 2016 by Michael Gogins

This software is licensed under the terms of the
GNU Lesser General Public License

Part of Silencio, an HTML5 algorithmic music composition library for Csound.

This file implements Lehmer linear congruential generators (LCGs) loosely 
based on Bret Battey's "nodewebba."
*/

(function() {
    
/**
 * Returns the remainder of the dividend divided by the divisor,
 * according to the Euclidean definition.
 */
function modulo(dividend, divisor) {
    var quotient = 0.0;
    if (divisor < 0.0) {
        quotient = Math.ceil(dividend / divisor);
    }
    if (divisor > 0.0) {
        quotient = Math.floor(dividend / divisor);
    }
    var remainder = dividend - (quotient * divisor);
    return remainder;
}
    
function Lehmer(a, b, modulus, seed) {
    if (typeof a === 'undefined') {
        this.a = 1;
    } else {
        this.a = a;
    }
    if (typeof b === 'undefined') {
        this.b = 0;
    } else {
        this.b = b;
    }
    if (typeof modulus === 'undefined') {
        this.modulus = 1;
    } else {
        this.modulus = modulus;
    }
    this.reseed(seed);
}

Lehmer.prototype.reseed(seed) {
    if (typeof seed === 'undefined') {
        this.seed = 0;
    } else {
        this.seed = seed;
    }
    this.value = seed;
}

Lehmer.prototype.iterate = function() {
    this.value = modulo(this.value * this.a + this.b), this.modulus);
    return this.value;
}

/**
 * Creates a matrix of LCGs. The columns
 * are output LCGs and the rows are 
 * inputs (parameters) of the LCGs.
 */
function LehmerMatrix(size_) {
    this.generators = [];
    this.patch = [];
    for (var i = 0; i < size_; i++) {
        this.generators.push(new Lehmer());
        this.patch.push({"enabled": false, "routing":'a', "value": 0});
    }
}

LehmerMatrix.prototype.enable = function(index) {
    this.patch[index].enabled = true;
}

LehmerMatrix.prototype.disable = function(index) {
    this.patch[index].enabled = false;
}

/**
 * Input must be one of 'a', 'b', or 'modulus'.
 */
LehmerMatrix.prototype.route = function(index, input) {
    this.patch[index].routing = input;
}




var LinearCongruence = {
    modulo: modulo,
    Lehmer: Lehmer,
    LehmerMatrix: LehmerMatrix
};

// Node: Export function
if (typeof module !== "undefined" && module.exports) {
    module.exports = LinearCongruence;
}
// AMD/requirejs: Define the module
else if (typeof define === 'function' && define.amd) {
    define(function () {return LinearCongruence;});
}
// Browser: Expose to window
else {
    window.LinearCongruence = LinearCongruence;
}

})();
