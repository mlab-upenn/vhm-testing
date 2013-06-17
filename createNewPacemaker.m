clear;
new_pace.mode_switch = 'on';
new_pace.mode = 'DDD';
%TODO: take these different modes into account

new_pace.lower_rate_timing_mode = 'A'; %'V'
new_pace.lower_rate_PVC_response = 'AEI'; %'LRI'
new_pace.upper_rate_resp_mode = 'Wenckebach'; %'Fixed-ratio Block'
new_pace.PVC_extend_PVARP = 'on'; %'off'
new_pace.PVARP_extend_def = 400;
new_pace.VSP_enabled ='on'; %'off'

new_pace.LRI_cur = 1000;
new_pace.LRI_def = 1000;
%new_pace.LRI_extend_avi = 'off';

new_pace.URI_cur = 600;
new_pace.URI_def = 600;
new_pace.URI = 'off';
%atrial timers after atrial stimulus
new_pace.pAVI_cur = 250; %unblanked region can detect atrial signals, but cannot reset LRI or AVI
new_pace.pAVI_def = 250;
new_pace.sAVI_cur = 250;
new_pace.sAVI_def = 250;
new_pace.AVI = 'off';
new_pace.ABP = 30; %blocks all signals detected by atrial probe in AVI
%ventricular timers after atrial stimulus
new_pace.PAVB = 30; %blocks ventricular signals in AVI
new_pace.VSP_sense = 110;
new_pace.VSP = 'off';
%{
new_pace.AEI_cur = 750;
new_pace.AEI_def = 750;
new_pace.AEI = 'off'
%}

%ventricular timers after ventricular stimulus (pg 168)
new_pace.VRP_cur = 300;%can detect signals after VBP, but does not restart LRI
new_pace.VRP_def = 300;
new_pace.VRP = 'off';
new_pace.VBP = 0; %blocks all signals in VRP
%atrial timers after ventricle stimulus
new_pace.PVARP_cur = 300; %avoids atrial sensing of ventricular events
new_pace.PVARP_def = 300;
new_pace.PVARP = 'off';
new_pace.PVAB = 0; %blocks atrial signals in PVARP. When not blocked, PVARP can sense AS but cannot restart AVI or LRI
%new_pace.PVC = 0;

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