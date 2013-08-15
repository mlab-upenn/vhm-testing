classdef Visitable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %THIS CODE IS INCOMPLETE
    %This class has multiple classes
    properties (SetAccess = private)
        %Visitable
        
        %StartExpr
        ex; %Expr*
        
        %ValExpr
        value; %int
        
        %IdentExpr
        identifier; %string*
        
        %ParanExpr
        inParan; %Expr*
        
        %NegExpr
        negated; %Expr*
        
        %PlusExpr
        left; %Expr*
        right; %Expr*
        
        %SubExpr
        left; %Expr*
        right; %Expr*
        
        %MultExpr
        left; %Expr*
        right; %Expr*
        
        %DivExpr
        left; %Expr*
        right; %Expr*
        
        %ModExpr
        left; %Expr*
        right; %Expr*
        
        %Guard
        equal; %bool
        greater; %bool
        strict; %bool
        left; %Expr*
        right; %Expr*
       
    end
    
    methods
    
        %Guard
        Guard::Guard (bool gre, bool str,Expr* l,Expr* r) {
            greater = gre;
            strict = str;
            equal = false;
            left = l;
            right = r;
        }

        Guard::Guard (Expr* l, Expr* r) {
            greater = false;
            strict =  false;
            left  = l;
            right = r;
        }

        void Guard::SwapLeftAndRight () {
            Expr* buf = left;
            left = right;
            right = buf;
        }

        void Guard::visit (Visitor *v) {
            v->caseGuard (this);
        }
        
        void Guard::toString (ostream& o) {
            left->toString (o);
            o<< "<<";
            right ->toString (o);
            o << endl;
        }
        
        bool isStrict() {return strict;}
        bool isGreater() {return greater;}
        bool isEqual() {return equal;}
        Expr* getLeft() {return left;}
        Expr* getRight() {return right;}
        void setLeft(Expr* newLeft) {left = newLeft;}
        void setRight(Expr* newRight) {right = newRight;}
        
        
        %ParanExpr
        ParanExpr::ParanExpr (Expr* e ) {
            inParan = e;
        }

        Expr* ParanExpr::getParantheses () {
            return inParan;
        }
        void ParanExpr::visit (Visitor* v) {}
        void ParanExpr::toString (ostream& o){
            o<< "(";
            inParan->toString (o);
            o<< string (")");
        }
        
        %NegExpr
        NegExpr::NegExpr (Expr* e) {
            negated = e;
        }
        
        Expr* NegExpr::getNegate () {
            return negated;
        }
        void NegExpr::visit (Visitor* v) {}
        void NegExpr::toString (ostream& o){
            o<< "-";
            negated->toString (o);
        }

        %PlusExpr
        PlusExpr::PlusExpr (Expr* l, Expr* r ) {
            left = l;
            right = r;
        }

        
        Expr* PlusExpr::getLeft () {return left;}
        Expr* PlusExpr::getRight () {return right;}
        void PlusExpr::visit (Visitor* v) {
            v->casePlusExpr (this);
        }
        void PlusExpr::toString (ostream& o){
            left->toString (o);
            o << "+";
            right->toString (o);
        }
        
        %SubExpr
        SubExpr::SubExpr (Expr* l, Expr* r ) {
            left = l;
            right = r;
        }
        Expr* SubExpr::getLeft () {return left;}
        Expr* SubExpr::getRight () {return right;}
        void SubExpr::visit (Visitor* v) {
            v->caseSubExpr (this);
        }
        void SubExpr::toString (ostream& o){
            left->toString (o);
            o << "-";
            right->toString (o);
        }
        
        %MultExpr
        MultExpr::MultExpr (Expr* l, Expr* r ) {
            left = l;
            right = r;
        }
        Expr* MultExpr::getLeft () {return left;}
        Expr* MultExpr::getRight () {return right;}
        void MultExpr::visit (Visitor* v) {
            v->caseMultExpr (this);
        }
        void MultExpr::toString (ostream& o){
            left->toString (o);
            o << "*";
            right->toString (o);
        }
        
        %DivExpr
        DivExpr::DivExpr (Expr* l, Expr* r ) {
            left = l;
            right = r;
        }
        Expr* DivExpr::getLeft () {return left;}
        Expr* DivExpr::getRight () {return right;}
        void DivExpr::visit (Visitor* v) {
            v->caseDivExpr (this);
        }
        void DivExpr::toString (ostream& o){
            left->toString (o);
            o << "/";
            right->toString (o);
        }
        
        %ModExpr
        ModExpr::ModExpr (Expr* l, Expr* r ) {
            left = l;
            right = r;
        }     
        Expr* ModExpr::getLeft () {return left;}
        Expr* ModExpr::getRight () {return right;}
        void ModExpr::visit (Visitor* v) {
            v->caseModExpr (this);
        }
        void ModExpr::toString (ostream& o){
            left->toString (o);
            o << "%";
            right->toString (o);
        }
        
        %IdentExpr
        IdentExpr::IdentExpr (string* id) {
            identifier = id;
        }
        string IdentExpr::getIdentifier () {
            return string (*identifier);
        }
        void IdentExpr::toString (ostream& o){

            o<< getIdentifier ();
        }
        void IdentExpr::visit (Visitor* v) {
            v->caseIdentExpr (this);
        }

        %ValExpr
        ValExpr::ValExpr (int val) {
            value = val;
        }
        void ValExpr::toString (ostream& o){
            o << value;
        }
        void ValExpr::visit (Visitor* v) {
            v->caseValExpr (this);
        }
        int ValExpr::getValue () {return value;}
    end
    
end

