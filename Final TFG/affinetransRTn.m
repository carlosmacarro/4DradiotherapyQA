function [ xyzcoord ] = affinetransRTn( info, struct )
%Transform pixel coordinates to x,y,z(mm) space coordinates
%Inputs:
%   info: is a cell with the info for all slices as a structure (use
%   leeDicom) 1xnumberofdicoms
%   struct: is the rcs coord of the structure which we want to transform

nsl=size(info,2);
ny=double(info{1,1}.Height);
nx=double(info{1,1}.Width);
T1=double(info{1,1}.ImagePositionPatient);
spacing=double(info{1,1}.PixelSpacing);
dx=spacing(1);
dy=spacing(2);
dz=double(info{1,1}.SliceThickness);
dX=[1;1;1].*dx;
dY=[1;1;1].*dy;
dZ=[1;1;1].*dz;
dircos=double(info{1,1}.ImageOrientationPatient);
dircosX=dircos(1:3);
dircosY=dircos(4:6);

if nsl == 1;
    dircosZ = cross(dircosX,dircosY);
else
    N = nsl;
    TN = double(info{1,N}.ImagePositionPatient);
    dircosZ = ((T1-TN)./nsl)./dZ;
end

alldircos=[dircosX dircosY dircosZ];
allspacing=[dX dY dZ];

R=alldircos.*allspacing;

A = [[R T1];[0 0 0 1]];

n=size(struct,1);
coord=[];
for i=1:n
    rcs=[struct(i,1);struct(i,2);struct(i,3);1];
    PxPyPz=A*rcs;
    unit=dz/10;
    int=fix(struct(i,3));
    pl=struct(i,3)-int;
    slipos=info{1,ceil(struct(i,3))}.SliceLocation + pl*unit;
    coord=[coord; PxPyPz(1); PxPyPz(2); slipos];
    %struct=struct(4:end);
end

xyzcoord=coord;

end
