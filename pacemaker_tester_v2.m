load medtronic_params
pace_param.mode_switch = 'on';

%% Script Variables
    %Parameters    
    tolerance_atrial = 100; %Acceptable tolerance (in ms) for detecting atrial output signals
    tolerance_ventrical = 100; %Acceptable tolerance (in ms) for detecting ventrical output signals.
    greatestTolerance = max([tolerance_percent_atrial, tolerance_percent_ventrical]);
    pace_inter = 1;
    %Global Variables
    next_Line = 0; %variable to determine which line in the file is being processed
    t = 0;
    offset = 0; %variable to store any necessary offsets
    a_ifPaced = 0; %boolean to determine if pacemaker paced atrium
    v_ifPaced = 0; %boolean to determine if pacemaker paced ventricle
    a_ifSensed = 0; %boolean to determine if pacemaker sensed atrium signal
    v_ifSensed = 0; %boolean to determine if pacemaker sensed ventricle signal
%% File Variables
   %Constants
        ATRIAL_INPUT = 1;
        VENTRICAL_INPUT = 2;
        ATRIAL_OUTPUT = 3;
        VENTRICAL_OUTPUT = 4;
   %Global Variables
        nextTime = 0; %the next time an event occurs.
        nextNextTime = 0; % the next time for the event after the expected event
        nextEvent = 0; %The next type of event, from 1-4
        nextNextEvent = 0; %The next next type of event, from 1-4
%% Main Script
%
%Insert code here to preallocate file data
    load sample_File
    nextLine = next_Line + 1;
    nextTime = sample_File(nextLine,1);
    nextEvent = sample_File(nextLine,2);

    nextNextTime = sample_File(nextLine+1,1);
    nextNextEvent = sample_File(nextLine+1,2);
while 1
    switch nextEvent
% Atrial Input        
        case ATRIAL_INPUT
            if t == (nextTime + offset)
                pace_param = pacemaker_new(pace_param,1,0, pace_inter);
                disp('sent atrial signal');
                t = t+1;
                nextLine = nextLine + 1;
                nextTime = sample_File(nextLine,1);
                nextEvent = sample_File(nextLine,2);
                nextNextTime = sample_File(nextLine+1,1);
                nextNextEvent = sample_File(nextLine+1,2);
                
                if pace_param.a_sense
                    disp('pacemaker detected atrial signal');
                else
                    disp('pacemaker did not detect atrial signal');
                end
            end
% VENTRICAL Input            
        case VENTRICAL_INPUT
            if t == (nextTime + offset)
                pace_param = pacemaker_new(pace_param,0,1, pace_inter);
                disp('sent ventrical signal');
                t = t +1;
                nextLine = nextLine + 1;
                nextTime = sample_File(nextLine,1);
                nextEvent = sample_File(nextLine,2);
                nextNextTime = sample_File(nextLine+1,1);
                nextNextEvent = sample_File(nextLine+1,2);
                
                if pace_param.a_sense
                    disp('pacemaker detected ventrical signal');
                else
                    disp('pacemaker did not detect ventrical signal');
                end
            end
% Atrial Output           
        case ATRIAL_OUTPUT
            a_lowBound = (nextTime+offset)-tolerance_atrial;
            a_highBound = (nextTime+offset)+tolerance_atrial;
            if t < a_lowBound
                if pace_param.a_pace == 1
                    disp('Pacemaker sent atrial signal early');
                    offset = offset + (t-nextTime);
                    nextLine = nextLine + 1;
                    nextTime = sample_File(nextLine,1);
                    nextEvent = sample_File(nextLine,2);
                    nextNextTime = sample_File(nextLine+1,1);
                    nextNextEvent = sample_File(nextLine+1,2);
                end
                if pace_param.v_pace == 1
                    if nextNextEvent == VENTRICAL_OUTPUT
                        disp('Pacemaker sent ventrical signal early');
                    else
                        disp('Pacemaker incorrectly sent ventrical signal');
                    end
                end
            elseif t >= a_lowBound && t <= a_highBound
                if pace_param.a_pace == 1
                    offset = offset + (t-nextTime);
                    disp('Pacemaker sent atrial signal On Time');
                    nextLine = nextLine + 1;
                    nextTime = sample_File(nextLine,1);
                    nextEvent = sample_File(nextLine,2);
                    nextNextTime = sample_File(nextLine+1,1);
                    nextNextEvent = sample_File(nextLine+1,2);
                end
                if pace_param.v_pace == 1
                    if nextNextEvent == VENTRICAL_OUTPUT
                        disp('Pacemaker sent ventrical signal early');
                    else
                        disp('Pacemaker incorrectly sent ventrical signal');
                    end
                end
            elseif t > a_highBound
                if pace_param.a_pace == 1
                    offset = offset + (t-nextTime);
                    disp('Pacemaker sent atrial signal late');
                    nextLine = nextLine + 1;
                    nextTime = sample_File(nextLine,1);
                    nextEvent = sample_File(nextLine,2);
                    nextNextTime = sample_File(nextLine+1,1);
                    nextNextEvent = sample_File(nextLine+1,2);
                end
                if pace_param.v_pace == 1
                    if nextNextEvent == VENTRICAL_OUTPUT
                        disp('Pacemaker sent ventrical signal early');
                    else
                        disp('Pacemaker incorrectly sent ventrical signal');
                    end
                end
            end
            
% VENTRICAL Output
        case VENTRICAL_OUTPUT
            v_lowBound = (nextTime+offset)-tolerance_atrial;
            v_highBound = (nextTime+offset)+tolerance_atrial;
            if t < v_lowBound
                if pace_param.a_pace == 1
                    disp('Pacemaker sent atrial signal late');
                    offset = offset + (t-nextTime);    
                end
                if pace_param.v_pace == 1
                    disp('Pacemaker sent ventrical signal too early');
                    nextLine = nextLine + 1;
                    nextTime = sample_File(nextLine,1);
                    nextEvent = sample_File(nextLine,2);
                    nextNextTime = sample_File(nextLine+1,1);
                    nextNextEvent = sample_File(nextLine+1,2);
                end
            elseif t >= v_lowBound && t <= v_highBound
                if pace_param.v_pace == 1
                    offset = offset + (t-nextTime);
                    disp('Pacemaker send ventrical signal On Time');
                    nextLine = nextLine + 1;
                    nextTime = sample_File(nextLine,1);
                    nextEvent = sample_File(nextLine,2);
                    nextNextTime = sample_File(nextLine+1,1);
                    nextNextEvent = sample_File(nextLine+1,2);
                end
                if pace_param.a_pace == 1
                    if nextNextEvent == ATRIAL_OUTPUT
                        disp('Pacemaker sent atrial signal too early');
                    else
                        disp('Pacemaker incorrectly sent atrial signal');
                    end
                end
            elseif t > v_highBound
                if pace_param.v_pace == 1
                    offset = offset + (t-nextTime);
                    disp('Pacemaker sent ventrical signal late');
                    nextLine = nextLine + 1;
                    nextTime = sample_File(nextLine,1);
                    nextEvent = sample_File(nextLine,2);
                    nextNextTime = sample_File(nextLine+1,1);
                    nextNextEvent = sample_File(nextLine+1,2);
                end
                if pace_param.a_pace == 1
                    if nextNextEvent == ATRIAL_OUTPUT
                        disp('Pacemaker sent atrial signal too early');
                    else
                        disp('Pacemaker incorrectly sent atrial signal');
                    end
                end
            end
            
    end
    
    %break out of while loop once finished testing
    if t > (nextTime + offset)*(1+greatestTolerance) && nextLine > length(sample_File)
        t
        break;
    %else continue on.    
    else
        pace_param = pacemaker_new(pace_param,0,0, pace_inter);
        t = t+1;
        t
        nextLine
        
    end 
end

    disp('Complete');