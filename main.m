%% Import datasets
%ALL_IDB = './ALL_IDB';
%ALL_IDB = 'D:\ImmaginiLavoro\Medical\WBC\ALL_IDB';
%ALL_IDB1 = fullfile( ALL_IDB, 'ALL_IDB1' );
%ALL_IDB2 = fullfile( ALL_IDB, 'ALL_IDB2' );
%pFalciparumDB = '/Users/andre/Documents/MATLAB/Malaria/1_PlasmodiumFalciparumDataset';
%plasmodiumDB = '/Users/andre/Documents/MATLAB/Malaria/2_PlasmodiumDataset';

%I = im2double( imread( fullfile( ALL_IDB1, 'img', 'Im001_1.jpg') ) );

I = im2double( imread( 'Im001_1.jpg' ) );
I = imresize(I, 0.25);
testSet = featureExtraction(I);
[featVectU,~,iFV] = unique((testSet),'rows') ;

if exist(fullfile(pwd, 'Model.mat'), 'file') == 0
    
    %% training set settings
    classNumbers = 3; % WBC, RBC, bkgrd, parasites...
    trainingImagesNumber = 100; % 73, 200, 260;
    trainingSetPixels = 1800;
    opt = 1;
    dbDir = ALL_IDB;
    
    %% Sampling and training
    [trainingSet, trainingClasses] = svm.getTrainingSamples( ...
        classNumbers, trainingImagesNumber, trainingSetPixels, dbDir, opt );
    trainingClasses = trainingClasses - 1;
    
    %% SVM Classification
    [Model, predicted] = svm.classify(trainingSet, trainingClasses, featVectU);
    save('Model.mat', 'Model');
else
    load('Model.mat');
    predicted = svm.predict(Model, featVectU);
end
predicted = predicted(iFV);
p = reshape(predicted, size(I,1), size(I,2));
figure(), imshow(I);
figure(), imshow(p);