% Matrix multiplication.

% Code by Iman Aganj.

function C = multD(A, B, D)

sA = sizeD(A,D);
sB = sizeD(B,D);
if ndims(A) <= D     % Scalar product
    C = bsxfun(@times, A, B);
else                 % Matrix product
    if sA(D+2) ~= sB(D+1)
        error('Matrices do not have the correct size.')
    end
    if D==2
        C = bsxfun(@times, A(:,:,:,1), B(:,:,1,:));
        for k = 2:sA(4)
            C = C + bsxfun(@times, A(:,:,:,k), B(:,:,k,:));
        end
    else
        C = bsxfun(@times, A(:,:,:,:,1), B(:,:,:,1,:));
        for k = 2:sA(5)
            C = C + bsxfun(@times, A(:,:,:,:,k), B(:,:,:,k,:));
        end
    end
end
