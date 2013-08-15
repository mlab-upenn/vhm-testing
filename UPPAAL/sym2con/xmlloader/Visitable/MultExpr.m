classdef MultExpr
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        %MultExpr
        left; %Expr*
        right; %Expr*
        
    end
    
    methods
        function obj = MultExpr(l,r)
            obj.left = l;
            obj.right = r;
            %{
            MultExpr::MultExpr (Expr* l, Expr* r ) {
                left = l;
                right = r;
            }
            %}
        end
        function left = getLeft(obj)
            left = obj.left;
            %Expr* MultExpr::getLeft () {return left;}
        end
        
        function right = getRight(obj)
            right = obj.right;
            %Expr* MultExpr::getRight () {return right;}
        end
        function v = visit(obj,v)
            v.caseMultExpr(obj);
            %{
            void MultExpr::visit (Visitor* v) {
                v->caseMultExpr (this);
            }
            %}
        end
        
        %{
        function 
        void MultExpr::toString (ostream& o){
            left->toString (o);
            o << "*";
            right->toString (o);
        }
        %}
    end
    
end

