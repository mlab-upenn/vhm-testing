function [] = pacemaker_tester(filename,pacemaker_param,varargin)
%pacemaker_tester takes in:
%   filename, a char array of the name of a file that contains the test 
%       data.
%   pacemaker_param, a structure defining pacemaker parameters.
%   and additional arguments.
%
%
%varagin
%   'plot' plots the data. 
%       'signals' or 0 plots only the signals
%       'timers' or 1 plots only the timers
%       'all' or 2 plots both
%   'runTo' defines the length of the test (i.e. if the test to run up to 3000 ms, etc.).
%       Default is to stop the test once the test file has an error, or until the file has finished reading.   
%       parameter is a double or char defining the time in ms when to stop.
%       i.e. ,'runTo',750) stops the test at 750 ms.
%   'plotIteratively' plots the data piece by piece after each loop
%       parameter is a double or char defining the time in ms when to start
%       plotting. i.e. 'plotIteratively',750) starts plotting at 750 ms.
%       Default is off.s
%   'tolerances' defines the allowable error in ms to be considered on time
%       parameter is a matrix or cell array defining the accepted tolerance 
%       for atrial timing and ventrial timing.
%       i.e. [10,8] or {10,8} allows for 10 ms for atrial tolerance and 8 ms for
%       ventricular tolerance. Default is no tolerances ([0,0]).
%   'allowOffset' defines if an offset will be applied if a signal is not
%   on time
%       parameter is either 'yes' or 1 to enable. Default is off.
%   'stepSize' defines the step in ms per each iteration in the test.
%       parameter is a double or char defining the stepsize. i.e
%       'stepSize',.1) will set the step to 0.1 ms. Default is 1 ms.
%   'output' defines where the report should be output to. Parameter is
%       either 'display' if the results are printed on the matlab command
%       prompt, or a filename (i.e. 'report.txt') where the report will be
%       printed to.
%   'seePaceSense' defines if the report should also include if the model
%       detected A/V stimuli. 0 to disallow or 1 to allow. In terms of black
%       box testing, this should not be used. Default is not on.
%
%{
close all;
clear;
clc;
%}
%% Decide what to plot
plotSignals = 0;
plotTimers = 0;
breakEarly = 1;
plotIteratively = 0;
skipTo = 0; %if plotting iteratively, select how far you want to skip to.
pace_inter=1; %default stepsize
total_time = 3000;%ms %define how long you want to run the test.
tolerance_atrial = 0; %Acceptable tolerance (in ms) for detecting atrial output signals
tolerance_ventrical = 0; %Acceptable tolerance for detecting ventricular output signals.
greatestTolerance = max([tolerance_atrial, tolerance_ventrical]);
output = 0; %0 if output to display, 1 if printing to file.
seePaceSense = 0;
totalFiles = 1;

%stats
%Global stats
testError = 0;
testsInError = '';
total_V_late_errors = 0;
total_V_early_errors = 0;
total_V_wrong_errors = 0;

total_A_late_errors = 0;
total_A_early_errors = 0;
total_A_wrong_errors = 0;

avgMarginError = 0;
greatestMarginError = 0;


%file Stats
marginError = 0;
V_late_error = 0;
V_early_error = 0;
V_wrong_error = 0;

A_late_error = 0;
A_early_error = 0;
A_wrong_error = 0;
fileError = 0;

%% Decide what to test
allowOffsets = 0;
%% Varagins
%take into account multiple argumemts
    if ~isempty(varargin)
        for i = 1:2:length(varargin)
            argument = varargin{i};
            if strcmpi(argument,'plot')
                parameter = varargin{i+1};
                if isa(parameter,'char')
                    if strcmpi(parameter,'signals')
                        plotSignals = 1;
                    elseif strcmpi(parameter,'timers')
                        plotTimers = 1;
                    elseif strcmpi(parameter,'all')
                        plotSignals = 1;
                        plotTimers = 1;
                    end
                elseif isa(parameter,'double')
                    switch parameter
                        case 0
                            plotSignals = 1;
                        case 1
                            plotTimers = 1;
                        case 2
                            plotSignals = 1;
                            plotTimers = 1;
                    end
                end
            elseif strcmpi(argument,'runTo')
                parameter = varargin{i+1};
                total_time = parameter;
                breakEarly = 0;
            elseif strcmpi(argument,'plotIteratively')
                parameter = varargin{i+1};
                if isa(parameter,'char')
                    if strcmpi(parameter,'beginning')
                        skipTo = 0;
                        plotIteratively = 1;
                        plotSignals = 1;
                        plotTimers = 1;
                    else
                        skipTo = str2num(parameter);
                        plotIteratively = 1;
                        plotSignals = 1;
                        plotTimers = 1;
                    end
                elseif isa(parameter,'double')
                    skipTo = parameter;
                    plotIteratively = 1;
                    plotSignals = 1;
                    plotTimers = 1;
                end
            elseif strcmpi(argument,'tolerances')
                parameter = varargin{i+1};
                if iscell(parameter)
                    tolerance_atrial = parameter{1};
                    tolerance_ventrical = parameter{2};
                    greatestTolerance = max([tolerance_atrial, tolerance_ventrical]);
                else
                    tolerance_atrial = parameter(1);
                    tolerance_ventrical = parameter(2);
                    greatestTolerance = max([tolerance_atrial, tolerance_ventrical]);
                end
            elseif strcmpi(argument,'allowOffset')
                parameter = varargin{i+1};
                if isa(parameter,'char')
                    if strcmpi(parameter,'yes')
                        allowOffsets = 1;
                    end
                elseif isa(parameter,'double')
                    if parameter == 1
                        allowOffsets = 1;
                    end
                end
            elseif strcmpi(argument,'stepSize')
                parameter = varargin{i+1};
                if isa(parameter,'char')
                    pace_inter = str2num(parameter);
                elseif isa(parameter,'double')
                    pace_inter = parameter;
                end
            elseif strcmpi(argument,'output')
                parameter = varargin{i+1};
                if strcmpi(parameter,'display')
                    output = 0;
                else
                    output = 1;
                    fileId = fopen(parameter,'w');
                end
            elseif strcmpo(argument,'seePaceSense')
                parameter = varargin{i+1};
                if parameter == 1
                    seePaceSense = 1;
                end
            else
                error(['Unknown argument ''',varargin{i},'''']);
            end
        end
    end

%% Preallocation
pace_param = pacemaker_param;
if isa(filename, 'double')
    sample_File = filename;
    name = inputname(1);
    if output == 0
        disp(name);
    else
        fprintf(fileId,[name,'\n']);
    end
elseif isa(filename,'char')
    [path file ext] = fileparts(filename);
    name = file;
    if strcmp(ext,'.txt')
        fid = fopen(filename);
        sample_File = fscanf(fid,'%d %d',[2,inf])';
        if output == 0
            disp(name);
        else
            fprintf(fileId,[name,'\n']);
        end
    else
        error(['Unsupported file format ''',ext,'''']);
    end
elseif isa(filename,'cell')
    totalFiles = length(filename);
else
    error(['Unsupported file format ''',inputname(1),'''']);
end

for k = 1:totalFiles
    if totalFiles > 1
        if isa(filename{k},'double')
            sample_File = filename{k};
            name = [inputname(1),' ',num2str(k)];
            if output == 0
                disp(name);
            else
                fprintf(fileId,[inputname(1),' %d\n'],k);
            end    
        elseif isa(filename{k},'char')
            [path file ext] = fileparts(filename{k});
            name = file;
            if strcmp(ext,'.txt')
                fid = fopen(filename{k});
                sample_File = fscanf(fid,'%d %d',[2,inf])';
                if output == 0
                    disp(name);
                else
                    fprintf(fileId,[name,'\n']);
                end
            else
                error(['Unsupported file format ''',ext,'''']);
            end
        end
    end
    
%% Script Variables
if plotTimers
    % Timer Global Variables
    avi_switch = 0;
    vrp_switch = 0;
    vrp_vsp_switch = 0;
    pvarp_switch = 0;
    pvarp_pvc_switch = 0;
    lri_flip = 0;
    uri_switch = 0;
    uri_printed = 0;

    avi_init = 0;
    vrp_init = 0;
    pvarp_init = 0;
    lri_init = 0;
    uri_init = 0;
    
    %Constant values
    AVI_UPPER_Y = 4;
    AVI_LOWER_Y = 3;
    P_AVI_DEF_COLOR = [1 90/255 0];
    S_AVI_DEF_COLOR = [255/255 204/255 153/255];
    R_AVI_DEF_COLOR = [102/255 51/255 0];
    AVI_CUR_COLOR = 'red';
   
    VRP_UPPER_Y = 3;
    VRP_LOWER_Y =2;
    VRP_DEF_COLOR = [1 0 1];
    R_VRP_DEF_COLOR = [190/255 10/255 230/255];
    VRP_CUR_COLOR = [76/255 0 153/255];
   
    PVARP_UPPER_Y =2;
    PVARP_LOWER_Y =1;
    PVARP_DEF_COLOR = 'c';
    PVARP_EXTEND_DEF_COLOR = [102/255 178/255 255/255]; 
    PVARP_CUR_COLOR = 'blue';
   
    LRI_UPPER_Y = 1;
    LRI_LOWER_Y = 0;
    LRI_DEF_COLOR = [0 128/255 128/255];
    AEI_DEF_COLOR = [100/255 200/255 150/255];
    LRI_CUR_COLOR = 'g';
   
    URI_UPPER_Y = 0;
    URI_LOWER_Y = -1;
    URI_DEF_COLOR = [207/255 181/255 59/255];
    URI_CUR_COLOR = 'y';
   
    BLOCK_COLOR = 'k';
    VSP_COLOR = 'w';
   
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
    TITLE_NAME = ['Pacemaker Operation Medtronic Test ',name];
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

    XAXIS_NAME = 'time (milliseconds)';
    XAXIS_FONT_WEIGHT = 'Bold';
    XAXIS_FONT_SIZE = 16;
   
    TEXT_FONT = 'Arial';
    TEXT_FONT_SIZE = 16;
    TEXT_FONT_WEIGHT = 'Bold';
    
%% Test Variables
%Message Constants
    SENT_A_SIG = 'sent atrial signal at t=';
    DETECT_A_SIG = 'pacemaker detected atrial signal at t=';
    NDETECT_A_SIG = 'WARNING: pacemaker did not detect atrial signal at t=';
    
    SENT_V_SIG = 'sent ventrical signal at t=';
    DETECT_V_SIG = 'pacemaker detected ventrical signal at t=';
    NDETECT_V_SIG = 'WARNING: pacemaker did not detect ventrical signal at t=';
    
    A_EARLY = 'ERROR: Pacemaker paced atrium, early at t=';
    A_ON = 'Pacemaker paced atrium On Time at t=';
    A_LATE = 'ERROR: Pacemaker paced atrium late at t=';
    A_WRONG = 'ERROR: Pacemaker incorrectly paced atrium. at t=';
    
    V_EARLY = 'ERROR: Pacemaker paced ventricle early at t=';
    V_ON = 'Pacemaker paced ventricle On Time at t=';
    V_LATE = 'ERROR: Pacemaker paced ventricle late at t=';
    V_WRONG = 'ERROR: Pacemaker incorrectly paced ventricle at t=';
    
    WARNING_COLOR = [229/255 222/255 22/255];
    GOOD_COLOR = 'Comments';
    ERROR_COLOR = [1 0 0];
    NOTE_COLOR = [0 0 1];
%Global Variables
    nextLine = 0; %variable to determine which line in the file is being processed
    offset = 0; %variable to store any necessary offsets
    a_ifPaced = 0; %boolean to determine if pacemaker paced atrium
    v_ifPaced = 0; %boolean to determine if pacemaker paced ventricle
    a_ifSensed = 0; %boolean to determine if pacemaker sensed atrium signal
    v_ifSensed = 0; %boolean to determine if pacemaker sensed ventricle signal
%% Input File Variables
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
%% Signal occurences
    read_next(); %see script/ or see function increment
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
t=-1;

while t< total_time
    
    t=t+1;
    
    %% Do Test
        sendASignal = 0;
        sendVSignal = 0;
        switch nextEvent
% Atrial Input        
        case ATRIAL_INPUT
            atrialInput() %see script
            if sendASignal == 1;
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
            ventricularInput() %see script
            if sendVSignal == 1;
                if plotSignals
                    if plotTimers
                        subplot(2,1,1)
                    end
                    arrow([t,0],[t,-SIGN_MAGNITUDE],'Length', roLength, 'TipAngle',roTipAngle,'EdgeColor','k','FaceColor','w');
                    text(t+10,-SIGN_MAGNITUDE-0.4,'V_{Signal}','FontName', INPUT_FONT,'FontWeight',INPUT_FONT_WEIGHT,'Fontsize', INPUT_FONT_SIZE); 
                end
                read_next(); %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% Atrial Output           
        case ATRIAL_OUTPUT
            atrialOutput() %see script
            if ifAOutput == 1 
                read_next(); %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% VENTRICAL Output
        case VENTRICAL_OUTPUT
            ventricularOutput() %see script
            if ifVOutput == 1
                read_next(); %see script/ or see function increment
                ifBoundsPrinted = 0;
            end
% TODO: Deal with these cases          
        case A_OUTPUT_V_INPUT
            atrialOutput() 
            ventricularInput()
    %        if pace_param.a_pace ==1
    %        end      
            if ifAOutput == 1
                output_done = 1;
            end
            if sendVSignal == 1
                input_done = 1;
            end
            if input_done && output_done
                read_next
                ifBoundsPrinted = 0;
                input_done = 0;
                output_done = 0;
            end
        case V_OUTPUT_A_INPUT
            ventricularOutput()
            atrialInput()
            if ifVOutput == 1
                output_done = 1;
            end
            if sendASignal == 1
                input_done = 1;
            end
            if input_done && output_done
                read_next;
                ifBoundsPrinted = 0;
                output_done = 0;
                input_done = 0;
            end
        end

      
    
    %% Plot Pacemaker Sensing/Pacing
    if plotSignals
        %% plot bound lines
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
              %AVI  
              if ~strcmp(pace_param.AVI,'off')
                  %if timer just started, plot the expected timer time for
                  %AVI, ABP, and VSP (if on).
                 
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if strcmp(pace_param.AVI,'S')
                      AVI_cur = pace_param.sAVI_cur;
                      AVI_def = pace_param.sAVI_def;
                      AVI_DEF_COLOR = S_AVI_DEF_COLOR;
                  elseif strcmp(pace_param.AVI,'P')
                      AVI_cur = pace_param.pAVI_cur;
                      AVI_def = pace_param.pAVI_def;
                      AVI_DEF_COLOR = P_AVI_DEF_COLOR;
                  elseif strcmp(pace_param.AVI, 'R')
                      AVI_cur = pace_param.sAVI_cur;
                      AVI_def = pace_param.pAVI_def;
                      AVI_DEF_COLOR = R_AVI_DEF_COLOR;
                  end
                if AVI_cur == AVI_def
                    avi_switch = 1;
                    avi_init = t;
                    rectangle('Position',[t,AVI_LOWER_Y, AVI_def,1],'FaceColor',AVI_DEF_COLOR);
                    if strcmp(pace_param.AVI, 'P')
                        rectangle('Position',[t,AVI_LOWER_Y, pace_param.ABP,0.5],'FaceColor',BLOCK_COLOR);
                        if strcmp(pace_param.VSP_enabled, 'on')
                            rectangle('Position',[t,AVI_LOWER_Y+0.25, pace_param.VSP_sense,0.25],'FaceColor',VSP_COLOR);
                        end
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
                if pace_param.v_ref
                    rectangle('Position',[t,VRP_LOWER_Y, pace_param.VRP_def,1],'FaceColor',R_VRP_DEF_COLOR);
                    width = (t-1) - vrp_init;
                    if width > 0
                        rectangle('Position',[vrp_init,VRP_LOWER_Y+0.5,width,0.5],'FaceColor',VRP_CUR_COLOR);
                    end
                    vrp_switch = 1;
                    vrp_init = t;
                elseif pace_param.VRP_cur == pace_param.VRP_def ||pace_param.v_sense || pace_param.v_pace
                    if vrp_vsp_switch
                        width = (t-1) - vrp_init;
                        if width > 0
                             rectangle('Position',[vrp_init,VRP_LOWER_Y+0.5,width,0.5],'FaceColor',VRP_CUR_COLOR);
                        end
                    end
                    vrp_vsp_switch = 1;
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
                    vrp_vsp_switch = 0;
                    vrp_init = 0;
                end
              
              % PVARP
                if strcmp(pace_param.PVARP, 'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.PVARP_cur == pace_param.PVARP_extend_def-1 && pace_param.PVARP_def < pace_param.PVARP_extend_def 
                      if pvarp_pvc_switch
                        width = (t-1) - pvarp_init;
                            if width > 0
                                rectangle('Position',[pvarp_init,PVARP_LOWER_Y+0.5,width,0.5],'FaceColor',PVARP_CUR_COLOR);
                            end
                      end
                      rectangle('Position',[t-1,PVARP_LOWER_Y, pace_param.PVARP_extend_def,1],'FaceColor',PVARP_EXTEND_DEF_COLOR);
                      pvarp_init = t;
                      pvarp_switch = 1;      
                      pvarp_pvc_switch = 1;
                  elseif pace_param.PVARP_cur == pace_param.PVARP_def
                        if pvarp_pvc_switch ~=1
                            rectangle('Position',[t,PVARP_LOWER_Y, pace_param.PVARP_def,1],'FaceColor',PVARP_DEF_COLOR);
                            pvarp_init = t;
                            pvarp_switch = 1;
                        end          
                  elseif plotIteratively
                    rectangle('Position',[t-1,PVARP_LOWER_Y+0.5, 1,0.5],'FaceColor',PVARP_CUR_COLOR,'EdgeColor', PVARP_CUR_COLOR);
                  end
                end
              if strcmp(pace_param.PVARP,'off') && pvarp_switch==1
                width = (t-1) - pvarp_init;
                if width > 0
                    rectangle('Position',[pvarp_init,PVARP_LOWER_Y+0.5,width,0.5],'FaceColor',PVARP_CUR_COLOR);
                end
                pvarp_switch = 0;
                pvarp_pvc_switch = 0;
              end
              
              % LRI
                if plotSignals
                    subplot(2,1,2)
                end
                %if LRI was reset, or if a PVC was detected
                if pace_param.LRI_cur == pace_param.LRI_def-2  || (pace_param.PVARP_cur == pace_param.PVARP_extend_def-1 && pace_param.PVARP_def < pace_param.PVARP_extend_def)  %t== 0 %(pace_param.v_pace || pace_param.v_sense || t == 0) && (strcmp(pace_param.PVARP, 'off') || pace_param.LRI_cur == pace_param.LRI_def)   
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
                    if pace_param.LRI_cur == pace_param.LRI_def-2
                        rectangle('Position',[t-2,LRI_LOWER_Y + position, pace_param.LRI_def,0.5],'FaceColor',LRI_DEF_COLOR);
                    end
                    if pace_param.PVARP_cur == pace_param.PVARP_extend_def-1
                        AEI_period = pace_param.LRI_def - pace_param.pAVI_def;
                        rectangle('Position',[t-2,LRI_LOWER_Y + position,AEI_period,0.5],'FaceColor',AEI_DEF_COLOR);
                    end
                    width = (t-1) - lri_init; 
                    if width > 0
                        rectangle('Position',[lri_init, LRI_LOWER_Y + pos,width,0.25],'FaceColor', LRI_CUR_COLOR);
                    end
                    lri_init = t-2; 
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
                    uri_switch = 1; %flag to determine if URI became on.
                    %plot out the expected length of the timer
                    rectangle('Position',[t,URI_LOWER_Y, pace_param.URI_def,0.5],'FaceColor',URI_DEF_COLOR);
                    
                    %if previous URI ended prematurely, plot out the current timer
                    width = (t-1) - uri_init;
                    if width > 0 && uri_printed ~= 1
                        rectangle('Position',[uri_init,URI_LOWER_Y+0.5,width,0.5],'FaceColor',URI_CUR_COLOR);
                        %uri_switch = 0;
                        
                    end
                    uri_printed = 0;
                    uri_init = t;
                  elseif plotIteratively
                    rectangle('Position',[t-1,URI_LOWER_Y+0.5, 1,0.5],'FaceColor',URI_CUR_COLOR, 'EdgeColor', URI_CUR_COLOR);
                  end
              end
                %Plot the current timer 
                  if strcmp(pace_param.URI,'off') && uri_switch==1
                    width = (t-1) - uri_init;
                    if width > 0
                    rectangle('Position',[uri_init,URI_LOWER_Y+0.5,width,0.5],'FaceColor',URI_CUR_COLOR);
                    uri_switch = 0; 
                    end
                    uri_printed = 1; %checks to see if the current timer got printed
                  end
   end
%%    
    if plotIteratively
        if skipTo <= 0 || skipTo <= t
            pause(0.001);
        end
     %   pace_param.AF_interval
    end
        if sendASignal == 1
            pace_param = pacemaker_new(pace_param,1,0, pace_inter);
                if output == 0
                    %cprintf(NOTE_COLOR, [SENT_A_SIG, num2str(t), '\n'])
                    disp(strcat(SENT_A_SIG,num2str(t)));
                else
                    fprintf(fileId,[SENT_A_SIG,'%d\n'],t);
                end
            if pace_param.a_sense
                if seePaceSense
                    if output == 0
                        %cprintf(GOOD_COLOR, [DETECT_A_SIG, num2str(t), '\n'])
                        disp(strcat(DETECT_A_SIG,num2str(t)));
                    else
                        fprintf(fileId,[DETECT_A_SIG,'%d\n'],t);
                    end
                end
            else
                if seePaceSense
                    if output == 0
                        %cprintf(WARNING_COLOR, [NDETECT_A_SIG, num2str(t), '\n'])
                        disp(strcat(NDETECT_A_SIG,num2str(t)));
                        %warning([NDETECT_A_SIG, num2str(t)])
                    else
                        fprintf(fileId,[NDETECT_A_SIG,'%d\n'],t);
                    end
                end
            end
        elseif sendVSignal == 1
            pace_param = pacemaker_new(pace_param,0,1, pace_inter);
            if output == 0
                %cprintf(NOTE_COLOR, [SENT_V_SIG, num2str(t), '\n'])
                disp(strcat(SENT_V_SIG,num2str(t)));
            else
                fprintf(fileId,[SENT_V_SIG,'%d\n'],t);
            end
                if pace_param.v_sense
                    if seePaceSense
                        if output == 0
                            %cprintf(GOOD_COLOR, [DETECT_V_SIG, num2str(t), '\n'])
                            disp(strcat(DETECT_V_SIG,num2str(t)));
                        else
                            fprintf(fileId,[DETECT_V_SIG,'%d\n'],t);
                        end
                    end
                else
                    if seePaceSense
                        if output == 0
                            %cprintf(WARNING_COLOR, [NDETECT_V_SIG, num2str(t), '\n'])
                            disp(strcat(NDETECT_V_SIG,num2str(t)));
                            %warning([NDETECT_V_SIG, num2str(t)])
                        else
                            fprintf(fileId,[NDETECT_V_SIG,'%d\n'],t);
                        end
                    end
                end
        else
            pace_param = pacemaker_new(pace_param,0,0, pace_inter);
        end

        
        %break out of while loop once finished testing  
    if breakEarly        
        if t > (nextTime + offset)+ greatestTolerance + 300 && nextLine > length(sample_File)
            if plotSignals && plotTimers
                subplot(2,1,1)
                set(gca,'Ylim',[-4,4],'Xlim',[0,t]);
                subplot(2,1,2)
                set(gca,'Ylim',[-4,4],'Xlim',[0,t]);
            elseif plotSignals || plotTimers
                set(gca,'Ylim',[-4,4],'Xlim',[0,t]);
            end
            break;
 
        end   
    end        
%if error was found, exit the test
    if fileError
        break;
    end
        
end
if plotSignals || plotTimers
    set(gcf, 'PaperPositionMode', 'auto');
end

    testError = testError + fileError;
    if fileError
        testsInError = [testsInError,', ',name];
        fileError = 0;
    end
if output == 0
    disp(' ');
else
    fprintf(fileId,'\n');
end
end

if output == 0
    disp('Complete.');
else
    fprintf(fileId,'Results:\n');
    fprintf(fileId,'Total tests: %d\n', totalFiles);
    fprintf(fileId,'Total tests failed: %d\tpercentage: %d%%\n',testError,testError/totalFiles*100);
    fprintf(fileId,'Tests with errors: %s\n',testsInError);
    fprintf(fileId,'Total early ventricular signals: %d \t average per test: %d\n',total_V_early_errors,total_V_early_errors/totalFiles);
    fprintf(fileId,'Total early atrial signals: %d \t average per test: %d\n', total_A_early_errors, total_A_early_errors/totalFiles);
    fprintf(fileId,'Total late ventricular signals: %d \t average per test: %d\n', total_V_late_errors, total_V_late_errors/totalFiles);
    fprintf(fileId,'Total late atrial signals: %d \t average per test: %d\n', total_A_late_errors, total_A_late_errors/totalFiles);
    fprintf(fileId,'Total ventricular signals in error: %d \t average per test: %d\n', total_V_wrong_errors, total_V_wrong_errors/totalFiles);
    fprintf(fileId,'Total atrial signals in error: %d \t average per test: %d\n', total_A_wrong_errors, total_A_wrong_errors/totalFiles);
    fclose(fileId);

end
%% functions

    function ventricularOutput()
         ifVOutput = 0;
            if nextLine == 1
                correctTime = nextTime;
                writeReport(output,V_ON,correctTime,1)
                pace_param.v_pace = 1;
                ifVOutput = 1;
            else
                if allowOffsets
                    v_lowBound = (nextTime+offset)-tolerance_ventrical;
                    v_highBound = (nextTime+offset)+tolerance_ventrical;
                else
                    v_lowBound = (nextTime)-tolerance_ventrical;
                    v_highBound = (nextTime)+tolerance_ventrical;
                end
                if t < v_lowBound
                    if pace_param.a_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,A_LATE,correctTime,0)
                        
                        %errors
                        total_A_late_errors = total_A_late_errors + 1; 
                        fileError = 1;
                    end
                    if pace_param.v_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,V_EARLY,correctTime,0)
                        offset = offset + (t-nextTime);
                        ifVOutput = 1;
                        
                        %errors
                        total_V_early_errors = total_V_early_errors + 1;
                        fileError = 1;
                    end
                elseif t >= v_lowBound && t <= v_highBound
                    if pace_param.v_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,V_ON,correctTime,1)
                        offset = offset + (t-nextTime);
                        ifVOutput = 1;
                    end
                    if pace_param.a_pace == 1
                        if nextNextEvent == ATRIAL_OUTPUT
                            correctTime = getCorrectTime(allowOffsets,offset,nextNextTime);
                            writeReport(output,A_EARLY,correctTime,0)
                            %count errors
                            total_A_early_errors = total_A_early_errors + 1;
                            fileError = 1;
                        else
                            correctTime = NaN;
                            writeReport(output,A_WRONG,correctTime,0)
                            %count errors
                            total_A_wrong_errors = total_A_wrong_errors + 1;
                            fileError = 1;
                        end
                    end
                elseif t > v_highBound
                    if pace_param.v_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,V_LATE,correctTime,0)
                        offset = offset + (t-nextTime);
                        ifVOutput = 1;
                        %errors
                        total_V_late_errors = total_V_late_errors + 1;
                        fileError = 1;
                    end
                    if pace_param.a_pace == 1
                        if nextNextEvent == ATRIAL_OUTPUT
                            correctTime = getCorrectTime(allowOffsets,offset,nextNextTime);
                            writeReport(output,A_EARLY,correctTime,0)
                            %errors
                            total_A_early_errors = total_A_early_errors +1;
                            fileError = 1;
                        else
                            correctTime = NaN;
                            writeReport(output,A_WRONG,correctTime,0)
                            %errors
                            total_A_wrong_errors = total_A_wrong_errors + 1;
                            fileError = 1;
                        end
                    end
                end
            end
    end
    function atrialOutput()
           ifAOutput = 0;
            if nextLine == 1 %if first line in test
                correctTime = nextTime;
                writeReport(output,A_ON,correctTime)
                pace_param.a_pace = 1;
                ifAOutput = 1;
            else
                if allowOffsets
                    a_lowBound = (nextTime+offset)-tolerance_atrial;
                    a_highBound = (nextTime+offset)+tolerance_atrial;
                else
                    a_lowBound = (nextTime)-tolerance_atrial;
                    a_highBound = (nextTime)+tolerance_atrial;
                end
                if t < a_lowBound
                    if pace_param.a_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,A_EARLY,correctTime,0)
                        offset = offset + (t-nextTime);
                        ifAOutput = 1;
                        %errors
                        total_A_early_errors = total_A_early_errors + 1;
                        fileError = 1;
                    end
                    if pace_param.v_pace == 1
                        if nextNextEvent == VENTRICAL_OUTPUT
                            correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                            writeReport(output,V_EARLY,correctTime,0)
                            %errors
                            total_V_early_errors = total_V_early_errors + 1;
                            fileError = 1;
                        else
                            correctTime = NaN;
                            writeReport(output,V_WRONG,correctTime,0)
                            %errors
                            total_V_wrong_errors = total_V_wrong_errors + 1;
                            fileError = 1;
                        end
                    end
                elseif t >= a_lowBound && t <= a_highBound
                    if pace_param.a_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,A_ON,correctTime,1)
                        offset = offset + (t-nextTime);
                        ifAOutput = 1;
                    end
                    if pace_param.v_pace == 1
                        if nextNextEvent == VENTRICAL_OUTPUT
                            correctTime = getCorrectTime(allowOffsets,offset,nextNextTime);
                            writeReport(output,V_EARLY,correctTime,0)
                            %errors
                            total_V_early_errors = total_V_early_errors + 1;
                            fileError = 1;
                        else
                            correctTime = NaN;
                            writeReport(output,V_WRONG,correctTime,0)
                            %errors
                            total_V_wrong_errors = total_V_wrong_errors + 1;
                            fileError = 1;
                        end
                    end
                elseif t > a_highBound
                    if pace_param.a_pace == 1
                        correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                        writeReport(output,A_LATE,correctTime,0)
                        offset = offset + (t-nextTime);
                        ifAOutput = 1;
                        %errors
                        total_A_late_errors = total_A_late_errors + 1;
                        fileError = 1;
                    end
                    if pace_param.v_pace == 1
                        if nextNextEvent == VENTRICAL_OUTPUT
                            correctTime = getCorrectTime(allowOffsets,offset,nextNextTime);
                            writeReport(output,V_EARLY,correctTime,0)
                            %errors
                            total_V_early_errors = total_V_early_errors + 1;
                            fileError = 1;
                        else
                            correctTime = NaN;
                            writeReport(output,V_WRONG,correctTime,0)
                            %errors
                            total_V_wrong_errors = total_V_wrong_errors + 1;
                            fileError = 1;
                        end
                    end
                end
            end
    end
    
    function atrialInput()
        if t == (nextTime + offset)
            sendASignal = 1;
        end
    end

    function ventricularInput()
        if t == (nextTime + offset)
                sendVSignal = 1;
        end
    end

    function read_next()
    [nextLine, nextTime, nextEvent,...
        nextNextTime,nextNextEvent, sample_File] = increment(nextLine, nextTime, nextEvent,...
        nextNextTime,nextNextEvent, sample_File);       
    end

    function [nxtLine, nxtTime, nxtEvent, nNTime,nNEvent, smp_File] = increment(nxtLine, nxtTime, nxtEvent, nNTime,nNEvent, smp_File)
    %increment Summary of this function goes here
    %   Detailed explanation goes here
        nxtLine = nxtLine + 1;
        if nxtLine <= length(smp_File)
            nxtTime = smp_File(nxtLine,1);
            nxtEvent = smp_File(nxtLine,2);
        else
            nxtEvent = 0;
        end
    
        if nxtLine < length(smp_File)
            nNTime = smp_File(nxtLine+1,1);
            nNEvent = smp_File(nxtLine+1,2);
        else
            nNTime = 0;
            nNEvent = 0;    
        end

    end
    function writeReport(output,sentence,correctTime,good)
        if good
            if output == 0
                disp([sentence, num2str(t), '. (Expected at t=', num2str(correctTime),')']);
            else
                fprintf(fileId,[sentence,'%d. (Expected at t=%d)\n'],t,correctTime);
            end
        else
            if output == 0
                fprintf(2, [sentence, num2str(t),'. (Expected at t=',num2str(correctTime), ')\n'])
            else
                fprintf(fileId,[sentence,'%d. (Expected at t=%d)\n'],t,correctTime);
            end
        end
    end
    function correctTime = getCorrectTime(allowOffsets,offset,time)
         if allowOffsets
             correctTime = time + offset;
         else
             correctTime = time;
         end
         
    end
end

