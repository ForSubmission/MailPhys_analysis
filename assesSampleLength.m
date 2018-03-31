function result = assesSampleLength(nOfSamples, startTime, endTime)
% returns true if the number of samples is within a given time difference
% the time difference is defined in params.timeThresh

params = Params;

timeDiff = endTime - startTime;
timeDiffS = nOfSamples / params.shimmer_srate;

result = abs(timeDiff / 1000 - timeDiffS) < params.timeThresh;

end

