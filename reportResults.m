function reportResults(participantNumber, repetitions)
% Creates a number of plots (one for each variable) for a given set of results
% and writes figures in pub_PXX

% loop through all results
% find all .mat files (they should contain results)

sfo = ['P' Params.sfo_p];
partString = sprintf(sfo, participantNumber);
resultsDir = [Params.outdir filesep 'results_' partString '_' num2str(repetitions)];
pubDir = [Params.outdir filesep 'pub_' partString '_' num2str(repetitions)];

if ~exist(pubDir)
    mkdir(pubDir)
end

resultFiles = dir([resultsDir filesep '*.mat']);

%% make actual plots

for resultFileNum = 1 : numel(resultFiles)
    resultFile = resultFiles(resultFileNum);
    allResults = load([resultsDir filesep resultFile.name]);
    plotResults(allResults, pubDir);
end

%% p-value reporting

for i = 1:numel(allResults.results)
    for j = 1:numel(allResults.results{i}.predictions)
        pval = allResults.results{i}.predictions{j}.pval;
        superSetName = allResults.descriptor.superSetName;
        setName = allResults.descriptor.featureSets{j,1}{:};
        variable = allResults.results{i}.variable;
        if pval <= 0.05
            snum = ceil(log10(allResults.descriptor.repetitions));
            pstring = sprintf(['%.' num2str(snum) 'f'], pval);
            disp(['Significant: ' superSetName ', ' setName ', ' variable ' (p=' pstring ')']);
        end
    end
end
    
end

function plotResults(allResults, publishDir)
    % plot a set of results for a give featureSet / signal combination
    
    fig = figure;
    
    descriptor = allResults.descriptor;

    MAXROWS = 4;  % maximum number of rows, then use columns
    VPUSH = 0.03;  % push all axes up by this amount to make space for labels

    subPlotColumns = floor((numel(descriptor.variables)-1)/MAXROWS) + 1;
    subPlotRows = ceil(numel(descriptor.variables) / subPlotColumns);

    allAxes = cell(numel(descriptor.variables), 1);

    for i = 1 : numel(allResults.results)
        result = allResults.results{i};
        
        allAxes{i} = subplot(subPlotRows, subPlotColumns, i);

        makePlot(result, descriptor, allAxes{i});

        isLastRow = ceil(i/subPlotColumns) == subPlotRows;
        modcol = mod(numel(descriptor.variables), subPlotColumns);
        isLastOddRow = modcol > 0 && ceil((i+modcol)/subPlotColumns) == subPlotRows;

        % remove ticks if this is not a bottom row
        if ~(isLastRow || isLastOddRow)
            allAxes{i}.XTickLabel = {};
        end

        allAxes{i}.ActivePositionProperty = 'position';
    end

    setTitle = descriptor.outName;

    fig.Position(3) = fig.Position(3) * subPlotColumns; % enlarge width
    fig.Position(4) = fig.Position(4) * 1.65; % sligtly enlarge height to fit labels

    % push all subplot axes up by VPUSH
    for i = 1 : numel(allAxes)

        row = ceil(i/subPlotColumns);

        allAxes{i}.Position(2) = allAxes{i}.Position(2) + VPUSH*row;

    end

    % create title for whole figure, not available on all installations
    if exist('suptitle','file')
        suptitle(setTitle);
    end

    setTitle = strrep(setTitle, ' ', '_');
    outFile = [publishDir filesep setTitle];
    print(fig, outFile, '-depsc');

    disp(['Saved ' outFile '.eps']);
end