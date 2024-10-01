classdef HRIEnvironment < rl.env.MATLABEnvironment
    % Custom environment template for reinforcement learning

    properties
        % Number of possible expressions and sounds
        NumExpressions = 4
        NumSounds = 4
        % Current pressure input
        CurrentPressure = 1.0
        % Feedback history for termination condition
        FeedbackHistory = zeros(10, 1)
        FeedbackIndex = 1
        FeedbackCount = 0
        ConsecutivePerfectFeedback = 0  % Counter for consecutive perfect feedback
        % Store action and pressure history
        ActionHistory = []
        PressureHistory = []
    end

    properties (Access = public)  % Changed access to public
        % Internal flag to indicate the end of an episode
        IsDone = false
    end

    methods
        function this = HRIEnvironment()
            % Define observation and action info
            ObservationInfo = rlNumericSpec([1 1], 'LowerLimit', 1, 'UpperLimit', 5);
            ActionInfo = rlFiniteSetSpec(1:(4 * 4));  % Action space for both expressions and sounds

            % Call the superclass constructor FIRST
            this = this@rl.env.MATLABEnvironment(ObservationInfo, ActionInfo);

            % Initialize additional properties
            this.ObservationInfo.Name = 'pressure';
            this.ObservationInfo.Description = 'Pressure input';
            this.ActionInfo.Name = 'expression-sound';
        end

        function [Observation, Reward, IsDone] = step(this, Action,s,trial_no,RI_palpate,RI_select,ref_l,RI,force_lim,pain_sound, pain_sound_pitch,x_ticks, rand_pain_threshold)
            % Ensure Action is numeric
            Action = double(Action);  % Convert cell array to numeric

            % Decode action into expression and sound
            pitch = floor((Action-1) / this.NumSounds) + 1;
            amplitude = mod((Action-1), this.NumSounds) + 1;

            assignin("base","pitch",pitch);
            assignin("base","amplitude",amplitude);

            displayRobotPatient(s,trial_no,RI_palpate,RI_select,ref_l,RI,force_lim,pain_sound, pain_sound_pitch,x_ticks, rand_pain_threshold, amplitude, pitch);

            % Read Participant input
            Reward = evalin("base","z");

            % Present action to the participant
            fprintf('Pitch: %d, Amp: %d',pitch, amplitude);

            % Update feedback history
            this.FeedbackHistory(this.FeedbackIndex) = Reward;
            this.FeedbackIndex = mod(this.FeedbackIndex, 10) + 1;
            if this.FeedbackCount < 10
                this.FeedbackCount = this.FeedbackCount + 1;
            end

            % Store action and pressure history
            this.ActionHistory = [this.ActionHistory; Action];
            this.PressureHistory = [this.PressureHistory; this.CurrentPressure];

            % Check termination condition
            if Reward == 10
                this.ConsecutivePerfectFeedback = this.ConsecutivePerfectFeedback + 1;
            else
                this.ConsecutivePerfectFeedback = 0;
            end

            if this.ConsecutivePerfectFeedback >= 3
                this.IsDone = true;
            else
                this.IsDone = false;
            end

            IsDone = this.IsDone;
            LoggedSignals = [];
        end

        function InitialObservation = reset(this,force)
            % Reset the environment to an initial state
            this.CurrentPressure = force;
            this.FeedbackHistory = zeros(10, 1);
            this.FeedbackIndex = 1;
            this.FeedbackCount = 0;
            this.ConsecutivePerfectFeedback = 0;  % Reset consecutive perfect feedback counter
            this.ActionHistory = [];  % Reset action history
            this.PressureHistory = [];  % Reset pressure history
            InitialObservation = this.CurrentPressure;
            this.IsDone = false;
        end

        function mapping = getActionPressureMapping(this)
            % Return the mapping between action and pressure
            mapping = arrayfun(@(action, pressure) this.decodeAction(action, pressure), ...
                this.ActionHistory, this.PressureHistory, 'UniformOutput', false);
        end

        function decodedAction = decodeAction(this, action, pressure)
            % Decode action into expression and sound
            expression = floor((action-1) / this.NumSounds) + 1;
            sound = mod((action-1), this.NumSounds) + 1;
            decodedAction = struct('Expression', expression, 'Sound', sound, 'Pressure', pressure);
        end
    end
end
