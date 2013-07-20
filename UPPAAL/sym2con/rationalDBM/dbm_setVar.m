function [dbm] = dbm_setVar(x,val,dbm)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    pos = createBound(val,false);
   
    neg = createBound(-1*val,false);
    numOfVars = dbm_numOfVars(dbm);
    for i=0:numOfVars
        dbm.bounds{x,i} = pos + dbm.bounds{0,i};
        dbm.bounds{i,x} = neg + dbm.bounds{i,0};
    end

end

