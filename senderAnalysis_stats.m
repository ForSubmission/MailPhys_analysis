function senderAnalysis_stats(participants)
% Fits multiple glm to senders, assessing whether senders can predict
% binaryPriority, binaryWorkload and binaryPleasure and spam.
% Also runs them on shuffled (randomised) instances, just to verify that
% the predictions were valid.

    %% make table with top senders
    % consider only rows: from, priority, pleasure, workload, spam
    % eagerlyExpected

    columns = {'from' 'priority' 'pleasure' 'workload' 'spam' 'eagerlyExpected'};
    
    cattable = table();
    
    hold on;

    for participantNumber = participants
        sfo = ['P' Params.sfo_p];
        partString = sprintf(sfo, participantNumber);
        outdir = Params.outdir;
        partFolder = [outdir filesep partString];
        
        tableMatFile = [partFolder filesep 'datatable.mat']; 
            
        disp(['Attempting to read table from ' tableMatFile]);
        tables = load(tableMatFile);
        tab = tables.tab;
        
        % make sub table with only the desired colums
        subtab = tab(:, columns);
        
        %priority = subtab.priority + rand(size(subtab.priority, 1), 1) / 2;
        %pleasure = subtab.pleasure + rand(size(subtab.pleasure, 1), 1) / 2;
        %workload = subtab.workload + rand(size(subtab.workload, 1), 1) / 2;
        %scatter3(priority, pleasure, workload)
        
        subtab.participantNumber = repmat(participantNumber, size(subtab, 1), 1);
        
        cattable = vertcat(cattable, subtab);
    end
    
    % convert sender into numbers
    [senderStrings, ~, uniqueIndex] = unique(cattable.from);
    cattable.senderNum = categorical(uniqueIndex);
    cattable.binaryPriority = ordinal(cattable.priority > 2.5);
    cattable.binaryPleasure = ordinal(cattable.pleasure > 2.5);
    cattable.binaryWorkload = ordinal(cattable.workload > 2.5);
    
    disp(['For f-test, numerator is ' num2str(size(senderStrings, 1)) ' and denominator is the degrees of freedom outputted by fitglm']);
    disp('Note numberator number and press enter to continue');
    pause;
    
    m = fitglm(cattable, 'binaryPriority ~ senderNum');
    disp(m);
    disp('Above: binaryPriority');
    pause;
    
    
    m = fitglm(cattable, 'binaryPleasure ~ senderNum');
    disp(m);
    disp('Above: binaryPleasure');
    pause;

    
    m = fitglm(cattable, 'binaryWorkload ~ senderNum');
    disp(m);
    disp('Above: binaryWorkload');
    pause;
    
    
    m = fitglm(cattable, 'spam ~ senderNum');
    disp(m);
    disp('Above: spam');
    pause;
    
    shuffledPriority = cattable.binaryPriority;
    shuffledPriority = shuffledPriority(randperm(size(shuffledPriority, 1)));
    cattable.shuffledPriority = shuffledPriority;
    m = fitglm(cattable, 'shuffledPriority ~ senderNum');
    disp(m);
    disp('Above: shuffledPriority');
    pause;
    
    shuffledPleasure = cattable.binaryPleasure;
    shuffledPleasure = shuffledPleasure(randperm(size(shuffledPleasure, 1)));
    cattable.shuffledPleasure = shuffledPleasure;
    m = fitglm(cattable, 'shuffledPleasure ~ senderNum');
    disp(m);
    disp('Above: shuffledPleasure');
    pause;
    
    shuffledWorkload = cattable.binaryWorkload;
    shuffledWorkload = shuffledWorkload(randperm(size(shuffledWorkload, 1)));
    cattable.shuffledWorkload = shuffledWorkload;
    m = fitglm(cattable, 'shuffledWorkload ~ senderNum');
    disp(m);
    disp('Above: shuffledPriority');
    pause;
    
    shuffledSpam = cattable.spam;
    shuffledSpam = shuffledSpam(randperm(size(shuffledSpam, 1)));
    cattable.shuffledSpam = shuffledSpam;
    m = fitglm(cattable, 'shuffledSpam ~ senderNum');
    disp(m);
    disp('Above: shuffledSpam');
    pause;
end

