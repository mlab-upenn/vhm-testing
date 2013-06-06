clear;
%% Decide what to plot
plotSignals = 1;
plotTimers = 1;
plotIteratively = 0;
%%
avi_switch = 0;
vrp_switch = 0;
pvarp_switch = 0;
lri_switch = 0;
lri_flip = 0;
uri_switch = 0;

avi_init = 0;
vrp_init = 0;
pvarp_init = 0;
lri_init = 0;
uri_init = 0;
%%
load medtronic_params
pace_param.mode_switch = 'on';
pace_inter=1;
A_get=0;
V_get=0;

i=-1;
lri_switch = 0;
total_time = 3000;%ms
gdata=zeros(1,total_time);
%% Signal occurences
ASign = [0 300]; %times when an atrial signal occurs
VSign = [250]; %times when a venticular signal occurs
AOutput = [1000]
VOutput = [1250]
%% PreDraw Graphs
figure;
hold;
if plotSignals
    if plotTimers 
        subplot(2,1,1)
    end
    title('Pacemaker Operation');
    ylabel('pacemaker');
    xlabel('time (milliseconds)');
    set(gca,'Ylim',[-4,4],'Xlim',[0,total_time]);
    xVal = [0,total_time]; 
    yVal = [0,0];
    line(xVal, yVal, 'Color', 'k');
end

if plotTimers
    if plotSignals
        subplot(2,1,2);
    end
    set(gca,'Ylim',[-4,4],'Xlim',[0,total_time]);
    ylabel('timers');
    xlabel('time (milliseconds)');
end

while i< total_time
    i=i+1;
    data=0;
    name = '';
    faceColor = 'k';
    %% Plot Pacemaker Sensing/Pacing
        if ismember(i,ASign)
            pace_param=pacemaker_new(pace_param, 1, V_get, 1);
            if plotSignals
                startArrow = [i,0];
                endArrow = [i,0.5];
                if plotTimers
                    subplot(2,1,1)
                end
                arrow(startArrow,endArrow,'EdgeColor','k','FaceColor','y');
                text(i,0.5,'A Signal','Fontsize', 9); 
            end
        elseif ismember(i,VSign)
            pace_param=pacemaker_new(pace_param, A_get, 1, 1);
            if plotSignals
                startArrow = [i,0];
                endArrow = [i,-0.5];
                if plotTimers
                    subplot(2,1,1)
                end
                arrow(startArrow,endArrow,'EdgeColor','k','FaceColor','w');
                text(i,-0.5,'V Signal','Fontsize', 9);
            end
        else
            pace_param=pacemaker_new(pace_param, A_get, V_get, 1);
        end
        if plotSignals
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
                  if plotTimers
                    subplot(2,1,1)
                  end
                  arrow(startArrow,endArrow,'EdgeColor','k','FaceColor',faceColor);
                  text(i,data,name,'Fontsize', 10);
              end
        end
   %% Plot Timer States
   if plotTimers
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
   
    %local variables
   
              %AVI  
              if ~strcmp(pace_param.AVI,'off')
                  %if timer just started, plot the expected timer time for
                  %AVI, ABP, and VSP (if on).
                 
                  if plotSignals
                    subplot(2,1,2)
                  end
                if pace_param.AVI_cur == pace_param.AVI_def
                    avi_switch = 1;
                    avi_init = i;
                    rectangle('Position',[i,AVI_LOWER_Y, pace_param.AVI_def,1],'FaceColor',AVI_DEF_COLOR);
                    rectangle('Position',[i,AVI_LOWER_Y, pace_param.ABP,0.5],'FaceColor',BLOCK_COLOR);
                    if strcmp(pace_param.VSP,'on')
                        rectangle('Position',[(i+pace_param.ABP),AVI_LOWER_Y, pace_param.VSP_sense,0.5],'FaceColor','w');
                    end
                %else color the current timer state.    
                elseif plotIteratively
                    rectangle('Position',[i-1,AVI_LOWER_Y+0.5, 1,0.5],'FaceColor',AVI_CUR_COLOR,'EdgeColor', AVI_CUR_COLOR);
                end 
              end
              
              if ~plotIteratively
                if plotSignals
                    subplot(2,1,2)
                end
                if strcmp(pace_param.AVI,'off') && avi_switch==1
                    width = (i-1) - avi_init;
                    rectangle('Position',[avi_init,AVI_LOWER_Y+0.5,width,0.5],'FaceColor',AVI_CUR_COLOR);
                    avi_switch = 0;
                    avi_init = 0;
                end
              end
              
              %VRP
              if strcmp(pace_param.VRP, 'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                if pace_param.VRP_cur == pace_param.VRP_def ||pace_param.v_sense == 1 || pace_param.v_pace == 1
                    vrp_switch = 1;
                    vrp_init = i;
                    rectangle('Position',[i,VRP_LOWER_Y, pace_param.VRP_def,1],'FaceColor',VRP_DEF_COLOR);
                elseif plotIteratively
                    rectangle('Position',[i-1,VRP_LOWER_Y+0.5, 1,0.5],'FaceColor',VRP_CUR_COLOR,'EdgeColor', VRP_CUR_COLOR);
                end
              end
              if ~plotIteratively
                if strcmp(pace_param.VRP,'off') && vrp_switch==1
                    width = (i-1) - vrp_init;
                    rectangle('Position',[vrp_init,VRP_LOWER_Y+0.5,width,0.5],'FaceColor',VRP_CUR_COLOR);
                    vrp_switch = 0;
                    vrp_init = 0;
                end
              end
              
              % PVARP
              if strcmp(pace_param.PVARP, 'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.PVARP_cur == pace_param.PVARP_def
                    pvarp_switch = 1;
                    pvarp_init = i;
                    rectangle('Position',[i,PVARP_LOWER_Y, pace_param.PVARP_def,1],'FaceColor',PVARP_DEF_COLOR);
                  elseif plotIteratively
                    rectangle('Position',[i-1,PVARP_LOWER_Y+0.5, 1,0.5],'FaceColor',PVARP_CUR_COLOR,'EdgeColor', PVARP_CUR_COLOR);
                  end
              end
              
              if ~plotIteratively
                  if strcmp(pace_param.PVARP,'off') && pvarp_switch==1
                    width = (i-1) - pvarp_init;
                    rectangle('Position',[pvarp_init,PVARP_LOWER_Y+0.5,width,0.5],'FaceColor',PVARP_CUR_COLOR);
                    pvarp_switch = 0;
                    pvarp_init = 0;
                  end
              end
              
              % LRI
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.LRI_cur == pace_param.LRI_def-1   
                    if lri_flip == 0
                        lri_flip  = 1;
                        lri_switch = 1;
                    else
                        lri_flip = 0;
                        lri_switch = 1;
                    end  
                    if lri_flip 
                        position = 0.5;
                        pos = 0;
                    else
                        position = 0;
                        pos = 0.5;
                    end
                    rectangle('Position',[i,LRI_LOWER_Y + position, pace_param.LRI_def,0.5],'FaceColor',LRI_DEF_COLOR);
                    width = (i-1) - lri_init; 
                    if width > 0
                        rectangle('Position',[lri_init, LRI_LOWER_Y + pos,width,0.25],'FaceColor', LRI_CUR_COLOR);
                    end
                    lri_init = i;
                    
                  elseif plotIteratively
                    if lri_flip
                       pos = 0.5;
                    else
                       pos = 0;
                    end
                    rectangle('Position',[i-1,LRI_LOWER_Y+position, 1,0.25],'FaceColor',LRI_CUR_COLOR, 'EdgeColor', LRI_CUR_COLOR);  
                  end
                  
                  if i >= total_time
                    if lri_flip
                       pos = 0.5;
                    else
                       pos = 0;
                    end  
                    width = total_time - lri_init;
                    rectangle('Position',[lri_init, LRI_LOWER_Y + pos,width,0.25],'FaceColor', LRI_CUR_COLOR);
                  end
                  
              % URI
              if strcmp(pace_param.URI,'on')
                  if plotSignals
                    subplot(2,1,2)
                  end
                  if pace_param.URI_cur == pace_param.URI_def
                    uri_switch = 1;
                    uri_init = i;
                    rectangle('Position',[i,URI_LOWER_Y, pace_param.URI_def,1],'FaceColor',URI_DEF_COLOR);
                  elseif plotIteratively
                    rectangle('Position',[i-1,URI_LOWER_Y+0.5, 1,0.5],'FaceColor',URI_CUR_COLOR, 'EdgeColor', URI_CUR_COLOR);
                  end
              end
              
               if ~plotIteratively
                  if strcmp(pace_param.URI,'off') && uri_switch==1
                    width = (i-1) - uri_init;
                    rectangle('Position',[uri_init,URI_LOWER_Y+0.5,width,0.5],'FaceColor',URI_CUR_COLOR);
                    uri_switch = 0;
                    uri_init = 0;
                  end
              end
   end
 %% Store Data             
              gdata(i+1) = data;
    if plotIteratively
        pause(0.00001);
    end
end
