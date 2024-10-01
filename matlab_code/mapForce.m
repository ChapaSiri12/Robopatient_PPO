function mappedForce = mapForce(pain_level,rand_pain_threshold)

% Amplitude Mapping Values
inMin = 0;     % Minimum input range
inMax = rand_pain_threshold;   % Maximum input range
outMin = 0;    % Minimum output range
outMax = 100;  % Maximum output range

% Ensure x is within the input range
pain_level = min(max(pain_level, inMin), inMax);

% Perform the mapping
mappedForce = (pain_level - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;

end