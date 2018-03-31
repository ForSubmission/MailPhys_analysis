classdef SetCollection
    % Contains a predefined collection of feature sets
    
    properties (Constant)
        
        % individual signals are aggregated using these features
        
        % features are computed by aggregateData.m and written into a table
        % by writeTable.m
        
        % each feature is prefixed by the sensor from which it came and
        % is suffixed with the function that was used to create the
        % feature
        
        % suffixes:
        
        % - Int: Integration
        % - MeanDiff: Mean of diff (differentiation)
        % - MeanAbsDiff: Mean of absolute diff
        % - IntDiff: Integration of diff
        % - Obw: 99% occupied bandwidth
        % - Medfreq: median frequency
        % - Meanfreq: mean frequency
        % - Powerbw: 3-db power bandwidth
        % - MaxPeakTimeDiff: maximum difference between peak time diff (eda only - uses Ledalab's .peakTimes)
        % - MinPeakTimeDiff: minimum difference between peak time diff (eda only - uses Ledalab's .peakTimes)
        % - MeanPeakTimeDiff: mean of all peak time diff (eda only - uses Ledalab's .peakTimes)
        % - MaxPeakAmp: maximum of peak amplitudes (eda only - uses Ledalab's .peakTimes)
        % - MinPeakAmp: minimum of peak amplitudes (eda only - uses Ledalab's .peakTimes)
        % - MeanPeakAmp: mean of all peak amplitudes (eda only - uses Ledalab's .peakTimes)
        % - Count: count of all values found in array (e.g. using numel function)
        % - Sum: summation of all values found in array
        
        hand = {'handAccelInt' 'handMeanDiff' 'handMeanAbsDiff' 'handIntDiff' 'headObw' 'headMedfreq' 'headMeanfreq' 'headPowerbw'};
        head = {'headAccelInt' 'headMeanDiff' 'headMeanAbsDiff' 'headIntDiff' 'handObw' 'handMedfreq' 'handMeanfreq' 'handPowerbw'};
        corru = {'corrInt' 'emgCorrMeanDiff' 'emgCorrMeanAbsDiff' 'emgCorrIntDiff' 'emgCorrObw' 'emgCorrMedfreq' 'emgCorrMeanfreq' 'emgCorrPowerbw'};
        eda = {'phasicInt' 'edaMeanDiff' 'edaMeanAbsDiff' 'edaIntDiff' 'edaMaxPeakTimeDiff' 'edaMinPeakTimeDiff' 'edaMeanPeakTimeDiff' 'edaMaxPeakAmp' 'edaMinPeakAmp' 'edaMeanPeakAmp' 'edaObw' 'edaMedfreq' 'edaMeanfreq' 'edaPowerbw'};
        zygo = {'zygoInt' 'emgZygoMeanDiff' 'emgZygoMeanAbsDiff' 'emgZygoIntDiff' 'emgZygoObw' 'emgZygoMedfreq' 'emgZygoMeanfreq' 'emgZygoPowerbw'};
        activity = {'clickCount' 'clickSum' 'pointerCount' 'pointerSum' 'keyboardCount' 'keyboardSum'};
        
        % visits features are obtained from AgumentedMessage, using the visits array
        visits = {'timeSpent' 'nOfVisits' 'meanVisitTime'};
        
        % gaze features are mean, standard deviation and count of fixation durations
        gazeB = {'bodyGazeDurationMean' 'bodyGazeDurationStd' 'bodyGazeCount'};
        gazeT = {'preThreadGazeDurationMean' 'preThreadGazeDurationStd' 'preThreadGazeCount' 'threadGazeDurationMean' 'threadGazeDurationStd' 'threadGazeCount'}
        
        % keyword gaze features are extracted from the .keywords field found in AugmentedMessage
        gazeK = {'nOfKeywords' 'avgKeywordDuration' 'keywordDurationStd'}
        
    end
    
    methods (Static)
        
        % more high level features are obtained by combining signals
        
        function ac = accel()
            ac = horzcat(SetCollection.hand, SetCollection.head);
        end
        
        function fm = emg()
            fm = horzcat(SetCollection.corru, SetCollection.zygo);
        end
        
        function gz = gaze()
            gz = horzcat(SetCollection.gazeB, SetCollection.gazeT, SetCollection.gazeK);
        end
        
        function aa = behav()
            aa = horzcat(SetCollection.visits, SetCollection.activity);
        end
        
        function ee = all()
            ee = horzcat(SetCollection.behav(), SetCollection.gaze(), SetCollection.emg(), SetCollection.accel(), SetCollection.eda());
        end
        
    end
    
end

