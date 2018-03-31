function peaks = getPeaks(inData, minPeakHeight)
% Uses findpeaks to obtain some information on the peaks present in the
% input data

params = Params;

lastwarn('');
warning('off', 'signal:findpeaks:largeMinPeakHeight')

[~, locs, w, p] = findpeaks(inData, params.shimmer_srate, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', params.minPeakDistance);

[~, msgid] = lastwarn;

if strcmpi(msgid,'signal:findpeaks:largeMinPeakHeight')
    peaks = [];
    return
end

peaks = struct();

peaks.widths = w;
peaks.prominence = p;

peaks.avgProminence = mean(p);
peaks.avgWidth = mean(w);
peaks.avgDistance = mean(diff(locs));

end

