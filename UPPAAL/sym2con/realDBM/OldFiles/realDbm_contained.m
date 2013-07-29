function [ifTrue] = realDbm_contained(assignment, theDBM)
%UNTITLED24 Summary of this function goes here
%   Detailed explanation goes here
    %int xit;
    %int yit;
    for xit =0:theDBM.numVars
        for yit =0:theDBM.numVars
        %mpq_class 
            value = assignment(xit) - assignment(yit);
            if (~realBound_satisfied(value, theDBM(xit,yit)))
                ifTrue = false;
                return 
            end
        end
    end
    ifTrue = true;
    return

end

