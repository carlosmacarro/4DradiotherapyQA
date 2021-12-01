% This function visualizes 2D registration results by deforming image g
% with the transformation T and overlaying it on image f. The displacement
% field is also plotted with the spatial resolution 'res' (see the default
% value in the code).
% 
% showRegResults2D(f, g, T, res)
% 
% See also: registerMSI, interpT, MSI_CLI

% Code by Iman Aganj.

function showRegResults2D(f, g, T, res)

s = size(f);
if ~exist('res', 'var') || isempty(res)
    res = round(max(s)/20);
end
I = zeros([s 3]);
mx = max(max(f(:)), max(g(:)));
I(:,:,1) = f / mx;
I(:,:,2) = interpT(T, g) / mx;

imshow(I, 'InitialMagnification', 'fit')
hold on
[Id(:,:,2), Id(:,:,1)] = meshgrid(1:s(2), 1:s(1));
D = T - Id;
quiver(T(1:res:end,1:res:end,2), T(1:res:end,1:res:end,1), -D(1:res:end,1:res:end,2), -D(1:res:end,1:res:end,1), 0, 'm');
hold off
