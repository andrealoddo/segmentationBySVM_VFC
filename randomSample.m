function [ nRS, cRS, eRS ] = randomSample( nF, cF, eF, n )

    nRS = datasample(nF, n/3);
    cRS = datasample(cF, n/3);
    eRS = datasample(eF, n/3);
    
end

