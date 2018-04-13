function finalTableMaker(participants, iterations, onlyUnread)
% collect all results for the given participants (vector), created using the given
% number of iterations (scalar)
% onlyUnread can be set to 1 to only perform the test on unread messages

%% significant features summary
% two tables, one for signals the other for combined

% example

% signals
%              unread                 all messages
% featureSets   variable1 variable2 ...  variable1 variable2
%
% feature1    4/6 (.AVG AUC)       4/4 <- number of times feature was significantly better than random
% feature2    3/6 (.AVG AUC)        2/4 (.AVG AUC)
%  . . . 

if nargin < 3
    onlyUnread = 0;
end

signalsSigTable = createSummaryTable(participants, iterations, 'Signals', 'sig', onlyUnread);
combinedSigTable = createSummaryTable(participants, iterations, 'Combined', 'sig', onlyUnread);

outFolder = [Params.outdir filesep 'results_final_' num2str(iterations)];

if ~exist(outFolder)
    mkdir(outFolder)
end

separator = repmat({' '}, 1, size(combinedSigTable, 2));

finalTableBySet = vertcat(signalsSigTable, separator, combinedSigTable);

writetable(finalTableBySet, [outFolder filesep 'finalTable.csv']);

%% best feature summary
% two tables, one for signals the other for combined

% example

% signals                    unread    auc    all messages    auc
%
% participant1 signal      featureSet     x       featureSet         x
% participant1 combined    featureSet     x
% participant2 signal
% participant2 combined


signalsBestTable = createSummaryTable(participants, iterations, 'Signals', 'best', onlyUnread);
combinedBestTable = createSummaryTable(participants, iterations, 'Combined', 'best', onlyUnread);

separator = repmat({' '}, 1, size(signalsBestTable, 2));

finalTableByPart = vertcat(signalsBestTable, separator, combinedBestTable);

writetable(finalTableByPart, [outFolder filesep 'participantTable.csv'])

end

function tab = createSummaryTable(participants, iterations, superSet, type, onlyUnread)
    % returns a table of the given type
    % superset can be either 'Signals' or 'Combined'
    % type can be 'best' for best features or 'sig' for significance table
    
    % table has a row for each feature
    if strcmpi(superSet, 'signals')
        features = fields(SetCollection);
    else
        features = methods(SetCollection);
        features(1) = [];  % skip SetCollection method
    end
    
    % variables: binaryPriority binaryPleasure binaryWorkload spam
    % first for unread then for all messages
    
    variables = {'binaryPriority' 'binaryPleasure' 'binaryWorkload' 'spam'};
    nOfColumns = numel(variables);
    varNames = {};
    if strcmpi(type, 'sig')
        strings = cell(numel(features), nOfColumns);  % x/x outputs, for each feature and variable / unread combination
    else
        strings = cell(numel(participants), nOfColumns);  % featureSet name for each participant, for the given variable
    end
        
    for rowNo = 1 : size(strings, 1)  % featureSetNum == row for sig table
        column = 1;
        if onlyUnread
            appendage = '_unread';
        else
            appendage = '_all';
        end
        for variable = variables
            vname = [variable{:} appendage];
            if ~contains(vname, varNames)
                varNames = horzcat(varNames, vname);
            end

            if strcmpi(type, 'sig')                    
                predictor = features{rowNo};
                [counts, significants, avgAuc] = assessSignificance(participants, variable, predictor, onlyUnread, superSet, iterations);
                if ~isnan(avgAuc)
                    aucString = sprintf('%0.2f', avgAuc);
                    aucString = [' (' aucString(2:end) ')'];
                else
                    aucString = '';
                end
                strings{rowNo, column} = [num2str(significants) '/' num2str(counts) aucString];
            else
                strings{rowNo, column} = bestFeatureSet(participants(rowNo), variable, onlyUnread, superSet, iterations);
            end

            column = column + 1;
        end
    end
    
    tab = table('size', [size(strings, 1), nOfColumns], 'variableTypes', repmat({'cell'}, 1, nOfColumns), 'variableNames', varNames);
    for i = 1 : size(strings, 1)
        for j = 1 : nOfColumns
            tab{i, j} = strings(i, j);
        end
    end
    
    if strcmpi(type, 'sig')
        % add featureSets column and put last column first for sig table
        tab.featureSet = features;
        tab = tab(:, [end 1:end-1]);
    else
        % for best table put participant number first
        tab.partNum = num2cell(participants');
        tab = tab(:, [end 1:end-1]);
    end
    
end

function topString = bestFeatureSet(participantNumber, variable, wasUnread, superSet, iterations)
    % returns the name for the best significant feature and its AUC for the given
    % participant (which predicts this variable)
    % returns '-' if nothing is significant, '!' if variable wasn't present
    
    sfo = ['P' Params.sfo_p];
    partString = sprintf(sfo, participantNumber);
    partDir = [Params.outdir filesep 'results_' partString '_' num2str(iterations)];
    if wasUnread
        appendage = '-only unread.mat';
    else
        appendage = '-all messages.mat';
    end
    matfile = load([partDir filesep superSet appendage]);
    
    result = findresult(matfile, variable);
    
    if isempty(result)
        topString = '!';
        return
    end
    
    topString = '-';
    topAuc = -1;
    for pI = 1:size(matfile.descriptor.featureSets, 1)
        fsetName = matfile.descriptor.featureSets{pI, 1};
        if result.predictions{pI}.pval < 0.05
            if result.predictions{pI}.auc > topAuc
                name = fsetName;
                topAuc = result.predictions{pI}.auc;
                aucString = sprintf('%0.2f', topAuc);
                topString = [name{:} ' (' aucString(2:end) ')'];
            end
        end
    end
end

function [counts, significants, avgAuc] = assessSignificance(participants, variable, predictor, wasUnread, superSet, iterations)
    % superSet can be either 'Signals' or 'Combined'
    % count how many times in total the given variable was present in the
    % result for all participants, and how many times it was significant
    % and the average AUC
    sfo = ['P' Params.sfo_p];
    counts = 0;
    significants = 0;
    aucs = [];
    for partNum = participants
        
        partString = sprintf(sfo, partNum);
        partDir = [Params.outdir filesep 'results_' partString '_' num2str(iterations)];
        if wasUnread
            appendage = '-only unread.mat';
        else
            appendage = '-all messages.mat';
        end
        matfile = load([partDir filesep superSet appendage]);
        [finding, auc] = wasItSignificant(matfile, variable, predictor);
        if finding ~= -1
            counts = counts + 1;
            if finding == 1
                significants = significants + 1;
                aucs = [aucs auc];
            end
        end
    end
    avgAuc = mean(aucs);
end

function [finding, auc] = wasItSignificant(matfile, variable, predictor)
    % given a mat file, a variable and a predictor (featureSet) returns 1 if the given 
    % result was significant, 0 if not, or -1 if the given variable or featureSet was not
    % available
    auc = -1;
    result = findresult(matfile, variable);
    
    if isempty(result)
        finding = -1;
        return
    end
    
    prediction = findprediction(predictor, result, matfile.descriptor);
    
    if isempty(prediction)
        finding = -1;
        return
    end
    
    if prediction.pval < 0.05
        finding = 1;
        auc = prediction.auc;
    else
        finding = 0;
    end
    
end

function result = findresult(matfile, variable)
    % returns the result structure for the given variable (empty if not
    % present)
    
    foundResult = -1;
    for rI = 1:numel(matfile.results)
        result = matfile.results{rI};
        if strcmpi(result.variable, variable)
            foundResult = rI;
            break
        end
    end
    
    if foundResult == -1
        result = [];
        return
    end
    
end

function prediction = findprediction(predictor, result, descriptor)
    % given a predictor (featureSet) a result and a descriptor,
    % return the corresponding prediction (empty if not present)
    
    foundPredictionI = -1;
    for pI = 1:size(descriptor.featureSets, 1)
        fsetName = descriptor.featureSets{pI, 1};
        if strcmpi(predictor, fsetName)
            foundPredictionI = pI;
            break
        end
    end
    
    if foundPredictionI == -1
        prediction = [];
        return
    end
    
    prediction = result.predictions{foundPredictionI};
end