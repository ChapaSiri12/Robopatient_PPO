function env = HRIEnvironment_New(amplitude_vars,pitch_vars)
    env.PitchVars = pitch_vars;
    env.AmplitudeVars = amplitude_vars;
    env.NumPitch = length(pitch_vars);
    env.NumAmplitude = length(amplitude_vars);

    env.NumPitch = 4;
    env.NumAmplitude = 4;  % Number of possible amplitude values
    env.CurrentPressure = 1.0;  % Initial pressure input
    env.FeedbackHistory = zeros(10, 1);  % Store feedback
    env.FeedbackCount = 0;
    env.ConsecutivePerfectFeedback = 0;  % Consecutive perfect feedback
    env.TrialCount = 0;  % Trial counter
    env.MaxTrials = 10;  % Maximum number of trials before termination
    env.IsDone = false;  % Check if the episode is done
    env.ActionHistory = [];
    env.PressureHistory = [];
end



     
