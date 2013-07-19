function [dbm] = dbmConstrain(x,y,constrain,dbm)
%(int x, int y,Bound toConstrain)
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here
    if toConstrain < dbm{x,y}
        dbm.bounds{x,y} = toConstrain;
        for i=0:size(dbm.bounds)-1
            for j=0:size(dbm.bounds)-1
                if (gi,x)+getBound (x,j)) < getBound (i,j)
                    setConstraint(i,j,(getBound(i,x)+getBound (x,j)));
                end
                if (getBound(i,y)+getBound(y,j))<getBound(i,j)
                    setConstraint(i,j,(getBound(i,y)+getBound (y,j)));
                end 
            end
        end
    end


end

