classdef simpleLiveness
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant)
        INT_MAX = 2^32;
    end
    
    properties
    end
    
    methods
        function mpq_class = FindMaxDelay(point,dbm)
            maxDelay = simpleLiveness.INT_MAX;
            for i=1:dbm.numOfVars()-1
                bound = dbm.getBound(i,0);
                upperbound = bound.getBound();
                if (upperbound - point(i)) < maxDelay
                    maxDelay = upperbound - point(i);
                end
            end
            mpq_class = maxDelay;
        end
        
        function [point,delay] = DelayPoint(point,delay)
            temp;
            for i=1:size(point)-1
                point(i) = point(i) + delay;
            end
        end
        
        function int = PointVisited(point, visitedPoints)
            equal; %bool
            for i=1:size(visitedPoints)
                equal = true;
                for j = 1:size(visitedPoints)-1
                    if visitedPoints(i,j)  ~= point(j)
                        equal = false;
                        break;
                    end
                end
                if equal
                    int = i;
                    return    
                end
            end
            int = -1;
            return     
        end
        
        function [dbm,point] =  maxPointInZone(dbm,point)
            point(1) = 0;
            for i=1:dbm.numOfVars()-1
                bound = dbm.getBound(i,0);
                point(i) = bound.getBound();
            end
        end
        
        function result = CombineTraceParts(fromIndex, delayFor1Iteration)
            result; %vector<mpq_class>();
            for f = fromIndex:size(delayFor1Iteration)
                for i =1:size(delayFor1Iteration(f))
                    result = [result delayFor1Iteration(f,i)];
                end
            end
            
        end
        
        function [ v, mpq_class] = solveLiveCycleSimple(ta,opt,in,out)
            cindex = opt.clockIndex;
            loc = ta.getFirst();
            while
        end
    end
    
end

