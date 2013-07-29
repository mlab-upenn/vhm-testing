function [assigns, dbm] = dbm_findPointMax(epsilon)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% VariableAssignment DBM::findPointMax (mpq_class epsilon) const {
    numOfVars = dbm_numOfVars(dbm);
    VariableAssignment assigns (numOfVars ());
   % vector<int> restricted;
   % Bound upper,lower;
    for i=0:numOfVars
	 [upper,lower,dbm] = dbm_findPointCore(i,upper,lower,restricted,assigns);	    
	  assigns(i) = bound_chooseValueMax(upper,lower,epsilon);
	  restricted = [restricted i];
    end
end

