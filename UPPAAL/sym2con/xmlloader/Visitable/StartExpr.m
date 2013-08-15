classdef StartExpr
    %STARTEXPR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        %StartExpr
        ex; %Expr*
    end
    
    methods
        function obj = StartExpr(e)
            obj.ex = e;
            %StartExpr(Expr* e) {ex = e;}
        end
        
        %~StartExpr () {delete ex;}
        
        function ex = getExpr(obj)
            ex = obj.ex;
            %Expr* getExpr () {return ex;}
        end
        
        function obj = visit(obj,visitor)
            obj.ex.visit(visitor);
            %{
            void visit (Visitor* visitor ) {
                ex->visit (visitor);
            }
            %}
        end
        function obj = toString(obj,o)
            %{
            void toString (ostream& o) {
                ex->toString (o);
            }
            %}
        end
    end
    
end

