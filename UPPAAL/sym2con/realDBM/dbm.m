classdef dbm
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        zeroClock; %string 
        variablesOver; %set<string> 
        %map<string,map<string,Bound> > theDBM;
        theDBM; %vector<vector<Bound> > 
        keepClosed;%bool
        inconsistent;%bool
        numVars; %int
    end
    
    methods (Access = private)
        function obj = closeAfterUpdate(obj)
            if obj.keepClosed
                obj.doClose();
            end
        end
        
        function obj = doClose(obj)
            zeroB = Bound(0,false);
            for k = 1:obj.numVars
                for i =1:obj.numVars
                    for j = 1:obj.numVars
                        if i~=j
                            orig = obj.theDBM{i}{j};
                            sum = obj.theDBM{i}{k} + obj.theDBM{k}{j};
                            if sum < orig
                                obj.theDBM{i}{j} = sum;
                            end
                        end
                    end
                end
            end
            
        end
        
        function obj = zeroDiagonal(obj)
            b = Bound(0,false);
            for i=1:obj.numOfVars()
                obj.theDBM{i}{i} = b;
            end
        end
    end
    
    methods
        %{
        function obj = DBM()
            %DBM () {}
        end
        %}
  %DBM (string);
        function obj = DBM(varargin)
            if isa(varargin{1},'double')
                %theDBM (num, vector<Bound> (num)) 
                obj.numVars = varargin{1};
                obj.zeroDiagonal();
            else
                obj.numVars = size(varargin{1});
                obj.zeroDiagonal();
                for i = 1:length(varargin{1})
                    b = Bound(varargin{1}{i}.second,false);
                    b2 = Bound(-1*varargin{1}{i}.second,false);
                    obj.setConstraint(varargin{1}{i}.first,0,b);
                    obj.setConstraint(0,varargin{1}{i}.first,b2);
                end
                obj.doClose();
            end
            %DBM (int);
        end
        function obj = DBM(v)
            %theDBM (v.size(), vector<Bound> (v.size ()))
            obj.numVars = size(v);
            obj.zeroDiagonal();
            for i = 1:length(v)
                b = Bound(v{i}.second,false);
                b2 = Bound(-1*v{i}.second,false);
                obj.setConstraint(v{i}.first,0,b);
                obj.setConstraint(0,v{i}.first,b2);
            end
            obj.doClose();
            %DBM (VariableAssignment& );
        end
        
        function numVars = numOfVars(obj)
            numVars = obj.numVars;
            %int numOfVars() const;
        end
        
        function inconsistent = hasSolution(obj)
            if ~obj.keepClosed
                obj.doClose();
            end
            inconsistent = ~obj.inconsistent;
            %bool hasSolution();
        end
        %void setZero (string s);
        %string getZero ();
        
        %void addVariable (string name);
        
        function obj = constrain(obj,x,y,b)
            if b < obj.theDBM{x}{y}
                obj.setConstraint(x,y,b);
                for i = 1:obj.numVars
                    for j = 1:obj.numVars
                        buf = obj.theDBM{i}{x} + obj.theDBM{x}{j};
                        if buf < obj.theDBM{i}{j}
                            obj.theDBM{i}{j} = buf;
                        end
                        buf = obj.theDBM{i}{y} + obj.theDBM{y}{j};
                        if buf < obj.theDBM{i}{j}
                            obj.theDBM{i}{j} = buf;
                        end
                    end
                end
            end
            %void constrain (int, int, Bound );
        end
        
        function obj = setConstraint(obj,firstVar,secondVar,b)
            obj.theDBM{firstVar}{secondVar} = b;
            %void setConstraint (int, int, Bound );
        end
        
        function obj = setVar(obj,var,value)
            b1 = Bound(value,false);
            b2 = Bound(-1*value,false);
            for i = 1:obj.numVars
                oi = obj.getBound(0,i);
                obj.setConstraint(var,i,b1 + oi);
                io = obj.getBound(i,0);
                obj.setConstraint(i,var,b2+io);
            end
            %void setVar (int, mpq_class);        
        end
        
        function boolean = contained(obj,assignment)
            for xit=1:obj.numVars
                for yit=1:obj.numVars
                    value = assignment(xit) - assignment(yit);
                    if ~obj.theDBM{xit}{yit}.satisfied(value)
                        boolean = false;
                        return;
                    end
                end
            end
            boolean = false;
            return;
            %bool contained (VariableAssignment&);
        end
        
        function obj = output(obj,o,clocks)
            for i = 1:length(clocks)
                for j =1:length(clocks)
                    if obj.getBound(clocks{i}.second,clocks{j}.second).isUnbound()
                        %o << (*i).first << " -" << (*j).first << "<" << "inf" << endl;
                    else
                        % o << (*i).first << " -" << (*j).first<< ((theDBM[(*i).second][(*j).second].isStrict ()) ? ("< ") : ("<=") ) <<  (theDBM[(*i).second][(*j).second].getBound ()) << endl;
                    end
                end
            end
            %cout << endl << endl;
            %void output (ostream& out,map<string,int>);
        end
        
        function bound = getBound(obj,x,y)
            bound = obj.theDBM{x}{y};
            %Bound getBound (int, int) const;
        end
  %
        function obj = close(obj,keep)
            obj.keepClosed = true;
            obj.doClose();
            %void close (bool);
        end
  %We assume the other DBM is over the same variables
  %as we are
        function intersect(obj,other)
            newDBM = DBM(obj);
            for i=1:obj.numVars
                for j=1:obj.numVars
                    oth = other.getBound(i,j);
                    if oth < obj.theDBM{i}{j}
                        newDBM.constrain(i,j,oth);
                    end
                end
            end
            newDBM.close(true);
            
            %DBM intersect (DBM& );
        end
        
        function reset(obj,vars)
            newDBM = DBM(obj);
            for resetIt=1:length(vars)
                newDBM.setVar(resetIt,0);
            end
            %DBM reset (vector<int>&);
        end
        
        function newDBM = up(obj)
            newDBM = DBM(obj);
            for i = 1:obj.numVars
                newDBM.setConstraint(i,0,b);
            end
            %DBM up ();
        end
        
        function newDBM = down(obj)
            newDBM = DBM(obj);
            zero = Bound(0,false);
            for i =1:obj.numVars
                newDBM.setConstraint(0,i,zero);
                for j=1:obj.numVars
                    ji = obj.getBound(j,i);
                    oi = obj.getBound(0,i);
                    if (ji < oi)
                        newDBM.setConstraint(0,i,ji);
                    end
                end
            end
            %DBM down ();
        end
        
        function negReset(obj,vars)
            newDBM = DBM(obj);
            for f=1:length(vars)
                for i=1:obj.numVars
                    if i~=f
                        newDBM.setConstraint(f,i,b);
                        newDBM.setConstraint(i,f,obj.getBound(i,0));
                    end
                end
            end
            %DBM negReset (vector<int>&);
        end
        function bool = subset(obj,b)
            for i = 1:obj.numOfVars()
                for j = 1:obj.numOfVars()
                    if i~=j
                        his = b.getBound(i,j);
                        if obj.getBound(i,j) > his
                            bool = false;
                            return
                        end
                    end
                end
            end
            bool = true;
            return
            %bool subset (DBM& b);
        end
  
        function sol = findPoint(obj)
            boundVars;% = zero(1,size(obj.theDBM));
            sol;
            sol(1) = 0;
            boundVars = [boundVars 0];
            for unBoundIt = 1:obj.numVars
                upper = obj.getBound(unBoundIt,0);
                lower = obj.getBound(o,unBoundIt);
                for boundIt = 1:size(obj.theDBM)
                    buf = obj.getBound(unBoundIt,boundIt);
                    upBound = Bound(sol(unBoundIt),false) + buf;
                    if upBound < upper
                        upper = upBound;
                    end
                    buf = obj.getBound(boundIt,unBoundIt);
                    lowBound = Bound(-1*sol(boundIt),false) +buf;
                    if lowBound < lower
                        lower = lowBound;
                    end
                    
                    if ~lower.isStrict()
                        sol(unBoundIt) = -1*lower.getBound();
                    elseif upper.isUnbound()
                        sol(unBoundIt) = (0-lower.getBound() + 1);
                    else
                        sol(unBoundIt) = (upper.getBound() - lower.getBound())/2;
                    end
                    boundVars = [boundVars unBoundIt];
                end
            end
            %VariableAssignment findPoint ();
        end
        
        function sol = findMaxPoint(obj)
            boundVars; %size(obj.theDBM);
            sol; %VariableAssignment
            sol(1) = 0;
            boundVars = [boundVars 0];
            for unBoundIt=1:obj.numVars-1
               upper = obj.getBound(unBoundIt,0);
               lower = obj.getBound(0,unBoundIt);
               for boundIt = 1:size(obj.theDBM);
                    buf = obj.getBound(unBoundIt,boundIt);
                    upBound = Bound(sol(boundIt),false) + buf;
                    if upBound < upper
                        upper = upBound;
                    end
                    buf = obj.getBound(boundIt,unBoundIt);
                    lowBound = Bound(-1*sol(boundIt),false) + buf;
                    if lowBound < lower
                        lower = lowBound;
                    end
               end
               if ~upper.isStrict()
                sol(unBoundIt) = upper.getBound();
               elseif ~lower.isStrict()
                   sol(unBoundIt) = -1*lower.getBound();
               elseif upper.isUnbound()
                   sol(unBoundIt) = (0-lower.getBound() +1);
               else
                   sol(unBoundIt) = (upper.getBound() - lower.getBound())/2;
               end
               boundVars = [boundVars unBoundIt];
            end
            %VariableAssignment findMaxPoint ();
        end
        
        function bound = chooseMinVal(obj,up,low,eps)
            if ~low.isStrict()
                bound = 0-low.getBound();
                return
            elseif low.isUnbound() && up.isUnbound()
                bound = 0;
                return
            elseif up.isUnbound()
                bound = 0-low.getBound() + eps;
                return
            elseif (0-low.getBound() + eps < up.getBound())
                bound = 0-low.getBound() + eps;
                return
            else
                bound = (up.getBound() - low.getBound())/2;
                return
            end  
        end
        
        function sol = findPointMinClock(minClock,eps)
            boundVars;
            sol;
            sol(1) = 0;
            boundVars = [boundVars 0];
            
            up = obj.getBound(minClock,0);
            down = obj.getBound(0,minClock);
            
            sol(minClock) = obj.chooseMinVal(up,down,eps);
            boundVars =[boundVars minClock];
            for unBoundIt = 1:obj.numVars-1
                if unBoundIt ==minClock
                    continue;
                end
                upper = obj.getBound(unBoundIt,0);
                lower = obj.getBound(0,unBoundIt);

                for boundIt = 1:size(obj.theDBM)
                    buf =  obj.getBound(unBoundIt,boundIt);
                    upBound =Bound(sol(boundIt),false) + buf;
                    if upBound < upper
                        upper = upBound;
                    end
                    buf = obj.getBound(boundIt,unBoundIt);
                    lowBound = Bound(-1*sol(boundIt),false) + buf;
                    if lowBound < lower
                        lower = lowBound;
                    end
                end

    %We will (for now)  just choose a point right between upper and lower

                if ~lower.isStrict()
                    sol(unBoundIt) =  -1*lower.getBound();
                elseif lower.isUnbound () && upper.isUnbound()
                    sol(unBoundIt) = 0;
                elseif upper.isUnbound()
                    sol(unBoundIt) = (0-lower.getBound()+1);
                else 
                    sol(unBoundIt) = (upper.getBound() - lower.getBound())/2;
                end
                boundVars = [boundVars unBoundIt];
            end
            %VariableAssignment findPointMinClock (int , mpq_class );
        end         
    end
end

