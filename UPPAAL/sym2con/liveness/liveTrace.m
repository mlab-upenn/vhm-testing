classdef liveTrace
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        
        %Node
        upZone; %DBM 
        entryZone; %DBM
        guard;%DBM
        reset; %vector<int> 
        next; %Node* 
        prev; %Node* 
        enter; %  VariableAssignment 
        leave; %VariableAssignment
        
        
        %LinSequence
        deleteNodes; %bool 
        first; %Node* 
        last; %Node* 
    end
    
    methods
        %Node
        function obj = Node(u,g,r)
            obj.upZone = u;
            obj.guard = g;
            obj.reset = r;
            %Node (DBM,DBM,vector<int>);
        end
        function upZone = getUpped(obj)
            upZone = obj.upZone;
            %DBM getUpped ();
        end
        
        function entryZone = getEntry(obj)
            entryZone = obj.entryZone;
            %DBM getEntry ();
        end
        
        function obj = setEntry(e)
            obj.entryZone = e;
            %void setEntry (DBM);
        end
        
        function obj = setUp(e)
            obj.upZone = e;
            %void setUp (DBM);
        end
        
        function guard = getGuard(obj)
            guard = obj.guard;
            %DBM getGuard ();
        end
        
        function reset = getReset(obj)
            reset = obj.reset;
            %vector<int> getReset();
        end
        
        function obj = setNext(obj,n)
            obj.next = n;
            %void setNext (Node*);
        end
        
        function next = getNext(obj)
            next = obj.next;
            %Node* getNext ();
        end
        
        function prev = getPrev(obj)
            prev = obj.prev;
            %Node* getPrev ();
        end
        
        function obj = setPrev(obj,m)
            obj.prev = m;
            %void setPrev (Node*);
        end
        
        function obj = setEnter(obj,v)
            obj.enter = v;
            %void setEnter (VariableAssignment v) {enter = v;}
        end
        
        function obj = setLeave(v)
            obj.leave = v;
            %void setLeave (VariableAssignment v) {leave = v;}
        end
        
        function enter = getEnter(obj)
            enter = obj.enter;
            %VariableAssignment getEnter () {return enter;}
        end
        
        function leave = getLeave(obj)
            leave = obj.leave;
            %VariableAssignment getLeave () {return leave;}
        end
        
        %LinSequence
        
        %~LinSequence ();
        
        function obj = LinSequence(varargin)
            if nargin == 1
                ops = varargin{1};
                cur; %Node*
                prev; %Node*
                for i = 1: size(ops)
                    cur = Node(ops(i).init,ops(i).guard,ops(i).reset);
                    if i==0
                        obj.first = cur;
                    else
                        cur.setPrev(prev);
                        prev.setNext(cur);
                    end
                
                    prev = cur;
                end
            
                obj.last = prev;
                % LinSequence(vector<Op>&);
            elseif nargin == 2
                v = varargin{1};
                ops = varargin{2};
                prev; %Node*
                cur; %Node*
                
                for i = 1:size(ops)
                    if i == 0
                        cur = Node(DBM(v).up().intersect(ops(i).init),ops(i).guard,ops(i).reset);
                        obj.first = cur;
                    else
                        cur = Node(prev.getUpped().intersect(ops(i-1).guard).reset(ops(i-1).reset).up().intersect(ops(i).init),...
                            ops(i).guard,ops(i).reset);
                        prev.setNext(cur);
                        cur.setPrev(prev);
                        
                    end
                    
                    prev = cur;
                end
                
                obj.last = prev;
                
                %LinSequence(VariableAssignment, vector<Op>& );
            end
        end
        
 
        function obj = calcZones(obj) %? Pointer logic
            cur; %Node*
            prev; %Node*
            numOfVars = obj.getFirst().getUpped().numOfVars();
            initzZone = DBM.initZone(numOfVars);
            cur.obj.getFirst();
            guard = cur.getGuard();
            
            cur.setEntry(initZone);
            up = cur.getUpped();
            cur.setUp(initZone.up().intersect(up).intersect(guard));
            cur = cur.getNext();
            
            i = 0;
            while cur ~= 0
                res = cur.getPrev().getReset();
                entry = cur.getPrev().getUpped().reset(res);
                origUp = cur.getUpped();
                cur.setEntry(entry);
                cur.setUp(entry.up().intersect(origUp));
                if cur ~= obj.last
                    cur = cur.getNext();
                else
                    cur = 0;
                end
            end
            
            %void calcZones();
        end
        %void calcZones(VariableAssignment v);
        
        function obj = findAssignments(obj,v)
            obj.calcEntryZones();
            cur = obj.getLast();
            first = obj.getFirst(); %Node*
            dbm = DBM(v); %Node*
            cur.setLeave(v);
            
            entry = cur.getEntry();
            cur.setEnter(DBM(v).down().intersect(entry).findPoint());
            
            cur = cur.getPrev();
            
            while cur ~= 0
                entry = cur.getEntry(); %DBM
                guard = cur.getGuard(); %DBM
                upped = cur.getUpped(); %DBM
                r = cur.getReset();
                var = cur.getNext().getEnter();
                leave = DBM(var).free(r).intersect(upped).intersect(guard).findPoint();
                cur.setLeave(leave);
                %VariableAssignment leave
                if cur ~= obj.first
                    obj.enter = DBM(leave).down().intersect(entry).findPoint();
                    cur.setEnter(obj.enter);
                end
                
                if cur == obj.first
                    cur = 0;
                else
                    cur = cur.getPrev();
                end
            end
            
            %void findAssignments (VariableAssignment&);
        end
        
        function obj = splice(obj,other)
            obj.last.setNext(other.getFirst().getNext());
            other.getFirst().getNext().setPrev(obj.last);
            other.deleteNodes = false;
            %void splice(LinSequence* );
        end
        
        function obj = stabilize(obj) %? pointer logic 
            var;
            cur = obj.first.getNext();
            obj.prev = obj.first;
            while cur ~= 0
                var = obj.prev.getEnter();
                cur.setEnter(liveTrace.doReset(var,obj.prev.getReset()));
                if cur == obj.last %?
                    cur = 0;
                else
                    obj.prev = cur;
                    cur = cur.getNext();
                end
            end
            %void stabilize();
        end
        
        function first = getFirst(obj)
            first = obj.first;
            %Node* getFirst ();
        end
        
        function last = getLast(obj)
            last = obj.last;
            %Node* getLast ();
        end
        
    end
    
    methods (Static)
        
        function v = doReset(v,reset)
            for it = 1:length(reset)
                v(it) = 0;
            end
        end
    end
    
    methods (Access = private)
        %LinSequence
        function obj = calcEntryZones(obj) %pointer logic
            cur = obj.first.getNext(); %Node*
            while cur ~=0
                obj.prev = cur.getPrev(); %Node*
                upped = obj.prev.getUpped();
                res = obj.prev.getReset();
                cur.setEntry(upped.reset(res));
                if cur ~= obj.last
                    cur = cur.getNext();
                else
                    cur = 0;
                end
            end
            %void calcEntryZones();
        end
    end
    
end

