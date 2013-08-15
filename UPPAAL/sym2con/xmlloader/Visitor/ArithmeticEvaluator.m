classdef ArithmeticEvaluator
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        buffer; %int
        varValues; %map<string,int>* 
        systemVariableNameToId; %map<string,string>* 
        localVariableNameToId; %map<string,string>* 
    end
    
    methods
        
        function buffer = evalExpr(obj,g)
            obj.buffer = 0;
            obj = g.visit(obj);
            buffer = obj.buffer;
            %int evalExpr (Expr* );
        end
        
        function obj = caseSubExpr(obj,expr)
            obj = expr.getLeft().visit(obj);
            buf = obj.buffer;
            obj = expr.getRight().visit(obj);
            obj.buffer = buf - obj.buffer;
            %void caseSubExpr (SubExpr* expr);
        end
        
        function obj = caseDivExpr(obj,expr)
            obj = expr.getLeft().visit(obj);
            buf = obj.buffer;
            obj = expr.getRight().visit(obj);
            obj.buffer = buf/obj.buffer;
            %void caseDivExpr (DivExpr* expr);
        end
        
        function obj = caseMultExpr(obj,expr)
            obj = expr.getLeft().visit(obj);
            buf = obj.buffer;
            obj = expr.getRight().visit(obj);
            obj.buffer = buf*obj.buffer;
            %void caseMultExpr (MultExpr* expr);
        end
        
        function obj = caseParanExpr(obj,expr)
            obj = expr.getParantheses().visit(obj);
            %void caseParanExpr (ParanExpr* expr);
        end
        
        function obj = caseNegExpr(obj,expr)
            obj = expr.getNegate().visit(obj);
            obj.buffer = -1*obj.buffer;
            %void caseNegExpr (NegExpr* expr);
        end
        
        function obj = caseValExpr(obj,expr)
            obj.buffer = expr.getValue();
            %void caseValExpr (ValExpr* expr);
        end
        
        function obj = caseIdentExpr(obj,expr)
            id; %string
            name = expr.getIdentifier(); %string
            tempId; %string
            tempId = obj.localVariableNameToId(name)
            if ~isempty(tempId)
                id = tempId;
            else
                tempId = obj.systemVariableNameToId(name);
                if ~isempty(tempId)
                    id = tempId;
                else
                    disp('Sorry not a variable');
                end
            end
            obj.buffer = obj.varValues(id);
            %void caseIdentExpr (IdentExpr* expr);
        end
        
        %void caseGuard (Guard* guard);
        
        function obj = caseModExpr(obj,expr)
            obj = expr.getLeft().visit(obj);
            buf = obj.buffer;
            obj = expr.getRight().visit(obj);
            obj.buffer = mod(buf,obj.buffer);
            %void caseModExpr (ModExpr* expr);
        end
        
        function obj = setValues(obj,systemVariables,localVariables,varState)
            obj.systemVariableNameToId = systemVariables;
            obj.localVariableNameToId = localVariables;
            obj.varValues = varState;
            %void setValues (map<string,string>*,  map<string,string>*, map<string,int>*);
        end
        
        function obj = casePlusExpr(obj,expr)
            obj = expr.getLeft().visit(obj);
            buf = obj.buffer;
            obj = expr.getRight().visit(obj);
            obj.buffer = buf + obj.buffer;
            % void casePlusExpr (PlusExpr* expr);
        end
    end
    
end

