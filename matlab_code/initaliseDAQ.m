function s = initaliseDAQ()

% Configure data acquisition object and add input channels
s = daq('ni');
ch1 = addinput(s, 'Dev1', 'ai1', 'Voltage');
ch2 = addinput(s, 'Dev1', 'ai2', 'Voltage');
ch3 = addinput(s, 'Dev1', 'ai3', 'Voltage');
ch4 = addinput(s, 'Dev1', 'ai4', 'Voltage');

% Set acquisition configuration for each channel
ch1.Range = [-0.2 0.2];
ch2.Range = [-0.2 0.2];
ch3.Range = [-0.2 0.2];
ch4.Range = [-0.2 0.2];

% Set acquisition rate, in scans/second
s.Rate = 1000;

end