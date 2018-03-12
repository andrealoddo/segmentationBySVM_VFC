BW_rgb = im2bw(p_rgb);
BW = ~im2bw(p_vfc);

BW_diff=BW_rgb-BW;
figure;imshow(BW_diff)
testb=imerode(BW_diff, strel('disk', 1));
figure;imshow(testb)
imshow((imfill(testb,'holes')))
bw_fill = imfill(testb,'holes');
figure;imshow(bw_fill);
bw_er = imerode(bw_fill, strel('disk', 1));
test = regionMerging(bw_er);
BW_diff = regionMergingBigOversegmentedAreas(test);
test_fill=imfill(BW_diff,'holes');
test_clear=imclearborder(test_fill);
markers=bwareaopen(test_clear,1000);

D = bwdist(markers);
DL = watershed(D);
bgm = DL == 0;
gradmag2 = imimposemin(p_vfc, bgm | test_clear);
