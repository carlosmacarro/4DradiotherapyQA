function [ ROIcs, StructSet, RS ] = RGtoRSnew( RGdata, template, infoD )
%Create a DICOM file from the RegionGrowing data
%Inputs:
%   RGdata: RegionGrowing data, struct RG
%   template: DICOM file example
%   infoD: cell containing every DICOM file from the case
%MATLAB 2020a required

contour_table = dicomContours(template);
new_contour = contour_table; % This is a table
nroi = new_contour.ROIs.Number;
for i=1:size(nroi)
    new_contour = deleteContour(new_contour,nroi(i));
end

for i=1:numel(fieldnames(RGdata.vol))
%     if fix(i)~=i
%         slices=RGdata.vol.(['phase' num2str(fix(i)) '_' '5'])(:,3);
%     else
        slices=RGdata.vol.(['phase' num2str(i)])(:,3);
%     end
    uslices=unique(slices);
%     alignd=RSaligncoord(RGdata.vol.(['phase' num2str(i)]));
    ROIDisplayColor=[255;0;0];
    ROINumber=i;
    contour_points=cell(size(uslices,1),1);
    for k=1:size(uslices,1)
        [rowf, colf]=find(slices==uslices(k),1,'first');
        [rowl, coll]=find(slices==uslices(k),1,'last');
        contour_points{k,1}=RGdata.vol.(['phase' num2str(i)])((rowf):rowl,:);
        %NumberOfContourPoints=size(ROIContourSequence.(['Item_' num2str(i)]).ContourSequence.(['Item_' num2str(k)]).ContourData,1)/3;
    end
    ROIName=['phase' num2str(i) 'struct'];
    new_contour = addContour(new_contour, ROINumber, ROIName, ...
            contour_points, 'Closed_planar', ROIDisplayColor);
    clear contour_points
end

info = convertToInfo(new_contour);

for i = 1 : height(new_contour.ROIs)

    % Set Frame of Reference to Referred frame of Reference Sequence
     info.StructureSetROISequence.(['Item_',num2str(i)]).ReferencedFrameOfReferenceUID = ...
         template.StructureSetROISequence.Item_1.ReferencedFrameOfReferenceUID;
     info.StructureSetROISequence.(['Item_',num2str(i)]).ROIGenerationAlgorithm = ...
     template.StructureSetROISequence.Item_1.ROIGenerationAlgorithm;

     % Additional information (Not required)
     info.RTROIObservationsSequence.(['Item_',num2str(i)]).ObservationNumber = ROINumber;
     info.RTROIObservationsSequence.(['Item_',num2str(i)]).ROIInterpreter =...
            template.RTROIObservationsSequence.Item_1.ROIInterpreter;
     info.RTROIObservationsSequence.(['Item_',num2str(i)]).ROIObservationLabel = ROIName;
     info.RTROIObservationsSequence.(['Item_',num2str(i)]).RTROIInterpretedType = 'Closed_planar';
end
 
for i=1:numel(fieldnames(info.ROIContourSequence))
    contour=info.ROIContourSequence.(['Item_' num2str(i)]).ContourSequence;
    for j=1:numel(fieldnames(contour))
        x = contour.(['Item_' num2str(j)]).ContourData(1:3:end);
        y = contour.(['Item_' num2str(j)]).ContourData(2:3:end);
        z = contour.(['Item_' num2str(j)]).ContourData(3:3:end);
        xyzaffine = affinetransRTn(infoD, [x(:) y(:) z(:)]);
        X=xyzaffine(1:3:end); 
        Y=xyzaffine(2:3:end);
        Z=xyzaffine(3:3:end);
        coord=[];
        if size(xyzaffine,1)>9
            B=boundary(X(:),Y(:));
            for h=1:size(B,1)
                coord=[coord; X(B(h)); Y(B(h)); Z(1,1)];
            end 
        else
            coord=xyzaffine;
        end
        info.ROIContourSequence.(['Item_' num2str(i)]).ContourSequence...
        .(['Item_' num2str(j)]).ContourData = coord; %xyzaffine
        info.ROIContourSequence.(['Item_' num2str(i)]).ContourSequence...
        .(['Item_' num2str(j)]).NumberOfContourPoints = length(coord)/3; %xyzaffine
    end
end

    % Change date for new metafile
    %[info.InstanceCreationTime,info.InstanceCreationDate, info.FileModDate] = get_date4dicom();

    dicomwrite([],'RSdicom',info,'CreateMode','Copy');

%ROIcs=ROIContourSequence;
%StructSet=Sset;
%info = convertToInfo();
%info.ROIContourSequence=ROIContourSequence;
%info.StructureSetROISequence=Sset;
%info.Modality='RTSTRUCT';
%info.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID=info.ReferencedImageSequence.Item_1.ReferencedSOPInstanceUID;
%info.FrameOfReferenceUID=info.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID; %%%%%%%
%RS=info;
%dicomwrite([],'RS',info, 'CreateMode', 'copy')
end

