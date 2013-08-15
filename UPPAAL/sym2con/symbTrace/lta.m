classdef LTA
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        %LTA
        firstLocation; %  Location* 
        curLocation; %Location* 
        loopStartLocation; %Location* 
        numOfLocations; %unsigned 
        clocks; %vector<string>* 
        
        %LtaIterator
        cur; %Location
    end
    
    methods
        function obj = LTA(n,c)
            obj.firstLocation = n;
            obj.curLocation = n;
            obj.numOfLocations = l;
            obj.clocks = c;
            %{
                firstLocation = n;
                curLocation = n;
                numOfLocations =1;
                clocks = c;
            %}
        %Lta (Location*,vector<string>*);
        end
        %~Lta ();
        function obj = add(obj,e,n)
            e.setNextLocation(n);
            e.setPrev(obj.curLocation);
            if e.isLoopTrans()
                n.setBackLoop(e);
            else
                n.setBack(e)
                obj.curLocation.setEdge(e);
                obj.curLocation = n;
                obj.numOfLocations = obj.numOfLocations + 1;
            end
            %void add (Edge*, Location*);
        end
        
        function obj = setLoopStartLocation(loc)
            obj.loopStartLocation = loc;
            %void setLoopStartLocation(Location* loc) { loopStartLocation = loc; }
        end
        
        function numLoc = getNumberOfLocations(obj)
            numLoc = obj.numOfLocations;
            %unsigned int getNumberOfLocations ();
        end
        
        function clocks = getNumberOfClocks(obj)
            clocks = size(obj.clocks);
            %unsigned int getNumberOfClocks();
        end
        function clockNames = getClockNames(obj)
            clockNames = obj.clocks;
            %vector<string>* getClockNames ();
        end
        
        function iterator = getIterator(obj)
            iterator = obj.LtaIterator(obj.firstLocation);
            %LtaIterator* getIterator ();
        end
        
        function iterator = getLoopIterator(obj)
            iterator = obj.LtaIterator(obj.loopStartLocation);
            %LtaIterator* getLoopIterator();
        end
        
        function firstLocation = getFirst(obj)
            firstLocation = obj.firstLocation;
            %Location* getFirst () {return firstLocation;}
        end
        %void makeBackLinks ();
        
        %%
        %LTAIterator
        function obj = LtaIterator(n)
            obj.cur = n;
        %LtaIterator (Location*);
        end
        
        function [bool,obj] = move(obj)
            if obj.cur.getEdge() == 0 || obj.cur.getEdge().getNextLocation() == 0
                bool = false;
                return
            else
                obj.cur = obj.cur.getEdge().getNextLocation();
                bool = true;
                return
            end
            %bool move();
        end
        
        function location = getLocation(obj)
            location = obj.cur;
            %const Location* getLocation ();
        end
        
        function edge = getEdge(obj)
            edge = obj.cur.getEdge();
            %const Edge* getEdge ();
        end
        
        function bool = hasSomething(obj)
            bool = obj.cur ~= 0;
            %bool hasSomething ();
        end
    end
end
