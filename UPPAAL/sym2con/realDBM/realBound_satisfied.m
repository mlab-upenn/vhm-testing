function [ifTrue] = realBound_satisfied(value, realBound)
%UNTITLED21 Summary of this function goes here
%   Detailed explanation goes here
    if realBound.unbounded
        ifTrue = true;
        return
    end
    if value == realBound.bound
        ifTrue = ~realBound.strict;
        return
    elseif value < ralBound.bound
        ifTrue = true;
        return
    else 
        ifTrue = false;
        return
    end
end

