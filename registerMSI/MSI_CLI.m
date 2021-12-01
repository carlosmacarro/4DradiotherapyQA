% This is the command-line interface for mid-space-independent deformable
% image registration. It is especially useful to compile this file with
% 'mcc -m MSI_CLI', so it can be run on computers with no Matlab license.
% Run MSI_CLI without arguments to see the help page.
%
% See also:   registerMSI, interpT, showRegResults2D

% Codes by Iman Aganj

function MSI_CLI(varargin)

if nargin==0
    varargin{1} = 'none';
end
p = inputParser;
p.FunctionName = mfilename;
p.StructExpand = false;
switch upper(varargin{1})
    case 'REGISTER'
        if nargin<4
            disp('Registers a pair of 2D or 3D same-contrast images using the')
            disp('mid-space-independent (MSI) deformable registration approach. The images')
            disp('and transformations must be in the NIFTI format. Depending on the chosen')
            disp('methods and image dimension, a default value is assigned to any')
            disp('unspecified optional parameter.')
            disp(' ')
            disp('MSI_CLI register <input_image1> <input_image2> <output_transform>')
            disp('        [lambda <lambda>] [step <step>] [maxIter <maxIter>] [methodData <methodData>]')
            disp('        [methodRegul <methodRegul>] [logBarrier <logBarrier>]')
            disp('        [multiRes <multiRes>] [indexGPU <indexGPU>] [show <show>]')
            disp(' ')
            disp('input_image1:       First (reference) input image.')
            disp('input_image2:       Second (resampled) input image.')
            disp('output_transform:   Filename to save the computed transformation.')
            disp(' ')
            disp('Optional parameters:')
            disp('lambda:             Regularization parameter.')
            disp('step:               Optimization step size.')
            disp('maxIter:            The number of iterations at each level of resolution')
            disp('                    (default: [100,50,25]).')
            disp('methodData:         Data term:')
            disp('                       0           --> asymmetric')
            disp('                       1           --> symmetrization')
            disp('                       2 (default) --> MSI')
            disp('methodRegul:        Regularization term:')
            disp('                       0 (default) --> asymmetric')
            disp('                       1           --> symmetrization')
            disp('                       2           --> MSI')
            disp('logBarrier:         The weight of the logarithmic barrier that keeps the')
            disp('                    Jacobian determinant positive (default: 1e-6).')
            disp('multiRes:           The down-sampling scales for the multi-resolution')
            disp('                    levels (default: [2,2], for the quarter-, half-, and')
            disp('                    full-resolution levels).')
            disp('indexGPU:           If provided, the GPU device specified by this index')
            disp('                    will be used. Run ''CSAODF_CLI GPUs'' to see the')
            disp('                    indices of the available GPUs.')
            disp('show:               If 1, the process is illustrated on a figure (2D only)')
            disp('                    (default: 0).')
            disp(' ')
            disp('Reference for MSI registration:')
            disp(' ')
            disp('I. Aganj, J. E. Iglesias, M. Reuter, M. R. Sabuncu, and B. Fischl,')
            disp('"Mid-space-independent deformable image registration," NeuroImage, vol.')
            disp('152, pp. 158-170, 2017. http://doi.org/10.1016/j.neuroimage.2017.02.055')
            disp(' ')
            return
        end
        p.addRequired('input_image1');
        p.addRequired('input_image2');
        p.addRequired('output_transform');
        p.addParameter('lambda', []);
        p.addParameter('step', []);
        p.addParameter('maxIter', []);
        p.addParameter('methodData', []);
        p.addParameter('methodRegul', []);
        p.addParameter('logBarrier', []);
        p.addParameter('multiRes', []);
        p.addParameter('indexGPU', '0');
        p.addParameter('show', []);
        p.parse(varargin{2:end});
        param = [];
        if ~isempty(p.Results.lambda)
            param.lambda = str2double(p.Results.lambda);
        end
        if ~isempty(p.Results.step)
            param.step = str2double(p.Results.step);
        end
        if ~isempty(p.Results.maxIter)
            param.maxIter = str2num(p.Results.maxIter);
        end
        if ~isempty(p.Results.methodData)
            param.Method = str2double(p.Results.methodData);
        end
        if ~isempty(p.Results.methodRegul)
            param.MethodReg= str2double(p.Results.methodRegul);
        end
        if ~isempty(p.Results.logBarrier)
            param.logBarrier = str2double(p.Results.logBarrier);
        end
        if ~isempty(p.Results.multiRes)
            param.nMR = str2num(p.Results.multiRes);
        end
        if ~isempty(p.Results.show)
            param.showFigure = str2double(p.Results.show);
        end
        disp('Reading the images...')
        I1 = load_nifti_allOS(p.Results.input_image1);
        I2 = load_nifti_allOS(p.Results.input_image2);
        D = ndims(I1.vol);
        I1.vol = registerMSI(I1.vol, I2.vol, param, str2double(p.Results.indexGPU));
        I1.dim(D+2) = size(I1.vol,D+1);
        I1.datatype = 64;
        save_nifti_allOS(I1, p.Results.output_transform);
    case 'APPLYTRANSFORM'
        if nargin<4
            disp('Deforms ''input_image'' using the transformation ''input_transform'', and')
            disp('saves it into ''output_image''. The interpolation method ''interpMethod''')
            disp('(optional) can be ''nearest'', ''linear'' (default), ''spline'', or ''cubic''.')
            disp(' ')
            disp('MSI_CLI applyTransform <input_image> <input_transform> <output_image>')
            disp('        [interpMethod <interpMethod>]')
            disp(' ')
            return
        end
        p.addRequired('input_image');
        p.addRequired('input_transform');
        p.addRequired('output_image');
        p.addParameter('interpMethod', 'linear');
        p.parse(varargin{2:end});
        disp('Reading the images...')
        I = load_nifti_allOS(p.Results.input_image);
        T = load_nifti_allOS(p.Results.input_transform);
        I.vol = interpT(T.vol, I.vol, p.Results.interpMethod);
        save_nifti_allOS(I, p.Results.output_image);
    case 'SHOW'
        if nargin<4
            disp('Visualizes 2D registration results by deforming ''input_image2'' with the')
            disp('transformation ''input_transform'' and overlaying it on ''input_image1''.')
            disp('The displacement field is plotted every ''res'' (optional) pixels.')
            disp(' ')
            disp('MSI_CLI show <input_image1> <input_image2> <input_transform> [res <res>] ')
            disp(' ')
            return
        end
        p.addRequired('input_image1');
        p.addRequired('input_image2');
        p.addRequired('input_transform');
        p.addParameter('res', []);
        p.parse(varargin{2:end});
        if isempty(p.Results.res)
            res = [];
        else
            res = str2double(p.Results.res);
        end
        disp('Reading the images...')
        I1 = load_nifti_allOS(p.Results.input_image1);
        I2 = load_nifti_allOS(p.Results.input_image2);
        T = load_nifti_allOS(p.Results.input_transform);
        showRegResults2D(I1.vol, I2.vol, T.vol, res)
    case 'GPUS'
        nGPUs = gpuDeviceCount;
        switch nGPUs
            case 0
                disp('No GPU device was found. If this is unexpected, make sure that you have the most up-to-date CUDA driver.');
            case 1
                disp('The following GPU device was found.');
            otherwise
                disp(['The following ' num2str(nGPUs) ' GPU devices were found.'])
        end
        for n = 1:nGPUs
            fprintf('GPU device %d:\n\n', n)
            disp(gpuDevice(n))
        end
    otherwise
        disp('Mid-space-independent (MSI) deformable image registration.')
        disp('Usage:')
        disp('                  MSI_CLI <command> [options]')
        disp(' ')
        disp('One of the following can be used for ''command'':')
        disp(' ')
        disp('register:         Registers two images.')
        disp('applyTransform:   Applies the computed transformation to an image.')
        disp('show:             Plots the transformation (2D only).')
        disp('GPUs:             Shows the indices of the available GPUs.')
        disp(' ')
        disp('Developed by Iman Aganj.')
        disp('http://nmr.mgh.harvard.edu/~iman')
        disp(' ')
end

end


function V = load_nifti_allOS(filename)

if ~isunix && strcmp(filename(end-2:end), '.gz')
    disp(['Extracting ' filename ' ...'])
    gunzip(filename)
    filename = filename(1:end-3);
end
V = load_nifti(filename);  % load_nifti.m is part of FreeSurfer's Matlab codes.

end


function save_nifti_allOS(V, filename)

if ~isunix && strcmp(filename(end-2:end), '.gz')
    filename = filename(1:end-3);
    save_nifti(V, filename);  % save_nifti.m is part of FreeSurfer's Matlab codes.
    disp(['Compressing ' filename ' ...'])
    gzip(filename)
else
    save_nifti(V, filename);
end

end
