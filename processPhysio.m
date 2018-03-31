function data = processPhysio(data, columns, highPassFrequency)
% Filters physiological data (only the provided column numbers, separately).
% First high-pass filters at the given frequency using a 4th order butterworth,
% then full-wave rectifies data, then log-transforms, finally z-scores.

params = Params;
srate = params.shimmer_srate;
order = 4;

for i = columns
    [b, a] = butter(order, highPassFrequency/(srate/2));
    data(:, i) = filter(b, a, data(:, i));
    data(:, i) = zscore(log(abs(data(:, i))));
end

end

