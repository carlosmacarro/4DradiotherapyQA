% Computes the inverse of a matrix.

% Code by Iman Aganj.

function I = inverseD(A)

D = ndims(A)-2;
[d,C] = detD(A);
I = multD(1./d,transD(C,D),D);
