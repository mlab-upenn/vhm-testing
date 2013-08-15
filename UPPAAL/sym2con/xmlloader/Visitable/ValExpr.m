classdef ValExpr
    %VALEXPR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        %ValExpr
        value; %int
    end
    
    methods
        %ValExpr
        function obj = ValExpr(val)
            obj.value = val;
            %{
            ValExpr::ValExpr (int val) {
                value = val;
            }
            %}
        end
        
        function obj = toString(obj,o)
            %{
            void ValExpr::toString (ostream& o){
                o << value;
            }
            %}
        end
        
        function v = visit(obj,v)
            v.caseValExpr(obj);
            %{
            void ValExpr::visit (Visitor* v) {
                v->caseValExpr (this);
            }
            %}
        end
        
        function value = getValue(obj)
            value = obj.value;
            %int ValExpr::getValue () {return value;}
        end
    end
    
end

