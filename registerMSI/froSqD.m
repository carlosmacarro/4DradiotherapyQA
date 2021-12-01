% Computes the Frobenius norm.

% Code by Iman Aganj.

function f = froSqD(A, D)

f = sum(sum(A.^2,D+2),D+1);
