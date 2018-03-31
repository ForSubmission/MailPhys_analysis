function emg = aggregate_emg(emgData_raw, emgData_normalised, emgData_processed, emgData_mean_processed, startTime, endTime)
% Retrieve data found in emgData corresponding to what is found between
% starTime and endTime

params = Params;

% csv columns
% 1: timestamp (ms)
% 2: accel_x
% 3: accel_y
% 4: accel_z
% 5: status (always 128?)
% 6: emg_corr (channel 1) 
% 7: emg_zygo (channel 2)

iTimestamp = params.iTimestamp;
iaccX = params.iaccX;
iaccY = params.iaccY;
iaccZ = params.iaccZ;
iCorr = params.iCorr;
iZygo = params.iZygo;
srate = params.shimmer_srate;

% find all rows indices for which timestamp is greater than start and lower
% than end
rangeIs = find(emgData_raw(:, iTimestamp) > startTime & emgData_raw(:, iTimestamp) < endTime);

% all columns of rows whose timestamp is greater than start and less than end 
withinRange_raw = emgData_raw(rangeIs, :); %#ok<*FNDSB>
withinRange_normalised = emgData_normalised(rangeIs, :);
withinRange_processed = emgData_processed(rangeIs, :);
withinRange_meanAccel = emgData_mean_processed(rangeIs, :);

N = numel(rangeIs);

assert(assesSampleLength(size(withinRange_raw, 1), startTime, endTime), 'EMG:AGGR:RANGEFAIL', 'A sample time difference between number of samples and time is too great');

% calculate total integration of accel data to summarise overall movement
accelInt = trapz(withinRange_processed(:, iaccX)) + trapz(withinRange_processed(:, iaccY)) + trapz(withinRange_processed(:, iaccZ));

emg = struct();
emg.accelMean = withinRange_meanAccel;
emg.accelMeanInt = trapz(withinRange_meanAccel) / N;
emg.accelInt = accelInt / N;
emg.accX = withinRange_processed(:, iaccX);
emg.accY = withinRange_processed(:, iaccY);
emg.accZ = withinRange_processed(:, iaccZ);
emg.accX_n = withinRange_normalised(:, iaccX);
emg.accY_n = withinRange_normalised(:, iaccY);
emg.accZ_n = withinRange_normalised(:, iaccZ);

emg.corrugator = withinRange_processed(:, iCorr);
emg.zygomaticus = withinRange_processed(:, iZygo);
emg.corrugator_n = withinRange_normalised(:, iCorr);
emg.zygomaticus_n = withinRange_normalised(:, iZygo);
emg.corrInt = trapz(withinRange_processed(:, iCorr)) / N;
emg.zygoInt = trapz(withinRange_processed(:, iZygo)) / N;
emg.corrInt_n = trapz(withinRange_normalised(:, iCorr)) / N;
emg.zygoInt_n = trapz(withinRange_normalised(:, iZygo)) / N;

emg.accelObw = obw(withinRange_meanAccel, srate);
emg.accelMedfreq = medfreq(withinRange_meanAccel, srate);
emg.accelMeanfreq = meanfreq(withinRange_meanAccel, srate);
emg.accelPowerbw = powerbw(withinRange_meanAccel, srate);

emg.corrObw = obw(emg.corrugator, srate);
emg.corrMedfreq = medfreq(emg.corrugator, srate);
emg.corrMeanfreq = meanfreq(emg.corrugator, srate);
emg.corrPowerbw = powerbw(emg.corrugator, srate);

emg.zygoObw = obw(emg.zygomaticus, srate);
emg.zygoMedfreq = medfreq(emg.zygomaticus, srate);
emg.zygoMeanfreq = meanfreq(emg.zygomaticus, srate);
emg.zygoPowerbw = powerbw(emg.zygomaticus, srate);

emg.accelMeanDiff = mean(diff(emg.accelMean));
emg.corrMeanDiff = mean(diff(emg.corrugator));
emg.zygoMeanDiff = mean(diff(emg.zygomaticus));

emg.accelMeanAbsDiff = mean(abs(diff(emg.accelMean)));
emg.corrMeanAbsDiff = mean(abs(diff(emg.corrugator)));
emg.zygoMeanAbsDiff = mean(abs(diff(emg.zygomaticus)));

emg.accelIntDiff = trapz(diff(emg.accelMean)) / N;
emg.corrIntDiff = trapz(diff(emg.corrugator)) / N;
emg.zygoIntDiff = trapz(diff(emg.zygomaticus)) / N;

end

