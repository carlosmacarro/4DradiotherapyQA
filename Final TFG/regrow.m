function [P, J] = regrow(cIM, initPos, thresVal, maxDist)
%By Carlos Ribeiro de Sequeira Nunes
% error checking on input arguments

if ~exist('tfFillHoles', 'var')
    tfFillHoles = true;
end

if isequal(ndims(cIM), 2) %checkeo si es 2D o 3D
    initPos(3) = 1;
elseif isequal(ndims(cIM),1) || ndims(cIM) > 3
    error('There are only 2D & 3D image sets allowed!')
end

[nRow, nCol, nSli] = size(cIM);

if initPos(1) < 1 || initPos(2) < 1 ||...
   initPos(1) > nRow || initPos(2) > nCol
    error('Initial position out of bounds, please try again!')
end

if thresVal < 0 || maxDist < 0
    error('Threshold and maximum distance values must be positive!')
end

%if ~isempty(which('dpsimplify.m'))
%    if ~exist('tfSimplify', 'var')
%        tfSimplify = true;
%    end
%    simplifyTolerance = 1;
%else
%    tfSimplify = false;
%end


% initial pixel value
%initPos(3)=1;%%%%%%%%%%%%%%%%%%%%%%%%
pixelVal = double(cIM(initPos(1), initPos(2), initPos(3)));
%opixelVal = double(cIM(oPix(1),oPix(2),oPix(3)));

% text output with initial parameters
disp(['RegionGrowing Opening: Initial position (' num2str(initPos(1))...
      '|' num2str(initPos(2)) '|' num2str(initPos(3)) ') with '...
      num2str(pixelVal) ' as initial pixel value!'])

% preallocate array
J = false(nRow, nCol, nSli);

% add the initial pixel to the queue
seed = [initPos(1), initPos(2), initPos(3)];

%%% START OF REGION GROWING ALGORITHM
while size(seed, 1)
    
  % the first queue position determines the new values
  xv = seed(1,1);
  yv = seed(1,2);
  zv = seed(1,3);
 
  % .. and delete the first queue position
  seed(1,:) = [];
    
  % check the neighbors for the current position
  for i = -1:1
    for j = -1:1
      for k = -1:1
            
        if xv+i > 0  &&  xv+i <= nRow &&...          % within the x-bounds?
           yv+j > 0  &&  yv+j <= nCol &&...          % within the y-bounds?          
           zv+k > 0  &&  zv+k <= nSli &&...          % within the z-bounds?
           any([i, j, k])       &&...      % i/j/k of (0/0/0) is redundant!
           ~J(xv+i, yv+j, zv+k) &&...          % pixelposition already set?
           sqrt( (xv+i-initPos(1))^2 +...
                 (yv+j-initPos(2))^2 +...
                 (zv+k-initPos(3))^2 ) < maxDist &&...   % within distance?
           cIM(xv+i, yv+j, zv+k) <= (pixelVal + thresVal) &&...% within range
           cIM(xv+i, yv+j, zv+k) >= (pixelVal - thresVal) %&&...% of the threshold?
           %cIM(xv+i, yv+j, zv+k) > (opixelVal)

           % current pixel is true, if all properties are fullfilled
           J(xv+i, yv+j, zv+k) = true; 

           % add the current pixel to the computation queue (recursive)
           seed(end+1,:) = [xv+i, yv+j, zv+k];
        
        end        
      end
    end  
  end
end
%%% END OF REGION GROWING


% loop through each slice, fill holes and extract the polygon vertices
P = [];
for cSli = 1:nSli
    if ~any(J(:,:,cSli))
        continue
    end
    
	% use bwboundaries() to extract the enclosing polygon
    if tfFillHoles
        % fill the holes inside the mask
        J(:,:,cSli) = imfill(J(:,:,cSli), 'holes');    
        B = bwboundaries(J(:,:,cSli), 8, 'noholes');
    else
        B = bwboundaries(J(:,:,cSli));
    end
    
	newVertices = [B{1}(:,2), B{1}(:,1)];
	
    % simplify the polygon via Line Simplification
    %if tfSimplify
    %    newVertices = dpsimplify(newVertices, simplifyTolerance);        
    %end
    
    % number of new vertices to be added
    nNew = size(newVertices, 1);
    
    % append the new vertices to the existing polygon matrix
    if isequal(nSli, 1) % 2D
        P(end+1:end+nNew, :) = newVertices;
    else                % 3D
        P(end+1:end+nNew, :) = [newVertices, repmat(cSli, nNew, 1)];
    end
end

% text output with final number of vertices
disp(['RegionGrowing Ending: Found ' num2str(length(find(J)))...
      ' pixels within the threshold range (' num2str(size(P, 1))...
      ' polygon vertices)!'])