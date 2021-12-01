% This is an example script showing how to use the mid-space-independent
% deformable image registration, described in:
%
% I. Aganj, J. E. Iglesias, M. Reuter, M. R. Sabuncu, and B. Fischl,
% "Mid-space-independent deformable image registration," NeuroImage, vol.
% 152, pp. 158-170, 2017. http://doi.org/10.1016/j.neuroimage.2017.02.055
%
% Codes are by Iman Aganj.
% http://nmr.mgh.harvard.edu/~iman


%% Load the input images
I1 = 1-double(rgb2gray(imread('78phase1.jpg')))/255;  % The reference image
I2 = 1-double(rgb2gray(imread('78phase2.jpg')))/255;  % The resampled image
%% Set some parameters
% For more parameters, see the help of registerMSI.m .
clear param
param.lambda = .01;       % Regularization parameter
param.step = 5;           % Optimization step size
param.showFigure = true;  % Show the images during registration

%% Registration
% T is the resulting transformation that deforms I2 to I1. For more
% information see the help of registerMSI.m.
tic
T = registerMSI(I1, I2, param);
toc
%% Show the results
% Deform I2 with the transformation T:
M2T = interpT(T, I2);
figure
subplot(1,3,1), imshow(I1),  title I1
subplot(1,3,2), imshow(M2T), title I2oT
subplot(1,3,3), imshow(I2),  title I2
% isosurface(M.phase1);
% isosurface(M2T);
% isosurface(M.phase2);
% %% Apply the transformation to a different image
% % Synthesize a mesh image:
% [X,Y] = ndgrid(1:size(I1,1), 1:size(I1,2));
% I3 = (mod(X,10)+mod(Y,10))/18;
% 
% % Deform I3 with the transformation T:
% I3T = interpT(T, I3);
% 
% figure
% subplot(1,2,1), imshow(I3),  title I3
% subplot(1,2,2), imshow(I3T), title I3oT
