% Computes the Laplacian of a transformation.

% Code by Iman Aganj.

function L = laplacianTransD(T)

D = ndims(T)-1;
L = zeros(size(T), 'like', T);
if D==2
    L(2:end-1,:,:) = T(3:end,:,:)+T(1:end-2,:,:)-2*T(2:end-1,:,:);
    L(:,2:end-1,:) = L(:,2:end-1,:) + T(:,3:end,:)+T(:,1:end-2,:)-2*T(:,2:end-1,:);
else
    L(2:end-1,:,:,:) = T(3:end,:,:,:)+T(1:end-2,:,:,:)-2*T(2:end-1,:,:,:);
    L(:,2:end-1,:,:) = L(:,2:end-1,:,:) + T(:,3:end,:,:)+T(:,1:end-2,:,:)-2*T(:,2:end-1,:,:);
    L(:,:,2:end-1,:) = L(:,:,2:end-1,:) + T(:,:,3:end,:)+T(:,:,1:end-2,:)-2*T(:,:,2:end-1,:);
end
