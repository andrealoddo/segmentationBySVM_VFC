function [BW]=regionMergingBigOversegmentedAreas(BW)

%% funzione che si occupa di unire le aree di grandi dimensioni che sono state oversegmentate
[labeledImagebig, numberOfObject] = bwlabel(BW);
blobMeasurements = regionprops(labeledImagebig, BW, 'all');
blobCentroid = [blobMeasurements(:).Centroid];
centroidsmallX = [blobCentroid(1:2:end-1)];
centroidsmallY = [blobCentroid(2:2:end)];

[labeledImagebig2, numberOfObject] = bwlabel(BW);
blobMeasurements = regionprops(labeledImagebig2, BW, 'all');
blobCentroid = [blobMeasurements(:).Centroid];
centroidbigX = [blobCentroid(1:2:end-1)];
centroidbigY = [blobCentroid(2:2:end)];
bigLen=numel(centroidbigX);
radius=50;

for i=1:bigLen
    for j=1:bigLen
        if i~=j
            distance = sqrt((centroidsmallX(i)-centroidbigX(j))^2+(centroidsmallY(i)-centroidbigY(j))^2);
        
            if distance<=radius
                small=labeledImagebig2==i;
                big=(labeledImagebig==j);
                union=small|big;
                union=imclose(union,strel('disk',10));
                BW=union|BW;
            end
        end  
         
    end

end