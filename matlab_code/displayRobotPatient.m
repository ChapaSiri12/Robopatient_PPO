function displayRobotPatient(s,trial_no,RI_palpate,RI_select,ref_l,RI,force_lim,pain_sound, pain_sound_pitch,x_ticks, rand_pain_threshold, amplitude, pitch)
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

end