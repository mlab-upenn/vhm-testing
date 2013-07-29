classdef LTA
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        firstLocation; %  Location* 
        curLocation; %Location* 
        loopStartLocation; %Location* 
        numOfLocations; %unsigned 
        clocks; %vector<string>* 
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
        %{
        function iterator = getIterator(obj)
            iterator = obj.LtaIterator(firstLocation);
            %LtaIterator* getIterator ();
        end
        %}
        %{
        function iterator = getLoopIterator(obj)
            iterator = obj.LtaIterator(loopStartLocation);
            %LtaIterator* getLoopIterator();
        end
        %}
        function firstLocation = getFirst(obj)
            firstLocation = obj.firstLocation;
            %Location* getFirst () {return firstLocation;}
        end
        %void makeBackLinks ();
    end
end
