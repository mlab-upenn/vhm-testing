classdef DCCreator
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant)
        %from constraints.h
        dbm_WEAK = 1;
        dbm_STRICT = 0;
        
        
      %  doTime; %bool
      %  keep;%timeKeeper
    end
    properties (SetAccess = private)
        % comparison for strings
        
        %{
            struct strCmp
            {
                bool operator()(const string s1,const string s2 ) const
                {
                    const char *c1;
                    const char *c2;

                    c1=s1.c_str();
                    c2=s2.c_str();
                    return strcmp( c1, c2 ) < 0;
                }
            };
        %}
            entryTimeDBM; %dbm_t 
            zeroClockRepresentation; %string 
            entrytimesmap; %map<string, int, strCmp> 
            lta; %Lta* 
            lastresetdata;%int
            clocknumbermap; %map<string, int, strCmp> 
          
       %{
            typedef struct {
                double createConstraint;
                double createDBM;
                double closeDBM;
                double findPoint;
  
            }timeKeeper;
         %}   
    end
    
    methods (Static)
        %from constraints.h
        function raw = dbm_bound2raw(bound,strict)
            raw = bitsra(bound,-1);
            raw = bitor(raw,strict);
        end
    end
    
    methods
        function bool = isLess(obj, x,y)
            strictnessX = obj.dbm_rawIsStrict(x);
            boundX = obj.dbm_raw2bound(x);
            boundY = obj.dbm_raw2bound(y);
            
            if boundX < boundY
                bool = true;
                return
            elseif boundX == boundY && strictnessX
                bool = true;
                return
            else
                bool = false;
                return
            end
        end
        function obj = DCCreator(inputlta,zeroclock)
            obj.lta = inputlta;
            obj.zeroClockRepresentation = zeroclock;
            obj.lastresetdata = zeros(1,obj.lta.getNumberOfLocations() * obj.lta.getNumberOfClocks());
            if obj.lastresetdata == 0
                disp('No memory obtained');
            end
            obj.clocknumbermap = containers.Map;
            for i=1:obj.lta.getNumberOfClocks()
                clockNames = obj.lta.getClockNames();
                obj.clocknumbermap(clockNames{i}) = i;
            end
            obj.CreateLastResetAtTable();
            %DCCreator(Lta*, string&);
        end
        %~DCCreator();
        %TODO:fix this function
        function entryTimeDBM = CreateEntryTimeConstraints(obj)
            start;%clock_t
            if Solver.doTime
                start = clock();
                dim = obj.lta.getNumberOfLocations();
                entryTimeDBM = dbm_t(dim);
                rawdbm = entryTimeDBM.getDBM();%raw_t 
                dbm_init(rawdbm,dim);
                ltaIterator = obj.lta.getIterator(); %LtaIterator *
                n = obj.lta.getNumberOfLocations(); %cindex_t
                invariant; %list<dc_t>
                guard; %list<dc_t>
                loc; %Location
                for i=1:n
                    loc = ltaIterator.getLocation();
                    invariant = loc.getInvariant();
                    obj.CreateConstraint(rawdbm,dim,invariant,i,false);
                    ltaIterator.move();
                end
                ltaIterator = obj.lta.getIterator();
                for i=1:n-1
                    loc = ltaIterator.getLocation();
                    rawdbm((i)*dim+(i+1)) = DCCreator.dbm_bound2raw(0,DCCreator.dbm_WEAK);
                    %DBM(I,J) rawdbm[(I)*dim+(J)]
                    guard = loc.getEdge().getGuard();
                    obj.CreateConstraint(rawdbm,dim,guard,i,true);
                    
                    invariant = loc.getInvariant();
                    obj.CreateConstraint(rawdbm,dim,invariant,i,true);
                    
                    ltaIterator.move();
                end
                
                if Solver.doTime
                    keep = SolutionFinder.keep();
                    keep.closeDBM = (clock()-start)/CLOCKS_PER_SEC;
                    SolutionFinder.keep(keep);
                end
            end
            %dbm_t& CreateEntryTimeConstraints();
        end
    end
    
    methods (Access = private)
        
        function out = DBM(I,J,dim,rawdbm)
            out = rawdbm((I)*dim+(J));
        end
        
        function int = LastResetAt(obj,locId,clock)
            clockNr = obj.clocknumbermap(clock);
            int = obj.lastresetdata(locId*(obj.lta.getNumberOfClocks())+clockNr);
            %int LastResetAt(int,string&);
        end
        function obj = CreateLastResetAtTable(obj)
            ltaIterator = obj.lta.getIterator();
            edge; %Edge
            location;%int
            clocknr;%int
            pos;%int
            clocknames;%vector<string>
            
            for clocknr=1:obj.lta.getNumberOfClocks()
                obj.lastresetdata(clocknr) = 0;
            end
            
            locs = obj.lta.getNumberOfLocations();
            clocks = obj.lta.getNumberOfClocks();
            
            for location = 1:obj.lta.getNumberOfLocations()-1
                edge = ltaIterator.getEdge();
                for clocknr = 1:obj.lta.getNumberOfClocks()
                    clockNames = obj.lta.getClockNames();
                    search = [',',clockNames{clocknr},','];
                    pos = strfind(edge.getReset(),search);
                    if isempty(pos)
                        obj.lastresetdata((location*clocks)+clocknr) = obj.lastresetdata(((location-1)*clocks)+clocknr);
                    else
                        obj.lastresetdata(location*clocks+clocknr) = location;
                    end
                end
            end
            
            %void CreateLastResetAtTable();
        end
        function obj = CreateConstraint(obj,rawdbm,dim,clockConstraints,location,compareToNext)
            %void CreateConstraint(raw_t*, int, const list<dc_t*>*, int, bool);
            if compareToNext
                aheadInTime = 1;
            else
                aheadInTime = 0;
            end
            for iterator = 1:length(clockConstraints)
                i = clockConstraints{iterator}.getX();
                j = clockConstraints{iterator}.getY();
                
                if clockConstraints{iterator}.getOp() == lt
                    strict = true;
                else
                    strict = false;
                end
                if i~=obj.zeroClockRepresentation && j~=obj.zeroClockRepresentation
                    obj.constrainEntry(rawdbm,dim,obj.LastResetAt(location,j),obj.LastResetAt(location,i),clockConstraints{iterator}.getBound(),strict);
                elseif i ~= obj.zeroClockRepresentation
                    obj.constrainEntry(rawdbm,dim,obj.LastResetAt(location,j),location + aheadInTime,clockConstraints{iterator}.getBound(),strict);
                else
                    obj.constrainEntry(rawdbm,dim,location+aheadInTime, obj.LastResetAt(location,i), clockConstraints{iterator}.getBound(),strict);
                end
            end
        end
        function [obj rawdbm] = constrainEntry(obj,rawdbm,dim,i,j,bound,isStrict)
            newval; %raw_t is just an integer
            if isStrict
                newval = DCCreator.dbm_bound2raw(bound,DCCreator.dbm_STRICT);
                
            else
                newval = DCCreator.dbm_bound2raw(bound,DCCreator.dbm_WEAK);
            end
            if obj.isLess(newval,rawdbm((i)*dim+(j)))
                rawdbm((i)*dim+(j)) = newval;
            end
            %void constrainEntry(raw_t*, int, int, int, int, bool);
        end
    end
    
end

