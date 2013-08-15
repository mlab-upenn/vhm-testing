classdef ModExpr
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %ModExpr
        left; %Expr*
        right; %Expr*
    end
    
    methods
        %ModExpr
        function obj = ModExpr(l,r)
            obj.left = l;
            obj.right = r;
            %{
            ModExpr::ModExpr (Expr* l, Expr* r ) {
                left = l;
                right = r;
            } 
            %}
        end
        
        function left = getLeft(obj)
            left = obj.left;
            %Expr* ModExpr::getLeft () {return left;}
        end
        
        function right = getRight(obj)
            right = obj.right;
            %Expr* ModExpr::getRight () {return right;}
        end
        
        function v = visit(obj,v)
            v.caseModExpr(obj)
            %{
                void ModExpr::visit (Visitor* v) {
                    v->caseModExpr (this);
                }
            %}
        end
        
        %{
        void ModExpr::toString (ostream& o){
            left->toString (o);
            o << "%";
            right->toString (o);
        }
        %}
    end
    
end

