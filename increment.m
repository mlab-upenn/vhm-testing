function [nxtLine, nxtTime, nxtEvent, nNTime,nNEvent, smp_File] = increment(nxtLine, nxtTime, nxtEvent, nNTime,nNEvent, smp_File)
%increment Summary of this function goes here
%   Detailed explanation goes here
    nxtLine = nxtLine + 1;
    if nxtLine <= length(smp_File)
        nxtTime = smp_File(nxtLine,1);
        nxtEvent = smp_File(nxtLine,2);
    else
        nxtEvent = 0;
    end
    
    if nxtLine < length(smp_File)
        nNTime = smp_File(nxtLine+1,1);
        nNEvent = smp_File(nxtLine+1,2);
    else
        nNTime = 0;
        nNEvent = 0;    
    end

end

