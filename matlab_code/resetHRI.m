function obs = resetHRI(env, force)
    % reset environment for next trial
    env.FeedbackHistory = zeros(10,1);
    env.FeedbackCount = 0;
    env.ConsecutivePerfectFeedback =0;
    env.TrialCount = 0;  % Reset trial count
    env.CurrentPressure = force;  % Set pressure input to the provided force value
    env.IsDone = false;
    obs = env.CurrentPressure;  % Return the initial observation
end