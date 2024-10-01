function minimum_calibration(src, ~)

% Minimum Calibration, no weight
%mV_to_N_factor=[9584.28997117874,10399.6607653981,9689.36737616672,10220.3469292077];
mV_to_N_factor = [4.018783189335981e+04 4.137462537443594e+04 4.079664804773283e+04 4.048539970227224e+04]; %1,2,3,4

    [eventData, eventTimestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    
    Load_cell_F1 =  eventData(:,1)*mV_to_N_factor(:,1);  %in N
    Load_cell_F2 =  eventData(:,2)*mV_to_N_factor(:,2);  %in N
    Load_cell_F3 =  eventData(:,3)*mV_to_N_factor(:,3);  %in N
    Load_cell_F4 =  eventData(:,4)*mV_to_N_factor(:,4);  %in N
    ref=[mean(Load_cell_F1),mean(Load_cell_F2),mean(Load_cell_F3),mean(Load_cell_F4)];

assignin('base','ref_l',ref);

end 