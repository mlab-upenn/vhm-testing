classdef SolutionFinder
    %UNTITLED15 Summary of this class goes here
    %   Detailed explanation goes here
    %TODO: THIS CODE HAS ERRORS '%?' indicates this line does not work.
    properties
        %start;%clock_t
        %end_clock; %clock_t
    end
    
    methods (Static)
        %this is a workaround for the timekeeper keep variable
        function timeKeep = keep(change)
            persistent keep;
            if nargin >= 1
                keep = change;
            end
            timeKeep  = keep;
            
            %{
            typedef struct {
                double createConstraint;
                double createDBM;
                double closeDBM;
                double findPoint;
  
            }timeKeeper;
            %} 
        end
        
        function start_clock = start(change)
            persistent start;
            if nargin >=1
                start = change;
            end
            start_clock = start;
            
        end
        
        function end_clock = end(change)
            persistent end_c;
            if nargin >=1
                end_c = change;
            end
            end_clock = end_c;
        end
        
        %taken from constraints.h
        function bool = dbm_rawIsStrict(raw)
            dbm_WEAK = 1;
            a = bitand(raw,1);
            bool = xor(a,dbm_WEAK);
            % return (BOOL)((raw & 1) ^ dbm_WEAK);
        end
        %taken from constraints.h
        function int = dbm_raw2bound(raw)
            int = bitsra(raw,1);
        end
        
        function [entryTimes delays] = ConvertEntryTimesToDelays(entryTimes,delays)
            for i=1:size(entryTimes)-1
                delays(i) = entryTimes(i+1)-entryTimes(i);
            end
        end
        
        function mpq_class = findValue(lStrict,lower,ustrict,upper,increase)
            if ~lStrict
                mpq_class = lower;
                return
            else 
                mpq_class = lower +increase;
                return
            end
        end
        
        function res = findFastestPoint(dbm,epsilon)
            if Solver.doTime
                SolutionFinder.start = clock();
            end
            dim = dbm.pdim(); %cindex_t %?
            entryTimes = VariableAssignment(dim); %?
            restricted = zeros(1,dim);
            raw = dbm.getDBM(); %raw_t %?
            
            for i=1:dim
                restricted(i) = false;
            end
            lower; %mpq_class
            upper; %mpq_class
            increase = (1/epsilon)/dim; %mpq_class
            
            %First of all we restrict that entering the first state must be = 0;
            entryTimes(1) = 0;
            %and hence it is restricted
            restricted(1) = true;
            
            lstrict;
            ustrict;
            
            %Go through all variables that are free
            for i=1:dim-1
                if ~restricted(i)
                    ustrict = SolutionFinder.dbm_rawIsStrict(raw((i)*dim+(0))); %?
                    lstrict = SolutionFinder.dbm_raw_IsStrict(raw((0)*dim+(i))); %?
                    upper = mpq_class(mpq_class(SolutionFinder.dbm_raw2bound(raw((i)*dim+(0))))); %?
                    lower = mpq_class(mpq_class(-SolutionFinder.dbm_raw2bound(raw((0)*dim+(i)))));%?
                
                    for j=1:dim-1
                        if restricted(j) && i~=j
                            boundStrict = dbm_rawIsStrict(raw((i)*dim+(j))); %?
                            bound = mpq_class (dbm_raw2bound(raw((i)*dim+(j)))) + entryTimes(j); %?
                            if bound < upper || bound == upper && boundStrict
                                ustrict = boundStrict;
                                upper = bound;
                            end
                            boundStrict = dbm_rawIsStrict(raw((j)*dim+(i)));
                            bound = mpq_class(-dbm_raw2bound(raw((j)*dim+(i)))) + entryTimes(j); %?
                            
                            if bound > lower || (bound == lower && boundStrict)
                                lstrict = boundStrict;
                                lower = bound;
                            end
                        end
                    end
                    % We now have the tighest bounds. Choose something between these values
                    entryTimes(i) = findIntValue(lstrict,lower,ustrict,upper,increase);
                    restricted(i) = true;
                end  
            end
            if Solver.doTime
                SolutonFinder.end = clock(); %?
                keep = SolutionFinder.keep();
                keep.findPoint = (SolutionFinder.end- SolutionFinder.start)/CLOCKS_PER_SEC; %?
                SolutionFinder.keep(keep);
            end
            delays = VariableAssignment(dim-1);
            [entryTimes delays] = SolutionFinder.ConvertEntryTimesToDelays(entryTimes,delays);
            
            res = DumbResult(delays);
            
        end
        
        function mpq_class = findIntValue(lstrict,lower,ustrict,upper,increase,prev)
            diff = lower - prev;
            intentry; %mpq_class
            times; %mpq_class
            %mpz_init(times);
            %cout.flush();
            mpz_cdiv_q(times, diff.get_num_mpz_t(), diff.get_den_mpz_t()); %?
            nrOfTimes = mpz_class(times);%?
            intentry = nrOfTimes + lower;
            if intentry == lower && lstrict
                intentry = intentry +1;
            end
            if (intentry < upper) || (intentry < upper && ~ustrict)
                mpq_class = intentry;
                return
            else
                if ~lstrict
                    mpq_class = lower;
                    return
                end
                increasedlower = lower+increase;
                if increasedlower < upper || (increasedlower == upper && ~ustrict)
                    mpq_class = increasedlower;
                    return
                else
                    mpq_class = (lower + upper)/2;
                    return
                end
            end
        end
        
        function res = findFastestIntDelayPoit(dbm,epsilon)
            if Solver.doTime
                SolutionFinder.start = clock();
            end
            dim = dbm.pdim();
            entryTimes = VariableAssignment(dim);
            restricted = zeros(1,dim);
            raw = dbm.getDBM();
            
            %Initialize all variables to be free
            for i =1:dim
                restricted(i) = false;
            end
            
            upper;
            lower;
            increase = 1/epsilon;
            
            %First of all we restrict that entering the first state must be = 0;
            entryTimes(1) = 0;
            %and hence it is restricted
            restricted(1) = true;
            
            lstrict;
            ustrict;
            
            for i=1:dim-1
                if ~restricted(i)
                    ustrict = SolutionFinder.dbm_rawIsStrict(raw((i)*dim+(0)));%?
                    lstrict= SolutionFinder.dbm_rawIsStrict(raw((0)*dim+(i)));%?
                    upper = mpq_class(mpq_class(SolutionFinder.dbm_raw2bound(raw((i)*dim+(0))))); %?
                    lower = mpq_class(mpq_class(-SolutionFinder.dbm_raw2bound(raw((0)*dim+(i))))); %?
                
                    for j=1:dim-1
                        if restricted(j) && i~=j
                            boundStrict = SolutionFinder.dbm_rawIsStrict(raw((i)*dim+(j)));%?
                            bound = mpq_class(SolutionFinder.dbm_raw2bound(raw((i)*dim+(j)))) + entryTimes(j); %?
                            if bound < upper || bound == upper && boundStrict
                                ustrict = boundStrict;
                                upper = bound;
                            end
                            boundStrict = SolutionFinder.dbm_rawIsStrict(raw((j)*dim+(i)));
                            bound = mpq_class(-SolutionFinder.dbm_raw2bound(raw((j)*dim+(i)))) + entryTimes(j);

                            if bound > lower  || (bound == lower && boundStrict)
                                lstrict = boundStrict;
                                lower = bound;
                            end
                        end
                    end
                    %We now have the tighest bounds. Choose something between these values
                    entryTimes(i) = SolutionFinder.findIntValue(lstrict,lower,ustrict,upper, increase, entryTimes(i-1));
                    restricted(i) = true;
                end
            end
            if Solver.doTime
                SolutionFinder.end =clock();
                keep = SolutionFinder.keep();
                keep.findPoint = (SolutionFinder.end = SolutionFinder.start)/CLOCKS_PER_SEC; %?
                SolutionFinder.keep(keep);
            end
            
            delays = zeros(1,dim-1);%?
            SolutionFinder.ConvertEntryTimesToDelays(entryTimes,delays);
            res = DumbResult(delays);
        end
        
        function res = FindSolution(entryTimeDBM,epsilon)
            if Solver.integer
                res = SolutionFinder.findFastestIntDelayPoint(entryTimeDBM,epsilon);
                return
            else
                res = SolutionFinder.findFastestPoint(entryTimeDBM,epsilon);
            end
        end
    end
    
end

