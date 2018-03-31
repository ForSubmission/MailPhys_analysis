function eda = aggregate_eda(gsrData_raw, gsrData_normalised, gsrData_processed, gsrData_mean_processed, edaData, startTime, endTime)
% Returns a struct containing eda metrics calculated within a time window defined by startTime and
% endTime

params = Params;

% columns in gsrData
% 1: timestamp (ms)
% 2: accel_x
% 3: accel_y
% 4: accel_z
% the columns below are used by eda_preprocess
% 5: range (should be 1, or at least make sure it doesn't change)
% 6: Skin Conductance
% 7: Skin Resistance

iTimestamp = params.iTimestamp;
iaccX = params.iaccX;
iaccY = params.iaccY;
iaccZ = params.iaccZ;
iGSR = params.iGSR;
srate = params.shimmer_srate;

% all columns of rows whose timestamp is greater than start and less than end 

% find all rows indices for which timestamp is greater than start and lower
% than end
rangeIs = find(gsrData_raw(:, iTimestamp) > startTime & gsrData_raw(:, iTimestamp) < endTime);

phasicData = edaData.analysis.phasicData';
phasicMed = median(phasicData);

% the two lines below are equal
%withinRange = gsrData(gsrData(:, iTimestamp) > startTime & gsrData(:, iTimestamp) < endTime, :);
withinRange_raw = gsrData_raw(rangeIs, :); %#ok<*FNDSB>
withinRange_normalised = gsrData_normalised(rangeIs, :);
withinRange_processed = gsrData_processed(rangeIs, :);
withinRange_meanAccel = gsrData_mean_processed(rangeIs, :);

edaTime = edaData.data.time';
peakTimes = edaData.analysis.peakTime';
withinRange_edaTime = (edaTime(rangeIs));
withinRange_peakIs = find(peakTimes > min(withinRange_edaTime) & peakTimes < max(withinRange_edaTime))';
withinRange_peakTimes = edaData.analysis.peakTime(withinRange_peakIs)';
withinRange_peakAmps = edaData.analysis.amp(withinRange_peakIs)';

assert(assesSampleLength(size(withinRange_raw, 1), startTime, endTime), 'EDA:AGGR:RANGEFAIL', 'A sample time difference between number of samples and time is too great');

% calculate total integration of accel data to summarise overall movement
accelInt = trapz(withinRange_processed(:, iaccX)) + trapz(withinRange_processed(:, iaccY)) + trapz(withinRange_processed(:, iaccZ));

N = numel(rangeIs);

eda = struct();
eda.accelMean = withinRange_meanAccel;
eda.accelMeanInt = trapz(withinRange_meanAccel) / N;
eda.accelInt = accelInt / N;
eda.accX = withinRange_processed(:, iaccX);
eda.accY = withinRange_processed(:, iaccY);
eda.accZ = withinRange_processed(:, iaccZ);
eda.accX_n = withinRange_normalised(:, iaccX);
eda.accY_n = withinRange_normalised(:, iaccY);
eda.accZ_n = withinRange_normalised(:, iaccZ);

eda.accelObw = obw(withinRange_meanAccel, srate);
eda.accelMedfreq = medfreq(withinRange_meanAccel, srate);
eda.accelMeanfreq = meanfreq(withinRange_meanAccel, srate);
eda.accelPowerbw = powerbw(withinRange_meanAccel, srate);

eda.accelMeanDiff = mean(diff(eda.accelMean));
eda.accelMeanAbsDiff = mean(abs(diff(eda.accelMean)));
eda.accelIntDiff = trapz(diff(eda.accelMean)) / N;

eda.raw = withinRange_raw(:, iGSR);
eda.phasic = phasicData(rangeIs);
eda.phasicInt = trapz(eda.phasic) / N;

eda.obw = obw(eda.phasic, srate);
eda.medfreq = medfreq(eda.phasic, srate);
eda.meanfreq = meanfreq(eda.phasic, srate);
eda.powerbw = powerbw(eda.phasic, srate);

eda.meanDiff = mean(diff(eda.phasic));
eda.meanAbsDiff = mean(abs(diff(eda.phasic)));
eda.intDiff = trapz(diff(eda.phasic)) / N;

Npeaks = numel(withinRange_peakIs);
if Npeaks > 0
    if Npeaks > 1
        eda.maxPeakTimeDiff = max(abs(diff(withinRange_peakTimes)));
        eda.minPeakTimeDiff = min(abs(diff(withinRange_peakTimes)));
        eda.meanPeakTimeDiff = mean(abs(diff(withinRange_peakTimes)));
    else
        eda.maxPeakTimeDiff = 0;
        eda.minPeakTimeDiff = 0;
        eda.meanPeakTimeDiff = 0;
    end
    eda.maxPeakAmp = max(withinRange_peakAmps);
    eda.minPeakAmp = min(withinRange_peakAmps);
    eda.meanPeakAmp = mean(withinRange_peakAmps);
else
    eda.maxPeakTimeDiff = 0;
    eda.minPeakTimeDiff = 0;
    eda.meanPeakTimeDiff = 0;
    eda.maxPeakAmp = 0;
    eda.minPeakAmp = 0;
    eda.meanPeakAmp = 0;
end

end

