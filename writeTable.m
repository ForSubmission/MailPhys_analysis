function writeTable(alldata_dir)
% Reads back analysed json files (0.json, 1.json, etc) for one participant and outputs a table
% from that, saving it in the participant folder

jsonI = 0;  % start from 0 and stop when there's no more files

if nargin < 1
    alldata_dir = uigetdir('', 'Select folder containing numbered json files');
end

filename = [alldata_dir filesep num2str(jsonI) '.json'];
while exist(filename)
    jsonI = jsonI + 1;
    filename = [alldata_dir filesep num2str(jsonI) '.json'];
end
nOfFiles = jsonI;

assert(nOfFiles > 0, 'No files found');

msgNo = zeros(nOfFiles,1);
id = cell(nOfFiles, 1);
from = cell(nOfFiles, 1);
priority = zeros(nOfFiles,1);
workload = zeros(nOfFiles,1);
binaryPriority = zeros(nOfFiles,1);
pleasure = zeros(nOfFiles,1);
binaryPleasure = zeros(nOfFiles,1);
binaryWorkload = zeros(nOfFiles,1);
eagerlyExpected = zeros(nOfFiles,1);

spam = zeros(nOfFiles,1);
wasUnread = zeros(nOfFiles,1);

nOfKeywords = zeros(nOfFiles,1);
avgKeywordDuration = zeros(nOfFiles,1);
keywordDurationStd = zeros(nOfFiles,1);

headAccelInt = zeros(nOfFiles,1);
handAccelInt = zeros(nOfFiles,1);

corrInt = zeros(nOfFiles,1);
zygoInt = zeros(nOfFiles,1);

phasicInt = zeros(nOfFiles,1);

timeSpent = zeros(nOfFiles, 1);
nOfVisits = zeros(nOfFiles, 1);
meanVisitTime = zeros(nOfFiles, 1);

bodyGazeDurationMean = zeros(nOfFiles, 1);
bodyGazeDurationStd = zeros(nOfFiles, 1);
bodyGazeCount = zeros(nOfFiles, 1);

preThreadGazeDurationMean = zeros(nOfFiles, 1);
preThreadGazeDurationStd = zeros(nOfFiles, 1);
preThreadGazeCount = zeros(nOfFiles, 1);

threadGazeDurationMean = zeros(nOfFiles, 1);
threadGazeDurationStd = zeros(nOfFiles, 1);
threadGazeCount = zeros(nOfFiles, 1);

clickCount = zeros(nOfFiles, 1);
clickSum = zeros(nOfFiles, 1);
pointerCount = zeros(nOfFiles, 1);
pointerSum = zeros(nOfFiles, 1);
keyboardCount = zeros(nOfFiles, 1);
keyboardSum = zeros(nOfFiles, 1);

emgCorrObw = zeros(nOfFiles, 1);
emgCorrMedfreq = zeros(nOfFiles, 1);
emgCorrMeanfreq = zeros(nOfFiles, 1);
emgCorrPowerbw = zeros(nOfFiles, 1);

emgZygoObw = zeros(nOfFiles, 1);
emgZygoMedfreq = zeros(nOfFiles, 1);
emgZygoMeanfreq = zeros(nOfFiles, 1);
emgZygoPowerbw = zeros(nOfFiles, 1);

edaObw = zeros(nOfFiles, 1);
edaMedfreq = zeros(nOfFiles, 1);
edaMeanfreq = zeros(nOfFiles, 1);
edaPowerbw = zeros(nOfFiles, 1);

headObw = zeros(nOfFiles, 1);
headMedfreq = zeros(nOfFiles, 1);
headMeanfreq = zeros(nOfFiles, 1);
headPowerbw = zeros(nOfFiles, 1);

handObw = zeros(nOfFiles, 1);
handMedfreq = zeros(nOfFiles, 1);
handMeanfreq = zeros(nOfFiles, 1);
handPowerbw = zeros(nOfFiles, 1);

headMeanDiff = zeros(nOfFiles, 1);
emgCorrMeanDiff = zeros(nOfFiles, 1);
emgZygoMeanDiff = zeros(nOfFiles, 1);

headMeanAbsDiff = zeros(nOfFiles, 1);
emgCorrMeanAbsDiff = zeros(nOfFiles, 1);
emgZygoMeanAbsDiff = zeros(nOfFiles, 1);

headIntDiff = zeros(nOfFiles, 1);
emgCorrIntDiff = zeros(nOfFiles, 1);
emgZygoIntDiff = zeros(nOfFiles, 1);

edaMeanDiff = zeros(nOfFiles, 1);
edaMeanAbsDiff = zeros(nOfFiles, 1);
edaIntDiff = zeros(nOfFiles, 1);

handMeanDiff = zeros(nOfFiles, 1);
handMeanAbsDiff = zeros(nOfFiles, 1);
handIntDiff = zeros(nOfFiles, 1);

edaMaxPeakTimeDiff = zeros(nOfFiles, 1);
edaMinPeakTimeDiff = zeros(nOfFiles, 1);
edaMeanPeakTimeDiff = zeros(nOfFiles, 1);
edaMaxPeakAmp = zeros(nOfFiles, 1);
edaMinPeakAmp = zeros(nOfFiles, 1);
edaMeanPeakAmp = zeros(nOfFiles, 1);

for rowNo = 1 : nOfFiles
    filename = [alldata_dir filesep num2str(rowNo - 1) '.json'];
    
    text = fileread(filename);
    json = jsondecode(text);
    
    msgNo(rowNo) = rowNo - 1;
    priority(rowNo) = json.priority;
    binaryPriority(rowNo) = json.priority > 2.5;
    pleasure(rowNo) = json.pleasure;
    binaryPleasure(rowNo) = json.pleasure > 2.5;
    eagerlyExpected(rowNo) = json.eagerlyExpected;
    
    binaryWorkload(rowNo) = json.workload > 2.5;
    workload(rowNo) = json.workload;

    id{rowNo} = json.id;
    from{rowNo} = json.fromString;
    
    spam(rowNo) = json.spam;
    wasUnread(rowNo) = json.wasUnread;
    
    nOfKeywords(rowNo) = numel(json.keywords);
    
    keywordGazeDurations = structSub2Vector(json.keywords, 'gazeDurations');
    avgKeywordDuration(rowNo) = mean(keywordGazeDurations);
    keywordDurationStd(rowNo) = std(keywordGazeDurations);
    
    headAccelInt(rowNo) = json.emg.accelInt;
    handAccelInt(rowNo) = json.eda.accelInt;
    
    corrInt(rowNo) = json.emg.corrInt;
    zygoInt(rowNo) = json.emg.zygoInt;
    
    phasicInt(rowNo) = json.eda.phasicInt;
    
    timeSpent(rowNo) = json.endUnixtime - json.startUnixtime;
    nOfVisits(rowNo) = numel(json.visits);
    
    visitTimes = zeros(numel(json.visits), 1);
    for i = 1 : numel(json.visits)
        visitTimes(i) = json.visits(i).endUnixtime - json.visits(i).startUnixtime;
    end
    meanVisitTime(rowNo) = mean(visitTimes);
    
    emgCorrObw(rowNo) = json.emg.corrObw;
    emgCorrMedfreq(rowNo) = json.emg.corrMedfreq;
    emgCorrMeanfreq(rowNo) = json.emg.corrMeanfreq;
    emgCorrPowerbw(rowNo) = json.emg.corrPowerbw;

    emgZygoObw(rowNo) = json.emg.zygoObw;
    emgZygoMedfreq(rowNo) = json.emg.zygoMedfreq;
    emgZygoMeanfreq(rowNo) = json.emg.zygoMeanfreq;
    emgZygoPowerbw(rowNo) = json.emg.zygoPowerbw;

    edaObw(rowNo) = json.eda.obw;
    edaMedfreq(rowNo) = json.eda.medfreq;
    edaMeanfreq(rowNo) = json.eda.meanfreq;
    edaPowerbw(rowNo) = json.eda.powerbw;
    
    headObw(rowNo) = json.emg.accelObw;
    headMedfreq(rowNo) = json.emg.accelMedfreq;
    headMeanfreq(rowNo) = json.emg.accelMeanfreq;
    headPowerbw(rowNo) = json.emg.accelPowerbw;
    
    handObw(rowNo) = json.eda.accelObw;
    handMedfreq(rowNo) = json.eda.accelMedfreq;
    handMeanfreq(rowNo) = json.eda.accelMeanfreq;
    handPowerbw(rowNo) = json.eda.accelPowerbw;
    
    handMeanDiff(rowNo) = json.eda.accelMeanDiff;
    handMeanAbsDiff(rowNo) = json.eda.accelMeanAbsDiff;
    handIntDiff(rowNo) = json.eda.accelIntDiff;
    
    headMeanDiff(rowNo) = json.emg.accelMeanDiff;
    emgCorrMeanDiff(rowNo) = json.emg.corrMeanDiff;
    emgZygoMeanDiff(rowNo) = json.emg.zygoMeanDiff;

    headMeanAbsDiff(rowNo) = json.emg.accelMeanAbsDiff;
    emgCorrMeanAbsDiff(rowNo) = json.emg.corrMeanAbsDiff;
    emgZygoMeanAbsDiff(rowNo) = json.emg.zygoMeanAbsDiff;

    headIntDiff(rowNo) = json.emg.accelIntDiff;
    emgCorrIntDiff(rowNo) = json.emg.corrIntDiff;
    emgZygoIntDiff(rowNo) = json.emg.zygoIntDiff;

    edaMeanDiff(rowNo) = json.eda.meanDiff;
    edaMeanAbsDiff(rowNo) = json.eda.meanAbsDiff;
    edaIntDiff(rowNo) = json.eda.intDiff;

    edaMaxPeakTimeDiff(rowNo) = json.eda.maxPeakTimeDiff;
    edaMinPeakTimeDiff(rowNo) = json.eda.minPeakTimeDiff;
    edaMeanPeakTimeDiff(rowNo) = json.eda.meanPeakTimeDiff;
    edaMaxPeakAmp(rowNo) = json.eda.maxPeakAmp;
    edaMinPeakAmp(rowNo) = json.eda.minPeakAmp;
    edaMeanPeakAmp(rowNo) = json.eda.meanPeakAmp;
    
    [bodyGazeDurationMean(rowNo), bodyGazeDurationStd(rowNo), bodyGazeCount(rowNo)] = read_gaze(json.gazes.body);
    if isfield(json, 'pre_gazes')
        [preThreadGazeDurationMean(rowNo), preThreadGazeDurationStd(rowNo), preThreadGazeCount(rowNo)] = read_gaze(json.pre_gazes.thread);
    else
        preThreadGazeDurationMean(rowNo) = 0;
        preThreadGazeDurationStd(rowNo) = 0;
        preThreadGazeCount(rowNo) = 0;
    end
    [threadGazeDurationMean(rowNo), threadGazeDurationStd(rowNo), threadGazeCount(rowNo)] = read_gaze(json.gazes.thread);
    
    [clickCount(rowNo), clickSum(rowNo)] = read_active(json.clickActivity);
    [pointerCount(rowNo), pointerSum(rowNo)] = read_active(json.pointerActivity);
    [keyboardCount(rowNo), keyboardSum(rowNo)] = read_active(json.keyboardActivity);

    
end

spam = categorical(spam);

tab = table(msgNo, id, from, priority, pleasure, workload, eagerlyExpected, spam, nOfKeywords, wasUnread, avgKeywordDuration, keywordDurationStd, headAccelInt, handAccelInt, phasicInt, corrInt, zygoInt, binaryPriority, binaryPleasure, binaryWorkload, timeSpent, bodyGazeDurationMean, bodyGazeDurationStd, bodyGazeCount, preThreadGazeDurationMean, preThreadGazeDurationStd, preThreadGazeCount, threadGazeDurationMean, threadGazeDurationStd, threadGazeCount, clickCount, clickSum, pointerCount, pointerSum, keyboardCount, keyboardSum, ...
            emgCorrObw, emgCorrMedfreq, emgCorrMeanfreq, emgCorrPowerbw, emgZygoObw, emgZygoMedfreq, emgZygoMeanfreq, emgZygoPowerbw, edaObw, edaMedfreq, edaMeanfreq, edaPowerbw, ...
            nOfVisits, meanVisitTime, headObw, headMedfreq, headMeanfreq, headPowerbw, handObw, handMedfreq, handMeanfreq, handPowerbw, ...
            headMeanDiff, emgCorrMeanDiff, emgZygoMeanDiff, headMeanAbsDiff, emgCorrMeanAbsDiff, emgZygoMeanAbsDiff, headIntDiff, emgCorrIntDiff, emgZygoIntDiff, edaMeanDiff, edaMeanAbsDiff, edaIntDiff, handMeanDiff, handMeanAbsDiff, handIntDiff, edaMaxPeakTimeDiff, edaMinPeakTimeDiff, edaMeanPeakTimeDiff, edaMaxPeakAmp, edaMinPeakAmp, edaMeanPeakAmp, ...
            'VariableNames', ...
            {'msgNo' 'id' 'from' 'priority' 'pleasure' 'workload' 'eagerlyExpected' 'spam' 'nOfKeywords' 'wasUnread' 'avgKeywordDuration' 'keywordDurationStd' 'headAccelInt' 'handAccelInt' 'phasicInt' 'corrInt' 'zygoInt' 'binaryPriority' 'binaryPleasure' 'binaryWorkload' 'timeSpent' 'bodyGazeDurationMean' 'bodyGazeDurationStd' 'bodyGazeCount' 'preThreadGazeDurationMean' 'preThreadGazeDurationStd' 'preThreadGazeCount' 'threadGazeDurationMean' 'threadGazeDurationStd' 'threadGazeCount' 'clickCount' 'clickSum' 'pointerCount' 'pointerSum' 'keyboardCount' 'keyboardSum' ...
             'emgCorrObw' 'emgCorrMedfreq' 'emgCorrMeanfreq' 'emgCorrPowerbw' 'emgZygoObw' 'emgZygoMedfreq' 'emgZygoMeanfreq' 'emgZygoPowerbw' 'edaObw' 'edaMedfreq' 'edaMeanfreq' 'edaPowerbw' ...
             'nOfVisits' 'meanVisitTime' 'headObw' 'headMedfreq' 'headMeanfreq' 'headPowerbw' 'handObw' 'handMedfreq' 'handMeanfreq' 'handPowerbw', ...
             'headMeanDiff' 'emgCorrMeanDiff' 'emgZygoMeanDiff' 'headMeanAbsDiff' 'emgCorrMeanAbsDiff' 'emgZygoMeanAbsDiff' 'headIntDiff' 'emgCorrIntDiff' 'emgZygoIntDiff' 'edaMeanDiff' 'edaMeanAbsDiff' 'edaIntDiff' 'handMeanDiff' 'handMeanAbsDiff' 'handIntDiff' 'edaMaxPeakTimeDiff' 'edaMinPeakTimeDiff' 'edaMeanPeakTimeDiff' 'edaMaxPeakAmp' 'edaMinPeakAmp' 'edaMeanPeakAmp'
             });

tableFile = [alldata_dir filesep 'datatable.mat'];
save(tableFile, 'tab');

disp(['Saved table into ' tableFile ' (' num2str(rowNo) ' rows)']);

end