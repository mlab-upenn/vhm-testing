classdef Location
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        inv; %const list<dc_t*>* 
        edge; %Edge* 
        id; %string
        dbm; %DBM
        isLoop; %boolean
        back; % Edge* 
        loopBack; %Edge* 
    end
    
    methods
        function obj = Location(varargin) %in,e)
            if nargin == 2
                obj.inv = varargin{1};
                obj.edge = varargin{2};
                obj.isLoop = false;
                return
            elseif nargin == 1
                obj.edge = 0;
                obj.inv = varargin{1};
                obj.isLoop = false;
                % Location (const list<dc_t*>*);
            end
            %Location (const list<dc_t*>*, Edge*); 
        end
   
        % ~Location ();
        function obj = setLoop(obj)
            obj.isLoop = true;
            %void setLoop ();
        end
        function isTrue = isLoopLoc(obj)
            isTrue = obj.isLoop();
            %bool isLoopLoc ();
        end
        function edge = getEdge(obj)
            edge = obj.edge;
            %Edge* getEdge ();
        end
        %const Edge* getEdge () const;
        function obj = setEdge(obj,e)
            obj.edge = e;
            %void setEdge (Edge*);
        end
        function inv = getInvariant(obj)
            inv = obj.inv;
            %const list<dc_t*>* getInvariant () const;
        end
    
        function text = getInvariantText(obj)
            text = '';
            for i = 1:length(obj.inv)
                text = [text, obj.inv{i},'&&'];
            end
            %string getInvariantText () const;
        end
        
        function obj = setDBM(obj,m)
            obj.dbm = m;
            %void setDBM (DBM);
        end
        
        function dbm = getDBM(obj)
            dbm = obj.dbm;
            %const DBM& getDBM () const ;
        end
        
        function obj = setBack(obj,e)
            obj.back = e;
            %void setBack (Edge*);
        end
        
        function obj = setBackLoop(obj,e)
            obj.loopBack = e;
            %void setBackLoop (Edge*); 
        end
        
        function back = getBack(obj)
            back = obj.back;
            %Edge* getBack ();
        end
        
        function loopBack = getBackLoop(obj)
            loopBack = obj.loopBack;
            %Edge* getBackLoop ();
        end
    end
    
end

