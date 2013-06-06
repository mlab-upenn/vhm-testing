
load pace_param
pace_inter=1;
A_get=0;
V_get=0;

i=0;
total_time = 5000;%ms
gdata=zeros(1,total_time);
%% Signal occurences
ASign = [200 400]; %times when an atrial signal occurs
VSign = [500 900]; %times when a venticular signal occurs
%%
figure;
hold;
subplot(2,1,1);
title('Pacemaker Operation');
ylabel('pacemaker');
xlabel('time (milliseconds)');
set(gca,'Ylim',[-4,4],'Xlim',[0,total_time]);

subplot(2,1,2);
set(gca,'Ylim',[-4,4],'Xlim',[0,total_time]);
ylabel('timers');
xlabel('time (milliseconds)');


while i< total_time
    i=i+1;
    data=0;
    name = '';
    faceColor = 'k';
    %%Plot Pacemaker Sensing/Pacing
    if ismember(i,ASign)
        pace_param=pacemaker_new(pace_param, 1, V_get, 1);
        startArrow = [i,0];
        endArrow = [i,0.5];
        subplot(2,1,1),
        arrow(startArrow,endArrow,'EdgeColor','k','FaceColor','y');
        text(i,0.5,'A Signal','Fontsize', 9);
    elseif ismember(i,VSign)
        pace_param=pacemaker_new(pace_param, A_get, 1, 1);
        startArrow = [i,0];
        endArrow = [i,-0.5];
        subplot(2,1,1),
        arrow(startArrow,endArrow,'EdgeColor','k','FaceColor','w');
        text(i,-0.5,'V Signal','Fontsize', 9);
    else
        pace_param=pacemaker_new(pace_param, A_get, V_get, 1);
    end
            % a_pace
              if pace_param.a_pace
                  data=3;
                  name = 'AP';
                  faceColor = 'r';
              end
              % v_pace
              if pace_param.v_pace               
                  data=-3;
                  name = 'VP';
                  faceColor = 'm';
              end
              % a_sense
              if pace_param.a_sense
                  data=2;
                  name = 'AS';
                  faceColor = 'b';
              end
              % v_sense
              if pace_param.v_sense
                  data=-2;
                  name = 'VS';
                  faceColor = 'c';
              end
              if pace_param.a_ref
                  data=1;
                  name = '[AR]';
                  faceColor = 'g';
              end
              
              if(data ~= 0)
                  startArrow = [i,0];
                  endArrow = [i,data];
                  subplot(2,1,1),
                  arrow(startArrow,endArrow,'EdgeColor','k','FaceColor',faceColor);
                  text(i,data,name,'Fontsize', 10);
              else
                  subplot(2,1,1),
                  xVal = [i-1,i]; 
                  yVal = [0,0];
                  line(xVal, yVal, 'Color', 'k');
              end
   %% Plot Timer States
   %Constant values
   AVI_UPPER_Y = 4;
   AVI_LOWER_Y = 3;
   AVI_DEF_COLOR = [1 90/255 0];
   AVI_CUR_COLOR = 'red';
   
   VRP_UPPER_Y = 3;
   VRP_LOWER_Y =2;
   VRP_DEF_COLOR = [1 0 1];
   VRP_CUR_COLOR = [76/255 0 153/255];
   
   PVARP_UPPER_Y =2;
   PVARP_LOWER_Y =1;
   PVARP_DEF_COLOR = 'c';
   PVARP_CUR_COLOR = 'blue';
   
   LRI_UPPER_Y = 1;
   LRI_LOWER_Y = 0;
   LRI_DEF_COLOR = [0 128/255 128/255];
   LRI_CUR_COLOR = 'g';
   
   URI_UPPER_Y = 0;
   URI_LOWER_Y = -1;
   URI_DEF_COLOR = [207/255 181/255 59/255];
   URI_CUR_COLOR = 'y';
   
   BLOCK_COLOR = 'k';
   VSP_COLOR = 'w';
              %AVI  
              if ~strcmp(pace_param.AVI,'off')
                  %if timer just started, plot the expected timer time for
                  %AVI, ABP, and VSP (if on).
                  subplot(2,1,2)
                if pace_param.AVI_cur == pace_param.AVI_def
                    rectangle('Position',[i,AVI_LOWER_Y, pace_param.AVI_def,1],'FaceColor',AVI_DEF_COLOR);
                    rectangle('Position',[i,AVI_LOWER_Y, pace_param.ABP,0.5],'FaceColor',BLOCK_COLOR);
                    if strcmp(pace_param.VSP,'on')
                        rectangle('Position',[(i+pace_param.ABP),AVI_LOWER_Y, pace_param.VSP_sense,0.5],'FaceColor','w');
                    end
                %else color the current timer state.    
                else
                    rectangle('Position',[i-1,AVI_LOWER_Y+0.5, 1,0.5],'FaceColor',AVI_CUR_COLOR,'EdgeColor', AVI_CUR_COLOR);
                end
                
              end
              %VRP
              if strcmp(pace_param.VRP, 'on')
                subplot(2,1,2)
                if pace_param.VRP_cur == pace_param.VRP_def ||pace_param.v_sense == 1 || pace_param.v_pace == 1
                    rectangle('Position',[i,VRP_LOWER_Y, pace_param.VRP_def,1],'FaceColor',VRP_DEF_COLOR);
                else
                    rectangle('Position',[i-1,VRP_LOWER_Y+0.5, 1,0.5],'FaceColor',VRP_CUR_COLOR,'EdgeColor', VRP_CUR_COLOR);
                end
              end
              % PVARP
              if strcmp(pace_param.PVARP, 'on')
                  subplot(2,1,2)
                  if pace_param.PVARP_cur == pace_param.PVARP_def
                    rectangle('Position',[i,PVARP_LOWER_Y, pace_param.PVARP_def,1],'FaceColor',PVARP_DEF_COLOR);
                  else
                    rectangle('Position',[i-1,PVARP_LOWER_Y+0.5, 1,0.5],'FaceColor',PVARP_CUR_COLOR,'EdgeColor', PVARP_CUR_COLOR);
                  end
              end
              % LRI 
                  subplot(2,1,2)
                  if pace_param.LRI_cur == pace_param.LRI_def || pace_param.v_pace || pace_param.v_sense
                      if lri_switch == 0
                          lri_switch = 1;
                      else 
                          lri_switch = 0;
                      end 
                    if lri_switch 
                        position = 0.5;
                    else
                        position = 0;
                    end
                    rectangle('Position',[i,LRI_LOWER_Y + position, pace_param.LRI_def,0.5],'FaceColor',LRI_DEF_COLOR);
                  else
                    if lri_switch
                       pos = 0.5;
                    else
                       pos = 0;
                    end
                    rectangle('Position',[i-1,LRI_LOWER_Y+pos, 1,0.25],'FaceColor',LRI_CUR_COLOR, 'EdgeColor', LRI_CUR_COLOR);  
                  end
                  
              % URI
              if strcmp(pace_param.URI,'on')
                  subplot(2,1,2)
                  if pace_param.URI_cur == pace_param.URI_def
                    rectangle('Position',[i,URI_LOWER_Y, pace_param.URI_def,1],'FaceColor',URI_DEF_COLOR);
                  else
                    rectangle('Position',[i-1,URI_LOWER_Y+0.5, 1,0.5],'FaceColor',URI_CUR_COLOR, 'EdgeColor', URI_CUR_COLOR);
                  end
              end
 %% Store Data             
              gdata(i) = data;
              
            
end
