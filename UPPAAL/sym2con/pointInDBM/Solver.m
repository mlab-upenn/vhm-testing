classdef Solver
    %UNTITLED14 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)%, SetAccess = public)
        keep; %timeKeeper
    end
    properties(SetAccess = public)
        epsilon = 10; %mpz_class
        scaleInteger = false;
        integer = false;
    end
    %this is a workaround for the doTime variable
    methods(Static)
        function time = doTime(change)
            persistent dotime;
            if nargin>=1
                dotime = change;
            end
            time = dotime;
        end
    end
    
    % #define DBM(I,J) dbm[(I)*dim+(J)]
    methods
        function solve = solvePoint(obj,lta,opt,inputstream,outputstream)
            solve = obj.solve(lta,inputstream,outputstream);
            %Result* solvePoint (LTA::Lta* lta, Options* opt, istream& inputstream,  ostream& outputstream) {
                %return solve(lta,opt,inputstream,outputstream);
            %}
        end
        
        function res = solve(lta,opt,inputstream,outputstream)
            if strcmp(opt.solveOptions,'integer')
                obj.integer = true;
            end
            Solver.doTime(opt.time);
            zeroRep(opt.zeroRep);
            start;%clock_t;
            creator = DCCreator(lta,zeroRep);
            entryTimeDBM = creator.CreateEntryTimeConstraints();
            res = FindSolution(entryTimeDBM,opt.epsilon);
        end
    end
    
end

