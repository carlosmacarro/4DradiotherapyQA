% Returns the size of a matrix.

% Code by Iman Aganj.

function s = sizeD(A,D)

s = [size(A) ones(1,D+2-ndims(A))];
