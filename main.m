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
Options=struct;
  Options.Wedge=8;
  Options.Wline=-8;
  Options.Wterm=0;
  Options.Sigma1=4;
% estraggo l'energia e la trasmormo in scala di grigi
Eext = ExternalForceImage2D(angle1,Options.Wline, Options.Wedge, Options.Wterm,Options.Sigma1);

% prendo i nuclei
Eextclear=imclearborder(Eext);
risaltodeinuclei=imcomplement(Eext)+Eextclear;

%  risaltodeinuclei=imfill(risaltodeinuclei,'holes');
% binarizzo per separare il foreground dal background
Eextbin = imbinarize(risaltodeinuclei,1.02);
Eextbin=imopen(Eextbin,strel('disk',30));
onlyLeuco=Eextbin.*angle;

Pmed = ordfilt2(angle,18,true(5));
Pmed1 = ordfilt2(onlyLeuco,18,true(5));

diff = Pmed - angle;
diff1 = Pmed1 - onlyLeuco;

diff3 = diff;
diff2 = diff1;

diff2(diff1<30)=0;
diff3(diff<30)=0;

% %% Segmentazione con skel
over=imoverlay(diff3,diff2,'red');
diff3=uint8(diff3)-uint8(over(:,:,2));
figure(2), imshow(diff3)

diff3=imbinarize(diff3,'adaptive');

%% Show visual result
p = reshape(predicted, size(I,1), size(I,2));
p(diff3==1)=0;
figure(1), imshow(I);
figure(3), imshow(p);

