classdef Bound
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ubound; %bool
        bound;%mpq_class 
        strict; %bool 
    end
    
    methods
        function obj = Bound(varargin) %{b,s%})
            if nargin < 1
                obj.strict = true;
                obj.ubound = true;
                return
            elseif nargin == 2
                obj.bound = varargin{1};
                obj.strict = varargin{2};
                obj.ubound = false;
                return
            end 
            %Bound(mpq_class,bool);
        end
        
        function o = operator_shiftLeft(o,b)
            if b.isUnbound()
                o = [o,'(inf, <)'];
            else
                o = [o,'(',b.getBound()];
                if b.isStrict()
                    c = '<';
                else
                    c = '<=';
                end
                o = [o,c,')'];
            end
            %ostream& operator<< (ostream&,const Bound&);
        end
        
        function bool = operator_lessThan(obj,oth)
            if obj.isUnbound()
                bool = false;
                return
            end
            if ~obj.isUnbound() && oth.isUnbound()
                bool = true;
                return
            elseif obj.getBound() < oth.getBound()
                bool = true;
                return
            elseif obj.getBound() == other.getBound() && obj.isStrict() && ~oth.isStrict()
                bool = true;
                return
            end
            bool = false;
            return
            %bool operator< (const Bound&) ;
        end
        
        function bool = operator_lessThanEqualTo(obj,oth)
            bool = obj.operator_equal(oth) || obj.operator_lessThan(oth);
            %bool operator<= (const Bound&);
        end
        
        function bool = operator_equal(obj,oth)
            if oth.isUnbound() && obj.isUnbound()
                bool = true;
                return
            else
                bool = oth.getBound() == obj.getBound() && oth.isStrict() == obj.isStrict();
                return
            end
            %bool operator== (const Bound&);
        end
        
        function bool = operator_greaterThan(obj,oth)
            bool = ~obj.operator_lessThanEqualTo(oth);
            %bool operator> (const Bound&);
        end
        
        function bool = operator_greaterThanEqualTo(obj,oth)
            bool = obj.operator_equal(oth) || obj.operator_greaterThan(oth);
            %bool operator>= (const Bound&);
        end
        
        function bool = operator_notEqual(obj,oth)
            bool = ~obj.operator_equal(oth);
            %bool operator!= (const Bound&);
        end
        
        function bound = operator_plus(obj,oth)
            b = Bound();
            if obj.isUnbound() || oth.isUnbound()
                bound = b;
                return
            end
            s_strict = obj.isStrict() || oth.isStrict();
            r = Bound(oth.getBound() + obj.getBound(),s_strict);
            bound = r;
            return
            %Bound operator+ (const Bound&);
        end
        
        function bound = getBound(obj)
            bound = obj.bound;
            %mpq_class getBound() const ;
        end
        
        function strict = isStrict(obj)
            strict = obj.strict;
            %bool isStrict () const;
        end
        
        function ubound = isUnbound(obj)
            ubound = obj.ubound;
            %bool isUnbound () const ;
        end
        
        function bool = satisfied(obj,val)
            if obj.isUnbound()
                bool = true;
                return
            elseif val < obj.getBound()
                bool = true;
                return
            elseif val == obj.getBound() && ~obj.isStrict()
                bool = true;
                return
            else
                bool = false;
                return
            end
            %bool satisfied (const mpq_class&) const;
        end
            
    end
    
    methods (Static)
        function mpq = chooseValueMax(obj,upper,lower,epsilon)
            if upper.isUnbound()
                disp('chooseValueMax was called with an upper infinity bound. THis should not happen...')
                disp('uses chooseValueMin instead')
                mpq = obj.chooseValueMin(upper,lower,epsilon);
            elseif upper.isStrict()
                mpq = upper.getBound() - epsilon;
                return
            else
                mpq = upper.getBound();
                return
            end
            %static mpq_class chooseValueMax (const Bound&  upper, const Bound& lower, const mpq_class& epsilon);
        end
        
        function mpq = chooseValueMin(obj,upper,lower,epsilon)
            static mpq_class chooseValueMin (const Bound&  upper, const Bound& lower, const mpq_class& epsilon);
            if lower.isUnbound()
                disp('Very strange: chooseValueMin was called with an infinity bound as lower...')
                disp('Returning zero')
                mpq = 0;
                return
            elseif lower.isStrict()
                mpq = (-1*lower.getBound()) + epsilon;
                return
            else
                mpq = -1*lower.getBound();
                return
            end
        end
   
        function mpq = chooseValueBetween(obj,upper, lower, epsilon)
            if upper.isUnbound() && lower.isUnbound()
                disp('Strange: chooseValueBetween was called with two infinity bounds...')
                disp('Returning zero')
                mpq = 0;
                return
            elseif upper.isUnbound()
                mpq = obj.chooseValueMin(upper,lower,epsilon);
                return
            elseif lower.isUnbound()
                mpq = obj.chooseValueMax(upper,lower,epsilon);
                return
            elseif ~lower.isStrict()
                mpq = -1*lower.getBound();
                return
            elseif ~upper.isStrict()
                mpq = upper.getBound();
                return
            else
                mpq = (upper.getBound() - lower.getBound())/2;
                return
            end
            % static mpq_class chooseValueBetween (const Bound& upper, const Bound& lower, const mpq_class& epsilon);
        end
        
    end
    
end

