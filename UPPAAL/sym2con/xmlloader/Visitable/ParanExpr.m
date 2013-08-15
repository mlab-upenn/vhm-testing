classdef ParanExpr
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        inParan; %Expr*
    end
    
    methods
        function obj = ParanExpr(e)
            obj.inParan = e;
            %{
            ParanExpr::ParanExpr (Expr* e ) {
                inParan = e;
            }
            %}
        end
        
        function expr = getParantheses(obj)
            expr = obj.inParan;
            %{
            Expr* ParanExpr::getParantheses () {
                return inParan;
            }
            %}
        end
        
       
        %void ParanExpr::visit (Visitor* v) {}
        
        %{
        void ParanExpr::toString (ostream& o){
            o<< "(";
            inParan->toString (o);
            o<< string (")");
        }
        %}
        
    end
    
end

