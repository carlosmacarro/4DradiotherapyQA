% This function aligns, in multiple resolution levels, a pair of 2D or 3D
% same-contrast images using the mid-space-independent (MSI) deformable
% registration.
% 
% T = registerMSI(f, g, param, indexGPU)
% 
% f:         First (reference) input image.
% g:         Second (resampled) input image.
% param:     A structure containing the following registration parameters.
%            A default value is set to any non-existing field.
%    param.Method:      The data term:
%                         0 --> asymmetric
%                         1 --> symmetrization
%                         2 --> MSI (default)
%    param.MethodReg:   The regularization term:
%                         0 --> asymmetric (default)
%                         1 --> symmetrization
%                         2 --> MSI
%    param.lambda:      Regularization parameter (see the code for the
%                       default values).
%    param.step:        Optimization step size (see the code for the
%                       default values).
%    param.nMR:         The down-sampling scales for the multi-resolution
%                       levels. (default: [2 2], for the quarter-, half-,
%                       and full-resolution levels)
%    param.maxIter:     The number of iterations at each level of
%                       resolution. (default: [100 50 25])
%    param.logBarrier:  The weight of the logarithmic barrier that keeps
%                       the Jacobian determinant positive. (default: 1e-6)
%    param.showLS:      If 'true', line-search iterations are also shown.
%                       (default: false)
%    param.showFigure:  If 'true' in 2D registration, the process is
%                       illustrated on a figure. (default: false)
% indexGPU:  If provided, the GPU device specified by this index will be
%            used. See the gpuDevice command for more info.
% 
% T:         The computed transformation, deforming g to f.
% 
% Reference for MSI registration:
% 
% I. Aganj, J. E. Iglesias, M. Reuter, M. R. Sabuncu, and B. Fischl,
% "Mid-space-independent deformable image registration," NeuroImage, vol.
% 152, pp. 158-170, 2017. http://doi.org/10.1016/j.neuroimage.2017.02.055
% 
% See also: interpT, showRegResults2D, MSI_CLI, EXAMPLE.

% Code by Iman Aganj.

function T = registerMSI(f, g, param, indexGPU)

if ~exist('param', 'var')
    param = [];
end
D = ndims(f);
if D<2 || D>3
    error('Image dimension should be 2 or 3.')
end
if ~isfield(param, 'nMR')
    nMR = [2 2];
else
    nMR = param.nMR;
end
if ~isfield(param, 'Method')
    param.Method = 2;
end
if ~isfield(param, 'MethodReg')
    param.MethodReg = 0;
end
if ~isfield(param, 'step')
    if D==2
        if param.MethodReg==0
            switch param.Method
                case 0
                    param.step = 30;
                case 1
                    param.step = 10;
                case 2
                    param.step = 50;
            end
        else
            param.step = 0.3;
        end
    else
        if param.MethodReg==0
            switch param.Method
                case 0
                    param.step = 150;
                case 1
                    param.step = 60;
                case 2
                    param.step = 150;
            end
        else
            param.step = 3;
        end
    end
    disp(['Choosing step = ' num2str(param.step) ' .'])
end
if ~isfield(param, 'lambda')
    if D==2
        if param.MethodReg==0
            switch param.Method
                case 0
                    param.lambda = 0.003;
                case 1
                    param.lambda = 0.006;
                case 2
                    param.lambda = 0.004;
            end
        else
            param.lambda = 0.02;
        end
    else
        if param.MethodReg==0
            switch param.Method
                case 0
                    param.lambda = 0.003;
                case 1
                    param.lambda = 0.006;
                case 2
                    param.lambda = 0.003;
            end
        else
            param.lambda = 0.0006;
        end
    end
    disp(['Choosing lambda = ' num2str(param.lambda) ' .'])
end
if ~isfield(param, 'maxIter')
    param.maxIter = round(100*2.^-(0:length(nMR))); % e.g., [100 50 25]
    disp(['Choosing maxIter = [' replace(num2str(param.maxIter(1:end-1), '%d,'), ' ', '') num2str(param.maxIter(end)) '] .'])
end
maxIter = param.maxIter;
if ~isfield(param, 'logBarrier')
    param.logBarrier = 1e-6;
    disp(['Choosing logBarrier = ' num2str(param.logBarrier) ' .'])
end
if ~isfield(param, 'showFigure')
    param.showFigure = false;
end
if ~isfield(param, 'showLS')
    param.showLS = false;
end
% Use 'single' instead of 'double' for faster, but less precise results:
mx = double(max(max(f(:)), max(g(:))));
f = double(f) / mx;
g = double(g) / mx;
if exist('indexGPU', 'var') && indexGPU
    gpu = gpuDevice(indexGPU);
    disp(['Using the "' gpu.Name '" GPU...'])
    f = gpuArray(f);
    g = gpuArray(g);
end

T = [];
for k = length(nMR):-1:1
    sMR = prod(nMR(1:k))';
    disp(['Scale: ' num2str(sMR)])
    df = dSampleD(f,sMR);
    dg = dSampleD(g,sMR);
    param.maxIter = maxIter(length(nMR)-k+1);
    T = registerMSI_singleLevel(df, dg, param, cropT(T, size(df)));
    T = upSampleT(T, nMR(k));
end
clear df dg

disp('Scale: 1')
param.maxIter = maxIter(length(nMR)+1);
T = gather(registerMSI_singleLevel(f, g, param, cropT(T, size(f))));

function T = cropT(T, s)
if ~isempty(T)
    if ndims(T)-1 == 2
        T = T(1:s(1), 1:s(2), :);
    else
        T = T(1:s(1), 1:s(2), 1:s(3), :);
    end
end
