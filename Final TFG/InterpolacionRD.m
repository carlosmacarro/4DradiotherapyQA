%%%%%%%%%%%%%%%%%%
%SCRIPT PRINCIPAL%
%%%%%%%%%%%%%%%%%%
%Run all necesary steps to perform tumor phases interpolation

load('RegionGrowingData.mat'); %Load RegionGrowing data 
RSej = dicominfo('1-1Case108'); %Load template DICOM for RG to RS transformation
leeDicom('D:\Marta Puente\datos\Lung4DnewCase108\'); %Load full case DICOM for coordinates transformation

%Checks if masks is included in RG, if so, modifies it for calculations
if isfield(RG, 'masks')
    modifyRGmask;
    RG=RGprev;
end

%Perform deformable register and interpolation
[M, lim] = slicesMatrix(RG, 512, 512); 
RD = regDeformableT(M, 1);

RGnew = newRG(RG, RD); %Add interpolated volumens to the original data

%Transform the new data to the accepted format by CARMEN
%Modifies struct RS, specifically coordinates and number of points
RGtoRSnew(RGnew, RSej, infoD); %MatLab 2020a required 
