% Outputs a ventricular signal. DO NOT RUN THIS SCRIPT.
if t == (nextTime + offset)
    outSignal = 1;
    pace_param = pacemaker_new(pace_param,0,1, pace_inter, vsp_mode);
    disp(strcat(SENT_V_SIG,num2str(t)));
    if pace_param.v_sense
        disp(strcat(DETECT_V_SIG,num2str(t)));
    else
        disp(strcat(NDETECT_V_SIG,num2str(t)));
    end
end