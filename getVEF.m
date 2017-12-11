function [Fext,imageGray]=getVEF(dbdir,filename)

enddot = find(filename== '.', 1, 'last' );
suffix = filename(enddot+1:enddot+3);

A=filename;
[row col chan]=size(A);
rx=row;
ry=col;

imageGray=A(:,:,2);

imageGrayDouble=double(imageGray);
maxvalue=max(max(imageGrayDouble,[],2));
imageGrayDouble =imageGrayDouble/maxvalue;

%% Porzione di codice che esegue la watershed con marker. Usata solo per fare un paragone con il nostro progetto 
% % % hy = fspecial('sobel');
% % % hx = hy';
% % % Iy = imfilter(double(imageGrayDouble), hy, 'replicate');
% % % Ix = imfilter(double(imageGrayDouble), hx, 'replicate');
% % % gradmag = sqrt(Ix.^2 + Iy.^2);
% % % se = strel('disk', 5);
% % % Io = imopen(imageGrayDouble, se);
% % % Ie = imerode(imageGrayDouble, se);
% % % Iobr = imreconstruct(Ie, imageGrayDouble);
% % % Ioc = imclose(Io, se);
% % % Iobrd = imdilate(Iobr, se);
% % % Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% % % Iobrcbr = imcomplement(Iobrcbr);
% % % fgm = imregionalmax(Iobrcbr);
% % % I2 = imageGrayDouble;
% % % I2(fgm) = 255;
% % % se2 = strel(ones(5,5));
% % % fgm2 = imclose(fgm, se2);
% % % fgm3 = imerode(fgm2, se2);
% % % fgm4 = bwareaopen(fgm3, 20);
% % % I3 = imageGrayDouble;
% % % I3(fgm4) = 255;
% % % bw = imbinarize(Iobrcbr);
% % % D = bwdist(bw);
% % % DL = watershed(D);
% % % bgm = DL == 0;
% % % gradmag2 = imimposemin(gradmag, bgm | fgm4);
% % % L = watershed(gradmag2);
% % % I4 = imageGrayDouble;
% % % I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
% % % Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
% % % figure
% % % imshow(Lrgb)
% % % title('Colored watershed label matrix (Lrgb)')

% 
% coloredLabels = label2rgb (L, 'hsv', 'k', 'shuffle');
% 
% figure; imshow(coloredLabels)

% edge dell'immagine da passare al campo vettoriale. Il parametro varia tra
% lo 0.05 e 0.07 dipende dal grado di rumorosit� dell'immagine
f = edge(imageGrayDouble,'Sobel',0.06);
% clcolo il kernel del campo vettorile. Tieni valore fisso 1.8 per non
% andare a creare artefatti nel risultato finale
K = AM_VFK(2, ry,'power',1.8);
% calcolo il campo vettoriale
Fext = AM_VFC(f, K, 1,'auto');

end
            
            