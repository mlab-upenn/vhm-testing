function [iftrue] = dbm_subset(dbm,dbm2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    numOfVars = dbm_numOfVars(dbm);
    for i=0:numOfVars
        for j=0:numOfVars
            if (dbm.bounds{i,j} > dbm2.bounds{i,j})
                iftrue = false;
                return
            end
        end
    end

    iftrue = true;

end

