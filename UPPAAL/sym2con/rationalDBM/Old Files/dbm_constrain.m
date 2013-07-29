function [dbm] = dbm_constrain(x,y,constrain,dbm)
%(int x, int y,Bound toConstrain)
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here
    numOfVars = dbm_numOfVars(dbm);
    if constrain < dbm.bounds{x,y}
        dbm.bounds{x,y} = constrain;
        for i=0:numOfVars
            for j=0:numOfVars
                if (dbm.bounds{i,x}+dbm.bounds{x,j}) < dbm.bounds{i,j}
                    dbm.bounds{i,j} = dbm.bounds{i,x} + dbm.bounds{x,j};
                end
                if (dbm.bounds{i,y}+dbm.bounds{y,j}) < dbm.bounds{i,j}
                    dbm.bounds{i,j} = dbm.bounds{i,y} + dbm.bounds{y,j};
                end 
            end
        end
    end


end

