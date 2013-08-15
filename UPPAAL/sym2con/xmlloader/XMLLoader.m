classdef XMLLoader
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    %TODO: This code is incomplete
    
    properties
    end
    
    methods
       % int evaluate (map<string, string>& localVariables, map<string, string>& systemVariables, map<string,int>& varState, string &s);
        
       %Function used to modify constraints expressed as arithmetic expressions to
        %x-y [<|<=] n
        
        %dc_t* modifyConstraint (map<string, string>& localClocks, map<string, string>& systemClocks, map<string, string>& localVariables, map<string, string>& systemVariables, map<string,int>& varState, string &s,string& zero);
        
        function s = removeInnerArith(s,localVarsNameToId, globalVarsNameToId,state)
            firstPos = strfind(s,'[');
            firstPos = firstPos(1);
            lastPos = strfind(s,']');
            lastPos = lastPos(1);
            value;
            
            if ~isempty(firstpos) && ~isempty(lastPos)
                sh = s(firstPos+1,length(s)-firstPos-2);
                value = evaluate(localVarsNameToId,globalVarsNameToId,state,sh);
                str;
                %{
                    stringstream str;
                    str << value;
                    stringstream createOut;
                    createOut << s.substr(0,firstPos+1) << str.str().c_str () << s.substr(lastPos);
     
                    return createOut.str();;
                %}
                
                %string sh = s.substr (firstPos+1,s.size ()-(firstPos)-2);
            end
            
            %s
        end
        
        function getResets(varS,localClocksNameToId,localVars,update)
            
            %{
            ostringstream theStream;
            boost::regex spaces ("\\s*");
            string updateNoSpace = boost::regex_replace (update,spaces,"");
            string varNames ("[a-zA-Z][+\\-\\*\\\\%\\[\\]\\(\\)\\_\\.a-zA-Z0-9]*");
            string number ("0");
            boost::regex r (varNames+":="+number);
            boost::sregex_token_iterator it (updateNoSpace.begin (),updateNoSpace.end (),r);
            boost::sregex_token_iterator end;
            while (it!=end)
            {
                ostringstream buf;
                buf << (*it);
        
                string var = boost::regex_replace (buf.str(),boost::regex(":=0"),"");
                string id;
                var = removeInnerArith (var,  localVars, systemVariablesNameToId, varS);
                if ((id= localClocksNameToId[var]) != "")
                    theStream << "," << id <<",";
                else if ((id=systemClocksNameToId[var]) != "")
                    theStream << "," << id <<",";
                it++;
            }
            return theStream.str ();

            %}
        end
        
        function CreateConstraints(str,procInfo,varState)
            %theList = new list<dc_t>();
            %istringstream instream(str);
            %string buf;
            %{
            while (instream >> buf)
            {
                if (buf != "1")  // Hvad gør det her?
                {
                    string b = removeInnerArith (buf,procInfo->localVariablesNameToId, systemVariablesNameToId,varState);
                    dc_t* buffer = modifyConstraint (procInfo->localClocksNameToId, systemClocksNameToId, procInfo->localVariablesNameToId, systemVariablesNameToId, varState, b, zero);
	  
                    if (buffer!=0)
                    {
                        if (buffer->getOp () == eq)
                        {
                            dc_t* buf1 = new dc_t (buffer->getY (),buffer->getX(),leq,buffer->getBound ()*-1);
                            dc_t* buf2 = new dc_t (buffer->getX (),buffer->getY(),leq,buffer->getBound ());
                            delete buffer;
                            theList->push_front (buf1);
                            theList->push_front (buf2);
                        }
                        else
                            theList->push_front (buffer);
                    }
                }
            }
            return theList;
            %}
        end
        
        function parseDocument(documentName,doc2)
            %{
            (*doc2) = doc = xmlParseFile(documentName.c_str ());
            if (doc==0)
                return false;
            else
            {
                bool res =  parseTrace (xmlDocGetRootElement (doc));
                //xmlFreeDoc (doc);
                return res;
            }

            %}
        end
        
    end
    
end

