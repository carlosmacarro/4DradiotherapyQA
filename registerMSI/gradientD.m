% Computes the gradient.

% Code by Iman Aganj.

function G = gradientD(V, gradD, midVoxelDiscrete)

if exist('gradD', 'var') && ~isempty(gradD)
    if ~exist('midVoxelDiscrete', 'var') || ~midVoxelDiscrete
        G = zeros(size(V), 'like', V);
        switch gradD
            case 1
                G(2:end-1,:,:,:) = .5*(V(3:end,:,:,:)-V(1:end-2,:,:,:));
                G([1 end],:,:,:) = V([2 end],:,:,:)-V([1 end-1],:,:,:);
            case 2
                G(:,2:end-1,:,:) = .5*(V(:,3:end,:,:)-V(:,1:end-2,:,:));
                G(:,[1 end],:,:) = V(:,[2 end],:,:)-V(:,[1 end-1],:,:);
            case 3
                G(:,:,2:end-1,:) = .5*(V(:,:,3:end,:)-V(:,:,1:end-2,:));
                G(:,:,[1 end],:) = V(:,:,[2 end],:)-V(:,:,[1 end-1],:);
            otherwise
                error('gradD needs to be 1, 2, or 3!')
        end
    else
        G = zeros(size(V), 'like', V);
        switch gradD
            case 1
                G(2:end,:,:,:) = V(2:end,:,:,:) - V(1:end-1,:,:,:);
            case 2
                G(:,2:end,:,:) = V(:,2:end,:,:) - V(:,1:end-1,:,:);
            case 3
                G(:,:,2:end,:) = V(:,:,2:end,:) - V(:,:,1:end-1,:);
        end
    end
else
    if ~exist('midVoxelDiscrete', 'var') || ~midVoxelDiscrete
        D = ndims(V);
        G = zeros([size(V) D], 'like', V);
        if D==2
            G(2:end-1,:,1) = .5*(V(3:end,:)-V(1:end-2,:));
            G([1 end],:,1) = V([2 end],:)-V([1 end-1],:);
            G(:,2:end-1,2) = .5*(V(:,3:end)-V(:,1:end-2));
            G(:,[1 end],2) = V(:,[2 end])-V(:,[1 end-1]);
        else
            G(2:end-1,:,:,1) = .5*(V(3:end,:,:)-V(1:end-2,:,:));
            G([1 end],:,:,1) = V([2 end],:,:)-V([1 end-1],:,:);
            G(:,2:end-1,:,2) = .5*(V(:,3:end,:)-V(:,1:end-2,:));
            G(:,[1 end],:,2) = V(:,[2 end],:)-V(:,[1 end-1],:);
            G(:,:,2:end-1,3) = .5*(V(:,:,3:end)-V(:,:,1:end-2));
            G(:,:,[1 end],3) = V(:,:,[2 end])-V(:,:,[1 end-1]);
        end
    else
        D = ndims(V)-1;
        G = zeros(size(V), 'like', V);
        if D==2
            G(2:end,:,1) = V(2:end,:,1) - V(1:end-1,:,1);
            G(:,2:end,2) = V(:,2:end,2) - V(:,1:end-1,2);
        else
            G(2:end,:,:,1) = V(2:end,:,:,1) - V(1:end-1,:,:,1);
            G(:,2:end,:,2) = V(:,2:end,:,2) - V(:,1:end-1,:,2);
            G(:,:,2:end,3) = V(:,:,2:end,3) - V(:,:,1:end-1,3);
        end
    end
end
