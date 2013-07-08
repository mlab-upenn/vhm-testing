%% Main simple_tester
load edge_cov
load PM_new
 
 t=0;
 a_in=0;
 v_in=0;
 tolerance_atrial = 5;
 tolerance_ventrical = 5;
 allowOffsets = 1;
 while t<=test(end,1)+100 %continue looping until end of file
     t=t+1;
     [a_out,v_out,pass]=simple_tester(test,a_in,v_in,t,tolerance_atrial,tolerance_ventrical,allowOffsets);
   
     [a_out,v_out,t]
     pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
     a_in=pace_param.a_pace;
     v_in=pace_param.v_pace;
     
     if pass==0
         disp('Test Fail');
         break;
     end
     
 end