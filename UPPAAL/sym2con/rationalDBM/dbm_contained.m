function [ ifTrue ] = dbm_contained( c , dbm)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
% bool DBM::contained (const VariableAssignment& c) const {
    numOfVars = dbm_numOfVars(dbm);
    for i=0:numOfVars
      for j=0:numOfVars
        if i~=0 
            %mpq_class
            val = c(i) - c(j);
            %mpq_class 
            val2 = c(j) - c(i);
            if (~bound_satisfied(val, dbm.bounds{i,j})|| ~bound_satisfied(val2, dbm.bounds{j,i}))
                ifTrue = false;
                return
            end
        end
      end
    end
    ifTrue = true;
    return
    
    function [check] = bound_satisfied(val,bound)
        if bound.unbound 
            check = true;
            return 
        elseif val < bound.bound
            check = true;
            return
        elseif val == bound.bound && ~bound.strict 
            check = true;
            return
        else 
            check = false;
            return
        end
    end
    
end

