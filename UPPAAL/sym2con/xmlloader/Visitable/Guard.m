classdef Guard
    %GUARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        %Guard
        equal; %bool
        greater; %bool
        strict; %bool
        left; %Expr*
        right; %Expr*
    end
    
    methods
        %Guard
        function obj = Guard(varargin)
            if nargin == 4
                gre = varargin{1};
                str = varargin{2};
                l = varargin{3};
                r = varargin{4};
                
                obj.greater = gre;
                obj.strict = str;
                obj.equal = false;
                obj.left = l;
                obj.right = r;
            elseif nargin == 2
                l = varargin{1};
                r = varargin{2};
                
                obj.greater = false;
                obj.strict = false;
                obj.left = l;
                obj.right = r;
            end
            %{
            Guard::Guard (bool gre, bool str,Expr* l,Expr* r) {
                greater = gre;
                strict = str;
                equal = false;
                left = l;
                right = r;
            }
            
            Guard::Guard (Expr* l, Expr* r) {
                greater = false;
                strict =  false;
                left  = l;
                right = r;
            }
        
            %}
        end
        
        function obj = SwapLeftAndRight(obj)
            buf = obj.left;
            obj.left = obj.right;
            obj.right = buf;
            %{
            void Guard::SwapLeftAndRight () {
                Expr* buf = left;
                left = right;
                right = buf;
            }
            %}
        end

        function obj = visit(obj,v)
            v.caseGuard(obj);
            %{
            void Guard::visit (Visitor *v) {
                v->caseGuard (this);
            }
            %}
        end
        
        function obj = toString(obj,o)
            %{
            void Guard::toString (ostream& o) {
                left->toString (o);
                o<< "<<";
                right ->toString (o);
                o << endl;
            }
            %}
        end
        
        function bool = isStrict(obj)
            bool = obj.strict;
            %bool isStrict() {return strict;}
        end
        
        function bool = isGreater(obj)
            bool = obj.greater;
            %bool isGreater() {return greater;}
        end
        
        function bool = isEqual(obj)
            bool = obj.equal;
            %bool isEqual() {return equal;}
        end
        
        function expr = getLeft(obj)
            expr = obj.left;
            %Expr* getLeft() {return left;}
        end
        
        function expr = getRight(obj)
            expr = obj.right;
            %Expr* getRight() {return right;}
        end
        
        function obj = setLeft(obj,newLeft)
            obj.left = newLeft;
            %void setLeft(Expr* newLeft) {left = newLeft;}
        end
        
        function obj = setRight(obj,newRight)
            obj.right = newRight;
            %void setRight(Expr* newRight) {right = newRight;}
        end
    end
    
end

