% trainHRIEnvironment.m

% Create the custom environment
env = HRIEnvironment();

% Define the observation and action space
obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

% Create a deep neural network for the actor (policy network)
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

% Create a deep neural network for the critic (value network)
criticNetwork = [
    featureInputLayer(obsInfo.Dimension(1), 'Name', 'pressure')  % Match the name with obsInfo
    fullyConnectedLayer(24, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(24, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'fc3')  % Output is a single value (state value)
    ];

criticNet = rlValueRepresentation(criticNetwork, obsInfo, 'Observation', {'pressure'});

% Define the PPO agent options
agentOpts = rlPPOAgentOptions(...
    'ClipFactor', 0.2, ...
    'ExperienceHorizon', 256, ...
    'MiniBatchSize', 64, ...
    'DiscountFactor', 0.99, ...
    'EntropyLossWeight', 0.01, ...
    'AdvantageEstimateMethod', 'gae', ...
    'GAEFactor', 0.95);

% Create the PPO agent
agent = rlPPOAgent(actorNet, criticNet, agentOpts);

% Initialize the observation
obs = reset(env);

% Continuous learning loop
while true
    % Get the action from the agent
    action = getAction(agent, {obs});
    action = cell2mat(action);  % Ensure action is numeric
    
    % Take a step in the environment
    [obs, reward, isDone, ~] = step(env, action);
    reward = double(reward);  % Ensure reward is numeric
    
    % Display action and reward
    fprintf('Action: %d, Reward: %d\n', action, reward);
    
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
end