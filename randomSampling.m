function varargout = randomSampling( nPixels, varargin )

    for k = 1:nargout
        varargout{k} = datasample( varargin{k}, nPixels/size(varargin,2) );
    end
    
    %nRS = datasample(nF, n/3);
    %cRS = datasample(cF, n/3);
    %eRS = datasample(eF, n/3);
        
end

