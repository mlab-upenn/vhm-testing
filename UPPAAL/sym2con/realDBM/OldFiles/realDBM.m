function [realDbm] = realDBM(v)
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here
%DBM::DBM (VariableAssignment& v) :  theDBM (v.size(), vector<Bound> (v.size ())) {
  realDbm.numVars = size(v);
  realDbm = zeroDiagonal(realDbm);
%variableAssignment is a map<int,mpq_class>
  for it=0:size(v)
    %Bound 
    b =  realBound(v(it).second,false);
    %Bound 
    b2 = realBound(-1*v(it).second,false);
    realDbm = realDbm_setConstraint(v(it).first,0,b);
    realDbm = realDbm_setConstraint(0,v(it).first,b2);
  end
  [realDbm] = realDbm_doClose(realDbm);
end

