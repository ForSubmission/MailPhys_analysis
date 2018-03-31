function saveResults(participantNumber, repetitions, runOnIndividualFeatures, unreadOnlyVector)
    % Runs a set of classifiers on the given participant, using a
    % permutation test that employs the given number of repetitions
    % runOnIndividualFeatures : if 1, also run all classifiers on every individual
    % feature
    % if unreadVector is set, it is used to define whether we run on
    % unread mssages only (example: [1] or [0 1] or [1 0] or [0])

    if nargin < 3
        runOnIndividualFeatures = 0;
    end
    
    if nargin < 4
        unreadOnlyVector = [0];
    end
    
    %% read parameters

    params = Params;
    outdir = params.outdir;
    sfo = ['P' params.sfo_p];
    partString = sprintf(sfo, participantNumber);
    partFolder = [outdir filesep partString];
    outFolder = [outdir filesep 'results_' partString '_' num2str(repetitions)];

    tableMatFile = [partFolder filesep 'datatable.mat'];    
    disp(['Attempting to read table from ' tableMatFile]);
    tables = load(tableMatFile);

    tab = tables.tab;

    %% classify
    % run both onlyUnread 0 and 1

    for onlyUnread=unreadOnlyVector
        
        variables = {'spam' 'binaryWorkload' 'binaryPleasure' 'binaryPriority'};

        % create set names, where first column is name and second column list of
        % features

        %% signals
        
        sets = {};
        met = fields(SetCollection);

        for i = 1 : numel(met)
            features = SetCollection.(met{i});
            sets = vertcat(sets,{met(i), features});
        end
        
        descriptor = Descriptor(variables, onlyUnread, 'Signals', sets, repetitions);

        runOnSet(tab, descriptor, outFolder);
        
        %% combined

        sets = {};
        met = methods(SetCollection);

        for i = 2 : numel(met)
            features = SetCollection.(met{i});
            sets = vertcat(sets,{met(i), features});
        end
        
        descriptor = Descriptor(variables, onlyUnread, 'Combined', sets, repetitions);

        runOnSet(tab, descriptor, outFolder);
        
        %% individual features
        
        if runOnIndividualFeatures
            
            sets = cell(numel(SetCollection.everything), 2);
            for i = 1 : numel(SetCollection.everything)
                sets{i, 1} = SetCollection.everything{i};
                sets{i, 2} = { SetCollection.everything{i} };
            end

            descriptor = Descriptor(variables, onlyUnread, 'Individual', sets, repetitions);

            runOnSet(tab, descriptor, outFolder);
        
        end
    end

end

function runOnSet(tab, descriptor, outFolder)

    % append 'wasUnread' to feature sets if we are considering read messages
    if ~descriptor.onlyUnread
        % append wasUnread to each feature set
        for i=1:size(descriptor.featureSets,1)
            descriptor.featureSets{i, 2} = horzcat(descriptor.featureSets{i, 2}, 'wasUnread');
        end
        disp('Running on all messages');
    else
        tab(tab.wasUnread == 0,:) = [];
        disp('Running on only unread');
    end
    
    %% check if all variables are valid for the given set
    % variable must have at least 5 instances for both 0 and 1
    variablesToRemove = [];
    warnings = {};
    for i = 1 : numel(descriptor.variables)
        for j = [0 1]
            var = descriptor.variables{i};
            if iscategorical(tab.(var))
                nOfInstances = nnz(tab.(var) == categorical(j));
            else
                nOfInstances = nnz(tab.(var) == j);
            end
            if nOfInstances < 5
                warnString = ['Removing ' var ' variable from predictions as only ' num2str(nOfInstances) ' instances were present for ' num2str(j)];
                warning('RUNCLASS:INVALIDVARIABLE', warnString);
                variablesToRemove = [variablesToRemove i];
                warnings = horzcat(warnings, warnString);
                continue
            end
        end
    end
    descriptor.variables(variablesToRemove) = [];
    descriptor.warnings = warnings;
    
    %% classify
    
    results = cell(numel(descriptor.variables), 1);

    for i = 1 : numel(descriptor.variables)
        variable = descriptor.variables{i};
        
        results{i} = classifyOnVariable(tab, variable, descriptor);
    end

    if ~exist(outFolder)
        mkdir(outFolder);
    end
    
    allResults = struct();
    allResults.results = results;
    allResults.descriptor = descriptor;
    
    save([outFolder filesep descriptor.outName '.mat'], '-struct', 'allResults');

end

function result = classifyOnVariable(table, variable, descriptor)
    % classifies a variable using a set of predictors and saves results_<variable>.mat in the given folder
    % axes : axes in which to plot result
    
    result = struct();
    result.predictions = cell(size(descriptor.featureSets,1),1);
    
    repetitions = descriptor.repetitions;

    for i = 1:size(descriptor.featureSets, 1)
        predictors = descriptor.featureSets{i, 2};
        lastwarn('');
        [inSampleLoss, outSampleLoss, X, Y, T, auc] = classify(table, variable, predictors);
        if ~isempty(lastwarn)
            warnstring = ['For ' variable ' using ' descriptor.featureSets{i, 1} ':' lastwarn];
            descriptor.warnings = horzcat(descriptor.warnings, warnstring);
        end
        
        result.predictions{i} = struct();
        
        if repetitions > 0
            [inSampleLosses, outSampleLosses, Xs, Ys, Ts, aucs] = randomizedClassify(table, variable, predictors, repetitions);
            pval = nnz(auc <= aucs) / repetitions;
            result.predictions{i}.pval = pval;
            result.predictions{i}.inSampleLosses = inSampleLosses;
            result.predictions{i}.outSampleLosses = outSampleLosses;
            result.predictions{i}.Xs = Xs;
            result.predictions{i}.Ys = Ys;
            result.predictions{i}.Ts = Ts;
            result.predictions{i}.aucs = aucs;
        end
        
        result.predictions{i}.inSampleLoss = inSampleLoss;
        result.predictions{i}.outSampleLoss = outSampleLoss;
        result.predictions{i}.X = X;
        result.predictions{i}.Y = Y;
        result.predictions{i}.T = T;
        result.predictions{i}.auc = auc;
    end
    
    result.sNaiveAcc = superNaive(table, variable);
    result.variable = variable;
    
end