RGprev =struct();
for i=1:numel(fieldnames(RG.masks))
    fase = RG.masks.(['phase' num2str(i)]);
    [x, y, z] = ind2sub(size(fase), find(fase));
    xyz=[y(:) x(:) z(:)];
    RGprev.vol.(['phase' num2str(i)])= xyz;
end
RGprev.phases=RG.phases;