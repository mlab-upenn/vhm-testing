function [ifTrue ] = realBound_isNeg(realBound)
%UNTITLED20 Summary of this function goes here
%   Detailed explanation goes here
  if (realBound.unbounded) 
    ifTrue = false;
    return
  end
  if realBound.bound< 0
    ifTrue = true;
    return
  elseif realBound.bound == 0 && realBound.strict 
    ifTrue = true;
    return
  else
    ifTrue = false;
    return

  end
end

