function J = rgb2you(J,you)
% Convert image color spaces from RGB to your choice color space

if numel(size(J)) < 3
    error('input image:must be true color image');
else
    color=[1 0 0 ; 0 1 0 ; 0 0 1 ; 1 1 0 ; 1 0 1 ; 0 1 1];
    switch you
        case 'r00'
            J(:,:,~color(1,:))=0;
        case '0g0'
            J(:,:,~color(2,:))=0;
        case '00b'
            J(:,:,~color(3,:))=0;
        case 'rg0'
            J(:,:,~color(4,:))=0;
        case 'r0b'
            J(:,:,~color(5,:))=0;
        case '0gb'
            J(:,:,~color(6,:))=0;
        case 'graygb'
            J(:,:,1) = rgb2gray(J);
        case 'rgrayb'
            J(:,:,2) = rgb2gray(J);
        case 'rggray'
            J(:,:,3) = rgb2gray(J);
        case 'rgraygray'
            J(:,:,2) = rgb2gray(J);
            J(:,:,3) = rgb2gray(J);
        case 'grayggray'
            J(:,:,1) = rgb2gray(J);
            J(:,:,3) = rgb2gray(J);
        case 'graygrayb'
            J(:,:,1) = rgb2gray(J);
            J(:,:,2) = rgb2gray(J);
        case 'gray'
            gray = rgb2gray(J);
            J(:,:,1) = gray;
            J(:,:,2) = gray;
            J(:,:,3) = gray;
        case {'cmy','CMY'}
            J = imcomplement(J);
%             J = double(J)/255;
%             c = 1 - J(:,:,1);
%             m = 1 - J(:,:,2);
%             y = 1 - J(:,:,3);
%             J = cat(3,c,m,y);
        case {'cmyk','CMYK'}
            J = imcomplement(J);
            k2 = min(J,[],3);
            c2 = J(:,:,1) - k2;
            m2 = J(:,:,2) - k2;
            y2 = J(:,:,3) - k2;
            J = cat(3,c2,m2,y2,k2);
%Completamente diversa dalla conversione di MATLAB
%             C = makecform('srgb2cmyk');
%             J = applycform(J,C);
        case {'yiq','YIQ'}
            J = rgb2ntsc(J);
        case {'hsv','HSV'}
            J = rgb2hsv(J);
        case {'hsi','HSI'}
            J = rgb2hsi(J);
        case {'ycbcr','YCBCR','Ycbcr'}
            J = rgb2ycbcr(J);
        case {'xyz','XYZ'}
            C = makecform('srgb2xyz');
            J = applycform(J,C);
        case {'lab','LAB','Lab'}
            C = makecform('srgb2lab');
            J = applycform(J,C);
        case {'lch','LCH','Lch'}
            J = rgb2you(J,'lab');
            C = makecform('lab2lch');
            J = applycform(J,C);
        case {'uvl','LUV','Luv','luv'}
            C = makecform('srgb2xyz');
            J = applycform(J,C);
            C = makecform('xyz2uvl');
            J = applycform(J,C);
        case {'upvpl','UPVPL'}
            C = makecform('srgb2xyz');
            J = applycform(J,C);
            C = makecform('xyz2upvpl');
            J = applycform(J,C);
        case {'xyl' ,'XYL'}
            C = makecform('srgb2xyz');
            J = applycform(J,C);
            C = makecform('xyz2xyl');
            J = applycform(J,C);
        otherwise 
            switch you
                case 'rrr'
                    fun = @(block_struct) block_struct.data(:,:,[1 1 1]);
                case 'ggg'
                    fun = @(block_struct) block_struct.data(:,:,[2 2 2]);
                case 'bbb'
                    fun = @(block_struct) block_struct.data(:,:,[3 3 3]);
                case 'grb'
                    fun = @(block_struct) block_struct.data(:,:,[2 1 3]);
                case 'gbr'
                    fun = @(block_struct) block_struct.data(:,:,[2 3 1]);
                case 'rbg'
                    fun = @(block_struct) block_struct.data(:,:,[1 3 2]);
                case 'bgr'
                    fun = @(block_struct) block_struct.data(:,:,[3 2 1]);
                case 'brg'
                    fun = @(block_struct) block_struct.data(:,:,[3 1 2]);
                case 'rrb'
                    fun = @(block_struct) block_struct.data(:,:,[1 1 3]);
                case 'rbr'
                    fun = @(block_struct) block_struct.data(:,:,[1 3 1]);
                case 'rrg'
                    fun = @(block_struct) block_struct.data(:,:,[1 1 2]);
                case 'rgr'
                    fun = @(block_struct) block_struct.data(:,:,[1 2 1]);
                case 'ggb'
                    fun = @(block_struct) block_struct.data(:,:,[2 2 3]);
                otherwise
                    error('Unsupported  color model.');
            end
            J = blockproc(J,[200 200],fun);
    end
    J = im2uint8(J);
end

%----------------------------------------------------------------------------

function y = rgb2hsi(x)
x = double(x);
x = x/255;
r = x(:,:,1); 
g = x(:,:,2); 
b = x(:,:,3);
% componente H
num = 0.5*((r-g) + (r-b));
den = sqrt((r-g).^2 + (r-b).*(g-b));
theta = acos(num./(den + eps));
H = theta;
H(b>g) = 2*pi - H(b>g);
H = H/(2*pi); % normalizzazione componente H
% componente S
num = min(min(r,g),b);
den = r+g+b;
den(den == 0) = eps;
S = 1-3.*num./den;
% componente I
H(S==0) = 0;
I = (r+g+b)/3;
y = cat(3,H,S,I);

%----------------------------------------------------------------------------
    
function y = rgb2xyz(x)

x = double(x);
x = x/255;
R = x(:,:,1); 
G = x(:,:,2); 
B = x(:,:,3);
a = 0.4124564; 
b = 0.2126729;  
c = 0.0193339; 
d = 0.3575761;  
e = 0.7151522;  
f = 0.1191920;  
g = 0.1804375;  
h = 0.0721750;  
i = 0.9503041;

a = 0.4124564; 
d = 0.2126729;  
g = 0.0193339; 
b = 0.3575761;  
e = 0.7151522;  
h = 0.1191920;  
c = 0.1804375;  
f = 0.0721750;  
i = 0.9503041;
X = (R * a) + (G * d) + (B * g);
Y = (R * b) + (G * e) + (B * h);
Z = (R * c) + (G * f) + (B * i);
y = cat(3,X,Y,Z);

%----------------------------------------------------------------------------

% function JJ2 = LAB2LCH(JJ)
% [L,a,b]=component(JJ);
% L2 = L;
% c = sqrt(double(a.^2+b.^2));
% c = uint8(c);
% h = atan2(double(b),double(a));
% h = h*180/pi + 360*(h < 0);
% h = uint8(h);
% Lch=cat(3,L2,c,h);

%----------------------------------------------------------------------------

% function lch = lab2lch(lab)
% lch = zeros(size(lab));
% lch(:,:,1) = lab(:,:,1);
% lch(:,:,2) = sqrt(lab(:,:,2).^2 + lab(:,:,3).^2);
% lch(:,:,3) = mod(atan2(lab(:,:,3), lab(:,:,2)) * 180/pi, 360);