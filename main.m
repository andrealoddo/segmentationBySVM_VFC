%% Multi-Class SVM
clc
clear
close all

%% Import datasets
ALL_IDB = './ALL_IDB';
ALL_IDB1 = './ALL_IDB/ALL_IDB1';
ALL_IDB2 = './ALL_IDB/ALL_IDB2';
%pFalciparumDB = '/Users/andre/Documents/MATLAB/Malaria/1_PlasmodiumFalciparumDataset';
%plasmodiumDB = '/Users/andre/Documents/MATLAB/Malaria/2_PlasmodiumDataset';

%% My code -> training set settings
classNumbers = 3; % WBC, RBC, bkgrd, parasites...
trainingImagesNumber = 73; % 73, 200, 260;
trainingSetPixels = 600;
opt = 1;
dbDir = ALL_IDB;

I = im2double( imread( fullfile( ALL_IDB1, 'img', 'Im001_1.jpg') ) );
%I = im2double( imread( fullfile( plasmodiumDB, 'Vivax', '1703121298', '1703121298-0001.tif') ) );
I = imresize(I, 0.25);
% I = im2double( imread( fullfile( ALL_IDB2, 'img', 'Im001_1.tif') ) );

%% Sampling and training
[trainingSet, trainingClasses] = svm.getTrainingSamples( ...
    classNumbers, trainingImagesNumber, trainingSetPixels, dbDir, opt );
trainingClasses = trainingClasses - 1;
% Model = svm.train( trainingSet, trainingClasses );
%% SVM Classification
[Fext,f]=getVEF('',I);
u=Fext(:,:,1)./sqrt(Fext(:,:,1).*Fext(:,:,1) + Fext(:,:,2).*Fext(:,:,2));
v=Fext(:,:,2)./sqrt(Fext(:,:,1).*Fext(:,:,1) + Fext(:,:,2).*Fext(:,:,2));
testSet = [reshape(I, [size(I,1)*size(I,2), 3]), u(:), v(:)];
%predict = svm.predict(Model, testSet);

[Model, predicted] = svm.classify(trainingSet, trainingClasses, testSet);

%disp('class predict')
%disp([class predict])

%% Find Accuracy
%Accuracy = mean(trainingClasses==predicted)*100;
%fprintf('\nAccuracy =%d\n',Accuracy)

%% Segmentation step
angle=atan2(-v,u)*180/pi;
angle=angle+180;
angle1=bwdist(angle);
Pmed = ordfilt2(angle,18,true(5));

diff = Pmed - angle;

diff3 = diff;

diff3(diff<50)=0;

%% Show visual result
p = reshape(predicted, size(I,1), size(I,2));
figure(1), imshow(I);
figure(2), imshow(imoverlay(p,diff3));

