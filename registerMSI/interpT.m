% Deforms image f using the transformation T, and interpolates it using
% mthd, which can be 'nearest', 'linear' (default), 'spline', or 'cubic'.
% 
% fT = interpT(T, f, mthd)
% 
% See also: registerMSI, showRegResults2D, MSI_CLI, EXAMPLE.

% Code by Iman Aganj.

function fT = interpT(T, f, mthd)

if ismatrix(T)
    T = cat(3, T, ones(size(T)));
end
D = ndims(T)-1;

if ~exist('mthd', 'var')
    mthd = 'linear';
end
if D==2
    fT = interp2(f, T(:,:,2), T(:,:,1), mthd);
elseif D==3
    fT = interp3(f, T(:,:,:,2), T(:,:,:,1), T(:,:,:,3), mthd);
else
    error('The image should be 2D or 3D.')
end

fT(isnan(fT(:))) = 0;
