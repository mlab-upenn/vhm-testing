function [ output_args ] = sym2conMainFunction(argc, argv)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%{
#include <sstream>
#include <string>
#include <iostream>


#include <dlfcn.h>
#include <unistd.h>
#include "solver/interface.hpp"
#include "solver/interfaceStat.hpp"

#include "symbTrace/lta.hpp"
#include "symbTrace/Location.hpp"
#include "symbTrace/Edge.hpp"
#include "symbTrace/DCConstraint.hpp"
#include "xmlloader/XMLLoader.hpp"

#include "main/Options.hpp"



#include <libxml/parser.h>
#include <libxml/xmlsave.h>
#define standardSolver "point"


void* handle;

solve_func solve_plug;

xmlDocPtr doc;
%}


    if argc == 1
        disp('No Arguments specified. Use -h to obtain a list of options');       
    else
        options = loadOptions(argc,argv);
        ready = loadRoutine(options);
        l = createLTA(options); %Lta
        disp(['Trace loaded contains',l.getNumberOfLocations(),' states.']);
        res; %Result
        
        if ready && l ~= 0
            res = solve_plug(l,options,cin,cout); %?
           % cout.flush();
            if res.hasResult()
                if options.saveRes
                    saveRes(l,res,options);
                end
                if ~options.quiet
                    if ~options.floating
                        if options.entry
                            res.outputAlternateEntry(cout);
                        else
                            res.outputAlternateDelay(cout);
                        end
                    else
                        if options.entry
                            res.outputDoubleEntry(cout);
                        else
                            res.outputDoubleDelay(cout);
                        end
                    end
                    
                    if options.time
                        res.outputTiming(cout);
                    end
                end
                
                if l~=0
                    %delete l;
                end
                %delete options;
                if doc~=0
                    xmlFreeDoc(doc); %remove xml memory
                end
                unloadRoutine();
                %return 0;
            end
            
            %delete res;
            
        end
        
    end

    
    function getTrans(theMap, cur2)
        cur = cur2.getChildNodes;
      %  cur = cur2.xmlChildrenNode; %xmlNodePtr
        while cur ~=0
            theChild = childNodes.item(count-1);
            childName = char(theChild.getNodeName);
            if ~strcmp(childName,'transition')  %if ~xmlStrcmp(cur.name, 'transition') %(!xmlStrcmp (cur->name, (const xmlChar*)"transition"))
                from = cur.getAttribute('from');
                %from = xmlGetProp(cur,'from'); %xmlChar   xmlGetProp (cur,(const xmlChar*) "from");
                    if ~isempty(from)
                    %   string strFrom((const char*)from);
                        strFrom = from;
                        theMap(strFrom) = cur;
                    end
            else 
                getTrans(theMap,cur);
            end
            cur = cur.next;
        end
    end
        
        function saveRes(lta,res,options)
            if doc ~=0
                %map<string,xmlNodePtr> theMap;
                getTrans(theMap,xmlDocGetRootElement(doc));
                iter = lta.getIterator(); %LTA::LtaIterator* 
                %ostringstream ostream;
                if ~options.floating
                    res.outputAlternateSimp(ostream);
                else
                    res.outputDoubleSimp(ostream);
                end
                str = ostream.str();%string
                istr(str); %istringstream 
                if (iter.hasSomething())
                    bool = true;
                    while iter.move() || bool
                        buf; %string 
                     %   istr >> buf;
                        if (iter.getEdge() ~= 0)
                            xmlNewProp(theMap(iter.getEdge().getId()),'delay',buf.c_str());
                        end
                        bool = false;       
                    end
                end
            
            else
                disp('Doc is not set');
            end

            ctxt = xmlSaveToFilename(options.saveResTo.c_str(),NULL,1); %xmlSaveCtxtPtr 
            xmlSaveDoc(ctxt,doc);
            xmlSaveClose(ctxt);
            %xmlFree(ctxt); 
        end
        
        function lta = createLTA(o)
            loader(o.zeroRep); %XMLLoader,  %////after loadOption zeroRep = "sys.t(0)";
            lta = loader.generateLTA(o.modelpath,doc,o.clockIndex);
            disp('LTA created');
        end
        
        function unloadRoutine()
            if handle ~=0
                dlclose(handle);
                %dlclose() is used to inform the system that the object referenced by a handle returned from a previous dlopen() invocation is no longer needed by the application.

            end
        end
        
        function bool = loadRoutine(options)
            if strcmp(options.solver,'entry')
                solve_plug = solvePoint;
                bool = true;
                return
            elseif strcmp(options.solver,'back')
                solve_plug = solveSmall;
                bool = true;
                return
            elseif strcmp(options.solver,'live')
                solve_plug = solveLive;
                bool = true;
                return
            elseif strcmp(options.solver,'dummy')
                bool = false;
                return
            else
                %no internal matches. We therefore guess it must be an external one...
                fileToOpen = [options.solverPath,'/',options.solver,'.so']; %string
                handle = dlopen(fileToOpen.c_str(),RTLD_LAZY);
                
                if handle~=0
                    solve_plug = (solve_func) dlsym(handle,'solve'); %?
                    bool = true;
                    return
                else
                    solve_plug = solvePoint; %?
                    bool = true;
                    return
                end
            end
            disp('solver not found');
            bool = false;
            return
        end
end

