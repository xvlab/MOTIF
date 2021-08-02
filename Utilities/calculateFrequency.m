function [frequency, frequency_thresh] = calculateFrequency(motif_threshold, frequency_thresh, frequency, vector)
    %cal - Description
    %
    % Syntax: frequency = calculateFrequency   (vector)
    %
    % Long description
    for i = 1:size(vector)
        if vector(i) > motif_threshold
            frequency_thresh(i, 1) = frequency_thresh(i, 1) + 1;
        end
        if vector(i) > 0.1
            frequency(i, 1) = frequency(i, 1) + 1;
        end
        if vector(i) > 0.2
            frequency(i, 2) = frequency(i, 2) + 1;
        end
        if vector(i) > 0.3
            frequency(i, 3) = frequency(i, 3) + 1;
        end
        if vector(i) > 0.4
            frequency(i, 4) = frequency(i, 4) + 1;
        end
        if vector(i) > 0.5
            frequency(i, 5) = frequency(i, 5) + 1;
        end
        if vector(i) > 0.6
            frequency(i, 6) = frequency(i, 6) + 1;
        end
        if vector(i) > 0.7
            frequency(i, 7) = frequency(i, 7) + 1;
        end
        if vector(i) > 0.8
            frequency(i, 8) = frequency(i, 8) + 1;
        end
        if vector(i) > 0.9
            frequency(i, 9) = frequency(i, 9) + 1;
        end
    end
end
