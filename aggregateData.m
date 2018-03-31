function aggregateData(source)
% Collects all data stored in various files from one participants and outputs all
% json files for that participant, one per email, containing all data
% collected, in chronological order
% source: where source files are located. If this parameter is not given
% opens a dialog asking for directory location.

%% setup
params = Params;
basedir = params.basedir;

if nargin < 1
    source = uigetdir('', 'Select folder containing all source data');
end

% find all json files
mails = dir([source filesep 'MAIL_*']);

% create output dir if it doesn't exist

outdir = params.outdir;

if ~exist(basedir, 'dir')
    mkdir(basedir);
end
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

filenum = 0;
doneNames = {};

emgData_file = struct();
emgData_file.time = [];
emgData_file.accelX = [];
emgData_file.accelY = [];
emgData_file.accelZ = [];
emgData_file.corr = [];
emgData_file.zygo = [];
    
gsrData_file = struct();
gsrData_file.time = [];
gsrData_file.accelX = [];
gsrData_file.accelY = [];
gsrData_file.accelZ = [];
gsrData_file.gsr = [];
gsrData_file.phasic = [];

maildir = mails(1);

% get account number and session number
spl = strsplit(maildir.name, '_');

pString = spl{2};

outdir = [outdir filesep pString];

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

disp(['Writing data to ' outdir]);
    
for maildirI = 1:numel(mails)
    %% read jsons in mail folder
    
    maildir = mails(maildirI);
    
    % get account number and session number
    spl = strsplit(maildir.name, '_');
    
    sesString = spl{3};
    
    sesNum = str2num(sesString(2));
    accNum = str2num(spl{4}(2));
    
    mailJsons = dir([source filesep maildir.name filesep 'MailEye_*']);
    
    % look through all jsons and make list of startTimes and their related
    % json name
    jsonSortTable = struct();
    for jsonI = 1:numel(mailJsons)
        path = [mailJsons(jsonI).folder filesep mailJsons(jsonI).name];
        
        text = fileread(path);
        
        json = jsondecode(text);
        
        jsonSortTable(jsonI).path = path;
        jsonSortTable(jsonI).name = mailJsons(jsonI).name;
        jsonSortTable(jsonI).startTime = json.startUnixtime;
    end
    
    jsonSortTable = struct2table(jsonSortTable);
    jsonSortTable = sortrows(jsonSortTable, 'startTime');
    
    %% prepare data
    
    % read data all data, then for each json aggregate emg and eda
    % and calculate some simple features on them
    
    emgData_raw = csvread([maildir.folder filesep 'EMG_' pString '_' sesString '.csv' ], params.csvStart);
    gsrData_raw = csvread([maildir.folder filesep 'GSR_' pString '_' sesString '.csv' ], params.csvStart);
    edaData = load([maildir.folder filesep 'EDA_' pString '_' sesString '.mat' ]);
        
    % remove discarded rows from gsrData (removedRows, if any)
    if isfield(edaData, 'removedRows') 
        gsrData_raw(edaData.removedRows, :) = [];
    end
    
    phasicData = edaData.analysis.phasicData';
    gsrRows = size(gsrData_raw, 1);
    edaRows = size(phasicData, 1);
    
    assert(gsrRows == edaRows, 'AGGR:EDAMISMATCH', ['Eda data and gsr data number of rows do not match. eda: ' num2str(edaRows) '. gsr:' num2str(gsrRows) '.']);
   
    % normalise accelerometer and fEMG using our custom function
    emgData_normalised = normalisePhysio(emgData_raw, [2:4 6 7]);
    
    % process emg data using specs in paper (10 Hz high pass)
    emgData_processed = processPhysio(emgData_raw, [6 7], 10);
    % process head accel using specs in paper (0.3 Hz high pass)
    emgData_processed = processPhysio(emgData_processed, 2:4, 0.3);
    % calculate mean head accelerometer and process it too
    emgData_meanAccel = mean(emgData_raw(:, 2:4), 2);
    emgData_mean_processed = processPhysio(emgData_meanAccel, 1, 0.3);
    
    % normalise accelerometer using our custom function
    gsrData_normalised = normalisePhysio(gsrData_raw, 2:4);
    
    % process wrist accelerometer using specs in paper (0.3 Hz high pass)
    gsrData_processed = processPhysio(gsrData_raw, 2:4, 0.3);
    % calculate mean head accelerometer and process it too
    gsrData_meanAccel = mean(gsrData_raw(:, 2:4), 2);
    gsrData_mean_processed = processPhysio(gsrData_meanAccel, 1, 0.3);
    
    %% save raw vectors of all data to json
    emgData_file.time = vertcat(emgData_file.time, emgData_raw(:, params.iTimestamp));
    emgData_file.accelX = vertcat(emgData_file.accelX, emgData_raw(:, params.iaccX));
    emgData_file.accelY = vertcat(emgData_file.accelY, emgData_raw(:, params.iaccY));
    emgData_file.accelZ = vertcat(emgData_file.accelZ, emgData_raw(:, params.iaccZ));
    emgData_file.corr = vertcat(emgData_file.corr, emgData_raw(:, params.iCorr));
    emgData_file.zygo = vertcat(emgData_file.zygo, emgData_raw(:, params.iZygo));
    
    outtext = jsonencode(emgData_file);
    fid = fopen([outdir filesep 'emgData.json'], 'w');
    fprintf(fid, outtext);
    
    gsrData_file.time = vertcat(gsrData_file.time, gsrData_raw(:, params.iTimestamp));
    gsrData_file.accelX = vertcat(gsrData_file.accelX, gsrData_raw(:, params.iaccX));
    gsrData_file.accelY = vertcat(gsrData_file.accelY, gsrData_raw(:, params.iaccY));
    gsrData_file.accelZ = vertcat(gsrData_file.accelZ, gsrData_raw(:, params.iaccZ));
    gsrData_file.gsr = vertcat(gsrData_file.gsr, gsrData_raw(:, params.iGSR));
    gsrData_file.phasic = vertcat(gsrData_file.phasic, phasicData);
    
    outtext = jsonencode(gsrData_file);
    fid = fopen([outdir filesep 'gsrData.json'], 'w');
    fprintf(fid, outtext);
    % end of raw vector save
    
    %% one-by-one aggregation
    for tableI = 1:size(jsonSortTable, 1)
        
        name = jsonSortTable{tableI, 'name'};
        
        % skip if this file name was already done
        if any(contains(doneNames, name))
            continue
        end
        doneNames = [doneNames{:} name];
        
        text = fileread(jsonSortTable{tableI, 'path'}{1});
        json = jsondecode(text);

        json.emg = aggregate_emg(emgData_raw, emgData_normalised, emgData_processed, emgData_mean_processed, json.startUnixtime, json.endUnixtime);
        json.eda = aggregate_eda(gsrData_raw, gsrData_normalised, gsrData_processed, gsrData_mean_processed, edaData, json.startUnixtime, json.endUnixtime);
        
        % save session and account number in output json
        json.session = sesNum;
        json.account = accNum;
        
        % get raw eye data (saved in Fixations_*.json)
        nameSplit = strsplit(name{:}, '_');
        rawEyeName = ['Fixations_' nameSplit{2}];
        rawEyeFile = [source filesep maildir.name filesep rawEyeName];
        text = fileread(rawEyeFile);
        
        rawEyeData = jsondecode(text);
        json.rawEyeData = rawEyeData;
        
        outtext = jsonencode(json);
        fid = fopen([outdir filesep num2str(filenum) '.json'], 'w');
        fprintf(fid, outtext);
        filenum = filenum + 1;
        
    end
    
end

disp(['Done, wrote ' num2str(filenum) ' files.']);

end