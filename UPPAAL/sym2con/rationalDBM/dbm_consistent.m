function [iftrue] = dbm_consistent(dbm)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    neg = createBound(0,true);
    numOfVars = dbm_numOfVars(dbm);
    for i=0:numOfVars
        if (dbm.bounds{i,i} <= neg)
            iftrue = true;
            return
        end
    end
    iftrue = false;
end

