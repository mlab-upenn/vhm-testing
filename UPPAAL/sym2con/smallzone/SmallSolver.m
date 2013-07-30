classdef SmallSolver
    %UNTITLED18 Summary of this class goes here
    %   Detailed explanation goes here
    %This code is not complete
    properties
        EntryAndLeave = struct('enter',zeros(1,1),'leave',zeros(1,1));
        
    end
    
    methods (Static)
        
        function operator_shiftLeft(varass)
        %ostream & operator<< (ostream & nycout, VariableAssignment& varass)
            str = '';    
            for i=1:size(varass)
                str =[str,num2str(varass(i)),' '];
            end
            disp(str);
        end
       
        function v = doReset(v,reset)
            for i =1:size(reset)
                v(reset(i)) = 0;
            end
        end
        
        function res = FindDelayDifference(info)
            res = info.leave(1) - info.enter(1);
            for i=2:size(info.enter)-1
                if info.leave(i) - infor.enter(i) ~= res
                    disp('Error in finding delays!');
                end
            end
            disp('DelayDifference found');
        end
        
        function res = solveSmallForw(ta, opt,in,out)
            entries; %vector<EntryAndLeave>
            cur = ta.getFirst(); %location
            while cur~=0
                buffer; %EntryAndLeave
                if cur == ta.getFirst()
                    enterZone = DBM.initZone(cur.getDBM().numOfVars()); %?
                    buffer.enter = enterZone.findPoint();
                else
                    buffer.enter = SmallSolver.doReset(entries.back().leave, cur.getBack().getResetVector()); %?
                end
                
                delayZone;%DBM
                if cur.getEdge() ~= 0
                    delayZone = DBM(buffer.enter).up().intersect(cur.getEdge().getDBM()).intersect(cur.getDBM());%?
                    
                else
                    delayZone =DBM(buffer.enter).up().intersect(cur.getDBM());
                    buffer.leave = delayZone.findPoint();
                    entries = [entries buffer];
                end
                if cur.getEdge ~=0
                    cur = cur.getEdge().getNextLocation();
                else
                    cur = 0;
                end
            end
            delays;%vector<mpq_class>
            for i = 1:size(entries)
                delays = [delays SmallSolver.FindDelayDifference(entries(i))];
            end
            res = DumbResult(delays);
        end
        
        function res = solveSmallBack(ta,opt,in,out)
            myEps = (1/opt.epsilon)/ta.getNumberOfLocations();
            cur = ta.getFirst(); %?
            
            while cur.getEdge() ~= 0
                cur = cur.getEdge().getNextLocation();
            end
            
            entries; %vector<EntryAndLeave>
            buffer; %EntryAndLeave
            laststate = true;
            iter = 0;
            while cur ~= 0
                iter = iter + 1;
                if laststate
                    buffer.leave = cur.getDBM().findPointMinClock(opt.clockIndex(opt.globalC),1/opt.epsilon);%?
                    laststate = false;
                else
                    actionPredecessor = DBM(entries.back().enter).free(cur.getEdge().getResetVector()).intersect(cur.getEdge().getDBM()).intersect(cur.getDBM());%?
                    buffer.leave = actionPredecessor.findPointMin(myEps);
                end
                enterZone; %DBM
                if cur == ta.getFirst()
                    enterZone = DBM.initZone(cur.getDBM().numOfVars());%?
                else
                    enterZone = cur.getBack().getPrev().getDBM().intersect(cur.getBack().getDBM()).reset(cur.getBack().getResetVector()); %?
                end
                
                timePredecessor = DBM(buffer.leave).down().intersect(enterZone); %?
                buffer.enter = timePredecessor.findPointMax(myEps);
                
                if cur ~= ta.getFirst()
                    cur = cur.getBack().getPrev();
                else
                    cur = 0;
                end
                
                entries = [entries buffer];
                
            end
            delays; %vector<mpq_class>
            
            for i= size(entries):-1:1
                delays = [delays (entries(i).leave(2)-entries(i).enter(2))];
            end
            
            res = DumbResult(delays);
        end
        
        function res = solveSmall(ta, opt, in, out)
            if strcmp(opt.solveOptions,'back')
                if ~opt.quiet
                    disp('Doing search backward')
                end
                res = SmallSolver.solveSmallBack(ta,opt,in,out);
                return
            elseif strcmp(op.solveOptions,'forw')
                if ~opt.quiet
                    disp('Doing search forward')
                end
                res = SmallSolver.solveSmallForw(ta,opt,in,out);
                return
            else
                if ~opt.quiet
                    disp('Doing standard search: Backward')
                end
                res = SmallSolver.solveSmallBacl(ta,opt,in,out);
                return
            end
        end
    end
    
end

