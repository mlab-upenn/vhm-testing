classdef Bound
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bound; %mpq_class 
        unbounded; %bool 
        strict; %bool 
    end
    
    methods
        
        function obj = Bound(varargin)
            if nargin == 2
                obj.bound = varargin{1}; %b;
                obj.strict = varargin{2};% str;
                obj.unbounded = false;
                return
            elseif nargin == 0
                obj.unbounded = true;
                return
            end
            %Bound (mpq_class, bool);
        end
        
        function boolean = operator_lessThan(obj,other)
            boolean = operator_lessThanEqualTo(obj,other) && ~operator_equal(obj,other);
            % bool operator< (Bound& );
        end
       
        function boolean = operator_equal(obj,other)
            if obj.isUnbound() && other.isUnbound()
                boolean = true;
                return;
            else
                boolean = other.getBound() == obj.getBound() && obj.isStrict() == other.isStrict();
            end
            %bool operator== (Bound& );
        end
        function boolean = operator_greaterThan(obj,other)
            boolean = ~operator_lessThanEqualTo(obj,other);
            %bool operator> (Bound& );
        end
        function boolean = operator_lessThanEqualTo(obj,other)
            if other.isUnbound()
                boolean = true;
                return;
            elseif obj.isUnbound()
                boolean = false;
                return;
            elseif obj.getBound() < other.getBound() 
                boolean = true;
                return;
            elseif obj.getBound() == other.getBound() && obj.isStrict() && ~other.isStrict()
                boolean = true;
                return;
            else
                boolean = false;
                return;
            end
            %bool operator<= (Bound& );
        end
        function boolean = operator_greaterThanEqualTo(obj,other)
            boolean = ~operator_lessThan(obj,other);
            %bool operator>= (Bound& );
        end
        function bound = getBound(obj)
            bound = obj.bound;
            %mpq_class& getBound ();
        end
        function strict = isStrict(obj)
            strict = obj.strict;
            %bool isStrict ();
        end
        function bound = operator_plus(obj,other)
            b = Bound();
            if other.isUnBound() || obj.isUnBound()
                bound = b;
                return;
            end
            newBound = other.getBound() + obj.getBound();
            isstrict = other.isStrict() || obj.isStrict();
            bound = Bound(newBound,isstrict);
            return;
            %{
            mpq_class newBound (other.getBound () + getBound ());
            bool strict = other.isStrict () || isStrict ();
            Bound h (newBound,strict); 
            //cout << h << endl;;
            return Bound (newBound,strict);

            %}
            %Bound operator+ (Bound&);
        end
        function boolean = isNeg(obj)
            if obj.unbounded
                boolean = false;
                return;
            end
            if obj.getBound() < 0
                boolean = true;
                return;
            elseif obj.getBound() == 0 && obj.isStrict()
                boolean = true;
                return;
            else
                boolean = false;
                return;
            end 
            %bool isNeg ();
        end
        function unbounded = isUnbound(obj)
            unbounded = obj.unbounded;
            %bool isUnbound ();
        end
        function boolean = satisfied(obj,value)
            if obj.isUnbound()
                boolean = true;
                return;
            end
            if value == obj.getBound()
                boolean = ~obj.isStrict();
                return;
            elseif value < obj.getBound()
                boolean = true;
                return;
            else
                boolean = false;
                return;
            end
        %bool satisfied (mpq_class&);
        end
    
    end
end

