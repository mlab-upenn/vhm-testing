function [options] = loadOptions(argc, argv)
%loadOptions Summary of this function goes here
%   Detailed explanation goes here
    Options options = new Options;
        options.zeroRep = 'sys.t(0)';
        options.epsilon = mpz_class ('10');
        options.floating = false;
        options.fast = false;
        options.globalC = 'sys.#tau';
        options.quiet = false;
        options.solver = 'bigZone';
        while (getopt(argc,argv,'g:s:z:l:e:o:thdfnq')~=-1)
            i = getopt(argc,argv,'g:s:z:l:e:o:thdfnq');
            switch i 
            	case 'q'
                    options.quiet = true;
                case 'g'
                    options.globalC = optarg; % charPtrToString (optarg);
                case 's'
                    options.solver = optarg; % charPtrToString (optarg);
                case 'l'
                    options.solverPath = optarg; % charPtrToString (optarg);
                case 'o' %outputfile
                    options.saveResTo = optarg; % charPtrToString (optarg);
                    options.saveRes = true;
                case 't' %measure time
                    options.time = true;
                case 'f' %output floating points
                    options.floating = true;
                case 'n' %output entry times
                    options.entry = true;
                case 'e': %select epsilon
                    options.epsilon = optarg;  % mpz_class (optarg); %mpz_class is an overloader that allows for different typedefs to be added together
                    options.fast = true;
                case 'z'
                    options.zeroRep = optarg; % charPtrToString(optarg);
            end
        end
                                                
            argumentNumber = optind;
            if (argumentNumber <argc) 
                istringstream stream (argv[argumentNumber]);
                stream >> options -> modelpath;
                argumentNumber ++;
            end
                                                
            options.solveOptions = readSolveOptions(argv,argc,argumentNumber);
                                                
            return options;

            
                    %v is a char, argc is an int, argN is an int, stream.str is a
        %string
    function [str] = readSolveOptions(v,argc, argN) 
        ostringstream stream;
        while (argN < argc) 
            if (string(v[argN]) ~= '--') %appends at characters that aren't '--'
                stream << v[argN];
            end
            argN = argN + 1;
        end
        str = stream.str ();
    end
    % s is a string, h is a char
    function [s] = charPtrToString(h) 
        istringstream str (h);
        string s;
        str >> s;
        return s;
    end


     
end

