% Computes the Jacobian of a transformation.

% Code by Iman Aganj.

function [J, detJ, C, invJ] = jacobianD(T, midVoxelDiscrete)

s = size(T);
D = s(end);
if ~exist('midVoxelDiscrete', 'var')
    midVoxelDiscrete = 0;
end
if midVoxelDiscrete==1 % Computes D sets of Jacobians, one for the mid-voxel of each dimension
    J = zeros([s(1:D) D D D], 'like', T);
    if D==2
        J(1:end-1,:,:,1,1) = T(2:end,:,:) - T(1:end-1,:,:);
        J(end,:,:,1,1) = .5*J(end-1,:,:,1,1);
        J(:,2:end-1,:,2,1) = .5*(T(:,3:end,:) - T(:,1:end-2,:));
        J(:,[1 end],:,2,1) = T(:,[2 end],:) - T(:,[1 end-1],:);
        J(1:end-1,:,:,2,1) = .5*(J(1:end-1,:,:,2,1) + J(2:end,:,:,2,1));
        
        J(2:end-1,:,:,1,2) = .5*(T(3:end,:,:) - T(1:end-2,:,:));
        J([1 end],:,:,1,2) = T([2 end],:,:) - T([1 end-1],:,:);
        J(:,1:end-1,:,1,2) = .5*(J(:,1:end-1,:,1,2) + J(:,2:end,:,1,2));
        J(:,1:end-1,:,2,2) = T(:,2:end,:) - T(:,1:end-1,:);
        J(:,end,:,2,2) = .5*J(:,end-1,:,2,2);
    else
        J(1:end-1,:,:,:,1,1) = T(2:end,:,:,:) - T(1:end-1,:,:,:);
        J(end,:,:,:,1,1) = .5*J(end-1,:,:,:,1,1);
        J(:,2:end-1,:,:,2,1) = .5*(T(:,3:end,:,:) - T(:,1:end-2,:,:));
        J(:,[1 end],:,:,2,1) = T(:,[2 end],:,:) - T(:,[1 end-1],:,:);
        J(:,:,2:end-1,:,3,1) = .5*(T(:,:,3:end,:) - T(:,:,1:end-2,:));
        J(:,:,[1 end],:,3,1) = T(:,:,[2 end],:) - T(:,:,[1 end-1],:);
        J(1:end-1,:,:,:,2:3,1) = .5*(J(1:end-1,:,:,:,2:3,1) + J(2:end,:,:,:,2:3,1));
        
        J(2:end-1,:,:,:,1,2) = .5*(T(3:end,:,:,:) - T(1:end-2,:,:,:));
        J([1 end],:,:,:,1,2) = T([2 end],:,:,:) - T([1 end-1],:,:,:);
        J(:,1:end-1,:,:,2,2) = T(:,2:end,:,:) - T(:,1:end-1,:,:);
        J(:,end,:,:,2,2) = .5*J(:,end-1,:,:,2,2);
        J(:,:,2:end-1,:,3,2) = .5*(T(:,:,3:end,:) - T(:,:,1:end-2,:));
        J(:,:,[1 end],:,3,2) = T(:,:,[2 end],:) - T(:,:,[1 end-1],:);
        J(:,1:end-1,:,:,[1 3],2) = .5*(J(:,1:end-1,:,:,[1 3],2) + J(:,2:end,:,:,[1 3],2));
        
        J(2:end-1,:,:,:,1,3) = .5*(T(3:end,:,:,:) - T(1:end-2,:,:,:));
        J([1 end],:,:,:,1,3) = T([2 end],:,:,:) - T([1 end-1],:,:,:);
        J(:,2:end-1,:,:,2,3) = .5*(T(:,3:end,:,:) - T(:,1:end-2,:,:));
        J(:,[1 end],:,:,2,3) = T(:,[2 end],:,:) - T(:,[1 end-1],:,:);
        J(:,:,1:end-1,:,2,3) = T(:,:,2:end,:) - T(:,:,1:end-1,:);
        J(:,:,end,:,2,3) = .5*J(:,:,end-1,:,2,3);
        J(:,:,1:end-1,:,1:2,3) = .5*(J(:,:,1:end-1,:,1:2,3) + J(:,:,2:end,:,1:2,3));
    end
    if nargout>2
        C = zeros([s(1:D) D D D], 'like', T);
        detJ = zeros([s(1:D) D], 'like', T);
        colD = repmat({':'}, 1, D);
        colJ = repmat({':'}, 1, D+2);
        for d=1:D
            IndD = [colD d];
            IndJ = [colJ d];
            [detJ(IndD{:}), C(IndJ{:})] = detD(J(IndJ{:}));
        end
    elseif nargout>1
        detJ = zeros([s(1:D) D], 'like', T);
        colD = repmat({':'}, 1, D);
        colJ = repmat({':'}, 1, D+2);
        for d=1:D
            IndD = [colD d];
            IndJ = [colJ d];
            detJ(IndD{:}) = detD(J(IndJ{:}));
        end
    end
    if nargout>3
        invJ = zeros([s(1:D) D D D], 'like', T);
        colD = repmat({':'}, 1, D);
        colJ = repmat({':'}, 1, D+2);
        for d=1:D
            IndD = [colD d];
            IndJ = [colJ d];
            invJ(IndJ{:}) = multD(1./detJ(IndD{:}),transD(C(IndJ{:}),D),D);
        end
    end
else
    J = zeros([s(1:D) D D], 'like', T);
    if midVoxelDiscrete==0 % Computes the Jacobian on the grid
        if D==2
            J(2:end-1,:,:,1) = .5*(T(3:end,:,:) - T(1:end-2,:,:));
            J([1 end],:,:,1) = T([2 end],:,:) - T([1 end-1],:,:);
            J(:,2:end-1,:,2) = .5*(T(:,3:end,:) - T(:,1:end-2,:));
            J(:,[1 end],:,2) = T(:,[2 end],:) - T(:,[1 end-1],:);
        else
            J(2:end-1,:,:,:,1) = .5*(T(3:end,:,:,:) - T(1:end-2,:,:,:));
            J([1 end],:,:,:,1) = T([2 end],:,:,:) - T([1 end-1],:,:,:);
            J(:,2:end-1,:,:,2) = .5*(T(:,3:end,:,:) - T(:,1:end-2,:,:));
            J(:,[1 end],:,:,2) = T(:,[2 end],:,:) - T(:,[1 end-1],:,:);
            J(:,:,2:end-1,:,3) = .5*(T(:,:,3:end,:) - T(:,:,1:end-2,:));
            J(:,:,[1 end],:,3) = T(:,:,[2 end],:) - T(:,:,[1 end-1],:);
        end
    elseif midVoxelDiscrete==2 % Computes the gradient at the half-voxel shift
        if D==2
            J(1:end-1,:,:,1) = T(2:end,:,:) - T(1:end-1,:,:);
            J(end,:,:,1) = .5*J(end-1,:,:,1);
            J(:,1:end-1,:,1) = .5*(J(:,1:end-1,:,1)+J(:,2:end,:,1));
            
            J(:,1:end-1,:,2) = T(:,2:end,:) - T(:,1:end-1,:);
            J(:,end,:,2) = .5*J(:,end-1,:,2);
            J(1:end-1,:,:,2) = .5*(J(1:end-1,:,:,2) + J(2:end,:,:,2));
        else
            J(1:end-1,:,:,:,1) = T(2:end,:,:,:) - T(1:end-1,:,:,:);
            J(end,:,:,:,1) = .5*J(end-1,:,:,:,1);
            J(:,1:end-1,:,:,1) = .5*(J(:,1:end-1,:,:,1)+J(:,2:end,:,:,1));
            J(:,:,1:end-1,:,1) = .5*(J(:,:,1:end-1,:,1)+J(:,:,2:end,:,1));
            
            J(:,1:end-1,:,:,2) = T(:,2:end,:,:) - T(:,1:end-1,:,:);
            J(:,end,:,:,2) = .5*J(:,end-1,:,:,2);
            J(1:end-1,:,:,:,2) = .5*(J(1:end-1,:,:,:,2)+J(2:end,:,:,:,2));
            J(:,:,1:end-1,:,2) = .5*(J(:,:,1:end-1,:,2)+J(:,:,2:end,:,2));
            
            J(:,:,1:end-1,:,3) = T(:,:,2:end,:) - T(:,:,1:end-1,:);
            J(:,:,end,:,3) = .5*J(:,:,end-1,:,3);
            J(1:end-1,:,:,:,3) = .5*(J(1:end-1,:,:,:,3)+J(2:end,:,:,:,3));
            J(:,1:end-1,:,:,3) = .5*(J(:,1:end-1,:,:,3)+J(:,2:end,:,:,3));
        end
    end
    if nargout>2
        [detJ, C] = detD(J);
    elseif nargout>1
        detJ = detD(J);
    end
    if nargout>3
        invJ = multD(1./detJ,transD(C,D),D);
    end
end
