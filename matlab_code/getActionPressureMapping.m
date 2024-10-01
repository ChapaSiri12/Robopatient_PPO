function mapping = getActionPressureMapping(env)
    % Return the mapping between action and pressure
    mapping = arrayfun(@(action, pressure) decodeAction(env, action, pressure), ...
        env.ActionHistory, env.PressureHistory, 'UniformOutput', false);
end