classdef NegExpr
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        negated; %Expr*
    end
    
    methods
        
        function obj = NegExpr(e)
            obj.negated = e;
            %{
            NegExpr::NegExpr (Expr* e) {
                negated = e;
            }
            %}
        end
        
        function negated = getNegate(obj)
            negated = obj.negated;
            %{
            Expr* NegExpr::getNegate () {
                return negated; 
            }
            %}
        end
        
        
        %void NegExpr::visit (Visitor* v) {}
        
        %{
        void NegExpr::toString (ostream& o){
            o<< "-";
            negated->toString (o);
        }
        %}

    end
    
end

