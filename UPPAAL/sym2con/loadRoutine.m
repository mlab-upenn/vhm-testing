function [bool ] = loadRoutine(options)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if strcmp(options.solver,'entry')
        %solve_plug is a solve_func
        solve_plug =solvePoint;
        bool = true;
        return
    elseif strcmp(options.solver,'back') 
        solve_plug =  solveSmall;
        bool = true;
        return
    elseif strcmp(options.solver,'live')
        solve_plug = solveLive;
        bool = true;
        return
    elseif strcmp(options.solver,'dummy')
        bool =false;
        return
    else 
        %no internal matches. We therefore guess it must be an external one...
        fileToOpen = [options.solverPath,'/',options.solver,'.so'];
        handle = dlopen (fileToOpen.c_str (),RTLD_LAZY);
        if (handle~=0) 
            solve_plug = (solve_func) dlsym (handle,'solve');
            return true;
        else 
            solve_plug =solvePoint;
            return true;
        end
    end
        cerr << "Solver not found" << endl;
    
    bool = false;
    return
    
                                      

end

