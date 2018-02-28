function [LBP,H] = im2lbp(varargin) % image,radius,neighbors,mapping,mode)
%LBP returns the local binary pattern image or LBP histogram of an image.
%  LBP = LBP(I,R,N) returns either a local binary pattern
%  coded image or the local binary pattern histogram of an intensity image 
%  I. The LBP codes are computed using N sampling points on a circle of 
%  radius R and using mapping table, whose type is defined in MAPTYPE 
%  (u2- uniform, ri- rotation invariant, riu2- uniform rotationinvariant)
%  LBP = LBP(I,SP) computes the LBP codes using n sampling points defined 
%  in (n * 2) matrix SP. The sampling points should be defined around the 
%  origin (coordinates (0,0)).
%
%  Examples
%  --------
%       I=imread('rice.png');
%       	 %LBP image and histogram in (8,1) 
%                                neighborhood using uniform patterns
%
%       SP = [0 1; -1 1 ; -1 0; -1 -1; 0 -1;  1 -1; 1 0; 1 1];
%       [LBP, H] =im2lbp(I,SP); %LBP using sampling points
% Check number of input arguments.
narginchk(1,4);
image=varargin{1};
d_image=double(image);

if nargin==1
    spoints = [0 1; -1 1 ; -1 0; -1 -1; 0 -1;  1 -1; 1 0; 1 1];
    neighbors = 8;
    maptype = 'no';
end

if (nargin == 2) && (length(varargin{2}) == 1)
    error('Input arguments');
end

if (nargin > 2) && (length(varargin{2}) == 1)
    radius=varargin{2};
    neighbors=varargin{3};  
    spoints=zeros(neighbors,2);
   
    a = 2*pi/neighbors;  % Angle step.

    for i = 1:neighbors
        spoints(i,1) = -radius*sin((i-1)*a);
        spoints(i,2) = radius*cos((i-1)*a);
    end
    
    if(nargin == 4)
        maptype=varargin{4};
    else
        maptype = 'no';
    end
end

if (nargin > 1) && (length(varargin{2}) > 1)
    spoints=varargin{2};
    neighbors=size(spoints,1);
    
    if(nargin == 3)
        maptype=varargin{3};
    else
        maptype = 'no';
    end
end

% Determine the dimensions of the input image.
[ysize, xsize] = size(image);

miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));

% Block size, each LBP code is computed within a block of size bsizey*bsizex
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;

% Coordinates of origin (0,0) in the block
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));

% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
if(xsize < bsizex || ysize < bsizey)
  error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end

% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Fill the center pixel matrix C.
C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);

bins = 2^neighbors;

% Initialize the LBP image with zeros.
LBP=zeros(dy+1,dx+1);

%Compute the LBP code image
for i = 1:neighbors
  y = spoints(i,1)+origy;
  x = spoints(i,2)+origx;
  % Calculate floors, ceils and rounds for the x and y.
  fy = floor(y); cy = ceil(y); ry = round(y);
  fx = floor(x); cx = ceil(x); rx = round(x);
  % Check if interpolation is needed.
  if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
    % Interpolation is not needed, use original datatypes
    N = image(ry:ry+dy,rx:rx+dx);
    D = N >= C; 
  else
    % Interpolation needed, use double type images 
    ty = y - fy;
    tx = x - fx;

    % Calculate the interpolation weights.
    w1 = roundn((1 - tx) * (1 - ty),-6);
    w2 = roundn(tx * (1 - ty),-6);
    w3 = roundn((1 - tx) * ty,-6) ;
    % w4 = roundn(tx * ty,-6) ;
    w4 = roundn(1 - w1 - w2 - w3, -6);
            
    % Compute interpolated pixel values
    N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
    N = roundn(N,-4);
    D = N >= d_C; 
  end  
  % Update the LBP image.
  v = 2^(i-1);
  LBP = LBP + v*D;
end

%Apply maptype if it is defined
if ~strcmp(maptype,'no')
    [map, bins] = getMapping(neighbors, bins, maptype);
    LBP = map(LBP+1);
end

if ((bins-1)<=intmax('uint8'))
    LBP=uint8(LBP);
elseif ((bins-1)<=intmax('uint16'))
    LBP=uint16(LBP);
else
    LBP=uint32(LBP);
end

if nargout ==2
    H=hist(LBP(:),0:(bins-1));
end

%-------------------------------------------------------------------------

function [map, bins] = getMapping(neighbors, bins, maptype)

if strcmp(maptype,'u2') %Uniform 2
    map = 0:bins-1;
    bin2 = dec2bin(map,neighbors);
    bin3 = circshift(bin2, -1,2);
    binsum = sum(bin2~=bin3,2)';
    isbin = binsum <= 2;
    top = sum(isbin);
    value = 0:top-1;
    map(isbin) = value;
    map(~isbin) = top;
    bins = top+1;
elseif strcmp(maptype,'ri') %rotation invariant
    map = 0:bins-1;
    bin2 = dec2bin(map,neighbors);
    mini = map;
    for i = 1:neighbors-1
        mini = min(mini, bin2dec(circshift(bin2,-1*i,2))');
    end
    [~, ~, idx] = unique(mini);
    top = max(idx);
    value = 0:top-1;
    map = value(idx);
    bins = top;
elseif strcmp(maptype,'riu2') %rotation invariant
    map = 0:bins-1;
    bin2 = dec2bin(map,neighbors);
    bin3 = circshift(bin2, -1,2);
    binsum = sum(bin2~=bin3,2)';
    rneighbors = repmat(1:neighbors, bins,1);
    rmap = repmat(map',1, neighbors);
    bin2sum = sum(bitget(rmap',rneighbors'));
    map = bin2sum;
    map(binsum > 2)= neighbors +1;
    bins = neighbors +2;
else
    error('Unknown maptype');
end

%-------------------------------------------------------------------------

function x = roundn(x, n)

narginchk(2, 2)
validateattributes(x, {'single', 'double'}, {}, 'ROUNDN', 'X')
validateattributes(n, {'numeric'}, {'scalar', 'real', 'integer'}, 'ROUNDN', 'N')

if n < 0
    p = 10 ^ -n;
    x = round(p * x) / p;
elseif n > 0
    p = 10 ^ n;
    x = p * round(x / p);
else
    x = round(x);
end