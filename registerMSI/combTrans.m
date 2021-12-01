% Combines (composes) two transformations.

% Code by Iman Aganj.

function T = combTrans(T1, T2, Id, N)

D = ndims(T1)-1;

if ~exist('Id', 'var') || isempty(Id)
    if D==2
        [Id(:,:,2), Id(:,:,1)] = meshgrid(1:size(T2,2), 1:size(T2,1));
    elseif D==3
        [Id(:,:,:,2), Id(:,:,:,1), Id(:,:,:,3)] = meshgrid(1:size(T2,2), 1:size(T2,1), 1:size(T2,3));
    else
        error ('Unknown size!')
    end
end
if exist('N', 'var') && N>1
    S = T2;
    T = cell(1,N);
    T{1} = combTrans(T1, S, Id);
    for k = 2:N
        S = combTrans(S, S, Id);
        T{k} = combTrans(T1, S, Id);    % Line search
    end
else
    T = zeros(size(T1), 'like', T1);
    T1 = T1 - Id;
    if D==2
        for k = 1:D
            T(:,:,k) = interp2(T1(:,:,k), T2(:,:,2), T2(:,:,1));
        end
    else
        for k = 1:D
            T(:,:,:,k) = interp3(T1(:,:,:,k), T2(:,:,:,2), T2(:,:,:,1), T2(:,:,:,3));
        end
    end
    T(isnan(T(:))) = 0;
    T = T + T2;
end
