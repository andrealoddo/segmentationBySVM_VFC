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

% edge dell'immagine da passare al campo vettoriale. Il parametro varia tra
% lo 0.05 e 0.07 dipende dal grado di rumorosit� dell'immagine
f = edge(imageGrayDouble,'log');

% clcolo il kernel del campo vettorile. Tieni valore fisso 1.8 per non
% andare a creare artefatti nel risultato finale
K = AM_VFK(2, ry,'power', 1.8);
% calcolo il campo vettoriale
Fext = AM_VFC(f, K, 1,'auto');

end
            
            