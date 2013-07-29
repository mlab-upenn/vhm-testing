function [theDBM] = realDbm_zeroDiagonal(theDBM)
%UNTITLED22 Summary of this function goes here
%   Detailed explanation goes here
%Bound 
    b = realBound(0,false);
  for i=0:theDBM.numVars
    theDBM(i,i) = b;
  end

end

