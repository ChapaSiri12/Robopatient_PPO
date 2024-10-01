%% Clear all
clear;clc;close all;
%% Variables to change between breaks

%first gender (counter balance)
gender = "Male";
%gender = "Female";

%subject number
subject_no = 35;
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

%% Audio and force matrix

%number of trials
no_trials = 240;

%pain sounds ID
pain_sounds_id = [1 2 3];

% amplitude
amplitude_vars = [1 1/3 1/9 1/27];

% pitch
pitch_vars = [0.7 0.9 1.1 1.3];

% force values
threshold_vocal_pain = [5 10 15 20];

%parameters for plot
force_lim = threshold_vocal_pain(:,end);
x_ticks = [0 threshold_vocal_pain];

%all possible combinations of pain sounds,amplitude,pitch and force (192 combinations)
audio_pool = combvec(pain_sounds_id,threshold_vocal_pain);

%random permutations for array index
rand_indexes = randperm(12);

%% Counters

Trial_ID = [];
Amp_T = [];
Pitch_T = [];
trial_no = 0;

counter = 0;
ppoTerSwitch = 0;
audioPoolIndex = 1;
v = 0;
%% Main program

for h = 1:no_trials
    %clear before trial
    clc;close all;

    %initialisation time
    pause(1);

    trial_no = trial_no + 1;
    ppoTerSwitch = ppoTerSwitch + 1;


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

    if ppoTerSwitch == 10 || h == 1 || h == 121

        % pain sound index
        index = rand_indexes(audioPoolIndex);
        combination = audio_pool(:,index);
        
        % pain sound
        pain_sound_num = combination(1,1);

        % palpation thereshold
        rand_pain_threshold = combination(2,1);

        ppoTerSwitch = 0;
        audioPoolIndex = audioPoolIndex + 1;
    end

    if pain_sound_num == 1
        pain_sound = s_1;
        pain_sound_pitch = Fs_1;
        pain_sound_label = "1";
    elseif pain_sound_num == 2
        pain_sound = s_2;
        pain_sound_pitch = Fs_2;
        pain_sound_label = "2";
    elseif pain_sound_num == 3
        pain_sound = s_3;
        pain_sound_pitch = Fs_3;
        pain_sound_label = "3";
    end

    count = 0;
    stop_command = 0;

    X = 0; % clear search run raw data
    L = 0; % clear locate run raw data

    % Create the custom environment
    env = HRIEnvironment_New(amplitude_vars,pitch_vars);

    % Define the observation and action space
    obsInfo = rlNumericSpec([1 1], 'LowerLimit', 1, 'UpperLimit', 5);
    actInfo = rlFiniteSetSpec(1:(env.NumPitch * env.NumAmplitude));

    % Create a deep neural network for the actor
    actorNetwork = [
        featureInputLayer(obsInfo.Dimension(1), 'Name', 'pressure')  % Match the name with obsInfo
        fullyConnectedLayer(24, 'Name', 'fc1')
        reluLayer('Name', 'relu1')
        fullyConnectedLayer(24, 'Name', 'fc2')
        reluLayer('Name', 'relu2')
        fullyConnectedLayer(numel(actInfo.Elements), 'Name', 'fc3')
        softmaxLayer('Name', 'softmax')
        ];

    actorNet = rlStochasticActorRepresentation(actorNetwork, obsInfo, actInfo, 'Observation', {'pressure'});

    % Create a deep neural network for the critic
    criticNetwork = [
        featureInputLayer(obsInfo.Dimension(1), 'Name', 'pressure')  % Match the name with obsInfo
        fullyConnectedLayer(24, 'Name', 'fc1')
        reluLayer('Name', 'relu1')
        fullyConnectedLayer(24, 'Name', 'fc2')
        reluLayer('Name', 'relu2')
        fullyConnectedLayer(1, 'Name', 'fc3')
        ];

    criticNet = rlValueRepresentation(criticNetwork, obsInfo, 'Observation', {'pressure'});

    % Define the PPO agent
    agentOpts = rlPPOAgentOptions('ClipFactor', 0.2, 'ExperienceHorizon', 256, 'MiniBatchSize', 64);
    agent = rlPPOAgent(actorNet, criticNet, agentOpts);

    % Initialize observation
    obs = resetHRI(env,rand_pain_threshold);

    action = getAction(agent, {obs});
    action = cell2mat(action);  % Ensure action is numeric


    % Take a step in the environment
    [obs,isDone] = step(env, action,s,trial_no,RI_palpate,RI_select,ref_l,RI,force_lim,pain_sound, pain_sound_pitch,x_ticks, rand_pain_threshold);
    %reward = double(reward);  % Ensure reward is numeric

    % Check if the episode has ended
    if isDone
        fprintf('Terminating episode\n');
        mapping = getActionPressureMapping(env);
        disp('Mapping between actions and pressures:');
        for i = 1:length(mapping)
            disp(mapping{i});
        end
        obs = reset(env);  % Reset environment for the next episode
    end

    % %Plotting the values for initial inspection
    % %ploting data during search run
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

    dir_path = ['./Raw_data_', date ,'/S',int2str(subject_no),'/',convertStringsToChars(gender)];
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
    Force_T(trial_no,:) = string(rand_pain_threshold) ;
    choice(trial_no,:)= string(z);
    pain_sound_labels(trial_no,:) = pain_sound_label;

    %save data
    if (h == 120 || h == no_trials )

        disp("Saving Data...");

        choice(ismissing(choice)) = "n";
        Exp_data = [Trial_ID,Force_T,pain_sound_labels, Amp_T, Pitch_T,choice];

        dir_path = ['./Raw_data_', date ,'/S',int2str(subject_no),'/',convertStringsToChars(gender)];
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

    %break every 60 trials
    if h == 60 || h == 180
        sound(sin(1:3000)/2,25000);
        pause(0.3);
        sound(sin(1:3000)/2,25000);

        clc;
        disp("Break for 90secs...");
        pause(90);
    end

    %switch gender
    if h == 120
        if gender == "Male"
            gender = "Female";
            trial_no = 0;
            ppoTerSwitch = 1;
            audioPoolIndex = 1;

            rand_indexes = randperm(12);

            sound(sin(1:3000)/2,25000);
            pause(0.3);
            sound(sin(1:3000)/2,25000);

            clc;
            disp("Switching in 5 mins, break...");
            pause(270);

            sound(sin(1:3000)/2,25000);
            pause(0.3);
            sound(sin(1:3000)/2,25000);

            clc;
            disp("30 secs left...");
            pause(30);

        elseif gender == "Female"
            gender = "Male";
            trial_no = 0;
            ppoTerSwitch = 0;
            audioPoolIndex = 1;

            rand_indexes = randperm(12);

            sound(sin(1:3000)/2,25000);
            pause(0.3);
            sound(sin(1:3000)/2,25000);

            clc;
            disp("Switching in 5 mins, break...");
            pause(270);

            sound(sin(1:3000)/2,25000);
            pause(0.3);
            sound(sin(1:3000)/2,25000);

            clc;
            disp("30 secs left...");
            pause(30);
        end
    end

end

