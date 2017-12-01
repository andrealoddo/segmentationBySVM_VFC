function [a2] = shiftMatrix(a, off1, off2)

if nargin==2, 
    off2 = off1(2);
    off1 = off1(1);
end 

[r,c]=size(a);
if ((r <= off1) || (c <= off2))
    error('The offsets should be minor than matrix sizes');
end

a2 = NaN(r,c);
startr = 1; startc = 1; startr2 = 1; startc2 = 1; 
stopr = r; stopc = c; stopr2 = r; stopc2 = c;
if off1 > 0
    startr = 1+off1;
    stopr2 = r-off1;
elseif off1 < 0
    startr2 = 1-off1;
    stopr = r+off1;
end

if off2 > 0
    startc = 1+off2;
    stopc2 = c-off2;
elseif off2 < 0
    startc2 = 1-off2;
    stopc = c+off2;
end

a2(startr2:stopr2,startc2:stopc2)=a(startr:stopr,startc:stopc);