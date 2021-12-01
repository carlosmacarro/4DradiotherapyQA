function RD = regDeformableT(M, indexGPU)
%Performs deformable register in every phase and interpolates an
%intermediate volume between every two phases
%Returns a struct compound by the arrays that descript the new interpolated
%volumes
%Inputs:
%   M: struct that contains the original volumes phases arrays
%   indexGPU: optional. Default: 0. Index of the GPU to be used, if
%   available, in order to improve performance.

    tic
    clear param
    param.lambda = .01;       % Regularization parameter
    param.step = 5;           % Optimization step size
    param.showFigure = true;  % Show the images during registration
    
    if ~exist('indexGPU','var')
            indexGPU = 0;
    end
    
    n = numel(fieldnames(M));
    cellM2T = cell(1,n);
    for i=1:n
        if i==n
           j=1;
        else
            j=i+1;
        end
        M1 = M.(['phase' num2str(i)]);
        M2 = M.(['phase' num2str(j)]);
        T = registerMSI(M1, M2, param, indexGPU);
        M2T = interpT(T, M2);
        cellM2T{i} = M2T;
    end
    for i=1:n
          RD.M2T.(['phase' num2str(i) '_' '5']) = cellM2T{i};
    end
    toc
end