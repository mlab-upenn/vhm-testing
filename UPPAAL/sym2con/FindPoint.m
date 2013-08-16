function [inconsistent,v] = FindPoint(H)
%FindPoint is the matlab implementation of Algorithm 2 in Concrete delays for Symbolic traces 
%See page 26. dbm H must be a closed from difference bound matrix over
%variables C

    inconsistent = 0;
    v = 0;
    if H(1,1) < 0
        inconsistent = 1;
        return
    end

    
    R = 1
    v(1)= 0
    C = size(H,1)
    
    for x=2:C
        c = x
        upper = H(c,1)
        lower = H(1,c)
        for r = 1:length(R)
            upper = min(upper, H(c,R(r)) + v(R(r)));
            lower = min(lower,H(R(r),x) + (-v(R(r))));
        end
        upper
        lower
        if (abs(lower) <= abs(upper)) && (H(c,c) >= 0) 
            s = round((abs(lower) + abs(upper))/2);
            v(c) = s;
            R = [R c];
        else
            inconsistent = 1;
            return
        end
    end
end

