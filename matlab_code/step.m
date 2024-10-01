function [obs,isDone] = step(env, action, s, trial_no, RI_palpate, RI_select, ref_l, RI, force_lim, pain_sound, pain_sound_pitch, x_ticks, rand_pain_threshold)
    % Decode action into pitch and amplitude indexes
     pitchIndex = floor((action-1) / env.NumAmplitude) + 1;
     amplitudeIndex = mod((action-1), env.NumAmplitude) + 1;
     
     % get pitch and amplitude values from vectors
     pitch = env.PitchVars(pitchIndex);
     amplitude = env.AmplitudeVars(amplitudeIndex);
     
     % assign pitch & amplitude to base ws
     assignin("base","pitch",pitch);
     assignin("base","amplitude",amplitude);

     % Present the action and perform necessary updates to the environment
     displayRobotPatient(s, trial_no, RI_palpate, RI_select, ref_l, RI, force_lim, pain_sound, pain_sound_pitch, x_ticks, rand_pain_threshold, amplitude, pitch);
     Reward = evalin("base", "z");

     env.FeedbackHistory(mod(env.FeedbackCount, 10) + 1) = Reward;
     env.FeedbackCount = env.FeedbackCount + 1;

     if Reward == 1
        env.ConsecutivePerfectFeedback = env.ConsecutivePerfectFeedback + 1;
     else
        env.ConsecutivePerfectFeedback = 0;
     end

     obs = env.CurrentPressure;

     env.TrialCount = env.TrialCount+1;
     if env.ConsecutivePerfectFeedback >= 3 || env.TrialCount >= env.MaxTrials
        env.IsDone = true;
     end

     isDone = env.IsDone;
end