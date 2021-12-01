% Computes the divergence of a transformation.

% Code by Iman Aganj.

function div = divergeD(A, midVoxelDiscrete)

s = size(A);
D = s(end);
div = zeros(s(1:(D+1)), 'like', A);
if D==2
    if ~exist('midVoxelDiscrete', 'var') || ~midVoxelDiscrete
        for j=1:2
            div = div + gradientD(A(:,:,:,j),j);
        end
    elseif midVoxelDiscrete==1
        for j=1:2
            div = div + gradientD(A(:,:,:,j,j),j,1);
        end
    end
else
    if ~exist('midVoxelDiscrete', 'var') || ~midVoxelDiscrete
        for j=1:3
            div = div + gradientD(A(:,:,:,:,j),j);
        end
    elseif midVoxelDiscrete==1
        for j=1:3
            div = div + gradientD(A(:,:,:,:,j,j),j,1);
        end
    end
end
