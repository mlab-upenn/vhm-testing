function [ variableAssignment, dbm] = dbm_findPointMinClock(clock,epsilon,dbm)
% int clock, mpq_class epsilon
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
    %variableAssignment is a vector containing mpq_class
    numOfVars = dbm_numOfVars(dbm);
    variableAssignment = zeros(1,numOfVars);
    upper = dbm.bounds{clock,0};
    lower = dbm.bounds{0,clock};
    variableAssignment(clock) = bound_chooseValueMin(upper,lower,epsilon);
    restricted = clock;
    for i=0:numOfVars
        if i == clock
            continue;
        end
        [upper lower dbm] = dbm_findPointCore(i,upper,lower,restricted,assigns);
	
        variableAssignment(i) = bound_chooseValueBetween(upper,lower,epsilon);
        restricted = [restricted i];
    end
end

