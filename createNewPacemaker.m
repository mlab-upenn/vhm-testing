clear;
new_pace.mode_switch = 'on';
new_pace.mode = 'DDD';
%TODO: take these different modes into account
%{
new_pace.lower_rate_timing_mode = 'A' %'V'
new_pace_upper_rate_resp_mode = 'Wenckebach' %'Fixed-ratio Block'
%}
new_pace.LRI_cur = 1000;
new_pace.LRI_def = 1000;
new_pace.LRI_extend_avi = 'off';

new_pace.URI_cur = 600;
new_pace.URI_def = 600;
new_pace.URI = 'off';

new_pace.pAVI_cur = 250;
new_pace.pAVI_def = 250;
new_pace.sAVI_cur = 250;
new_pace.sAVI_def = 250;
new_pace.AVI = 'off';

new_pace.AEI_cur = 750;
new_pace.AEI_def = 750;
new_pace.AEI = 'off'

new_pace.ABP = 30;

new_pace.VSP_sense = 110;
new_pace.VSP = 'off';

new_pace.VRP_cur = 150;
new_pace.VRP_def = 150;
new_pace.VRP = 'off';

new_pace.PVARP_cur = 300;
new_pace.PVARP_def = 300;
new_pace.PVARP = 'off';

new_pace.PAVB = 0;

new_pace.PVC = 0;

new_pace.AF_interval = 0;
new_pace.AF_thresh = 500;
new_pace.AF_count = 5;
new_pace.AF_limit = 5;



new_pace.a_pace = 0;
new_pace.v_pace = 0;
new_pace.a_sense = 0;
new_pace.v_sense = 0;
new_pace.a_ref = 0;
new_pace.v_ref = 0;

new_pace