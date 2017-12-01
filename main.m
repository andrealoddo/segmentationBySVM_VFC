%% Multi-Class SVM
clc
clear
close all

%% Import datasets
ALL_IDB = '/Users/andre/Google Drive/Uni/PhD/Work/Datasets/ALL_IDB';
ALL_IDB1 = '/Users/andre/Google Drive/Uni/PhD/Work/Datasets/ALL_IDB/ALL_IDB1';
ALL_IDB2 = '/Users/andre/Google Drive/Uni/PhD/Work/Datasets/ALL_IDB/ALL_IDB2';
pFalciparumDB = '/Users/andre/Documents/MATLAB/Malaria/1_PlasmodiumFalciparumDataset';
plasmodiumDB = '/Users/andre/Documents/MATLAB/Malaria/2_PlasmodiumDataset';

%% My code -> training set settings
classNumbers = 3; % WBC, RBC, bkgrd, parasites...
trainingImagesNumber = 73; % 73, 200, 260;
trainingSetPixels = 900;
opt = 1;
dbDir = ALL_IDB;

I = im2double( imread( fullfile( ALL_IDB1, 'im', 'Im001_1.jpg') ) );
I = im2double( imread( fullfile( plasmodiumDB, 'Vivax', '1703121298', '1703121298-0001.tif') ) );
I = imresize(I, 0.25);
%I = im2double( imread( fullfile( ALL_IDB2, 'img', 'Im001_1.tif') ) );

%% Sampling and training
[trainingSet, trainingClasses] = svm.getTrainingSamples( ...
    classNumbers, trainingImagesNumber, trainingSetPixels, dbDir, opt );
trainingClasses = trainingClasses - 1;
%Model = svm.train( trainingSet, trainingClasses );

%% SVM Classification
testSet = reshape(I, [size(I,1)*size(I,2), 3]);
%predict = svm.predict(Model, testSet);

[Model, predicted] = svm.classify(trainingSet, trainingClasses, testSet);

%disp('class predict')
%disp([class predict])

%% Find Accuracy
%Accuracy = mean(trainingClasses==predicted)*100;
%fprintf('\nAccuracy =%d\n',Accuracy)

%% Show visual result
p = reshape(predicted, size(I,1), size(I,2));
figure(1), imshow(I);
figure(2), imshow(p);

