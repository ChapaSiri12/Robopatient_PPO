function WithAudioCallback(src, ~,c,cal,RI,h1,h2,h4,force_lim,s, Fs,x_ticks, rand_pain_threshold,amplitude, pitch, flag_sound)

% data acqusition begins
[eventData, eventTimestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");

% defining persistent variables (these will stay in memory in beween
% function calls)

persistent count flag sound_once flag_plot max_total_force;

% at 1st data sample, initialize all variables
if eventTimestamps(1) == 0
    count = 0;
    flag = 0;
    flag_plot = 0;
    sound_once = 1;
end

% calibration factors. Calculated based on data sheet provided.
%mV_to_N_factor=[9584.28997117874,10399.6607653981,9689.36737616672,10220.3469292077];
mV_to_N_factor = [4.018783189335981e+04 4.137462537443594e+04 4.079664804773283e+04 4.048539970227224e+04]; %1,2,3,4

% converting loadcell values to forces in N
Load_cell_F1_unfiltered_1 =  eventData(:,1)*mV_to_N_factor(:,1)-cal.value(1);  %force in N
Load_cell_F2_unfiltered_1 =  eventData(:,2)*mV_to_N_factor(:,2)-cal.value(2);  %force in N
Load_cell_F3_unfiltered_1 =  eventData(:,3)*mV_to_N_factor(:,3)-cal.value(3);  %force in N
Load_cell_F4_unfiltered_1=  eventData(:,4)*mV_to_N_factor(:,4)-cal.value(4);  %force in N

%-----------------------------------------------------------------------------------------------
% Moving average filter for load cell signals (low pass filtering)
% Use a persistent variable 'buffer' that represents a sliding window of
% 20 samples at a time.
sample_window_LC = 20; 
persistent buffer_1 buffer_2 buffer_3  buffer_4;
if isempty(buffer_1)
    buffer_1 = zeros(sample_window_LC,1);
end
if isempty(buffer_2)
    buffer_2 = zeros(sample_window_LC,1);
end
if isempty(buffer_3)
    buffer_3 = zeros(sample_window_LC,1);
end
if isempty(buffer_4)
    buffer_4 = zeros(sample_window_LC,1);
end

Load_cell_F1_unfiltered = zeros(size(Load_cell_F1_unfiltered_1), class(Load_cell_F1_unfiltered_1));
Load_cell_F2_unfiltered = zeros(size(Load_cell_F2_unfiltered_1), class(Load_cell_F2_unfiltered_1));
Load_cell_F3_unfiltered = zeros(size(Load_cell_F3_unfiltered_1), class(Load_cell_F3_unfiltered_1));
Load_cell_F4_unfiltered = zeros(size(Load_cell_F4_unfiltered_1), class(Load_cell_F4_unfiltered_1));

for i = 1:numel(Load_cell_F1_unfiltered_1)
    % Scroll the buffer
    buffer_1(2:end) = buffer_1(1:end-1);
    buffer_2(2:end) = buffer_2(1:end-1);
    buffer_3(2:end) = buffer_3(1:end-1);
    buffer_4(2:end) = buffer_4(1:end-1);

    % Add a new sample value to the buffer
    buffer_1(1) = Load_cell_F1_unfiltered_1(i);
    buffer_2(1) = Load_cell_F2_unfiltered_1(i);
    buffer_3(1) = Load_cell_F3_unfiltered_1(i);
    buffer_4(1) = Load_cell_F4_unfiltered_1(i);

    % Compute the current average value of the window and
    % write result
    Load_cell_F1_unfiltered(i,1) = sum(buffer_1)/numel(buffer_1);
    Load_cell_F2_unfiltered(i,1) = sum(buffer_2)/numel(buffer_2);
    Load_cell_F3_unfiltered(i,1) = sum(buffer_3)/numel(buffer_3);
    Load_cell_F4_unfiltered(i,1) = sum(buffer_4)/numel(buffer_4);
end
%------------------------------------------------------------------------------------------------

% threshold cutoff for zero noise
threshold = 0.5;

for j = 1:length(Load_cell_F1_unfiltered)
    if Load_cell_F1_unfiltered(j,1) <= threshold && Load_cell_F1_unfiltered(j,1) >= -threshold
        Load_cell_F1_unfiltered(j,1) = 0.0;
    end


    if Load_cell_F2_unfiltered(j,1) <= threshold && Load_cell_F2_unfiltered(j,1) >= -threshold
        Load_cell_F2_unfiltered(j,1) = 0.0;
    end

    if Load_cell_F3_unfiltered(j,1) <= threshold && Load_cell_F3_unfiltered(j,1) >= -threshold
        Load_cell_F3_unfiltered(j,1) = 0.0;
    end

    if Load_cell_F4_unfiltered(j,1) <= threshold && Load_cell_F4_unfiltered(j,1) >= -threshold
        Load_cell_F4_unfiltered(j,1) = 0.0;
    end

    % total normal palpation force
    total_force_after_calibration(j,1)  = Load_cell_F1_unfiltered(j,1) + Load_cell_F2_unfiltered(j,1) + Load_cell_F3_unfiltered(j,1) + Load_cell_F4_unfiltered(j,1);

    % set a minimum force value
    if total_force_after_calibration(j,1) <=  1.0
        total_force_after_calibration(j,1) = 1.0;
    end


    if flag == 0
        if total_force_after_calibration(j,1)>10
            count = count + 1;
            flag = 1;
        end
    end

    if flag == 1
        if total_force_after_calibration(j,1)< 1.2
            flag = 0;
            if count == 50 
                stop_command = 1;
            end
        end
    end

end

% display 2D human face based on the palpation force and the position
% only datapoints 1, 25 and 50 are considered as more data points will
% slow down the program. Therefore, the 2D human face updates at every 100ms.

%flag_test = 0;
%generate pain sounds

for h= 1:1:200
    vocal_pain(h) = total_force_after_calibration(h,1);
end


for h= 1:1:200

    if total_force_after_calibration(h,1) <= 1
        flag_test = 0;
    end

    inputMin = 0;
    inputMax = force_lim;
    outputMin = 0;
    outputMax = 100;


    %Ensure the force value is with in the input range
    pain_face = min(max(total_force_after_calibration(h,1),inputMin),inputMax);

    %Perform mapping
    face_index = (pain_face-inputMin)*(outputMax-outputMin)/(inputMax-inputMin) + outputMin;

    f = round(face_index);

    if f >=99
        f=99;
    end
    if f<=0
        f=0;
    end

    
    % to avoid any random displays, display faces and force bar
    if (total_force_after_calibration(h,1) > 1 && flag_plot == 0)

        subplot(10,10,3:7);
        b_thresh = [(rand_pain_threshold - 0.2),rand_pain_threshold];
        set(h4,'XData', b_thresh);
        %barh(0,'BarWidth',0.5,'FaceColor','g')
        b_temp = [0,total_force_after_calibration(h,1)];
        set(h1,'XData', b_temp);
        %set(h1,'XData',[(rand_pain_threshold - 0.1),rand_pain_threshold]);
        set(gca,'Color','k');
        set(gca,'xtick',x_ticks);
        set(gca,'xticklabel',[]);
        set(gca,'ytick',[]);
        set(gca,'yticklabel',[]);
        set(gca,'FontSize',10);
        xlim([0 force_lim]); % set to max force thresh
        %xlim([0 100]);

        subplot(10,10,11:90);
        set(h2,'CData', RI{f+1});

    else

        subplot(10,10,3:7);
        b_thresh = [(rand_pain_threshold - 0.2),rand_pain_threshold];
        set(h4,'XData', b_thresh);
        %barh(0,'BarWidth',0.5,'FaceColor','g')
        b_temp = [0, vocal_pain];
        set(h1,'XData', b_temp);
        %set(h1,'XData',[(rand_pain_threshold - 0.1),rand_pain_threshold]);
        set(gca,'Color','k');
        set(gca,'xtick',x_ticks);
        set(gca,'xticklabel',[]);
        set(gca,'ytick',[]);
        set(gca,'yticklabel',[]);
        set(gca,'FontSize',10);
        xlim([0 force_lim]); % set to max force thresh
        %xlim([0 100]);

        subplot(10,10,11:90);
        set(h2,'CData', RI{1});
    end

    % play pain sound when force is equal to threshold
    if (total_force_after_calibration(h,1) >= rand_pain_threshold && sound_once == 1)

        max_total_force = rand_pain_threshold;

        sound(s * amplitude, Fs * pitch);

        sound_once = 0;
        flag_plot = 1;
    end

    % changes the color of the bar to red
    if (flag_plot == 1 && sound_once == 0)
        subplot(10,10,3:7);
        set(h1,'Color','r');
        set(h1,'XData', [0,max_total_force]);
    end

    %------------------------------------------------------------------------------------------------------

    % final output data vector
    %new_eventData = [Load_cell_F1_unfiltered,Load_cell_F2_unfiltered,Load_cell_F3_unfiltered,Load_cell_F4_unfiltered,total_force_after_calibration,x,y];
    new_eventData = total_force_after_calibration;

    % The final output data vector is stored in a persistent buffer (dataBuffer)
    % Persistent variables retain their values between calls to the function.
    persistent dataBuffer ;

    % If dataCapture is running for the first time, initialize persistent vars
    if eventTimestamps(1)==0
        dataBuffer = [];          % data buffer
        prevData = [];            % last data point from previous callback execution
    else
        prevData = dataBuffer(end, :);
    end

    % Store continuous acquisition timestamps and data in persistent FIFO
    % buffer dataBuffer
    latestData = [eventTimestamps, new_eventData];
    dataBuffer = [dataBuffer; latestData];
    numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;

    if (numSamplesToDiscard > 0)
        dataBuffer(1:numSamplesToDiscard, :) = [];
    end
    % pass the variables to workspace
    assignin('base','X',dataBuffer); % final output data vector
    %assignin('base','stop_command',stop_command); % flag for stopping the program
    assignin('base','stop_command',f); % flag for stopping the program

end
