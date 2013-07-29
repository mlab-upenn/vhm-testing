classdef Node
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        invariant; %string
        edge; %edge
    end
    
    methods
        function obj =  Node(varargin)
            if nargin == 2
                obj.edge = varargin{2};
                obj.invariant = varargin{1};
            elseif nargin == 1
                obj.edge = 0;
                obj.invariant = varargin{1};
            end
        end
        %~Node ();
        
        function edge = getEdge(obj)
            edge = obj.edge;
            %Edge* getEdge ();
        end
        
        %const Edge* getEdge () const;
        function obj = setEdge(obj,e)
            obj.edge = e;
            %void setEdge (Edge*);
        end
    end
    
end

