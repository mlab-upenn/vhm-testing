function [pace_param] = resetPacemaker(pace_param)
%resetPacemaker Summary of this function goes here
%   Resets the pacemaker model back to initial state.
pace_param.LRI_cur = pace_param.LRI_def;
pace_param.AVI_cur = pace_param.AVI_def;
pace_param.AVI = 'off';
pace_param.a_pace = 0;
pace_param.v_pace = 0;
pace_param.a_sense = 0;
pace_param.v_sense = 0;
pace_param.PVARP = 'off';
pace_param.VRP = 'off';
pace_param.URI = 'off';
pace_param.AF_count = pace_param.AF_limit;
pace_param.PVARP_cur = pace_param.PVARP_def;
pace_param.VRP_cur = pace_param.VRP_def;
pace_param.URI_cur = pace_param.URI_def;
pace_param.a_ref = 0;
pace_param.AF_interval = 0;
pace_param.VSP = 'off'
pace_param.v_ref = 0;
end

