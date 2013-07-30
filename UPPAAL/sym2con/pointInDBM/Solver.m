classdef Solver
    %UNTITLED14 Summary of this class goes here
    %   Detailed explanation goes here
    %%THIS CODE IS INCOMPLETE
    properties (Constant)%, SetAccess = public)
        %keep; %timeKeeper
        %doTime = false;
    end
    properties(SetAccess = public)
        epsilon = 10; %mpz_class
        %scaleInteger = false;
        %integer = false;
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
        %this is a workaround for the scaleInteger variable
        function int = scaleInteger(change)
            persistent scaleinteger;
            if nargin>=1
                scaleinteger = change;
            end
            int = scaleinteger;
        end
        %this is a workaround for the integer variable
        function int = integer(change)
            persistent intger;
            if nargin>=1
                intger = change;
            end
            int = intger;
        end
        
        function solve = solvePoint(obj,lta,opt,inputstream,outputstream)
            solve = obj.solve(lta,inputstream,outputstream);
            %Result* solvePoint (LTA::Lta* lta, Options* opt, istream& inputstream,  ostream& outputstream) {
                %return solve(lta,opt,inputstream,outputstream);
            %}
        end
        
        function res = solve(lta,opt,inputstream,outputstream)
            if strcmp(opt.solveOptions,'integer')
                Solver.integer = true;
            end
            Solver.doTime(opt.time);
            zeroRep(opt.zeroRep);
            start;%clock_t;
            creator = DCCreator(lta,zeroRep);
            entryTimeDBM = creator.CreateEntryTimeConstraints();
            res = SolutionFinder.FindSolution(entryTimeDBM,opt.epsilon);
        end
        
    end
    
    % #define DBM(I,J) dbm[(I)*dim+(J)]
    
end

