function [mpq_class] = bound_chooseValueMin(upper, lower, epsilon)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
    if (lower.unbound) 
        disp('Very strange: chooseValueMin was called with an infinity bound as lower...')
        disp('Returning zero')
        mpq_class = 0;
        return
    elseif (lower.strict)
        mpq_class = (-1*lower.bound)+epsilon;
        return
    else
        mpq_class = -1*lower.bound;
        return
    end


end

