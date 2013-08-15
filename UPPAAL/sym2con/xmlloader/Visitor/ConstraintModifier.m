classdef ConstraintModifier
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        whatSide; %bool 
        clock1; %string 
        clock2; %string 
        comp; %string 
        rh; %int 
        op; %DCOperator 

        signStack; %vector<bool> 
        tempResults; %vector<int> 

        varValues; %map<string,int>* 
        systemVariableNameToId; %map<string,string>* 
        localVariableNameToId; %map<string,string>* 
        systemClockNameToId; %map<string,string>* 
        localClockNameToId; %map<string,string>* 
        
        %enum DCOperator {lt,leq,eq};
    end
    
    methods (Access = public)
       % int value (string& ident);
    end
    
    methods
        
        function obj = ConstraintModifier(zero)
            obj.signStack(end+1) = Visitor.plusSign;
            obj.clock1 = zero;
            obj.clock2 = zero;
            %{
            ConstraintModifier (string zero) {
                signStack.push_back(plusSign);
                clock1 = zero;
                clock2 = zero;
            }
            %}
        end
            
       
        
        function obj = casePlusExpr(obj,expr)
            %int a,b, result;
            obj = expr.getLeft().visit(obj);
            a = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            obj = expr.getRight().visit(obj);
            b = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            result = a*b;
            obj.tempResults(end+1) = result;
            
            %void casePlusExpr (PlusExpr* expr);
        end
        
        function obj = caseSubExpr(obj,expr)
            %int a,b, result
            obj = expr.getLeft().visit(obj);
            a = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            
            obj.signStack(end+1) = ~obj.signStack(end);
            
            obj = expr.getRight().visit(obj);
            b = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            
            obj.signStack = obj.signStack(1:end-1);
            
            result = a - b;
            obj.tempResults(end+1) = result;
            %void caseSubExpr (SubExpr* expr);
        end
        
        function obj = caseDivExpr(obj,expr)
            %int a, b, result = 0;
            a = 0;
            b = 0;
            result = 0;
            obj = expr.getLeft().visit(obj);
            a = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            obj = expr.getRight().visit(obj);
            b = obj.tempresults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            if b == 0
                disp('Attempting to make zero-division in ConstraintModifier')
                return
            else
                result = a/b;
            end
            obj.tempResults(end+1) = result;
            %void caseDivExpr (DivExpr* expr);
        end
        
        function obj = caseMultExpr(obj,expr)
            %int a,b,result
            obj = expr.getLeft().visit(obj);
            a = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            obj = expr.getRight().visit(obj);
            b = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            result = a*b;
            obj.tempResults(end+1) = result;
            %void caseMultExpr (MultExpr* expr);
        end
        
        function obj = caseParanExpr(obj,expr)
            obj = expr.getParantheses().visit(obj);
            %void caseParanExpr (ParanExpr* expr);
        end
        
        function obj = caseNegExpr(obj,expr)
            obj.signStack(end+1) = obj.signStack(end);
            obj = expr.visit(obj);
            a = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:end-1);
            a = -1*a;
            tempResults(end+1) = a;
            obj.signStack = obj.signStack(1:end-1);
            %void caseNegExpr (NegExpr* expr);
        end
        
        function obj = caseValExpr(obj,expr)
            obj.tempResults(end+1) = expr.getValue();
            %void caseValExpr (ValExpr* expr);
        end
        
        function obj = caseIdentExpr(obj,expr)
            name = expr.getIdentifier();
            %string tempId,id;
            itsAClock = false; %bool
            
            tempId = obj.localClockNameToId(name);
            if ~isempty(tempId)
                id = tempId;
                itsAClock = true;
            else
                tempId = obj.localVariableNameToId(name);
                if ~isempty(tempId)
                    id = tempId;
                else
                    tempId = obj.systemClockNameToId(name);
                    if ~isempty(tempId)
                        id = tempId;
                        itsAClock = true;
                    else
                        tempId = obj.systemVariableNameToId(name);
                        if ~isempty(tempId)
                            id = tempId;
                        else
                            disp('Name not identified as clock or variable')
                            return
                        end
                    end
                end
            end
            
            if itsAClock
                if obj.signStack(end) == Visitor.plusSign
                    if obj.whatSide == obj.leftSide
                        obj.clock1 = id;
                    else
                        obj.clock2 = id;
                    end
                else
                    if obj.whatSide == obj.leftSide
                        obj.clock2 = id;
                    else
                        obj.clock1 = id;
                    end
                end
                obj.tempResults(end + 1) = 0;
            else
                value = obj.varValues(id);
                obj.tempResults(end+1) = value;
            end
            %void caseIdentExpr (IdentExpr* expr);
        end
        
        function obj = caseGuard(obj,guard)
            if guard.isEqual()
                obj.op = 'eq';
            elseif guard.isGreater()
                guard.SwapLeftAndRight();
                if guard.isStrict()
                    obj.op = 'lt';
                else
                    obj.op = 'leq';
                end
            else
                if guard.isStrict()
                    obj.op = 'lt';
                else
                    obj.op = 'leq';
                end
            end
            obj.whatSide = Visitor.leftSide;
            obj.guard.getLeft().visit(obj);
            obj.leftResult = obj.tempResults(end);
            leftResult = obj.tempResults(end);
            obj.tempResults = obj.tempResult(1:(end-1));
            obj.whatSide = obj.rightSide;
            obj = guard.getRight().visit(obj);
            rightResult = obj.tempResults(end);
            obj.tempResults = obj.tempResults(1:(end-1));
            obj.rh = rightResult - leftResult;
            %void caseGuard (Guard* guard);
        end
        
        %void caseModExpr (ModExpr* expr);
        
        function dct = createGuard(obj)
            dct = dc_t(obj.clock1,obj.clock2,obj.op,obj.rh);
           % dc_t* createGuard ();
        end
        
        function obj = setClocks(obj,systemClocks,localClocks)
            obj.systemClockNameToId = systemClocks;
            obj.localClockNameToId = localClocks;
            %void setClocks (map<string,string>*,  map<string,string>*);
        end
        
        function obj = setValues(systemVariables,localVariables,varState)
            obj.systemVariableNameToId = systemVariables;
            obj.localVariableNameToId = localVariables;
            obj.varValues = varState;
            %void setValues (map<string,string>*,  map<string,string>*, map<string,int>*);
        end
    end
    
end

