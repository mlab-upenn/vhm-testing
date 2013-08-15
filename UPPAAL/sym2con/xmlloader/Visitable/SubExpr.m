classdef SubExpr
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        left; %Expr*
        right; %Expr*
    end
    
    methods
        %SubExpr
        function obj = SubExpr(l,r)
            obj.left = l;
            obj.right = r;
            %{
            SubExpr::SubExpr (Expr* l, Expr* r ) {
                left = l;
                right = r;
            }
            %}
        end
        
        function left = getLeft(obj)
            left = obj.left;
            %Expr* SubExpr::getLeft () {return left;}
        end
        
        function right = getRight(obj)
            right = obj.right;
            %Expr* SubExpr::getRight () {return right;}
        end
        
        function v = visit(obj,v)
            v.caseSubExpr(obj)
            %{
            void SubExpr::visit (Visitor* v) {
                v->caseSubExpr (this);
            }
            %}
        end
        void SubExpr::toString (ostream& o){
            left->toString (o);
            o << "-";
            right->toString (o);
        }
    end
    
end

