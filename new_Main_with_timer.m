%{
Test Issues
Test 9
Test 22
Test 27
Test 40
Test 41
Test 43
Test 50
Test 53
Test 54
test 55
%}
close all;
clear;
clc;
index = [40:43, 45:55]; %[1:29, 31:34, 36:39];
for i= 1:length(index)
%% Decide what to plot
plotSignals = 1;
plotTimers = 1;
plotIteratively = 0;
skipTo = 990; %if plotting iteratively, select how far you want to skip to.

%% Decide what to test
doTest = 1;
useDataFile = 1;
allowTolerances = 1;
allowOffsets = 1;
plotTest = 1;

%% Preallocation
load Pacemaker_models/medtronic_params
load Medtronic_tests/medtronic_test_2
pace_param = new_pace;
number = index(i)
fileName = strcat('test_File_', num2str(number));
sample_File = eval(fileName);
pace_param.mode_switch = 'on';
switch number
    case {40}
        pace_param.URI_cur = 750;
        pace_param.URI_def = 750;
    case {50}
        pace_param.AVI_cur = 150;
        pace_param.AVI_def = 150;
    case {53}
        pace_param.AVI_def = 300;
        pace_param.AVI_cur = 300;
        pace_param.URI_cur = 666;
        pace_param.URI_def = 666;
        pace_param.LRI_cur = 1050;
        pacE_param.LRI_def = 1050;
    case {54, 55}
        pace_param.LRI_cur = 600;
        pace_param.LRI_def = 600;
        pace_param.URI_cur = 500;
        pace_param.URI_def = 500;
        pace_param.AVI_cur = 80;
        pace_param.AVI_def = 80;
        pace_param.VSP_sense = 80;
end
%{
pace_param.AVI_def = 150;
pace_param.AVI_cur = 150;
%}
pace_inter=1;
vsp_mode = 1;

A_get=0;
V_get=0;

t=-1;
total_time = 3000;%ms

gdata=zeros(1,total_time);

%% Script Variables
if plotTimers
    % Timer Global Variables
    avi_switch = 0;
    vrp_switch = 0;
    pvarp_switch = 0;
    lri_flip = 0;
    uri_switch = 0;

    avi_init = 0;
    vrp_init = 0;
    pvarp_init = 0;
    lri_init = 0;
    uri_init = 0;
end
% Plot Variables
if plotSignals
    %arrow properties
    roLength = 10;
    roTipAngle = 12;
    PACE_MAGNITUDE = 3;
    SENSE_MAGNITUDE = 2;
    REF_MAGNITUDE = 2;
    SIGN_MAGNITUDE = 0.3;
    %Title font properties
    TITLE_NAME = strcat('Pacemaker Operation Medtronic Test ',num2str(number));
    TITLE_FONT = 'AvantGarde';
    TITLE_FONT_SIZE = 20;
    TITLE_FONT_WEIGHT = 'Bold';
    %Signal plot font properties
    SIGNAL_NAME = 'Pacemaker Signals';
    SIGNAL_FONT = 'AvantGarde';
    SIGNAL_FONT_SIZE = 16;
    SIGNAL_FONT_WEIGHT = 'Bold';
    
    INPUT_FONT = 'Arial';
    INPUT_FONT_SIZE = 14;
    INPUT_FONT_WEIGHT = 'Bold';
end
if plotTimers
    %Timer plot font properties
    TIMER_NAME = 'Timers';
    TIMER_FONT = 'Arial';
    TIMER_FONT_SIZE = 16;
    TIMER_FONT_WEIGHT = 'Bold';
end
if useDataFile
    A_BOUND_COLOR = 'g';
    A_OFFSET_COLOR = [0 204/255 102/255];
    V_BOUND_COLOR = [153/255 204/255 1];
    V_OFFSET_COLOR = 'c';
    ALPHA_FACE_VALUE = 0.1;
    ALPHA_EDGE_VALUE = 0.25;
    ifBoundsPrinted = 0;
    ifAOutput = 0;
    ifVOutput = 0;
    input_done = 0;
    output_done = 0;
end
    XAXIS_NAME = 'time (milliseconds)';
    XAXIS_FONT_WEIGHT = 'Bold';
    XAXIS_FONT_SIZE = 16;
   
    TEXT_FONT = 'Arial';
    TEXT_FONT_SIZE = 16;
    TEXT_FONT_WEIGHT = 'Bold';
    
%% Test Variables
if doTest
%Message Constants
    SENT_A_SIG = 'sent atrial signal at t=';
    DETECT_A_SIG = 'pacemaker detected atrial signal at t=';
    NDETECT_A_SIG = 'pacemaker did not detect atrial signal at t=';
    
    SENT_V_SIG = 'sent ventrical signal at t=';
    DETECT_V_SIG = 'pacemaker detected ventrical signal at t=';
    NDETECT_V_SIG = 'pacemaker did not detect ventrical signal at t=';
    
    A_EARLY = 'Pacemaker sent atrial signal early at t=';
    A_ON = 'Pacemaker sent atrial signal On Time at t=';
    A_LATE = 'Pacemaker sent atrial signal late at t=';
    A_WRONG = 'Pacemaker incorrectly sent atrial signal. at t=';
    
    V_EARLY = 'Pacemaker sent ventrical signal early at t=';
    V_ON = 'Pacemaker sent ventrical signal On Time at t=';
    V_LATE = 'Pacemaker sent ventrical signal late at t=';
    V_WRONG = 'Pacemaker incorrectly sent ventrical signal at t=';
%parameters
if allowTolerances
    tolerance_atrial = 10; %Acceptable tolerance (in ms) for detecting atrial output signals
    tolerance_ventrical = 10; %Acceptable tolerance for detecting ventricular output signals.
    greatestTolerance = max([tolerance_atrial, tolerance_ventrical]);
else 
    tolerance_atrial = 0;
    tolerance_ventrical = 0;
end
%Global Variables
    nextLine = 0; %variable to determine which line in the file is being processed
    offset = 0; %variable to store any necessary offsets
    a_ifPaced = 0; %boolean to determine if pacemaker paced atrium
    v_ifPaced = 0; %boolean to determine if pacemaker paced ventricle
    a_ifSensed = 0; %boolean to determine if pacemaker sensed atrium signal
    v_ifSensed = 0; %boolean to determine if pacemaker sensed ventricle signal
end
%% Input File Variables
if useDataFile    
    %Constants
    ATRIAL_INPUT = 1;
    VENTRICAL_INPUT = 2;
    ATRIAL_OUTPUT = 3;
    VENTRICAL_OUTPUT = 4;
    A_OUTPUT_V_INPUT = 5; %If pacemaker outputs signal to atrium and detects a ventricular signal at the same time.
    V_OUTPUT_A_INPUT = 6; %If pacemaker outputs signal to ventricule and detects an atrial signal at the same time.
    %Global Variables
    nextTime = 0; %the next time an event occurs.
    nextNextTime = 0; % the next time for the event after the expected event
    nextEvent = 0; %The next type of event, from 1-4
    nextNextEvent = 0; %The next next type of event, from 1-4  
end
%% Signal occurences
if ~useDataFile
    ASign = [0 300]; %times when an atrial signal occurs
    VSign = [250]; %times when a venticular signal occurs
    AOutput = [1000];
    VOutput = [1250];
elseif useDataFile
    read_next; %see script/ or see function increment
end
%% PreDraw Graphs
if plotSignals || plotTimers
    figure;
    hold;
    if plotSignals
        if plotTimers 
            subplot(2,1,1)
        end
        %Signal Plot
        title(TITLE_NAME,'FontName',TITLE_FONT,'FontWeight',TITLE_FONT_WEIGHT, 'FontSize', TITLE_FONT_SIZE);
        ylabel(SIGNAL_NAME,'FontName',SIGNAL_FONT,'FontWeight',SIGNAL_FONT_WEIGHT,'FontSize', SIGNAL_FONT_SIZE);
        xlabel(XAXIS_NAME,'FontWeight',XAXIS_FONT_WEIGHT,'FontSize', XAXIS_FONT_SIZE);
        set(gca,'Ylim',[-4,4],'Xlim',[0,total_time],'FontWeight','Bold','FontSize', 16);
        set(gca, 'YTickLabel', {' ',' ',' ',' ',' '});
        xVal = [0,total_time]; 
        yVal = [0,0];
        line(xVal, yVal, 'Color', 'k');
        set(gca,'XGrid','on');
        %set(gca,'GridLineStyle', '.');
    end

    if plotTimers
        if plotSignals
            subplot(2,1,2);
        end
        %Timer Plot
        set(gca,'Ylim',[-4,4],'Xlim',[0,total_time]);
        set(gca, 'YTick',[-4:0.5:4]);
        set(gca, 'YTickLabel', {' ',' ',' ',' ',' ',' ',' ','URI',' ','LRI',' ','PVARP',' ','VRP', ' ','AVI'},'FontWeight','Bold','FontSize', 16);
        set(gca,'XGrid','on');
        ylabel(TIMER_NAME,'FontName',TIMER_FONT,'FontSize', TIMER_FONT_SIZE);
        xlabel(XAXIS_NAME,'FontWeight',XAXIS_FONT_WEIGHT,'FontSize', XAXIS_FONT_SIZE);
        for x = -4:1:4
            xVal = [0, total_time];
            yVal = [x, x];
            line(xVal, yVal,'Color','k');
        end
    end
end
%% Loop
while t< total_time
    
    t=t+1;
    
    %% Do Test
    if doTest
        outSignal = 0;
        switch nextEvent
% Atrial Input        
        case ATRIAL_INPUT
            atrial_input %see script
            if outSignal == 1;
                if plotSignals
                    if plotTimers
                        subplot(2,1,1)
                    end
                    arrow([t,0],[t,SIGN_MAGNITUDE],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor','y');
                    text(t+10,SIGN_MAGNITUDE+0.4,'A_{Signal}','FontName', INPUT_FONT,'FontWeight',INPUT_FONT_WEIGHT,'Fontsize', INPUT_FONT_SIZE); 
                end
                read_next; %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% Ventrical Input            
        case VENTRICAL_INPUT
            ventricular_input %see script
            if outSignal == 1;
                if plotSignals
                    if plotTimers
                        subplot(2,1,1)
                    end
                    arrow([t,0],[t,-SIGN_MAGNITUDE],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor','w');
                    text(t+10,-SIGN_MAGNITUDE-0.4,'V_{Signal}','FontName', INPUT_FONT,'FontWeight',INPUT_FONT_WEIGHT,'Fontsize', INPUT_FONT_SIZE); 
                end
                read_next; %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% Atrial Output           
        case ATRIAL_OUTPUT
            atrial_output %see script
            if ifAOutput == 1 
                read_next; %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% VENTRICAL Output
        case VENTRICAL_OUTPUT
            ventricular_output %see script
            if ifVOutput == 1
                read_next; %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% TODO: Deal with these cases          
        case A_OUTPUT_V_INPUT
            atrial_output 
            ventricular_input
            if pace_param.a_pace ==1
            end      
            if ifAOutput == 1
                output_done = 1;
            end
            if outSignal == 1
                input_done = 1;
            end
            if input_done && output_done
                read_next;
                ifBoundsPrinted = 0;
                input_done = 0;
                output_done = 0;
            end
        case V_OUTPUT_A_INPUT
            read_next;
            %{
            ventricular_output
            atrial_input
            if ifVOutput == 1
                output_done = 1;
            end
            if outSignal == 1
                input_done = 1;
            end
            if input_done && output_done
                read_next;
                ifBoundsPrinted = 0;
            end
           %}
        end
        %break out of while loop once finished testing  
        
        if t > (nextTime + offset)+ greatestTolerance + 300 && nextLine > length(sample_File)
            if plotSignals && plotTimers
                subplot(2,1,1)
                set(gca,'Ylim',[-4,4],'Xlim',[0,t]);
                subplot(2,1,2)
                set(gca,'Ylim',[-4,4],'Xlim',[0,t]);
            else
                set(gca,'Ylim',[-4,4],'Xlim',[0,t]);
            end
            break;
 
        end   
 
        
    end
    %% Plot Pacemaker Sensing/Pacing
    if plotSignals
        if ~useDataFile
            name = '';
            faceColor = 'k';
            if ismember(t,ASign)
                pace_param=pacemaker_new(pace_param, 1, V_get, 1);
                if plotSignals
                    if plotTimers
                        subplot(2,1,1)
                    end
                    arrow([t,0],[t,SIGN_MAGNITUDE],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor','y');
                    text(t+10,SIGN_MAGNITUDE+0.4,'A_{Signal}','FontName', INPUT_FONT,'FontWeight',INPUT_FONT_WEIGHT,'Fontsize', INPUT_FONT_SIZE); 
                end
            elseif ismember(t,VSign)
                pace_param=pacemaker_new(pace_param, A_get, 1, 1);
                if plotSignals
                    if plotTimers
                        subplot(2,1,1)
                    end
                    arrow([t,0],[t,-SIGN_MAGNITUDE],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor','w');
                    text(t+10,-SIGN_MAGNITUDE-0.4,'V_{Signal}','FontName', INPUT_FONT,'FontWeight',INPUT_FONT_WEIGHT,'Fontsize', INPUT_FONT_SIZE); 
                end
            else
                pace_param=pacemaker_new(pace_param, A_get, V_get, 1);
            end
        %% plot bound lines
        elseif useDataFile && plotTest
            switch nextEvent
                case {ATRIAL_OUTPUT ,A_OUTPUT_V_INPUT}   
                    if ifBoundsPrinted == 0
                        if plotTimers
                            subplot(2,1,1)
                        end
                        if ~allowOffsets
                            a_lowBound = nextTime-tolerance_atrial;
                            a_highBound = nextTime+tolerance_atrial;
                            patch([a_lowBound,a_highBound,a_highBound,a_lowBound],[0 0 4 4],A_BOUND_COLOR,'EdgeColor', A_BOUND_COLOR,'EdgeAlpha',ALPHA_EDGE_VALUE,'FaceAlpha',ALPHA_FACE_VALUE);
                        else
                            a_lowBound = (nextTime+offset)-tolerance_atrial;
                            a_highBound = (nextTime+offset)+tolerance_atrial;
                            patch([a_lowBound,a_highBound,a_highBound,a_lowBound],[0 0 4 4],A_OFFSET_COLOR,'EdgeColor', A_OFFSET_COLOR,'EdgeAlpha',ALPHA_EDGE_VALUE,'FaceAlpha',ALPHA_FACE_VALUE);
                        end
                        ifBoundsPrinted = 1;
                    end
                case {VENTRICAL_OUTPUT, V_OUTPUT_A_INPUT}
                    if ifBoundsPrinted == 0;
                        if plotTimers
                            subplot(2,1,1)
                        end
                        if ~allowOffsets
                            v_lowBound = nextTime-tolerance_ventrical;
                            v_highBound = nextTime+tolerance_ventrical;
                            patch([v_lowBound,v_highBound,v_highBound,v_lowBound],[-4 -4 0 0],V_BOUND_COLOR,'EdgeColor', V_BOUND_COLOR,'EdgeAlpha',ALPHA_EDGE_VALUE,'FaceAlpha',ALPHA_FACE_VALUE);
                        else
                            v_lowBound = (nextTime+offset)-tolerance_ventrical;
                            v_highBound = (nextTime+offset)+tolerance_ventrical;
                            patch([v_lowBound,v_highBound,v_highBound,v_lowBound],[-4 -4 0 0],V_OFFSET_COLOR,'EdgeColor', V_OFFSET_COLOR,'EdgeAlpha',ALPHA_EDGE_VALUE,'FaceAlpha',ALPHA_FACE_VALUE);
                        end
                        ifBoundsPrinted = 1;
                    end
            end
        end %end plotting boundlines
    
    data=0;
        % a_pace
        if pace_param.a_pace
            data=PACE_MAGNITUDE;
            name = 'AP';
            faceColor = 'r';
            height = data + 0.3;
            if plotTimers
                subplot(2,1,1)
            end
            arrow([t,0],[t,data],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor',faceColor);
            text(t,height,name,'FontName', TEXT_FONT,'FontWeight',TEXT_FONT_WEIGHT,'Fontsize', TEXT_FONT_SIZE); 
        end
        % v_pace
        if pace_param.v_pace               
            data=-PACE_MAGNITUDE;
            name = 'VP';
            faceColor = 'm';
            height = data - 0.3;
            if plotTimers
                subplot(2,1,1)
            end
            arrow([t,0],[t,data],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor',faceColor);
            text(t,height,name,'FontName', TEXT_FONT,'FontWeight',TEXT_FONT_WEIGHT,'Fontsize', TEXT_FONT_SIZE); 
        end
        % a_sense
        if pace_param.a_sense
            data=SENSE_MAGNITUDE;
            name = 'AS';
            faceColor = 'b';
            height = data + 0.3;
            if plotTimers
                subplot(2,1,1)
            end
            arrow([t,0],[t,data],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor',faceColor);
            text(t,height,name,'FontName', TEXT_FONT,'FontWeight',TEXT_FONT_WEIGHT,'Fontsize', TEXT_FONT_SIZE); 
        end
        % v_sense
        if pace_param.v_sense
            data=-SENSE_MAGNITUDE;
            name = 'VS';
            faceColor = 'c';
            height = data - 0.3;
            if plotTimers
                subplot(2,1,1)
            end
            arrow([t,0],[t,data],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor',faceColor);
            text(t,height,name,'FontName', TEXT_FONT,'FontWeight',TEXT_FONT_WEIGHT,'Fontsize', TEXT_FONT_SIZE); 
        end
        %a_ref
        if pace_param.a_ref
            data=REF_MAGNITUDE;
            name = '[AR]';
            faceColor = 'g';
            height = data + 0.3;
            if plotTimers
                subplot(2,1,1)
            end
            arrow([t,0],[t,data],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor',faceColor);
            text(t,height,name,'FontName', TEXT_FONT,'FontWeight',TEXT_FONT_WEIGHT,'Fontsize', TEXT_FONT_SIZE); 
        end
        % v_ref
        if pace_param.v_ref
            data = -REF_MAGNITUDE;
            name ='[VR]';
            faceColor = 'k';
            height = data - 0.3;
            if plotTimers
                subplot(2,1,1)
            end
            arrow([t,0],[t,data],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor',faceColor);
            text(t,height,name,'FontName', TEXT_FONT,'FontWeight',TEXT_FONT_WEIGHT,'Fontsize', TEXT_FONT_SIZE); 
        end
   end
   %% Plot Timer States
   if plotTimers
    %Constant values
    AVI_UPPER_Y = 4;
    AVI_LOWER_Y = 3;
    AVI_DEF_COLOR = [1 90/255 0];
    AVI_CUR_COLOR = 'red';
   
    VRP_UPPER_Y = 3;
    VRP_LOWER_Y =2;
    VRP_DEF_COLOR = [1 0 1];
    VRP_CUR_COLOR = [76/255 0 153/255];
   
    PVARP_UPPER_Y =2;
    PVARP_LOWER_Y =1;
    PVARP_DEF_COLOR = 'c';
    PVARP_CUR_COLOR = 'blue';
   
    LRI_UPPER_Y = 1;
    LRI_LOWER_Y = 0;
    LRI_DEF_COLOR = [0 128/255 128/255];
    LRI_CUR_COLOR = 'g';
   
    URI_UPPER_Y = 0;
    URI_LOWER_Y = -1;
    URI_DEF_COLOR = [207/255 181/255 59/255];
    URI_CUR_COLOR = 'y';
   
    BLOCK_COLOR = 'k';
    VSP_COLOR = 'w';
   
    %local variables
   
              %AVI  
              if ~strcmp(pace_param.AVI,'off')
                  %if timer just started, plot the expected timer time for
                  %AVI, ABP, and VSP (if on).
                 
                  if plotSignals
                    subplot(2,1,2)
                  end
                if pace_param.AVI_cur == pace_param.AVI_def
                    avi_switch = 1;
                    avi_init = t;
                    rectangle('Position',[t,AVI_LOWER_Y, pace_param.AVI_def,1],'FaceColor',AVI_DEF_COLOR);
                    if strcmp(pace_param.AVI, 'P')
                        rectangle('Position',[t,AVI_LOWER_Y, pace_param.ABP,0.5],'FaceColor',BLOCK_COLOR);
                    end
                    if vsp_mode == 1
                        rectangle('Position',[t,AVI_LOWER_Y+0.25, pace_param.VSP_sense,0.25],'FaceColor',VSP_COLOR);
                    end
                %else color the current timer state.    
                elseif plotIteratively
                    rectangle('Position',[t-1,AVI_LOWER_Y+0.5, 1,0.5],'FaceColor',AVI_CUR_COLOR,'EdgeColor', AVI_CUR_COLOR);
                end 
              end
              
                if plotSignals
                    subplot(2,1,2)
                end
                if strcmp(pace_param.AVI,'off') && avi_switch==1
                    width = (t-1) - avi_init;
                    rectangle('Position',[avi_init,AVI_LOWER_Y+0.5,width,0.5],'FaceColor',AVI_CUR_COLOR);
                    avi_switch = 0;
                    avi_init = 0;
                end
              
              %VRP
              if strcmp(pace_param.VRP, 'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                if pace_param.VRP_cur == pace_param.VRP_def ||pace_param.v_sense == 1 || pace_param.v_pace == 1
                    vrp_switch = 1;
                    vrp_init = t;
                    rectangle('Position',[t,VRP_LOWER_Y, pace_param.VRP_def,1],'FaceColor',VRP_DEF_COLOR);
                elseif plotIteratively
                    rectangle('Position',[t-1,VRP_LOWER_Y+0.5, 1,0.5],'FaceColor',VRP_CUR_COLOR,'EdgeColor', VRP_CUR_COLOR);
                end
              end
                if strcmp(pace_param.VRP,'off') && vrp_switch==1
                    width = (t-1) - vrp_init;
                    rectangle('Position',[vrp_init,VRP_LOWER_Y+0.5,width,0.5],'FaceColor',VRP_CUR_COLOR);
                    vrp_switch = 0;
                    vrp_init = 0;
                end
              
              % PVARP
              if strcmp(pace_param.PVARP, 'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.PVARP_cur == pace_param.PVARP_def
                    pvarp_switch = 1;
                    pvarp_init = t;
                    rectangle('Position',[t,PVARP_LOWER_Y, pace_param.PVARP_def,1],'FaceColor',PVARP_DEF_COLOR);
                  elseif plotIteratively
                    rectangle('Position',[t-1,PVARP_LOWER_Y+0.5, 1,0.5],'FaceColor',PVARP_CUR_COLOR,'EdgeColor', PVARP_CUR_COLOR);
                  end
              end
              
                  if strcmp(pace_param.PVARP,'off') && pvarp_switch==1
                    width = (t-1) - pvarp_init;
                    rectangle('Position',[pvarp_init,PVARP_LOWER_Y+0.5,width,0.5],'FaceColor',PVARP_CUR_COLOR);
                    pvarp_switch = 0;
                    pvarp_init = 0;
                  end
              
              % LRI
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.LRI_cur == pace_param.LRI_def-2 % || t== 0 %(pace_param.v_pace || pace_param.v_sense || t == 0) && (strcmp(pace_param.PVARP, 'off') || pace_param.LRI_cur == pace_param.LRI_def)   
                    if lri_flip == 0
                        lri_flip  = 1;   
                    else
                        lri_flip = 0;
                    end  
                    if lri_flip 
                        position = 0.5;
                        pos = 0;
                    else
                        position = 0;
                        pos = 0.5;
                    end
                    rectangle('Position',[t,LRI_LOWER_Y + position, pace_param.LRI_def,0.5],'FaceColor',LRI_DEF_COLOR);
                    
                    width = (t-1) - lri_init; 
                    if width > 0
                        rectangle('Position',[lri_init, LRI_LOWER_Y + pos,width,0.25],'FaceColor', LRI_CUR_COLOR);
                    end
                    lri_init = t;
                    
                  elseif plotIteratively
                    if lri_flip
                       pos = 0.5;
                       position = 0.5;
                    else
                       pos = 0;
                       position = 0;
                    end
                    rectangle('Position',[t-1,LRI_LOWER_Y+position, 1,0.25],'FaceColor',LRI_CUR_COLOR, 'EdgeColor', LRI_CUR_COLOR);  
                  end
                  %plot how long LRI timer went through if it passed the
                  %time limit.
                  if t >= total_time
                    if lri_flip
                       pos = 0.5;
                    else
                       pos = 0;
                    end  
                    width = total_time - lri_init;
                    rectangle('Position',[lri_init, LRI_LOWER_Y + pos,width,0.25],'FaceColor', LRI_CUR_COLOR);
                  end
                  
              % URI
              if strcmp(pace_param.URI,'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.URI_cur == pace_param.URI_def
                    uri_switch = 1;
                    uri_init = t;
                    rectangle('Position',[t,URI_LOWER_Y, pace_param.URI_def,1],'FaceColor',URI_DEF_COLOR);
                  elseif plotIteratively
                    rectangle('Position',[t-1,URI_LOWER_Y+0.5, 1,0.5],'FaceColor',URI_CUR_COLOR, 'EdgeColor', URI_CUR_COLOR);
                  end
              end
              
                  if strcmp(pace_param.URI,'off') && uri_switch==1
                    width = (t-1) - uri_init;
                    rectangle('Position',[uri_init,URI_LOWER_Y+0.5,width,0.5],'FaceColor',URI_CUR_COLOR);
                    uri_switch = 0;
                    uri_init = 0;
                  end
   end
   
    if plotIteratively
        if skipTo <= 0 || skipTo <= t
            pause(0.001);
            pace_param.LRI_cur
        end
     %   pace_param.AF_interval
    end
    
    if doTest
        if outSignal == 0
            pace_param = pacemaker_new(pace_param,0,0, pace_inter,vsp_mode);
        end
    end
   
end
disp(' ');
if plotSignals || plotTimers
    set(gcf, 'PaperPositionMode', 'auto');
end
end