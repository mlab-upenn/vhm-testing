classdef IdentExpr
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        %IdentExpr
        identifier; %string*
    end
    
    methods
        function obj = IdentExpr(id)
            obj.identifier = id;
            %{
            IdentExpr::IdentExpr (string* id) {
                identifier = id;
            }
            %}
        end
        
        function string = getIdentifier(obj)
            string = obj.identifier;
            %{
            string IdentExpr::getIdentifier () {
                return string (*identifier);
            }
            %}
        end
        
        function obj = toString(obj,o)
            
            %{
            void IdentExpr::toString (ostream& o){
                o<< getIdentifier ();
            }
            %}
        end
        
        
        function v = visit(obj,v)
            v.caseIdentExpr(obj);
            %{
            void IdentExpr::visit (Visitor* v) {
                v->caseIdentExpr (this);
            }
            %}
        end
        
    end
    
end

