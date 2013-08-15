classdef Visitor
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    %THIS CODE IS INCOMPLETE
    properties (Constant)
        plusSign = true;
        minusSign = false;
        
        leftSide = true;
        rightSide = false;
    end
    
    methods
        %{
        virtual void casePlusExpr (PlusExpr* expr)=0;
        virtual void caseSubExpr (SubExpr* expr)=0;
        virtual void caseDivExpr (DivExpr* expr)=0;
        virtual void caseMultExpr (MultExpr* expr)=0;
        virtual void caseParanExpr (ParanExpr* expr)=0;
        virtual void caseNegExpr (NegExpr* expr )=0;
        virtual void caseValExpr (ValExpr* expr)=0;
        virtual void caseIdentExpr (IdentExpr* expr)=0;
        virtual void caseGuard (Guard* guard) = 0;
        virtual void caseModExpr (ModExpr* expr)=0;
        %}
    end
    
end

