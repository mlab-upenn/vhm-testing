function [pass,v_out,a_out] = simple_tester(filename,v_in,a_in,t,tolerance_atrial,tolerance_ventrical,allowOffsets)
%simple_tester is function that tests a pacemaker at a single point in time
%t.
%   Detailed explanation goes here
%simple_tester takes in:
%   filename: a nx2 matrix contains the test data
%   v_in: a boolean that determines if the pacemaker (a separate function)
%       gave a ventricular pace at time t
%   a_in: a boolean that determines if the pacemaker (a separate function)
%       gave an atrial pace at time t
%   t: the global time variable
%   tolerance_atrial: an integer/double for acceptable tolerance (in ms) for detecting atrial output signals
%   tolerance_ventrical: and integer/double for acceptable tolerance (in ms) for detecting ventricular output signals.
%   allowOffsets: a boolean to determine if offsets should be applied.

%simple_tester outputs:
%   pass, a boolean that determines if the test passed or not (1 if
%       passed, 0 if not)
%   v_out, a boolean that determines if the file sent out a ventricular
%       signal at time t (0 if not sent out, 1 if sent out)
%   a_out, a boolean that determines if the file sent out an atrial signal
%       at time t (0 if not sent out, 1 if sent out)


persistent fileLine; %fileLine reads in t
persistent offset; %offset helps to adjust the expected time for an event if the pacemaker sent in too early or late

% these two static variables are used in the instance when the 'event'
% variable is either a 5 or 6
persistent output_done;
persistent input_done;

%reset fileLine and offset when t = 1, i.e. when a new test file is read
if t == 1
    fileLine = 1;
    offset = 0;
    output_done = 0;
    input_done = 0;
end

%Constants that define the 'event' variable
ATRIAL_INPUT = 1; %if next event is to output atrial sense
VENTRICAL_INPUT = 2; %if next event if to output ventricular sense
ATRIAL_OUTPUT = 3; % if next event is to deliver atrial pacing
VENTRICAL_OUTPUT = 4; % if next event is to deliver ventricular pacing
A_OUTPUT_V_INPUT = 5; %If pacemaker outputs signal to atrium and detects a ventricular signal at the same time.
V_OUTPUT_A_INPUT = 6; %If pacemaker outputs signal to ventricule and detects an atrial signal at the same time.


pass = 1;
%read the line
%also can be written:
% time = filename(fileLine,1);
% event = filename(fileLine,2);
[time event] = filename(fileLine,:);

    switch event
% Atrial Input        
        case ATRIAL_INPUT
            %check instances where there is incorrect pacing
            if a_in == 1 %if pacemaker paced atrium, failed
                pass = 0;
            end
            if v_in == 1 %if pacemaker paced ventricle, failed
                pass = 0;
            end
            %deliver the sense when the time is right
            if t == (time + offset)
                a_out = 1;
                fileLine = fileLine + 1; %increment to read next line.
            end
% Ventrical Input            
        case VENTRICAL_INPUT
            %check instances where there is incorrect pacing
            if a_in == 1 %if pacemaker paced atrium, failed
                pass = 0;
            end
            if v_in == 1 %if pacemaker paced ventricle, failed
                pass = 0;
            end
            %deliver the sense when the time is right
            if t == (time + offset)
                v_out = 1;
                fileLine = fileLine + 1; %increment to read next line.
            end
% Atrial Output           
        case ATRIAL_OUTPUT
            %case for atrial output. 
            ifAOutput = 0;
            if fileLine == 1 %if first line in test, just deliver atrium pacing
                a_out = 1;
                ifAOutput = 1;
            else
                if allowOffsets
                    a_lowBound = (time+offset)-tolerance_atrial;
                    a_highBound = (time+offset)+tolerance_atrial;
                else
                    a_lowBound = (time)-tolerance_atrial;
                    a_highBound = (time)+tolerance_atrial;
                end
                if t < a_lowBound
                    if a_in == 1 %if atrium pace was sent early                    
                        offset = offset + (t-time); %adjust offset
                        pass = 0; %failed
                        ifAOutput = 1;
                    end
                    if v_in == 1 %if ventricle pace was sent when it should be atrium pacing
                        pass = 0;
                    end
                elseif t >= a_lowBound && t <= a_highBound
                    if a_in == 1 %if atrium pacing was sent at the right time.
                        offset = offset + (t-time);
                        pass = 1;
                        ifAOutput = 1;
                    end
                    if v_in == 1 %if ventricle pacing was sent when atrium pacing was expected
                        pass = 0;
                    end
                elseif t > a_highBound
                    if a_in == 1 %if atrium pacing was sent late.
                        offset = offset + (t-time);
                        pass = 0;
                        ifAOutput = 1;
                    end
                    if v_in == 1 %if ventricle pacing was sent when before atrium pacing
                        pass = 0;
                    end
                end
            end
            
            if ifAOutput == 1 %read the next line
                fileLine = fileLine + 1; 
            end
% VENTRICAL Output
        case VENTRICAL_OUTPUT
            ifVOutput = 0;
            if fileLine == 1
                v_out = 1;
                ifVOutput = 1;
            else
                if allowOffsets
                    v_lowBound = (time+offset)-tolerance_ventrical;
                    v_highBound = (time+offset)+tolerance_ventrical;
                else
                    v_lowBound = (time)-tolerance_ventrical;
                    v_highBound = (time)+tolerance_ventrical;
                end
                if t < v_lowBound
                    if a_in == 1 %if atrium pacing was sent before ventricle pacing
                        pass = 0;
                    end
                    if v_in == 1 %if ventricle pacing was sent early
                        offset = offset + (t-time);
                        pass = 0;
                        ifVOutput = 1;
                    end
                elseif t >= v_lowBound && t <= v_highBound 
                    if v_in == 1 %if ventricle pacing was sent at the right time.
                        offset = offset + (t-time);
                        pass = 1;
                        ifVOutput = 1;
                    end
                    if a_in == 1 %if atrium pacing was sent when ventricle pacing was expected
                        pass = 0;
                    end
                elseif t > v_highBound
                    if v_in == 1 %if ventricle pacing was sent late
                        offset = offset + (t-time);                       
                        pass = 0;
                        ifVOutput = 1;
                    end
                    if a_in == 1 %if atrium pacing was sent before ventricle pacing
                        pass = 0;
                    end
                end
            end
            if ifVOutput == 1
                fileLine = fileLine + 1;
            end        
        case A_OUTPUT_V_INPUT
            %case for atrial output. 
            ifAOutput = 0;
            if fileLine == 1 %if first line in test, just deliver atrium pacing
                a_out = 1;
                ifAOutput = 1;
            else
                if allowOffsets
                    a_lowBound = (time+offset)-tolerance_atrial;
                    a_highBound = (time+offset)+tolerance_atrial;
                else
                    a_lowBound = (time)-tolerance_atrial;
                    a_highBound = (time)+tolerance_atrial;
                end
                if t < a_lowBound
                    if a_in == 1 %if atrium pace was sent early                    
                        offset = offset + (t-time); %adjust offset
                        pass = 0; %failed
                        ifAOutput = 1;
                    end
                    if v_in == 1 %if ventricle pace was sent when it should be atrium pacing
                        pass = 0;
                    end
                elseif t >= a_lowBound && t <= a_highBound
                    if a_in == 1 %if atrium pacing was sent at the right time.
                        offset = offset + (t-time);
                        pass = 1;
                        ifAOutput = 1;
                    end
                    if v_in == 1 %if ventricle pacing was sent when atrium pacing was expected
                        pass = 0;
                    end
                elseif t > a_highBound
                    if a_in == 1 %if atrium pacing was sent late.
                        offset = offset + (t-time);
                        pass = 0;
                        ifAOutput = 1;
                    end
                    if v_in == 1 %if ventricle pacing was sent when before atrium pacing
                        pass = 0;
                    end
                end
            end
            if ifAOutput == 1 
                output_done = 1;
            end
            if t == (time + offset)
                v_out = 1;
                input_done = 1;
            end
            if output_done && input_done
                fileLine = fileLine + 1; %increment to read next line.
                output_done = 0;
                input_done = 0;
            end
        case V_OUTPUT_A_INPUT
            ifVOutput = 0;
            if fileLine == 1
                v_in = 1;
                ifVOutput = 1;
            else
                if allowOffsets
                    v_lowBound = (time+offset)-tolerance_ventrical;
                    v_highBound = (time+offset)+tolerance_ventrical;
                else
                    v_lowBound = (time)-tolerance_ventrical;
                    v_highBound = (time)+tolerance_ventrical;
                end
                if t < v_lowBound
                    if a_in == 1 %if atrium pacing was sent before ventricle pacing
                        pass = 0;
                    end
                    if v_in == 1 %if ventricle pacing was sent early
                        offset = offset + (t-time);
                        pass = 0;
                        ifVOutput = 1;
                    end
                elseif t >= v_lowBound && t <= v_highBound 
                    if v_in == 1 %if ventricle pacing was sent at the right time.
                        offset = offset + (t-time);
                        pass = 1;
                        ifVOutput = 1;
                    end
                    if a_in == 1 %if atrium pacing was sent when ventricle pacing was expected
                        pass = 0;
                    end
                elseif t > v_highBound
                    if v_in == 1 %if ventricle pacing was sent late
                        offset = offset + (t-time);                       
                        pass = 0;
                        ifVOutput = 1;
                    end
                    if a_in == 1 %if atrium pacing was sent before ventricle pacing
                        pass = 0;
                    end
                end
            end
            if ifVOutput == 1
                output_done = 1;
            end
            if t == (time + offset)
                a_out = 1;
                input_done = 1;
            end
            if output_done && input_done
                fileLine = fileLine + 1; %increment to read next line.
                output_done = 0;
                input_done = 0;
            end
    end
end




