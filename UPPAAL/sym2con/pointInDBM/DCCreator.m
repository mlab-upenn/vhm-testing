function [dcCreator] = DCCreator(inputlta,zeroclock)
%UNTITLED11 inputlta is and LTA object. zeroclock is a string
%   Detailed explanation goes here
    lta = inputlta;
    zeroClockRepresentation = zeroclock;
    %Allocate space for last reset at data
    lastresetdata = (int*) calloc (lta.getNumberOfLocations() * lta.getNumberOfClocks(),sizeof(int));
    if (lastresetdata==0)
        cerr << "No memory obtained" << endl;
        cerr.flush ();
    end

    for (unsigned int i = 0; i < lta->getNumberOfClocks(); i++)
        clocknumbermap[(*(lta->getClockNames()))[i]] = i;
    end
    CreateLastResetAtTable();

    function CreateLastResetAtTable()
        LtaIterator *ltaIterator = lta.getIterator();
        const Edge* edge;
        unsigned int location, clocknr;
        int pos;
        vector<string> clocknames;

        for (clocknr = 0; clocknr < lta->getNumberOfClocks(); clocknr++)
            lastresetdata[clocknr] = 0;
        end

        unsigned int locs =  lta->getNumberOfLocations();
        unsigned int clocks = lta->getNumberOfClocks();
        for (location = 1; location < lta->getNumberOfLocations(); location++)
            edge = ltaIterator->getEdge();
            for (clocknr = 0; clocknr < lta->getNumberOfClocks(); clocknr++)   
                pos = edge->getReset().find("," + (*(lta->getClockNames()))[clocknr] + ",");
                if (pos == -1) 
                    lastresetdata[(location*clocks)+clocknr] = lastresetdata[((location-1)*clocks)+clocknr];
                else            
                    lastresetdata[location*clocks+clocknr] = location;
                end
            end
            ltaIterator->move();
        end
    end
end

