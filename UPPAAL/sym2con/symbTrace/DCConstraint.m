classdef DCConstraint
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        op; %DCOperator
        origX; %string
        origY; %string
        clockX; %string
        clockY; %string
        bound;%int
    end
    
    methods
        function obj = DCConstraint(varargin)
            if nargin == 4
                obj.op = varargin{3};
                obj.bound = varargin{4};
                obj.clockX = varargin{1};
                obj.clockY = varargin{2};
                obj.origX = varargin{1};
                obj.origY = varargin{2};
                return
            elseif nargin == 1
                obj.op = varargin{1}.getOp();
                obj.bound = varargin{1}.getBound();
                obj.clockX = varargin{1}.getX();
                obj.clockY = varargin{1}.getY();
                obj.origX = '';
                obj.origX = '';
                
            end
        end
        %{
        function setOp(obj)
            void setOp(DCOperator);
        end
        %}
        function dcOp = getOp(obj) 
            dcOp = obj.op;
        end
        function obj = replaceX(obj,r)
            obj.origX = obj.clockX;
            obj.clockX = r;
        end
        function x = getX(obj)
            x = obj.clockX;
        end
        function obj = replaceY(obj,r)
            obj.origY = obj.clockY;
            obj.clockY = r;
        end
        function y = getY(obj)
            y = obj.clockY;
        end
        function bound = getBound(obj)
            bound = obj.bound;
        end
        %{
        function obj = ostream()
            friend ostream& operator<< (ostream& out, const dc_t&);
        end
        %}
    end
    
end

