classdef PlusExpr
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %PlusExpr
        left; %Expr*
        right; %Expr*
    end
    
    methods
        function obj = PlusExpr(l,r)
            obj.left = l;
            obj.right = r;
            %{
            PlusExpr::PlusExpr (Expr* l, Expr* r ) {
            left = l;
            right = r;
        }
        %}
            
        end
        
        function left = getLeft(obj)
            left = obj.left;
            %Expr* PlusExpr::getLeft () {return left;}
        end
        
        function right = getRight(obj)
            right = obj.right;
            %Expr* PlusExpr::getRight () {return right;}
        end
        
        function v = visit(obj,v)
            v.casePlusExpr(obj);
            %{
            void PlusExpr::visit (Visitor* v) {
                v->casePlusExpr (this);
            }
            %}
        end
        %{
        function
        void PlusExpr::toString (ostream& o){
            left->toString (o);
            o << "+";
            right->toString (o);
        }
        end
        %}
    end
    
end

