%% Clear all
clear;clc;close all;
%% Variables to change between breaks

%first gender (counter balance)
%gender = "Male";
gender = "Female";

%subject number
subject_no = 33;
%% Loading all 2D face images

[IM_WM_1,IM_WW_1] = loadImages;

% Scaling, rotation of facesb
[RI_WM1,RI_WW1,targetSize,ang,alpha] = rotateImages(IM_WM_1,IM_WW_1);

% Load Prompt Images
[RI_palpate,RI_ready,RI_select,RI_calibrate] = loadPromptImages(targetSize,ang,alpha);

%% Initialise NI-USB-6212 DAQ

s = initaliseDAQ;
%% Minimum calibration

% call back function to minimum force calibration
s.ScansAvailableFcn = @(src,evt) minimum_calibration(src, evt);
start(s, "Duration", seconds(2))

while s.Running
    pause(0.5);
end
stop(s);

%% Load pain sounds

[s_1_M,Fs_1_M] = audioread('painsoundmale1.wav');
[s_2_M,Fs_2_M] = audioread('painsoundmale2.wav');
[s_3_M,Fs_3_M] = audioread('painsoundmale3.wav');

[s_1_F,Fs_1_F] = audioread('painsoundfemale1.wav');
[s_2_F,Fs_2_F] = audioread('painsoundfemale2.wav');
[s_3_F,Fs_3_F] = audioread('painsoundfemale3.wav');

%% run this to familirize with audio male (play sounds)
sound(s_2_M * (1/81), Fs_2_M); % pain level 1
pause(5);
sound(s_1_M/5, Fs_1_M*1.0); % pain level 2
pause(5);
sound(s_1_M, Fs_1_M*1.4); % pain level 3

%% run this to familirize with audio female (play sounds)
sound(s_2_F * (1/81), Fs_2_F); % pain level 1
pause(5);
sound(s_1_F/5, Fs_1_F*1.0); % pain level 2
pause(5);
sound(s_1_F, Fs_1_F*1.4); % pain level 3
%% Audio and force matrix

%number of trials
no_trials = 12;

% force values
threshold_vocal_pain = [5 10 15 20];

%parameters for plot
force_lim = threshold_vocal_pain(:,end);
x_ticks = [0 threshold_vocal_pain];
%% Counters

Trial_ID = [];
Amp_T = [];
Pitch_T = [];
trial_no = 0;

counter = 0;
v = 0;
force_counter_pilot = 0;
save_trial = 1;
save_trial_init = 2;

for i = 1:3
    save_trial_counts(i) = save_trial_init;
    save_trial_init = save_trial_init + 2;
end

%% Main program

for h = 1:no_trials
    %clear before trial
    clc;close all;

    %initialisation time
    pause(1);

    %switch gender
    if h == 7
        if gender == "Male"
            gender = "Female";
            trial_no = 0;

            sound(sin(1:3000)/2,25000);
            pause(0.3);
            sound(sin(1:3000)/2,25000);

            clc;
            disp("Switching in 60 secs...")
            pause(60);
        elseif gender == "Female"
            gender = "Male";
            trial_no = 0;

            sound(sin(1:3000)/2,25000);
            pause(0.3);
            sound(sin(1:3000)/2,25000);

            clc;
            disp("Switching in 60 secs...")
            pause(60);
        end
    end

    trial_no = trial_no + 1;

    %change variables dependent on gender
    if gender == "Male"
        s_1 = s_1_M; s_2 = s_2_M; s_3 = s_3_M;
        Fs_1 = Fs_1_M; Fs_2 = Fs_2_M; Fs_3 = Fs_3_M;
        RI = RI_WM1;

    elseif gender == "Female"
        s_1 = s_1_F; s_2 = s_2_F; s_3 = s_3_F;
        Fs_1 = Fs_1_F; Fs_2 = Fs_2_F; Fs_3 = Fs_3_F;
        RI = RI_WW1;
    end

    if h == 4 || h == 8 || h == 12
        force_counter_pilot = 0;
    end

    force_counter_pilot = force_counter_pilot + 1;

    %assign pain sound and pain sound ID
    if trial_no == 1 || trial_no == 2
        pain_sound = s_1;
        pain_sound_pitch = Fs_1;
        pain_sound_label = "1";
    elseif trial_no == 3 || trial_no == 4
        pain_sound = s_2;
        pain_sound_pitch = Fs_2;
        pain_sound_label = "2";
    elseif trial_no == 5 || trial_no == 6
        pain_sound = s_3;
        pain_sound_pitch = Fs_3;
        pain_sound_label = "3";
    end

    %keep amp and pitch vars for callback fcn to work
    %amplitude '1' for pilot trials
    amplitude = 1;

    %pitch '1' for pilot trials
    pitch = 1;

    % palpation thereshold
    rand_pain_threshold = threshold_vocal_pain(force_counter_pilot);

    count = 0;
    stop_command = 0;

    X = 0; % clear search run raw data
    L = 0; % clear locate run raw data

    %set figure properties
    fig = figure(1);
    WinOnTop(fig, true);
    set(gcf, 'MenuBar', 'None')
    set(gcf,'color','k');
    %set(gcf,'position',[1000 0 1920 1080])
    set(gcf,'position',[1 1 1920 1080])

    %force bar
    subplot(10,10,3:7);
    b_main = [0,0];
    c_main = [1,1];
    h1 = plot(b_main,c_main, 'color', 'g','LineWidth', 15);

    %force thresh marker
    hold on;
    subplot(10,10,3:7);
    b_thresh = [(rand_pain_threshold - 0.1),rand_pain_threshold];
    c_thresh = [1,1];
    h4 = plot(b_thresh,c_thresh, 'color', 'g','LineWidth', 15);
    ylim([0 2])
    set(gca,'Color','k')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    xlim([0 100])

    %faces
    hold on;
    subplot(10,10,11:90);
    h2 = imshow(RI_palpate);
    set(get(gca,'Ylabel'),'String',"Trial: " + string(trial_no));
    set(get(gca,'Ylabel'),'Color','w');
    set(get(gca,'Ylabel'),'Rotation',-90);
    set(get(gca,'Ylabel'),'FontSize',20);
    set(get(gca,'Ylabel'),'FontWeight','bold');


    % Main loop begins here
    %-----------------------------------------------------------------------------------------------
    capture.bufferSize = 30000; % raw data buffer size for search phase
    calibration.value = ref_l;
    flag_sound = 0;

    % call back function to main data recording function
    s.ScansAvailableFcn = @(src,evt) WithAudioCallback(src, evt,capture,calibration,RI,h1,h2,h4,force_lim,pain_sound, pain_sound_pitch,x_ticks, rand_pain_threshold, amplitude, pitch, flag_sound);
    s.ScansAvailableFcnCount = 200; % 50 data window size (in this case 200ms as Fs = 250Hz)

    % search run starts with a beep
    sound(sin(1:3000)/2);

    % data acquisition starts
    start(s,"Duration", seconds(3)) % search run time limit

    while s.Running
        pause(0.5);
    end

    %data acquisition stops
    stop(s);
    clear WithAudioCallback;

    % keyboard input (non-blocking)
    z = NaN;
    kb = HebiKeyboard();

    % run DAQ for 3 secs for selection display
    subplot(10,10,11:90);
    s.ScansAvailableFcn =  @(src,evt) selectCallback(src,evt,h2,RI_select);
    s.ScansAvailableFcnCount = 100;
    start(s,"Duration", seconds(3));

    % get keyboard input during 3 sec scan period (foreground)
    while s.Running

        state = read(kb);

        if all(state.keys('0'))
            z = 0;
        elseif all(state.keys('1'))
            z = 1;
        end
        assignin("base","z",z);
        pause(10^-10000);
    end

    %selection stops
    stop(s);
    clc;close all;
    clear selectCallback;

    %Plotting the values for initial inspection
    %ploting data during search run
    % movAvg_force = dsp.MovingAverage(2);
    % palpation_force = movAvg_force(X(:,2));
    % 
    % % display force plot if neccessary
    % 
    % fig_3 = figure(3);
    % WinOnTop( fig_3, true);
    % set(fig_3,'WindowStyle','modal');
    % set(fig_3,'WindowState','fullscreen');
    % set(gcf,'position',[0  0  1920  1080])
    % set(gcf, 'MenuBar', 'None')
    % sgtitle(['                                              trial', num2str(h)])
    % 
    % plot(palpation_force,'LineWidth',2);
    % xlabel('Sample No');
    % ylabel('Palpation Force (N)');
    % title('Palpation Force');
    % ylim([0 80]);
    % grid on;
    % 
    % pause(2);
    

    % write output to a text file (raw data)
    output_data = X;

    dir_path = ['./Raw_data_', date ,'/S',int2str(subject_no),'/',convertStringsToChars(gender),'_Pilot'];
    file_name = sprintf('T%s S%s.txt',int2str(trial_no),int2str(subject_no));
    mkdir(dir_path);
    out = fullfile(dir_path,file_name);
    fileID = fopen(out,'w');
    fprintf(fileID,'%12s   %12s\r\n','Time','Palpation Force');
    fprintf(fileID,'%12.4f %12.2f\r\n',output_data');
    fclose(fileID);

    %write experiment variables
    Trial_ID (trial_no,:) = string(trial_no);
    Amp_T(trial_no,:) = string(amplitude);
    Pitch_T(trial_no,:) = string(pitch);
    Force_T(trial_no,:) = string(rand_pain_threshold) ; %rand_pain_threshold
    choice(trial_no,:)= string(z);
    pain_sound_labels(trial_no,:) = pain_sound_label;

    %save data
    if (h == 6 || h == no_trials )

        disp("Saving Data...");
        choice(ismissing(choice)) = "n";
        Exp_data = [Trial_ID,Force_T,pain_sound_labels, Amp_T, Pitch_T,choice];

        dir_path = ['./Raw_data_', date ,'/S',int2str(subject_no),'/',convertStringsToChars(gender),'_Pilot'];
        file_name = sprintf('S%s Exp T%s.txt',int2str(subject_no),int2str(trial_no));
        mkdir(dir_path);
        out = fullfile(dir_path,file_name);
        fileID = fopen(out,'w');
        fprintf(fileID,'%12s %12s %12s %12s %12s %12s\r\n','Trial_No', 'F_Thresh','Pain_Sound','Amp','Pitch','Choice');
        fprintf(fileID,'%12s %12s %12s %12s %12s %12s\r\n',Exp_data.');
        fclose(fileID);

        disp("Data Saved");
    end

    X = [];

end


