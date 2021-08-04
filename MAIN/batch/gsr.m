function signal_gsr = gsr(signal)
    % GSR
    % @requires 
    % signal--data after dF/f0
    % @returns
    % signal_gsr--data after gsr
    m = size(signal, 1) * size(signal, 2);
    frames = [];
    for i = 1:n
        temp = signal(:, :, i);
        temp(find(isnan(temp) == 1)) = 0;
        frames(i, :) = temp(:);
    end
    mean_g = mean(frames, 2);
    g_plus = squeeze(pinv(mean_g));
    beta_g = g_plus * frames;
    global_signal = mean_g * beta_g;
    frames = frames - global_signal; 

    for i = 1:n
        signal_gsr(:, :, i) = reshape(frames(i, :), size(signal(:, :, 1)));
    end
    clear mean_g g_plus beta_g global_signal frames signal;
end
