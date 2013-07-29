classdef Edge
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        reset; %string
        constraints; %list<dc_t*>*
        resetVector; %vector<int> 
        dbm; %DBM
        nextLocation; %Location* 
        id; %string 
        isLoop; %bool 
        prev; %Location* 
    end
    properties
    end
    
    methods
        function obj = Edge(varargin) %r,g,n,i,cindex) %r,g,i,cindex)
            if nargin == 5
                obj.nextLocation = varargin{3};
                obj.constraints = varargin{2};
                obj.id = varargin{4};
                obj.createDBM(obj.constraints,obj.dbm,obj,varargin{5})
                obj.isLoop = false;
                obj.resetVector = convert(varargin{1},varargin{5});
            elseif nargin ==4
                obj.constraints = varargin{2};
                obj.id = varargin{3};
                obj.createDBM(obj.constraints,obj.dbm,varargin{4});
                obj.isLoop = false;
                obj.resetVector = convert(varargin{1},varargin{4});
            % Edge (const string&,  list<dc_t*>* ,string, map<string,int>);
            %{
           constraints = g;
            id = i;
            createDBM (constraints,dbm, cindex);
            isLoop = false;
            resetVector = convert(r, cindex);
           %}
            end
          %{
            Edge (const string&, list<dc_t*>* , Location*,string, map<string,int>);
          
            {
                nextLocation = n;
                constraints = g;
                id = i;
                createDBM (constraints,dbm, cindex);
                isLoop = false;
                resetVector = convert(r, cindex);
            }
        %}
        end
       
        function obj = createDBM(obj, dc_t_list,dbm,cindex)
            dbm = DBM(size(cindex));
            for it =1:length(dc_t_list)
                comp = dc_t_list{it}.op;
                x = cindex(dc_t_list{it}.clockX);
                y = cindex(dc_t_list{it}.clockY);
                bound = dc_t_list{it}.bound;
                if strcmp(comp,'lt')
                    dbm.constrain(x,y,createBound(bound,true));
                elseif strcmp(comp,'leq')
                    dbm.constrain (x,y,createBound(bound,false));
                else 
                    dbm.constrain(x,y,createBound(bound,false));
                    dbm.constrain(y,x,createBound(-1*bound,false));
                end
            end
            dbm.close();
            obj.dbm = dbm;
            %{
            void createDBM (list<dc_t*>*g, DBM& dbm,map<string,int> cindex) {
            list<dc_t*>::iterator it;
            dbm = DBM ( cindex.size ());
            for (it = g->begin (); it!=g->end ();it++) {
                DCOperator comp = (*it)->getOp ();
                int x = cindex[(*it)->getX ()];
                int y = cindex[(*it)->getY ()];
                int bound = (*it)->getBound ();
                if (comp == lt)
                    dbm.constrain (x,y,Bound (mpq_class (bound),true));
                else if (comp == leq)
                    dbm.constrain (x,y,Bound (mpq_class (bound),false));
                else {
                    dbm.constrain (x,y,Bound (mpq_class (bound),false));
                    dbm.constrain (y,x,Bound (mpq_class (-1*bound),false));
                        }

                    }

                dbm.close ();
                }
            %}
        end
        function buf = convert(s,index)
            %const string& s, map<string,int> index, index = containers.Map
            s = strsplit(s,',');
            for i =1:length(s);
                buffer = s{i};
                if strcmp(buffer, '')
                    buf = [buff index(buffer)];
                end
            end

            %{
            vector<int> convert (const string& s, map<string,int> index)
            {
                vector<int> buf;
                istringstream str (s);
                string buffer;
                while (std::getline(str, buffer, ','))
                {
                    //cout << "Converting: " << "," << buffer << "," <<endl;
                    if (buffer!= "")
                    {
                        buf.push_back (index[buffer]);
                    }
            }
                return buf;
            }
            %}
        end
        
        
        %{
        function delEdge()
            ~Edge ();
        end
        %}
        function obj = setLoop(obj)
            obj.isLoop = true;
        end
        function obj = setNextLocation(obj,n)
            obj.nextLocation = n;
           % void setNextLocation (Location*);
        end
        function nextLocation = getNextLocation(obj)
            nextLocation = obj.nextLocation;
            %Location* getNextLocation ();
        end
        %{
        function getNextLocation()  
            const Location* getNextLocation () const;
        end
        %}
        function reset = getReset(obj)
            reset = obj.reset;
            %const string& getReset () const ;
        end
        function resetVector = getResetVector(obj)
            resetVector = obj.resetVector;
            %const vector<int>& getResetVector() const;
        end
        function guard = getGuard(obj)
            guard = obj.constraints;
          %  const list<dc_t*>* getGuard () const ;
        end
        function str = getGuardText(obj)
            str = '';
            for i = 1:length(obj.constraints)
                str = [str, obj.constraints{i},'&&'];
            end
            %string getGuardText () const;
            %{
            list<dc_t*>::const_iterator it;
            ostringstream str;
            for (it = constraints->begin ();it!=constraints->end();it++) {
                 str << *(*it) << "&&";
            }
              return str.str ();
            %}
        end
        function id = getId(obj)
            id = obj.id;
            %string getId () const ;
        end
        function dbm = getDBM(obj)
            dbm = obj.dbm;
        end
        
        function obj = setPrev(obj,l)
            obj.prev = l;
            %void setPrev(Location*);
        end
        function prev = getPrev(obj)
            prev = obj.prev;
            %Location* getPrev ();
        end
        function loop = isLoopTrans(obj)
            loop = obj.isLoop;
           % bool isLoopTrans ();
        end
    end
    
end

