function [BW]=regionMerging(BW)


%% estrazione centroidi dalle componenti piccole
%//Read in text and extract properties

s  = regionprops(BW, 'Centroid', 'PixelList');

soglia=3500;

BWsmall=BW;
CC = bwconncomp(BWsmall,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);

while max(numPixels)>soglia
    BWsmall(CC.PixelIdxList{idx}) = 0;
    CC = bwconncomp(BWsmall,8);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
end


[labeledImagesmall, numberOfObject] = bwlabel(BWsmall);
blobMeasurements = regionprops(labeledImagesmall, BWsmall, 'all');
blobCentroid = [blobMeasurements(:).Centroid];
centroidsmallX = [blobCentroid(1:2:end-1)];
centroidsmallY = [blobCentroid(2:2:end)];
smaLen=numel(centroidsmallX);

%% estrazione centroid aree grandi
BWbig=BW;
CC = bwconncomp(BWbig,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = min(numPixels);

while min(numPixels)<=soglia
    BWbig(CC.PixelIdxList{idx})=0;
    CC = bwconncomp(BWbig,8);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = min(numPixels);
end


[labeledImagebig, numberOfObject] = bwlabel(BWbig);
blobMeasurements = regionprops(labeledImagebig, BWbig, 'all');
blobCentroid = [blobMeasurements(:).Centroid];
centroidbigX = [blobCentroid(1:2:end-1)];
centroidbigY = [blobCentroid(2:2:end)];
bigLen=numel(centroidbigX);


newdist=inf;
for i=1:smaLen
    for j=1:bigLen
            distance = sqrt((centroidsmallX(i)-centroidbigX(j))^2+(centroidsmallY(i)-centroidbigY(j))^2);
            if distance<=newdist
                newdist=distance;
                labelsmall=i;
                labelbig=j;
            end
         
    end
    small=labeledImagesmall==labelsmall;
    big=(labeledImagebig==labelbig);
    union=small|big;
    
    union=imclose(union,strel('disk',5));

    BW=union|BW;
    newdist=inf;
end
