function signal_gsr = gsr(signal)
    % GSR
    % @requires
    % signal--data after dF/f0
    %
    % @returns
    % signal_gsr--data after gsr
    temp = signal(1:end);
    temp(isnan(temp)) = 0;
    frames = reshape(temp, size(signal, 1), size(signal, 2), size(signal, 3));
    frames = reshape(frames, size(signal, 1) * size(signal, 2), size(signal, 3));
    frames = frames';

    mean_g = mean(frames, 2);
    g_plus = squeeze(pinv(mean_g));
    beta_g = g_plus * frames;
    global_signal = mean_g * beta_g;
    frames = frames - global_signal;
    dara_fgsr = [];

    signal_gsr = reshape(frames', size(signal, 1), size(signal, 2), size(signal, 3));

end
