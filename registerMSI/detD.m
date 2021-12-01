% Computes the determinant of a matrix.

% Code by Iman Aganj.

function [d, C] = detD(A)

D = ndims(A)-2;
if nargout>1
    C = cofactorD(A);
elseif D>2
    C = cofactorD(A, true);
end
if D==2
    d = A(:,:,1,1).*A(:,:,2,2) - A(:,:,1,2).*A(:,:,2,1);
else
    d = sum(C(:,:,:,1,:).*A(:,:,:,1,:), 5);
end
