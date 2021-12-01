% Upsamples a transformation.

% Code by Iman Aganj.

function uT = upSampleT(T, N, interpMethod)

if ~exist('interpMethod', 'var')
    interpMethod = 'cubic';
end
d = ndims(T) - 1;
s = size(T);
gpuConversion = isa(T, 'gpuArray') && strcmp(interpMethod, 'cubic');

Id = T;
uId = zeros([s(1:end-1)*N s(end)], 'like', Id);
if d==2
    [Id(:,:,2), Id(:,:,1)] = meshgrid(1:s(2), 1:s(1));
    [uId(:,:,2), uId(:,:,1)] = meshgrid(1:(s(2)*N), 1:(s(1)*N));
else
    [Id(:,:,:,2), Id(:,:,:,1), Id(:,:,:,3)] = meshgrid(1:s(2), 1:s(1), 1:s(3));
    [uId(:,:,:,2), uId(:,:,:,1), uId(:,:,:,3)] = meshgrid(1:(s(2)*N), 1:(s(1)*N), 1:(s(3)*N));
end

D = T - Id;
if gpuConversion
    D = gather(D);
    uId = gather(uId);
end
for k=1:d
    if d==2
        uD(:,:,k) = interp2(D(:,:,k), (uId(:,:,2)-.5)/N+.5, (uId(:,:,1)-.5)/N+.5, interpMethod, 0);
    else
        uD(:,:,:,k) = interp3(D(:,:,:,k), (uId(:,:,:,2)-.5)/N+.5, (uId(:,:,:,1)-.5)/N+.5, (uId(:,:,:,3)-.5)/N+.5, interpMethod, 0);
    end
end
if gpuConversion
    D = gpuArray(D);
    uId = gpuArray(uId);
end

uT = N*uD + uId;
