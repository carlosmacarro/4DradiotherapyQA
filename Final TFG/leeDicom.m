function leeDicom(filename)
    files=dir(filename);
    ndicoms=size(files,1);
    dicom=cell(ndicoms,1);
    for i=1:ndicoms
        if files(i).isdir==0
            dicom{i,1}=files(i).name;
        else
        end
    end
    dicom = dicom(~any(cellfun('isempty', dicom), 2), :);
    sorted=sort(dicom);

    for i=1:length(sorted) 
        info{i}=sorted{1, i};
        slicepositions(i)=info{i}.ImagePositionPatient(3);
    end

    jumps=0:size(slicepositions,2)/10:size(slicepositions,2);

    for i=1:size(jumps,2)-1
        [slicepositions(1,1+jumps(i):jumps(i+1)),I]=sort(slicepositions(1,1+jumps(i):jumps(i+1)));
        a=infoD(1,1+jumps(i):jumps(i+1));
        b=a(I);
        infoD(1,1+jumps(i):jumps(i+1))=b;
    end
end
