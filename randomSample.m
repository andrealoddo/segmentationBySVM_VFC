function [ nRS, cRS, eRS, edRS ] = randomSample( nF, cF, eF, edF , n )

    nRS = datasample(nF, n/4);
    cRS = datasample(cF, n/4);
    eRS = datasample(eF, n/4);
    edRS = datasample(edF, n/4);
    
end

