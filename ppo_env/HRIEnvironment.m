classdef HRIEnvironment < rl.env.MATLABEnvironment
    % Custom environment template for reinforcement learning
    
    properties
        NumExpressions = 4
        NumVocals = 4
        NumPitches = 4
        NumAmplitudes = 3
        CurrentPressure = 1.0
        FeedbackHistory = zeros(10, 1)
        FeedbackIndex = 1
        FeedbackCount = 0
        ConsecutivePositiveFeedback = 0
        ActionHistory = []
        PressureHistory = []
    end
    
    properties (Access = public)
        IsDone = false
    end
    
    methods
        function this = HRIEnvironment()
            % Call the superclass constructor FIRST
            ObservationInfo = rlNumericSpec([1 1], 'LowerLimit', 1, 'UpperLimit', 5);
            ActionInfo = rlFiniteSetSpec(1:(4 * 4 * 4 * 3));  % Adjust for vocal, pitch, amplitude
            this = this@rl.env.MATLABEnvironment(ObservationInfo, ActionInfo);
            
            % Initialize additional properties
            this.ObservationInfo.Name = 'pressure';
            this.ObservationInfo.Description = 'Pressure input';
            this.ActionInfo.Name = 'expression-vocal-pitch-amplitude';
        end
        
        function [Observation, Reward, IsDone, LoggedSignals] = step(this, Action)
            Action = double(Action);  % Convert cell array to numeric
            
            % Decode action into expression, vocal, pitch, and amplitude
            totalVocalPitchAmp = this.NumVocals * this.NumPitches * this.NumAmplitudes;
            expression = floor((Action-1) / totalVocalPitchAmp) + 1;
            vocalPitchAmpIndex = mod((Action-1), totalVocalPitchAmp);
            vocal = floor(vocalPitchAmpIndex / (this.NumPitches * this.NumAmplitudes)) + 1;
            pitch = floor(mod(vocalPitchAmpIndex, this.NumPitches * this.NumAmplitudes) / this.NumAmplitudes) + 1;
            amplitude = mod(vocalPitchAmpIndex, this.NumAmplitudes) + 1;
            
            % Present action to the participant
            this.presentActionToParticipant(expression, vocal, pitch, amplitude, this.CurrentPressure);
            
            % Get feedback from the participant
            Reward = this.getFeedbackFromParticipant();
            
            % Convert feedback to binary for termination condition (1 for "Agree" or "Strong Agree", 0 for others)
            if Reward >= 3  % Assuming "Strong Agree" is 4, "Agree" is 3, "Disagree" is 2, "Strong Disagree" is 1
                this.ConsecutivePositiveFeedback = this.ConsecutivePositiveFeedback + 1;
            else
                this.ConsecutivePositiveFeedback = 0;
            end
            
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
            if sum(this.FeedbackHistory >= 3) / 10 >= 0.8 && this.FeedbackCount == 10
                this.IsDone = true;
            else
                this.IsDone = false;
            end
            
            % Manually input next pressure
            this.CurrentPressure = input('Enter next pressure (1-5): ');
            Observation = this.CurrentPressure;
            
            IsDone = this.IsDone;
            LoggedSignals = [];
        end
        
        function InitialObservation = reset(this)
            % Reset the environment to an initial state
            this.CurrentPressure = input('Enter initial pressure (1-5): ');
            this.FeedbackHistory = zeros(10, 1);
            this.FeedbackIndex = 1;
            this.FeedbackCount = 0;
            this.ConsecutivePositiveFeedback = 0;
            this.ActionHistory = [];
            this.PressureHistory = [];
            InitialObservation = this.CurrentPressure;
            this.IsDone = false;
        end
        
        function presentActionToParticipant(~, expression, vocal, pitch, amplitude, pressure)
            % Present the action to the participant
            fprintf('Presenting Expression: %d, Vocal: %d, Pitch: %d, Amplitude: %d, Pressure: %.1f\n', expression, vocal, pitch, amplitude, pressure);
        end
        
        function feedback = getFeedbackFromParticipant(~)
            % Get feedback from the participant
            fprintf('Enter feedback (1-4) [1=Strong Disagree, 2=Disagree, 3=Agree, 4=Strong Agree]: ');
            feedback = input('');  % Assume the input is an integer between 1 and 4
        end
        
        function mapping = getActionPressureMapping(this)
            mapping = arrayfun(@(action, pressure) this.decodeAction(action, pressure), ...
                this.ActionHistory, this.PressureHistory, 'UniformOutput', false);
        end
        
        function decodedAction = decodeAction(this, action, pressure)
            totalVocalPitchAmp = this.NumVocals * this.NumPitches * this.NumAmplitudes;
            expression = floor((action-1) / totalVocalPitchAmp) + 1;
            vocalPitchAmpIndex = mod((action-1), totalVocalPitchAmp);
            vocal = floor(vocalPitchAmpIndex / (this.NumPitches * this.NumAmplitudes)) + 1;
            pitch = floor(mod(vocalPitchAmpIndex, this.NumPitches * this.NumAmplitudes) / this.NumAmplitudes) + 1;
            amplitude = mod(vocalPitchAmpIndex, this.NumAmplitudes) + 1;
            decodedAction = struct('Expression', expression, 'Vocal', vocal, 'Pitch', pitch, 'Amplitude', amplitude, 'Pressure', pressure);
        end
    end
end