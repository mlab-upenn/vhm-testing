classdef DivExpr
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        %DivExpr
        left; %Expr*
        right; %Expr*
    end
    
    methods
        %DivExpr
        function obj = DivExpr(l,r)
            obj.left = l;
            obj.right = r;
            %{
            DivExpr::DivExpr (Expr* l, Expr* r ) {
                left = l;
                right = r;
            }
            %}
        end
        
        function left = getLeft(obj)
            left = obj.left;
            %Expr* DivExpr::getLeft () {return left;}
        end
        
        function right = getRight(obj)
            right = obj.right;
            %Expr* DivExpr::getRight () {return right;}
        end
        
        function v = visit(obj,v)
            v.caseDivExpr(obj);
            %{
            void DivExpr::visit (Visitor* v) {
                v->caseDivExpr (this);
            }
            %}
        end
        
        %{
        void DivExpr::toString (ostream& o){
            left->toString (o);
            o << "/";
            right->toString (o);
        }
        %}
    end
    
end

