function preprocess_eda(input_file)
% Extracts EDA data from csv files and runs Ledalab on them.
% They will be outputted in Params.outdir/edatemp
% input_file: path of csv file containing Shimmer data.
% if no paramter is given, opens dialog

% Read common parameters
params = Params;
edatemp = params.edatemp;
edaduplicate = params.edaduplicate;
basedir = params.basedir;

if nargin < 1
    [filename, pathname, ~] = uigetfile('*.csv', 'Choose GSR csv file');
    input_file = [pathname filesep filename];
end

indata = csvread(input_file, 3);

% columns
% 1: timestamp (ms)
% 2: accel_x
% 3: accel_y
% 4: accel_z
% 5: range (should be 1, or at least make sure it doesn't change)
% 6: Skin Conductance
% 7: Skin Resistance

iTimestamp = 1;
iRange = 5;
iSC = 6;

hadWarnings = 0;

% make sure range is different from 1 only at start, then exclude
% every row for which range ~= 1

badRangeIs = find(indata(:, iRange)~=1);
if numel(badRangeIs) > 0 && badRangeIs(1) ~= 1
    hadWarnings = 1;
    warning('EDAPREP:BadRangeStart','GSR range is at an unexpected level long after data recording started.');
end
% throw warning if range changes
if numel(badRangeIs) > 0 && all(diff(badRangeIs) == 1) ~= 1
    hadWarnings = 1;
    warning('EDAPREP:BadRangeAfter','GSR range changes after start');
end

% get row indices for which range ~= 1 (only at start)
notOneRows = find(indata(:, iRange) ~= 1);
rowSkips = find(diff(notOneRows)>1); % if this contains something, set removedRows only for the first chunk of notOneRows
if numel(rowSkips) > 1
    removedRows = notOneRows(1:rowSkips(1));
else
    removedRows = notOneRows;
end

% throw warning if removed rows is greater than 30
if numel(removedRows) > 30
    hadWarnings = 1;
    removedRows = [];
    warning('EDAPREP:ManyRowsToRemove',['Keeping GSR range to 1 at start would require the removal of ' num2str(numel(removedRows)) ' rows, so no rows were removed']);
end

% remove rows for which range is not 1 at start
indata = removerows(indata, removedRows);

data = struct();

data.conductance = indata(:, iSC);
    
% remove negative values by adding constant

if min(data.conductance) < 0
    data.conductance = data.conductance - min(data.conductance);
end

% divide timestamp by 1000 to get seconds (Ledalab represents time
% using seconds)

% it appears Ledalab will overwrite our representation of time, regardless
% of what we do here

data.time = indata(:, iTimestamp) / 1000;
data.conductance = data.conductance';
data.time = data.time';
data.timeoff = 0;
data.event = [];

[~, name, ~] = fileparts(input_file);
spl = strsplit(name, '_');
outName = ['EDA_' spl{2} '_' spl{3} '.mat'];

if ~exist(basedir, 'dir')
    mkdir(basedir);
end
if ~exist(edatemp, 'dir')
    mkdir(edatemp);
end
if ~exist(edaduplicate, 'dir')
    mkdir(edaduplicate);
end
outMatFile = [edatemp filesep outName];
save(outMatFile, 'data');

% for some odd reason (filsystem bug?) Ledalab fails to load
% the file unless it is duplicated in a subfolder, so lets do that

save([edaduplicate filesep outName], 'data');

% if we had any warnings, wait for user input
if hadWarnings
    figure;
    plot(indata(:,iSC));
    disp('Some warnings were outputted. Check data plot for potential artefacts. Press enter to continue (ctrl-c to stop).');
    pause;
    close all;
end

% Runs ledalab in the duplicate folder (actual files analyses will be in
% the folder which contains the duplicates

Ledalab(edaduplicate, 'open', 'mat', 'analyze','CDA', 'optimize', 4);

% this produces GSR_PXX_SX_EDA.mat files, which can then be put in the Data
% folder

% in such files, analysis.phasicData will contain the EDA phasic time
% series we are interested in

save(outName, 'removedRows', '-append');
if ~isempty(removedRows)
    disp(['Removed rows ' num2str(removedRows') '. These were saved in the EDA matfile under removedRows']);
else
    disp('No rows removed');
end

delete([edaduplicate filesep outName]);
delete('batchmode_protocol.mat');

disp(['Wrote EDA data into ' outMatFile]);

end

