function [lta] = createLTA(options) %takes in option struct, and then makes an LTA struct
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    XMLLoader loader(options.zeroRep); %after loadOption zeroRep = "sys.t(0)";
    %{
        %zero is a string
        XMLLoader (string z) : zero(z) {
        nextClockId = 1;
        }
    %}
    lta = generateLTA(loader,options.modelpath,&doc,options.clockIndex);
    %{
    LTA::Lta* XMLLoader::generateLTA (string& path,xmlDocPtr* ptr,map<string, int>& clockIndex)
    {
        if (!parseDocument (path,ptr))
        {
            return 0;
        }
    %Now we have everything set u.
    %We can now generate the LTA from these information::
    clockIndex = clocksIndex; 
    createDBMS ();
    return createLTA ();
    }
    %}
    cout << "LTA created" << endl;
    lta;
    
    
    function [lta] = generateLTA(loader, modelpath, doc, clockIndex)
        if ~parseDocument(path,ptr)
            lta = 0;
            return
        end
    %Now we have everything set u.
    %We can now generate the LTA from these information::
    clockIndex = clocksIndex; 
    createDBMS ();
    createLTA ();
    return
    end
    
    
    
    function [lta] = createLTA(xmlLoader) 
        map<string, Node*> nodesAdded;
        NodeKeeper xmlNode = nodes[initNode];
        Node* ltaNode = createNode (xmlNode);
        LTA::Lta* lta = new LTA::Lta (ltaNode,new vector<string> (clocks));
   
        TransitionKeeper* xmlTransition = transitions[initNode];
        %{
            struct TransitionKeeper
            {
                string from;
                string to;
                string edges;
            };
        %}
        
        Transition* ltaTransition;

        string nextNodeId;
        while xmlTransition ~= 0
            ltaTransition = createTransition(*xmlTransition);
            nextNodeId = xmlTransition->to;
            xmlNode = nodes[nextNodeId];
        
            ltaNode = nodesAdded[nextNodeId];
            if  ltaNode~=0 && transitions[nextNodeId]~=0 
                ltaNode.setLoop ();
                ltaTransition ->setLoop ();
                lta.add (ltaTransition,ltaNode);
                break;
            else 
                ltaNode= createNode (xmlNode);
                if (ltaNode.isLoopLoc()) 
                    ltaTransition ->setLoop ();
                end
                nodesAdded(nextNodeId) = ltaNode;
                lta.add (ltaTransition,ltaNode);
                xmlTransition = transitions(nextNodeId);
            end
        end
    end

    function [transition] = createTransition(transkeeper)
        VarState state = (variableStates[nodes[transKeeper.from].variableVector]);
        list<dc_t*>* constraints = new list<dc_t*> ();

        istringstream edgStr (transKeeper.edges);
        string edge, 
        resetT='';
        while (edgStr >> edge)
            guard = edges(edge).guard; %string
            ProcessInfoKeeper* procInfo = edges(edge).parentProcess;
            %boost::regex spaces ('\\s*');
            %guard = boost::regex_replace(guard,spaces,''); %remove all spaces
            guard = strrep(guard,' ','');
            %boost::regex reg ('&&');
            %guard = boost::regex_replace(guard,reg,' '); %replace && with spaces
            guard = strrep(guard,'&&',' ');
            %add to the end of constraints (constraints is a list)
            %CreateConstraints (guard, procInfo, state)
            constraints.splice(constraints.end(), *(CreateConstraints (guard, procInfo, state)));

            resetT = resetT + getResets(state,procInfo.localClocksNameToId,procInfo.localVariablesNameToId,edges(edge).update);
            end
   
        transition = Transition(resetT,constraints,transKeeper.from,clocksIndex);
        return
    end

    %       list<dc_t*>* XMLLoader::CreateConstraints (string& str, ProcessInfoKeeper* procInfo, VarState varState)
    function [theList] = CreateConstraints(str, procInfo,varState)
    %list<dc_t*>* theList = new list<dc_t*> ();
    theList = cell(5);
    %{
    
    class dc_t
    {   
        public:
            //dc_t(string&);
            dc_t(string,string,DCOperator,int);
            dc_t(const dc_t*);
            void setOp(DCOperator);
            DCOperator getOp() const;
            void replaceX(string);
            string getX() const;
            void replaceY(string);
            string getY() const;
            int getBound() const;
            friend ostream& operator<< (ostream& out, const dc_t&);

        private:
            DCOperator op;
            string origX;
            string origY;
            string clockX;
            string clockY;
            int bound;
        };
    %}
    istringstream instream (str);
    string buf;
    %give buff one character at a time from string.`
    while (instream >> buf)
        if (buf ~= '1')  % Hvad gør det her?
            string b = removeInnerArith (buf,procInfo->localVariablesNameToId, systemVariablesNameToId,varState);
            dc_t* buffer = modifyConstraint (procInfo->localClocksNameToId, systemClocksNameToId, procInfo->localVariablesNameToId, systemVariablesNameToId, varState, b, zero);
	  
            if (buffer~=0)
                if (buffer->getOp () == eq)
                    dc_t* buf1 = new dc_t (buffer->getY (),buffer->getX(),leq,buffer->getBound ()*-1);
                    dc_t* buf2 = new dc_t (buffer->getX (),buffer->getY(),leq,buffer->getBound ());
                    delete buffer;
                    theList->push_front (buf1);
                    theList->push_front (buf2);
                else
                    theList->push_front (buffer);
                end
            end
        end
    end
    theList;
    return
    end
    
    function createDBMS() 
        list<DBMKeeper>::iterator iter;
 
        for iter = dbmKeeps.begin (); iter ~= dbmKeeps.end ();iter++ 
            DBM d (clocks.size ());
 
            vector<BoundKeeper>::iterator bIt;
            for (bIt =(*iter).bounds.begin (); bIt ~= (*iter).bounds.end ();bIt++) 
                d.setConstraint (clocksIndex[bIt.first],clocksIndex[bIt.second],bIt.bound);
                stringstream stream;
                stream << bIt->bound.getBound ();
                int i;
                stream >> i;
     
            end
    %d.close(true);
        dbms[(*iter).id] = d;
        end
    end
    
%{
    LTA::Lta* XMLLoader::createLTA ()
{
  map<string, Node*> nodesAdded;
    NodeKeeper xmlNode = nodes[initNode];
    Node* ltaNode = createNode (xmlNode);
    LTA::Lta* lta = new LTA::Lta (ltaNode,new vector<string> (clocks));
   
    TransitionKeeper* xmlTransition = transitions[initNode];
    Transition* ltaTransition;

    string nextNodeId;
    while(xmlTransition != 0)
    {
        ltaTransition = createTransition(*xmlTransition);
        nextNodeId = xmlTransition->to;
        xmlNode = nodes[nextNodeId];
        
	ltaNode = nodesAdded[nextNodeId];
	if (ltaNode!=0 && transitions[nextNodeId]!=0) {
	  ltaNode->setLoop ();
	  ltaTransition ->setLoop ();
	  lta->add (ltaTransition,ltaNode);
	  break;
	}
	else {
	  ltaNode= createNode (xmlNode);
	  if (ltaNode->isLoopLoc()) 
	    ltaTransition ->setLoop ();
	  nodesAdded[nextNodeId] = ltaNode;
	  lta->add (ltaTransition,ltaNode);
	  xmlTransition = transitions[nextNodeId];
	}
    }
    return lta;
}
    %}
    

    %{
    void XMLLoader::createDBMS () {
  
  list<DBMKeeper>::iterator iter;
 
  for (iter = dbmKeeps.begin (); iter!=dbmKeeps.end ();iter++) {
    DBM d (clocks.size ());
 
    vector<BoundKeeper>::iterator bIt;
    for (bIt =(*iter).bounds.begin (); bIt != (*iter).bounds.end ();bIt++) {
      d.setConstraint (clocksIndex[bIt->first],clocksIndex[bIt->second],bIt->bound);
      stringstream stream;
      stream << bIt->bound.getBound ();
      int i;
      stream >> i;
     
    }
    //d.close(true);
    dbms[(*iter).id] = d;
  }
}
    %}
    
end

