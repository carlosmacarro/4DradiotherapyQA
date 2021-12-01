function [M, lim] = slicesMatrix(data,m, n)
%Returns a struct with as many 3D arrays as phases, and the axis limits for
%the ghapic representation
%Each matrix is composed of one phase's slices images
%Inputs:
%   data: RegionGrowingData data. e.g.: RG
%   m, n: Dimensions of each slice image to be create. e.g.: 512x512
    names = fieldnames(data.vol);
    maxl = zeros(1,length(names));maxy = zeros(1,length(names));maxx = zeros(1,length(names));
    minl = zeros(1,length(names));miny = zeros(1,length(names));minx = zeros(1,length(names));
    for c=1:length(names)
       fase = data.vol.(['phase' num2str(c)]);
       maxl(c) = max(max(fase(:,3)));
       minl(c) = min(min(fase(:,3)));
       maxy(c) = max(max(fase(:,2)));
       miny(c) = min(min(fase(:,2)));
       maxx(c) = max(max(fase(:,1)));
       minx(c) = min(min(fase(:,1)));
    end
    ma = max(maxl);
    mi = min(minl);
    lim=[[min(minx) max(maxx)] [min(miny) max(maxy)] [min(minl) max(maxl)]];
    for j=1:length(names)
       fase = data.vol.(['phase' num2str(j)]);
       zuniq = unique(fase(:,3));
       Ifinal = zeros(m,n,length(zuniq));
       for i=1:1:length(zuniq)
           index = (fase(:,3)==zuniq(i));
           xy = fase(index, 1:2);
           x = xy(:,1);
           y = xy(:,2);
           k = boundary(x,y);
           if isempty(k)
              I = zeros(m,n);
              I(y(:),x(:))=1;
           else
              I = poly2mask(x(k), y(k), m, n);
           end
           Ifinal(:,:,i)= I;
       end
       if max(max(fase(:,3)))<ma
           dif = ma-max(max(fase(:,3)));
           Ifinal(:,:,end+dif) = 0;
       end
       if min(min(fase(:,3)))>mi
           dif = min(min(fase(:,3)))-mi;
           Ia = zeros(m,n, dif);
           Ifinal = cat(3, Ia, Ifinal);
       end
       
       M.(['phase' num2str(j)]) = Ifinal;
    end
    
    
end

