% Computes the transpose of a matrix.

% Code by Iman Aganj.

function A = transD(A,D)

A = permute(A, [1:D, D+2, D+1]);
