classdef Options
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % THIS CODE IS INCOMPLETE
    properties
        %{
        struct  Options{
                bool time; //do time measuring
                bool floating; //output result as floats 
                bool entry; //output entry times to screen instead of delays
                string modelpath; //path to model
                bool saveRes; //
                string saveResTo; //file to save concrete trace to ;
                string solver; //name of chosen solver
                mpz_class epsilon; //The epsilon  
  
                string solverPath; //Path to find dynamic solvers
                string zeroRep ; //ZeroRepresentation
                bool externalSolver;
                bool quiet;
                bool fast;
                string globalC;

                string solveOptions; //Options for the sovlers 

                map<string,int> clockIndex;
                };
        %}
    end
    
    methods
        %TODO: make this more matlab-compatible
        function options = loadOptions(argc,argv)
            i;
            options.zeroRep = 'sys.t(0)';
            options.epsilon = '10';
            options.floating = false;
            options.fast = false;
            options.globalC = 'sys.#tau';
            options.quiet = false;
            options.solver = 'bigZone';
            i = getOpt(argc,argv,'g:s:z:l:e:o:thdfnq');
            while i ~=1
                switch i
                    case 'q'
                        options.quiet = true;
                    case 'g'
                        options.globalC = optarg;
                    case 's'
                        options.solver = optarg;
                    case 'l'
                        options.solverPath = optarg;
                    case 'o'
                        options.saveResTo = optarg;
                        options.saveRes = true;
                    case 't'
                        options.time = true;
                    case 'f'
                        options.floating = true;
                    case 'n'
                        options.entry = true;
                    case 'e'
                        options.epsilon = optarg;
                        options.fast = true;
                    case 'z'
                        options.zeroRep = optarg;
                end
                i = getOpt(argc,argv,'g:s:z:l:e:o:thdfnq');
            end
            
            argumentNumber = optind;
            if argumentNumber <argc
                options.modelpath; %?
                argumentNumber = argumentNumber + 1;
                
            end
            options.solveOptions = Options.readSolveOptions(argv,argc,argumentNumber);
            
            %Options* loadOptions (int argc, char** argv);
        end
    end
    
    methods (Static)
        function stream = readSolveOptions(v,argc,argN)
            stream;
            while argN < argc
                if ~strcmp([v(argN),v(argN+1)],'--')
                    stream = [stream, [v(argN),v(argN+1)]];
                end
                argN = argN + 1; 
            end
        end
        
        %function s = charPtrToString(h)
        %    
        %end
    end
    
end

