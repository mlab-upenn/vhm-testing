function [dbm assigns] = dbm_findPointMin(dbm,epsilon)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    
  %VariableAssignment DBM::findPointMin (mpq_class epsilon) const {
  numOfVars = dbm_numOfVars(dbm);
   % VariableAssignment assigns (numOfVars ());
    %    vector<int> restricted;
    %    Bound upper,lower;
        for i=0:numOfVars
            [upper,lower,dbm]= dbm_findPointCore (i,upper,lower,restricted,assigns);
            assigns{i} = bound_chooseValueMin(upper,lower,epsilon);
            restricted = [restricted i];
        end
end

