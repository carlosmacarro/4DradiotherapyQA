function RG = newRG(rg, rd)
%Modifies data variable RG adding the new interpolated phases
%Inputs:
%   rg: original data
%   rd: interpolated volumes

    RG = rg;
    newvols = struct();
    names = fieldnames(rd.M2T);
    m=zeros(1,length(names));
    for j=1:length(names)
        fase=rg.vol.(['phase' num2str(j)]);
        m(j) = min(min(fase(:,3)));
    end
    mi=min(m)-1;
    j=1;
    k=2;
    for i=1:rg.phases
        fase = rg.vol.(['phase' num2str(i)]);
        newvols.(['phase' num2str(j)]) = fase;
        fase = rd.M2T.(string(names(i)));
        [r,c,v] = ind2sub(size(fase), find(fase));
        rcv = [c(:) r(:) v(:)+mi];
        newvols.(['phase' num2str(k)]) = rcv;
        j=j+2;
        k=k+2;
    end

    RG.vol=newvols;
    RG.phases=numel(fieldnames(newvols));
end