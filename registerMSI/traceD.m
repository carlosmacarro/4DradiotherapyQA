% Computes the trace of a matrix.

% Code by Iman Aganj.

function t = traceD(A)

s = size(A);
D = s(end);
if s(D+1)~=s(D+2)
    error('Not square!')
end
t = zeros(s(1:D), 'like', A);
if D==2
    for i = 1:s(3)
        t = t + A(:,:,i,i);
    end
else
    for i = 1:s(4)
        t = t + A(:,:,:,i,i);
    end
end
