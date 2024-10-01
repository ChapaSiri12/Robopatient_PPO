function decodedAction = decodeAction(env, action, pressure)
    % Decode action into expression, vocal, pitch, and amplitude
    totalVocalPitchAmp = env.NumPitch * env.NumAmplitude;
    pitch = floor((action - 1) / totalVocalPitchAmp) + 1;
    amplitude = mod((action - 1), env.NumAmplitude) + 1;
    decodedAction = struct('Pitch', pitch, 'Amplitude', amplitude, 'Pressure', pressure);
end