function [ output_args ] = simplePacemaker_tester(filename,pacemaker_param,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%pacemaker_tester takes in:
%   filename, a char array of the name of a file that contains the test 
%       data, or a matrix with test data, or a cell array containing multiples of either.
%   pacemaker_param, a structure defining pacemaker parameters.
%   and additional arguments.
%
%
%varagin
%   'tolerances' defines the allowable error in ms to be considered on time
%       parameter is a matrix or cell array defining the accepted tolerance 
%       for atrial timing and ventrial timing.
%       i.e. [10,8] or {10,8} allows for 10 ms for atrial tolerance and 8 ms for
%       ventricular tolerance. Default is no tolerances ([0,0]).
%   'allowOffset' defines if an offset will be applied if a signal is not
%       on time.
%       parameter is either 'yes' or 1 to enable. i.e. 'allowOffset,'yes')
%       will allow offsets. Default is off.
%   'stepSize' defines the step in ms per each iteration in the test.
%       parameter is a double or char defining the stepsize. i.e
%       'stepSize',.1) will set the step to 0.1 ms. Default is 1 ms.
%   'output' defines where the report should be output to. Parameter is
%       either 'display' if the results are printed on the matlab command
%       prompt, or a filename (i.e. 'report.txt') where the report will be
%       printed to.
%
%{
close all;
clear;
clc;
%}
%% Decide use
pace_inter=1; %default stepsize
total_time = 3000;%ms %define how long you want to run the test.
tolerance_atrial = 0; %Acceptable tolerance (in ms) for detecting atrial output signals
tolerance_ventrical = 0; %Acceptable tolerance for detecting ventricular output signals.
greatestTolerance = max([tolerance_atrial, tolerance_ventrical]);
output = 0; %0 if output to display, 1 if printing to file.
multiple = 0; %0 if multiple files for testings, 1 if not
breakEarly = 1;
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
            if strcmpi(argument,'runTo')
                parameter = varargin{i+1};
                total_time = parameter;
                breakEarly = 0;
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
    ifAOutput = 0;
    ifVOutput = 0;
    input_done = 0;
    output_done = 0;
    
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
    A_WRONG = 'ERROR: Pacemaker incorrectly paced atrium at t=';
    A_SKIP = 'ERROR: Pacemaker did not pace atrium at t=';
    
    V_EARLY = 'ERROR: Pacemaker paced ventricle early at t=';
    V_ON = 'Pacemaker paced ventricle On Time at t=';
    V_LATE = 'ERROR: Pacemaker paced ventricle late at t=';
    V_WRONG = 'ERROR: Pacemaker incorrectly paced ventricle at t=';
    V_SKIP = 'ERROR: Pacemaker did not pace ventricle at t=';
    
%Global Variables
    nextLine = 0; %variable to determine which line in the file is being processed
    offset = 0; %variable to store any necessary offsets
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
            atrialInput();
            if sendASignal == 1;
                read_next(); %see script/ or see function increment
            end
% Ventrical Input            
        case VENTRICAL_INPUT
            ventricularInput();
            if sendVSignal == 1;
                read_next(); %see script/ or see function increment
            end
% Atrial Output           
        case ATRIAL_OUTPUT
            %case for atrial output. 
            atrialOutput();
            if ifAOutput == 1 
                read_next(); %see script/ or see function increment
            end
% VENTRICAL Output
        case VENTRICAL_OUTPUT
            ventricularOutput();
            if ifVOutput == 1
                read_next(); %see script/ or see function increment
            end
% TODO: Deal with these cases          
        case A_OUTPUT_V_INPUT
            atrialOutput() 
            ventricularInput()   
            if ifAOutput == 1
                output_done = 1;
            end
            if sendVSignal == 1
                input_done = 1;
            end
            if input_done && output_done
                read_next()
                input_done = 0;
                output_done = 0;
            end
        case V_OUTPUT_A_INPUT
            ventricularOutput();
            atrialInput();
            if ifVOutput == 1
                output_done = 1;
            end
            if sendASignal == 1
                input_done = 1;
            end
            if input_done && output_done
                read_next();
                output_done = 0;
                input_done = 0;
            end
        end

%%    
        if sendASignal == 1
            pace_param = pacemaker_new(pace_param,1,0, pace_inter);
                if output == 0
                    disp(strcat(SENT_A_SIG,num2str(t)));
                else
                    fprintf(fileId,[SENT_A_SIG,'%d\n'],t);
                end
            if pace_param.a_sense
                if output == 0
                    disp(strcat(DETECT_A_SIG,num2str(t)));
                else
                    fprintf(fileId,[DETECT_A_SIG,'%d\n'],t);
                end
            else
                if output == 0
                    disp(strcat(NDETECT_A_SIG,num2str(t)));
                else
                    fprintf(fileId,[NDETECT_A_SIG,'%d\n'],t);
                end
            end
        elseif sendVSignal == 1  
            pace_param = pacemaker_new(pace_param,0,1, pace_inter);
            if output == 0 
                disp(strcat(SENT_V_SIG,num2str(t)));
            else
                fprintf(fileId,[SENT_V_SIG,'%d\n'],t);
            end
                if pace_param.v_sense
                    if output == 0
                        disp(strcat(DETECT_V_SIG,num2str(t)));
                    else
                        fprintf(fileId,[DETECT_V_SIG,'%d\n'],t);
                    end
                else
                    if output == 0
                        disp(strcat(NDETECT_V_SIG,num2str(t)));
                    else
                        fprintf(fileId,[NDETECT_V_SIG,'%d\n'],t);
                    end
                end
        else
            pace_param = pacemaker_new(pace_param,0,0, pace_inter);
        end
           %break out of while loop once finished testing  
           
    if breakEarly        
        if t > (nextTime + offset)+ greatestTolerance + 300 && nextLine > length(sample_File)
            break;
        end   
    end
    %if error was found, exit the test
    if fileError
        break;
    end
       
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
                        writeReport(output,A_WRONG,correctTime,0)
                        
                        %errors
                        total_A_wrong_errors = total_A_wrong_errors + 1; 
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
                        if nextNextEvent == ATRIAL_OUTPUT && t>=v_lowBound
                            correctTime = getCorrectTime(allowOffsets,offset,nextNextTime);
                            writeReport(output,A_EARLY,correctTime,0)
                            
                            read_next();
                            offset = offset + (t-nextTime);
                            read_next();
                            
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
                            v_lowBound = (nextTime+offset)-tolerance_ventrical;
                            if nextNextTime >= v_lowBound
                                %skipped the atrial pace
                                correctTime = getCorrectTime(allowOffsets,offset,nextTime);
                                writeReport(output,A_SKIP,correctTime,0)
                                offset = offset + (t-nextNextTime);
                                read_next(); %skip reading the ventricular pace.
                                ifAOutput = 1;
                            else
                                %sent ventrical pace too early
                                correctTime = getCorrectTime(allowOffsets,offset,nextNextTime);
                                writeReport(output,V_EARLY,correctTime,0)
                            %errors
                            end
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
        %check instances where there is incorrect pacing
        if pace_param.v_pace == 1
            if nextNextEvent == VENTRICAL_OUTPUT
                v_lowBound = (nextTime+offset)-tolerance_ventrical;
                if nextNextTime >= v_lowBound
                    
                end
            else
                correctTime = NaN;
                writeReport(output,V_WRONG,correctTime,0)
                %errors
                total_V_wrong_errors = total_V_wrong_errors + 1;
                fileError = 1;
            end
        end
        if pace_param.a_pace == 1
            if nextNextEvent == ATRIAL_OUTPUT
                a_lowBound = (nextTime+offset)-tolerance_atrial;
                if nextNextTime >= a_lowBound
                end
            else
                correctTime = NaN;
                writeReport(output,A_WRONG,correctTime,0)
                %errors
                total_A_wrong_errors = total_A_wrong_errors + 1;
                fileError = 1;
            end
        end
        %deliver the sense when the time is right
        if t == (nextTime + offset)
            sendASignal = 1;
        end
    end

    function ventricularInput()
        %check instances where there is incorrect pacing
        if pace_param.v_pace == 1
            if nextNextEvent == VENTRICAL_OUTPUT
                v_lowBound = (nextTime+offset)-tolerance_ventrical;
                if nextNextTime >= v_lowBound
                    
                end
            else
                correctTime = NaN;
                writeReport(output,V_WRONG,correctTime,0)
                %errors
                total_V_wrong_errors = total_V_wrong_errors + 1;
                fileError = 1;
            end
        end
        if pace_param.a_pace == 1
            if nextNextEvent == ATRIAL_OUTPUT
                a_lowBound = (nextTime+offset)-tolerance_atrial;
                if nextNextTime >= a_lowBound
                end
            else
                correctTime = NaN;
                writeReport(output,A_WRONG,correctTime,0)
                %errors
                total_A_wrong_errors = total_A_wrong_errors + 1;
                fileError = 1;
            end
        end
        %deliver the sense when the time is right
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



