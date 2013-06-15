%ventricular_output. DO NOT RUN THIS SCRIPT.
ifVOutput = 0;
if nextLine == 1
    %cprintf(GOOD_COLOR, [V_ON, num2str(t), '\n'])
    disp(strcat(V_ON,num2str(t)));
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
            %cprintf(ERROR_COLOR, [A_LATE, num2str(t), '\n'])
            fprintf(2, [A_LATE, num2str(t), '\n'])
            if sendText
                    message = [message num2str(index(i))];
            end
            %disp(strcat(A_LATE,num2str(t)));
        end
        if pace_param.v_pace == 1
            %cprintf(ERROR_COLOR, [V_EARLY, num2str(t), '\n'])
            fprintf(2, [V_EARLY, num2str(t), '\n'])
            if sendText
                    message = [message num2str(index(i))];
            end
            %disp(strcat(V_EARLY,num2str(t)));
            offset = offset + (t-nextTime);
            ifVOutput = 1;
            
        end
    elseif t >= v_lowBound && t <= v_highBound
        if pace_param.v_pace == 1
            offset = offset + (t-nextTime);
            %cprintf(GOOD_COLOR, [V_ON, num2str(t), '\n'])
            disp(strcat(V_ON,num2str(t)));
            ifVOutput = 1;
        end
        if pace_param.a_pace == 1
            if nextNextEvent == ATRIAL_OUTPUT
                %cprintf(ERROR_COLOR, [A_EARLY, num2str(t), '\n'])
                fprintf(2, [A_EARLY, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(A_EARLY,num2str(t)));
            else
                %cprintf(ERROR_COLOR, [A_WRONG, num2str(t), '\n'])
                fprintf(2, [A_WRONG, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(A_WRONG,num2str(t)));
            end
        end
    elseif t > v_highBound
        if pace_param.v_pace == 1
            offset = offset + (t-nextTime);
            %cprintf(ERROR_COLOR, [V_LATE, num2str(t), '\n'])
            fprintf(2, [V_LATE, num2str(t), '\n'])
            if sendText
                    message = [message num2str(index(i))];
            end
            %disp(strcat(V_LATE,num2str(t)));
            ifVOutput = 1;
        end
        if pace_param.a_pace == 1
            if nextNextEvent == ATRIAL_OUTPUT
                %cprintf(ERROR_COLOR, [A_EARLY, num2str(t), '\n'])
                fprintf(2, [A_EARLY, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(A_EARLY,num2str(t)));
            else
                %cprintf(ERROR_COLOR, [A_WRONG, num2str(t), '\n'])
                fprintf(2, [A_WRONG, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(A_WRONG,num2str(t)));
            end
        end
    end
end