function [dcConstraint] = make_dc_t(clockX,clockY,dcOperator,bound)
%UNTITLED16 Summary of this function goes here
%   Detailed explanation goes here
  dcConstraint.op =dcOperator;
  dcConstraint.bound = bound;
  dcConstraint.clockX = clockX;
  dcConstraint.clockY = clockY;
  dcConstraint.origX = clockX;
  dcConstraint.origY = clockY;

end

%enum DCOperator {lt,leq,eq};