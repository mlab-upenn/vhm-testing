function res = solveSmallBack(ta,opt,in,out)
            opt.epsilon = 10;
            myEps = (1/opt.epsilon)/ta.getNumberOfLocations();
            cur = ta.getFirst(); %?
            
            while cur.getEdge() ~= 0
                cur = cur.getEdge().getNextLocation();
            end
            
            entries; %vector<EntryAndLeave>
            buffer; %EntryAndLeave 
                        %{
                        struct EntryAndLeave
                        {
                            VariableAssignment enter;
                            VariableAssignment leave;
                        };
                        %}
            laststate = true;
            iter = 0;
            while cur ~= 0
                iter = iter + 1;
                if laststate
                    buffer.leave = cur.getDBM().findPointMinClock(opt.clockIndex(opt.globalC),1/opt.epsilon);%?
                    laststate = false;
                else
                    actionPredecessor = DBM(entries(end).enter).free(cur.getEdge().getResetVector()).intersect(cur.getEdge().getDBM()).intersect(cur.getDBM());%?
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