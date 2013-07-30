classdef trace
    %UNTITLED19 Summary of this class goes here
    %   Detailed explanation goes here
    
    %THIS CODE IS INCOMPLETE
    properties (SetAccess = private)
        %Transitions
        i = 0;
        guard; %DBM 
        reset; %vector<int> 
        from; %Node* 
        to; %Node* 

        
        %Trace
        entry; %DBM
        delay; %DBM
        trans; %Transition
        backTrans; %Transition

        valEntry; %VariableAssignment
        valDelay; %VariableAssignment
        
        %Node
        first; %Node*
        last; %Node*
        zero; %string
        refClock; %string
        states; %int

    end
    
    methods
        %Transitions
        function obj = Transition(g,r,f,t)
            %guard(g), reset (r)
            obj.guard = g;
            obj.reset = r;
            obj.from = f;
            obj.to = t;
           
            %Transition (DBM, vector<int>, Node*,Node*);
        end
        
        %~Transition ();
        
        function guard = getGuard(obj)
            guard = obj.guard;
            DBM& getGuard ();
        end
        
        function reset = getReset(obj)
            reset = obj.reset;
            %vector<int>& getReset ();
        end
        function to = getTo(obj)
            to = obj.to;
            %Node* getTo ();
        end
    
        function from = getFrom(obj)
            from = obj.from;
            %Node* getFrom ();
        end
        
         %Node
         function obj = Node(e,d)
             obj.entry = e;
             obj.delay = d;
             obj.trans = 0;
             %Node (DBM,DBM);
         end
        %~Node ();
        function entry = getEntry(obj)
            entry = obj.entry;
            %DBM& getEntry ();
        end
        
        function delay = getDelay(obj)
            delay = obj.delay;
            %DBM& getDelay ();
        end
        
        function obj = setBackward(obj, t)
            obj.backTrans = t;
            %void setBackward (Transition*);
        end
        
        function obj = setForward(obj,t)
            obj.trans = t;
            %void setForward (Transition*);
        end
        
        function backTrans = getBackward(obj)
            backTrans = obj.backTrans;
            %Transition* getBackward ();
        end
        
        function trans = getForward(obj)
            trans = obj.trans;
            %Transition* getForward ();
        end
    
        function obj = setEntry(obj,v)
            obj.valEntry = v;
            %void setEntry ( VariableAssignment v);
        end
        function valEntry = getEntryV(obj)
            valEntry = obj.valEntry;
            %VariableAssignment getEntryV ();
        end
        function obj = setDelay(obj,v)
            void setDelay ( VariableAssignment v);
        end
        
        function valDelay = getDelayV(obj)
            valDelay = obj.valDelay;
            %VariableAssignment getDelayV ();
        end
        
        %Trace
        function obj = Trace(ta,opt)
            obj.states = 0;
            opti = opt;
            numClocks = length(ta.getClockNames());
            zeroD = DBM(numClocks);
            zeroBound = Bound(0,false);
            it; %int
            it2; %int
            setRef = false; %bool
            obj.states = obj.states + 1;
            
            for it = 1:numClocks
                zeroD.setConstraint(0,it,zeroBound);
                zeroD.setConstraint(it,0,zeroBound);
                for it2=1:numClocks
                    zeroD.setConstraint(it,it2,zeroBound);
                    zeroD.setConstraint(it2,it,zeroBound);
                end
            end
            zeroD.close(true);
            ltait = ta.getIterator(); %?
            inv = ltait.getLocation().getDBM(); %?
            delayed = zeroD.up().intersect(inv);
            obj.first = Node(zeroD,delayed);
            obj.last = obj.first;
            
            %Trace (LTA::Lta*,Options*);
        end
        %~Trace () {if (first!=0) delete first;}
        function first = getFirst(obj)
            first = obj.first;
            %Node* getFirst () {return first;}
        end
        
        function last = getLast(obj)
            last = obj.last;
            %Node* getLast () {return last;}
        end
        
        function obj = add(obj,inv,resets,guard)
            lasDZone = obj.last.getDelay();
            entryZone = lastDZone.intersect(guard).reset(resets);
            delayZone = entryZone.up().intersect(inv);
            n = Node(entryZone,delayZone);
            obj.trans = Transition(guard, resets, obj.last, n);
            obj.last.setForward(obj.trans);
            n.setBackward(obj.trans);
            obj.last = n;
            obj.states = obj.states + 1;
            
            %do while -loop workaround
            bool = true;
            while ltait.move() || bool  %?
                if ltati.getEdge() ~= 0 && ltait.getEdge().getNextLocation() ~= 0
                    s = ltait.getEdge().getReset();
                    obj.reset = obj.convert(s,opt.clockIndex);
                    guard = ltait.getEdge().getDBM();
                    inv = ltait.getEdge().getNextLocation().getDBM();
                    obj.add(inv,obj.reset,guard);
                end
                bool= false;
            end
            %void add (DBM&, vector<int>,DBM&);
        end
        
        function buf = convert(s,index)
            buf;
            s;
            buffer = strsplit(s,',');
            for j=1:length(buffer)
                if ~isempty(buffer{j})
                    buf = [buf index(buffer)];
                end
            end
        end
        
        function refClock = getRefClock(obj)
            refClock = obj.refClock;
            %string getRefClock ();
        end
        
        function states = getStates(obj)
            states = obj.states;
            %int getStates () {return states;}
        end
       
    end
    
end

