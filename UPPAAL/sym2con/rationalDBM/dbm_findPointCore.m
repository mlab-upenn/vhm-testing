function [upper_bound,lower_bound,dbm] = dbm_findPointCore(dbm,clockToSet,upper_bound,lower_bound, restricted_vector,variableAssignment)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%(int clockToSet,Bound& upper, Bound&lower, vector<int>& restricted, VariableAssignment& assigned)const
    upper_bound = dbm.bounds{clockToSet,0};
    lower_bound = dbm.bounds{0,clockToSet};
    for i=0:size(restricted_vector)
        upBuf = createBound(variableAssignment(restricted_vector(i)),false)+dbm.bounds{clockToSet,restricted_vector(i)};
        lowBuf = createBound(-1*variableAssignment(restricted_vector(i)),false)+dbm.bounds{restricted_vector(i),clockToSet};
        if upBuf < upper_bound
            upper_bound = upBuf;
        end
        if lowBuf < lower_bound
            lower_bound = lowBuf;
        end
    end
end

