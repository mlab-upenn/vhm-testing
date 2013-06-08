clear;
load medtronic_params
pace_param.mode_switch = 'on';

%% Script Variables
    %Message Constants
    SENT_A_SIG = 'sent atrial signal at t=';
    DETECT_A_SIG = 'pacemaker detected atrial signal at t=';
    NDETECT_A_SIG = 'pacemaker did not detect atrial signal at t=';
    
    SENT_V_SIG = 'sent ventrical signal at t=';
    DETECT_V_SIG = 'pacemaker detected ventrical signal at t=';
    NDETECT_V_SIG = 'pacemaker did not detect atrial signal at t=';
    
    A_EARLY = 'Pacemaker sent atrial signal early at t=';
    A_ON = 'Pacemaker sent atrial signal On Time at t=';
    A_LATE = 'Pacemaker sent atrial signal late at t=';
    A_WRONG = 'Pacemaker incorrectly sent atrial signal. at t=';
    
    V_EARLY = 'Pacemaker sent ventrical signal early at t=';
    V_ON = 'Pacemaker sent ventrical signal On Time at t=';
    V_LATE = 'Pacemaker sent ventrical signal late at t=';
    V_WRONG = 'Pacemaker incorrectly sent ventrical signal at t=';
    
    
    
    
    %Parameters    
    tolerance_atrial = 100; %Acceptable tolerance (in ms) for detecting atrial output signals
    tolerance_ventrical = 100; %Acceptable tolerance (in ms) for detecting ventrical output signals.
    greatestTolerance = max([tolerance_atrial, tolerance_ventrical]);
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
                disp(strcat(SENT_A_SIG,num2str(t)));
                t = t+1;
                [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                if pace_param.a_sense
                    disp(strcat(DETECT_A_SIG,num2str(t)));
                else
                    disp(strcat(NDETECT_A_SIG,num2str(t)));
                end
            end
% VENTRICAL Input            
        case VENTRICAL_INPUT
            if t == (nextTime + offset)
                pace_param = pacemaker_new(pace_param,0,1, pace_inter);
                disp(strcat(SENT_V_SIG,num2str(t)));
                t = t +1;
                [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                if pace_param.a_sense
                    disp(strcat(DETECT_V_SIG,num2str(t)));
                else
                    disp(strcat(NDETECT_V_SIG,num2str(t)));
                end
            end
% Atrial Output           
        case ATRIAL_OUTPUT
            a_lowBound = (nextTime+offset)-tolerance_atrial;
            a_highBound = (nextTime+offset)+tolerance_atrial;
            if t < a_lowBound
                if pace_param.a_pace == 1
                    disp(strcat(A_EARLY,num2str(t)));
                    offset = offset + (t-nextTime);
                    [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                end
                if pace_param.v_pace == 1
                    if nextNextEvent == VENTRICAL_OUTPUT
                        disp(strcat(V_EARLY,num2str(t)));
                    else
                        disp(strcat(V_WRONG,num2str(t)));
                    end
                end
            elseif t >= a_lowBound && t <= a_highBound
                if pace_param.a_pace == 1
                    offset = offset + (t-nextTime);
                    disp(strcat(A_ON,num2str(t)));
                    
                    [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                end
                if pace_param.v_pace == 1
                    if nextNextEvent == VENTRICAL_OUTPUT
                        disp(strcat(V_EARLY,num2str(t)));
                    else
                        disp(strcat(V_WRONG,num2str(t)));
                    end
                end
            elseif t > a_highBound
                if pace_param.a_pace == 1
                    offset = offset + (t-nextTime);
                    disp(strcat(A_LATE,num2str(t)));
                    [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                end
                if pace_param.v_pace == 1
                    if nextNextEvent == VENTRICAL_OUTPUT
                        disp(strcat(V_EARLY,num2str(t)));
                    else
                        disp(strcat(V_WRONG,num2str(t)));
                    end
                end
            end
            
% VENTRICAL Output
        case VENTRICAL_OUTPUT
            v_lowBound = (nextTime+offset)-tolerance_atrial;
            v_highBound = (nextTime+offset)+tolerance_atrial;
            if t < v_lowBound
                if pace_param.a_pace == 1
                    disp(strcat(A_LATE,num2str(t)));
                    offset = offset + (t-nextTime);    
                end
                if pace_param.v_pace == 1
                    disp(strcat(V_EARLY,num2str(t)));
                    [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                end
            elseif t >= v_lowBound && t <= v_highBound
                if pace_param.v_pace == 1
                    offset = offset + (t-nextTime);
                    disp(strcat(V_ON,num2str(t)));
                    [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                end
                if pace_param.a_pace == 1
                    if nextNextEvent == ATRIAL_OUTPUT
                        disp(strcat(A_EARLY,num2str(t)));
                    else
                        disp(strcat(A_WRONG,num2str(t)));
                    end
                end
            elseif t > v_highBound
                if pace_param.v_pace == 1
                    offset = offset + (t-nextTime);
                    disp(strcat(A_EARLY,num2str(t)));
                    [nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
                    nextNextTime,nextNextEvent, sample_File);
                end
                if pace_param.a_pace == 1
                    if nextNextEvent == ATRIAL_OUTPUT
                        disp(strcat(A_EARLY,num2str(t)));
                    else
                        disp(strcat(A_WRONG,num2str(t)));
                    end
                end
            end
            
    end
    
    %break out of while loop once finished testing
    if t > (nextTime + offset)+ greatestTolerance && nextLine > length(sample_File)
        %t
        break;
    %else continue on.    
    else
        pace_param = pacemaker_new(pace_param,0,0, pace_inter);
        t = t+1;
        %t
        %nextLine
        
    end 
end

    disp('Complete');
    disp(' ');
    
   % function [ ] = increment(nxtTime, nxtEvent, nNTime, nNEvent, smp_File)
   % end