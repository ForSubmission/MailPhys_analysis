function senderAnalysis_plot(participants)
% Gets the top sender for each participant, and plots their priority,
% workload and pleasure values in a 3d plot

    %% make table with top senders
    % consider only rows: from, priority, pleasure, workload, spam
    % eagerlyExpected

    columns = {'from' 'priority' 'pleasure' 'workload' 'spam' 'eagerlyExpected'};
    
    cattable = table();
    
    fig = figure;
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
        
        % get top sender
        [uniqueValues, ~, uniqueIndex] = unique(tab.from);
        frequencies = accumarray(uniqueIndex(:),1);
        [maxfreq, maxI] = max(frequencies);
        topSender = uniqueValues(maxI);
        
        topSenderIs = find(strcmp(tab.from, topSender));
        
        % make sub table with only top sender and the desired colums
        subtab = tab(topSenderIs, columns);
        
        % add a little randomness to prevent overlap
        priority = subtab.priority + rand(size(subtab.priority, 1), 1) / 2;
        pleasure = subtab.pleasure + rand(size(subtab.pleasure, 1), 1) / 2;
        workload = subtab.workload + rand(size(subtab.workload, 1), 1) / 2;
        scatter3(priority, pleasure, workload)
        
        subtab.participantNumber = repmat(participantNumber, size(subtab, 1), 1);
        
        cattable = vertcat(cattable, subtab);
    end
    
    xlabel('Priority');
    ylabel('Pleasure');
    zlabel('Workload');

end

