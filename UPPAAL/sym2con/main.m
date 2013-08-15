classdef main
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function getTrans(theMap, cur2)
            while cur ~=0
                if ~xmlStrcmp(cur.name, 'transition')
                    from = xmlGetProp(cur,'from')
                    if from ~= 0
                        strFrom(from);
                        theMap(strFrom) = cur;
                    end
                else 
                    getTrans(theMap, cur);
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
    
end

