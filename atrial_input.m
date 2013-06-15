% Outputs an atrial signal. DO NOT RUN THIS SCRIPT. 
if t == (nextTime + offset)
    sendASignal = 1;
    %{
    pace_param = pacemaker_new(pace_param,1,0, pace_inter, vsp_mode);
    disp(strcat(SENT_A_SIG,num2str(t)));
    if pace_param.a_sense
        disp(strcat(DETECT_A_SIG,num2str(t)));
    else
        disp(strcat(NDETECT_A_SIG,num2str(t)));
    end
    %}
end