classdef DBM
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        bounds; %vector< vector<Bound > > 
    
    end
    
    methods (Access = private)
        %sets the lower bounds on all clocks to (0,<=)
        function obj = initLower(obj)
            zero = Bound(0,false);
            s = obj.numOfVars();
            for i=1:s
                obj.setConstraint(0,i,zero);
            end
            %void initLower ();
        end
        
        %Set the upper bounds on all clocks to (0,<=)
        function obj = initUpper(obj)
            zero = Bound(0,false);
            for i = 1:obj.numOfVars()
                obj.setConstraint(i,0,zero);
            end
            %void initUpper ();
        end
        
        %set all constraints to (0,<=) i.e. the init zone
        function obj = initAll(obj)
            zero = Bound(0,false);
            for i=1:obj.numOfVars()
                for j=1:obj.numOfVars()
                    obj.setConstraint(i,j,zero);
                end
            end
            %void initAll ();
        end
        %Zeros the diagonal
        function obj = setDiagonal(obj)
            zero = Bound(0,false);
            s = obj.numOfVars();
            for i=1:s
                obj.setConstraint(i,i,zero);
            end
            %void setDiagonal ();
        end
        %Reset one clock...Changes solution space
        function obj = reset_2(obj,x)
            obj.setVar(x,0);
            %void reset (int) ;
        end
        %Free one clock...Changes solution space
        function obj = free_2(obj,x)
            inf = Bound();
            for i=1:obj.numOfVars()
                if i~=x
                    obj.setConstraint(x,i,inf);
                    obj.setConstraint(i,x,obj.getBound(i,0));
                end
            end
            %void free (int);
        end
        %algorithm that that finds tighest constraints on clockToset based on the values from the variables in restricted
        function obj = findPointCore(obj,clockToSet,upper,lower,restricted,assigned)
            upper = obj.getBound(clockToSet,0);
            lower = obj.getBound(0,clockToSet);
            for i=1:size(restricted)
                upBuf = Bound(assigned(restricted(i)),false) + obj.getBound(clockToSet,restricted(i));
                lowBuf = Bound(-1*assigned(restricted(i)),false) + obj.getBound(restricted(i),clockToSet);
                
                if upBuf < upper
                    upper = upBuf;
                end
                if lowBuf < lower
                    lower = lowBuf;
                end
            end
            %void findPointCore (int clockToSet,Bound& upper, Bound&lower, vector<int>& restricted, VariableAssignment& assigned) const;
        end
        
    end
    
    methods
        function o = operator_shiftLeft(obj,o,dbm)
            for i =1:obj.numOfVars()
                for j=1:obj.numOfVars()
                    o = [o,num2str(i),'-',num2str(j),dbm(i,j)];
                end
            end
            %ostream& operator<< (ostream& o, const DBM& dbm);
        end
        
        %Create DBM with a specific number of clocks..including zero clock
        function obj = DBM(varargin)
            if isa(varargin{1},'double')
                %bounds(size,vector<Bound>(size))
                obj.setDiagonal();
                obj.initLower();
                %DBM (int size = 1);
            else 
                %bounds (v.size(), vector<Bound>(v.size()))
                obj.setDiagonal();
                s = size(varargin{1});
                for i=1:s
                    obj.setVar(i,varargin{1}(i));
                end
                %Create DBM with one variableAssignment in its solution space
                %DBM (VariableAssignment);
            end
        end
        
        %operator for notational convenience
        function bound = operator(obj,i,j)
            bound = obj.getBound(i,j);
            %Bound operator() (int,int) const;
        end
        
        function bound = getBound(obj,i,j)
            bound = obj.bounds{i,j};
            %Bound getBound (int ,int) const ;
        end
        %Close DBM using floyd warshall algorith
        function obj = close(obj)
            for i=1:size(obj.bounds)
                for j=1:size(obj.bounds)
                    for k=1:size(obj.bounds)
                        ij = obj.getBound(i,j);
                        ikPluskj = (obj.getBound(i,k)) + obj.getBound(k,j);
                        if ikPluskj < ij
                            obj.setConstraint(i,j,ikPluskj);
                        end
                    end
                end
            end
            %void close ();
        end
        
        %Find intersection between this DBM and the argument oth
        function obj = intersect(obj,oth)
            nDBM = DBM(obj.numOfVars());
            s = obj.numOfVars();
            for i=1:s
                for j=1:s
                    if obj.getBound(i,j) < oth.getBound(i,j)
                        nDBM.setConstraint(i,j,obj.getBound(i,j));
                    else
                        nDBM.setConstraint(i,j,oth.getBound(i,j));
                    end
                end
            end
            nDBM.close();
            
            %DBM intersect (const DBM&) const;
        end
        
        %Reset a set of clocks
        function nDBM = reset(obj,resets)
            nDBM = DBM(obj);
            for i=1:size(resets)
                nDBM.reset_2(resets(i));
            end
            %DBM reset (const vector<int>&) const; 
        end
        
        %free the clocks
        function nDBM = free(obj,frees)
            nDBM =DBM(obj);
            for i=1:size(frees)
                nDBM.free_2(frees(i));
            end
            %DBM free (const vector<int>&) const ;
        end
        
        %Classic DOwn operation
        function nDBM = down(obj)
            nDBM = DBM(obj);
            zeroBound = Bound(0,false);
            for i=1:obj.numOfVars()-1
                nDBM.setConstraint(0,i,zeroBound);
                for j=1:obj.numOfVars()-1
                    if obj.getBound(j,i) < obj.getBound(0,i)
                        nDBM.setConstraint(0,i,obj.getBound(j,i));
                    end
                end
                    
            end
            %DBM down () const;
        end
        
        %Classic up operation
        function nDBM = up(obj)
            inf = Bound();
            nDBM = DBM(obj);
            for i=1:obj.numOfVars()-1
                nDBM.setConstraint(i,0,inf);
            end
            nDBM.close();
                %DBM up ()const ;
        end
            
        %Constrain the DBM
        function obj = constrain(obj,x,y,toConstrain)
            if toConstrain < obj.getBound(x,y)
                obj.setConstraint(x,y,toConstrain);
                for i=1:obj.numOfVars()
                    for j=1:obj.numOfVars()
                        if (obj.getBound(i,x) + obj.getBound(x,j)) < obj.getBound(i,j)
                            obj.setConstraint(i,j,(obj.getBound(i,x) + obj.getBound(x,j)));
                        end
                        if (obj.getBound(i,y) + obj.getBound(y,j)) < obj.getBound(i,j)
                            obj.setConstraint(i,j,(obj.getBound(i,y) + obj.getBound(y,j)));
                        end
                    end
                end
            end
                %void constrain (int,int,Bound) ;
        end
            
        %Set the constraint...but do not preserve closed form 
        function obj = setConstraint(obj,x,y,constraint)
            obj.bounds{x,y} = constraint;
                %void setConstraint (int,int,Bound);
        end
        
        %constrain a variable to a specific value
        function obj = setVar(obj,x,val)
            pos = Bound(val,false);
            neg = Bound(-1*val,false);
            s = obj.numOfVars();
            for i=1:s
                obj.setConstraint(x,i,pos+obj.getBound(0,i));
                obj.setConstraint(i,x,obj.getBound(i,0)+neg);
            end
            %void setVar (int,mpq_class);
        end
            
            %Is this DBM a subset of the ohter
        function bool = subset(obj,oth)
            for i= 1:numOfVars()
                for j =1:numOfVars()
                    if obj.getBound(i,j) > oth.getBound(i,j)
                        bool = false;
                        return
                    end
                end
            end
            bool = true;
                %bool subset (DBM) const;
        end
            
        function bool = consistent(obj)
            neg = Bound(0,true);
            for i=1:obj.numOfVars()
                if obj.getBound(i,i) <= neg
                    bool = true;
                    return
                end
            end
            bool = false; 
                %bool consistent() const;
        end
            
        function s = numOfVars(obj)
            s = size(obj.bounds);
                %int numOfVars () const;
        end
        %Containment checker
        function bool = contained(obj,c)
            for i=1:obj.numOfVars()
                for j=1:obj.numOfVars()
                    if i~=0
                        val = c(i) - c(j);
                        val2 = c(j)-c(i);
                        if ~obj.getBound(i,j).satisfied(val) || ~obj.getBound(j,i).satisfied(val2)
                            bool = false;
                            return
                        end
                    end
                end
            end
            bool = true;
            return
                %bool contained (const VariableAssignment& val) const;
        end
        
        function assigns = findPoint(obj,epsilon)
            assigns;
            restricted;
            upper = Bound();
            lower = Bound();
            assigns(1) = 0;
            restricted = [restricted 0];
            for i=1:obj.numOfVars()-1
                obj.findPointCore(i,upper,lower,restricted,assigns);
                assigns(i) = Bound.chooseValueBetween(upper,lower,epsilon);
                restricted = [restricted i];
            end
                %VariableAssignment findPoint (mpq_class epsilon = mpq_class (0.1)) const;
        end
            
        function assigns = findPointMax(obj,epsilon)
            assigns;
            restricted;
            upper = Bound();
            lower = Bound();
            for i=1:obj.numOfVars()
                obj.findPointCore(i,upper,lower,restricted,assigns);
                assigns(i) = Bound.chooseValueMax(upper,lower,epsilon);
                restricted = [restricted i];
            end
                %VariableAssignment findPointMax (mpq_class epsilon = mpq_class (0.1)) const;
        end
            
        function assigns = findPointMin(obj,epsilon)
            assigns;
            restricted;
            upper = Bound();
            lower = Bound();
                
            for i=1:obj.numOfVars()
                obj.findPointCore(i,upper,lower,restricted,assigns);
                assigns(i) = Bound.chooseValueMin(upper,lower,epsilon);
                restricted = [restricted i];
            end
                %VariableAssignment findPointMin (mpq_class epsilon = mpq_class (0.1)) const;
        end
            
        function assigns = findPointMinClock(obj,clock,epsilon)
            assigns;
            restricted;
            upper = Bound();
            lower = Bound();
            upper = obj.getBound(clock,0);
            lower = obj.getBound(0,clock);
            assigns(clock) = Bound.chooseValueMin(upper,lower,epsilon);
            restricted = [restricted clock];
            for i=1:obj.numOfVars()
                if i == clock
                    continue;
                end
                obj.findPointCore(i,upper,lower,restricted,assigns);
                    
                assigns(i) = Bound.chooseValueBetween(upper,lower,epsilon);
                restricted = [restricted i];
            end
                %VariableAssignment findPointMinClock (int, mpq_class epsilon = mpq_class(0.1)) const;
        end
           
    end
    
    methods(Static)
        %Create initial zone DBM with i clocks
        function dbm = initZone(i)
            dbm = DBM(i);
            dbm.initAll();
            %static DBM initZone (int i);
        end
    end
    
end

