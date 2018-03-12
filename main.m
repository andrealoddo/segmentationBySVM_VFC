%% Import datasets
I = im2double( imread( 'Im001_1.jpg' ) );
%I = imresize(I, 0.25);

%% SVM settings
trainingImagesNumber = 73; % 73, 200, 260;
trainingSetPixels = 1800;
opt = 1;
dbDir = ALL_IDB;

rgbTestSet = featureExtraction(I, 'rgb');
[featVectRGB,~,iFV_rgb] = unique((rgbTestSet),'rows') ;

vfcTestSet = featureExtraction(I, 'vfc');
[featVectVFC,~,iFV_vfc] = unique((vfcTestSet ),'rows') ;


if exist(fullfile(pwd, 'RGB_Model.mat'), 'file') == 0

    disp('training rgb started');
    
    %% SVM 1: RGB sampling from gt_cn and model training
    [trainingSet, trainingClasses] = svm.getRGBTrainingSamples( ...
        trainingImagesNumber, trainingSetPixels, dbDir, opt );
    trainingClasses = trainingClasses - 1;
    
    %% SVM 1 Classification
    [RGB_Model, RGBprediction] = svm.classify(trainingSet, trainingClasses, featVectRGB);
    save('RGB_Model.mat', 'RGB_Model');

else
    load('RGB_Model.mat');
    RGBprediction = svm.predict(RGB_Model, featVectRGB);
end

if exist(fullfile(pwd, 'VFC_Model.mat'), 'file') == 0
    
    disp('training vfc started');
    
    %% SVM 2: VFC sampling from gt_cn and model training
    [trainingSet, trainingClasses] = svm.getVFCTrainingSamples( ...
        trainingImagesNumber, trainingSetPixels, dbDir, opt );
    trainingClasses = trainingClasses - 1;    
    
    %% SVM 2 Classification
    [VFC_Model, VFCprediction] = svm.classify(trainingSet, trainingClasses, featVectVFC);
    save('VFC_Model.mat', 'VFC_Model');
    
else    
    load('VFC_Model.mat');
    VFCprediction = svm.predict(VFC_Model, featVectVFC);
end

RGBprediction = RGBprediction(iFV_rgb);
p_rgb = reshape(RGBprediction, size(I,1), size(I,2));

VFCprediction = VFCprediction(iFV_vfc);
p_vfc = reshape(VFCprediction, size(I,1), size(I,2));
%figure(), imshow(I);
figure(), imshow(p_rgb);
[p_vfc, dir]=imgradient(uint8(p_vfc));
figure(), imshow(p_vfc);
