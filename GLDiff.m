function [GLDMS, Dhists] = GLDiff(I1, I2, offsets)
% GLDM calculates the GLDM matrix for two given images
% Example
%       I = imread('cell.tif');
%       [GLDMS, Dhists] = GLDiff(I, I); 

if nargin==1, 
    I2 = I1; % Only one bands (classical GLCM)
    offsets = [0 1;-1 1;-1 0;-1 -1]; % Default offsets
elseif nargin==2
    if size(I1)==size(I2)
        offsets = [0 1;-1 1;-1 0;-1 -1]; % Default offsets
    elseif size(I2,2)==2
        offsets = I2; % Specified offset
        I2 = I1; % Only one bands (classical GLCM)
    else
        error('Error input parameters');
    end
elseif nargin == 3
    if size(I1)==size(I2) && size(offsets,2)~=2
        error('Error input parameters');
    end
else
    error('Error input parameters');  
end

numOffsets = size(offsets,1);
I1 = doubleimg(I1);
I2 = doubleimg(I2);

GLDMS = zeros(size(I1,1),size(I1,2),numOffsets);
for k = 1 : numOffsets % For each offset
    I2b = shiftMatrix(I2, offsets(k,:));  % Shift the second image using the offset
    GLDMS(:,:,k) = abs(I1 - I2b); % Compute GLDM
end

if nargout == 2
    Dhists = zeros(256, numOffsets);
    for k = 1 : numOffsets % For each offset
        Dhists(:,k) = computehist(GLDMS(:,:,k)+1); % Compute histogram
    end
end

%--------------------------------------------------------------------------
function img = doubleimg(img)% converts into double

if isfloat(img)
    if max(img(:)) <= 1
        img = img*255;
    end
else
    img = double(img);
end

%--------------------------------------------------------------------------
function onehist = computehist(GLimg)% Compute histogram

G = GLimg(:); % Vectorises image 
G(isnan(G))=[]; % Delete locations where subscripts are NaN
onehist = accumarray(G, 1, [256 1]); % Accumulates occurrence on histogram