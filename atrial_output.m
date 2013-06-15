%case for atrial output. DO NOT RUN THIS SCRIPT. RUN new_Main_with_timer
%instead.
ifAOutput = 0;
if nextLine == 1
    %cprintf(GOOD_COLOR, [A_ON, num2str(t), '\n'])
    disp(strcat(A_ON,num2str(t)));
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
            %cprintf(ERROR_COLOR, [A_EARLY, num2str(t), '\n'])
            fprintf(2, [A_EARLY, num2str(t), '\n'])
            if sendText
                message = [message num2str(index(i))];
            end
            %disp(strcat(A_EARLY,num2str(t)));
            offset = offset + (t-nextTime);
            ifAOutput = 1;
        end
        if pace_param.v_pace == 1
            if nextNextEvent == VENTRICAL_OUTPUT
                %cprintf(ERROR_COLOR, [V_EARLY, num2str(t), '\n'])
                fprintf(2, [V_EARLY, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(V_EARLY,num2str(t)));
            else
                %cprintf(ERROR_COLOR, [V_WRONG, num2str(t), '\n'])
                fprintf(2, [V_WRONG, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(V_WRONG,num2str(t)));
            end
        end
    elseif t >= a_lowBound && t <= a_highBound
        if pace_param.a_pace == 1
            offset = offset + (t-nextTime);
            %cprintf(GOOD_COLOR, [A_ON, num2str(t), '\n'])
            disp(strcat(A_ON,num2str(t)));
            ifAOutput = 1;
        end
        if pace_param.v_pace == 1
            if nextNextEvent == VENTRICAL_OUTPUT
                %cprintf(ERROR_COLOR, [V_EARLY, num2str(t), '\n'])
                fprintf(2, [V_EARLY, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(V_EARLY,num2str(t)));
            else
                %cprintf(ERROR_COLOR, [V_WRONG, num2str(t), '\n'])
                fprintf(2, [V_WRONG, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(V_WRONG,num2str(t)));
            end
        end
    elseif t > a_highBound
        if pace_param.a_pace == 1
            offset = offset + (t-nextTime);
            %cprintf(ERROR_COLOR, [A_LATE, num2str(t), '\n'])
            fprintf(2, [A_LATE, num2str(t), '\n'])
            if sendText
                    message = [message num2str(index(i))];
            end
            %disp(strcat(A_LATE,num2str(t)));
            ifAOutput = 1;
        end
        if pace_param.v_pace == 1
            if nextNextEvent == VENTRICAL_OUTPUT
                %cprintf(ERROR_COLOR, [V_EARLY, num2str(t), '\n'])
                fprintf(2, [V_EARLY, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(V_EARLY,num2str(t)));
            else
                %cprintf(ERROR_COLOR, [V_WRONG, num2str(t), '\n'])
                fprintf(2, [V_WRONG, num2str(t), '\n'])
                if sendText
                    message = [message num2str(index(i))];
                end
                %disp(strcat(V_WRONG,num2str(t)));
            end
        end
    end
end