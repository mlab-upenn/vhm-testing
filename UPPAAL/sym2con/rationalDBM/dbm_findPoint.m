function [assigns dbm] = dbm_findPoint(epsilon)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
        numOfVars = dbm_numOfVars(dbm);
       % VariableAssignment assigns (numOfVars ());
       % vector<int> restricted;
       % Bound upper,lower;
        assigns(1)=mpq_class(0);
        restricted = [restricted 0];

        for i=1:numOfVars
           [upper,lower,dbm] = dbm_findPointCore (dbm,i,upper,lower,restricted,assigns);

            assigns(i) = bound_chooseValueBetween (upper,lower,epsilon);
            restricted = [restricted i];
        end
end

