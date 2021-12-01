% Down-samples an image.

% Code by Iman Aganj.

function J = dSampleD(I, N)

D = ndims(I);
I = padarray(I, N-mod(size(I)-1,N)-1, 'post'); % Zero-padding
J = convn(I, ones(ones(1,D)*N)/(N^D), 'same');
for i = 1:D
    J = permute(downsample(J, N, floor((N-1)/2)), circshift(1:D,[0,-1]));
end
