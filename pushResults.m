function pushResults(server, username, password)
% Sends the result of a given classification to an IMAP server
% Only the results of the 'all' feature sets are pushed

% we send predictions which are above this probability
THRESHOLD = .75;

[source, path] = uigetfile('*.mat', 'Select file containing results');

results = load([path filesep source]);

% find 'all' feature set. If not found, throw error.
foundI = -1;
for i = 1 : size(results.descriptor.featureSets, 1)
    if strcmp(results.descriptor.featureSets{i, 1}{:}, 'all')
        foundI = i;
    end
end

if foundI == -1
    error('Could not find the ''all'' featureSet');
end

% go through each result using variable as flag
for rNum = 1 : numel(results.results)
    result = results.results{rNum};
    flagName = result.variable;
    % find predictions which are above threshold and send those to server
    score_svm = result.predictions{foundI}.score_svm;
    for i = 1 : size(score_svm, 1)
        if score_svm(i, 2) > THRESHOLD
            id = result.table{i, 'id'}{:};
            pushItem(flagName, id, server, username, password);
        end
    end
end

end

function pushItem(flag, id, server, username, password)
% push an individual item to 
    
    % get UID of message using message id
    [~, output] = system(['curl --url "imaps://' server '/INBOX" --ssl --user "' username ':' password '" -X "SEARCH header Message-ID ' id '"']);
    spl = split(output);
    if numel(spl) < 3
        error(['Could not find message with id ' id]);
    end
    uid = spl{3};
    
    % push tag
    disp(['Tagging message with id ''' id ''' by adding flag ''' flag '''']);
    rcode = system(['curl --url "imaps://' server '/INBOX" --ssl --user "' username ':' password '" -X "STORE ' uid ' +flags (' flag ')"']);
    if rcode ~= 0
        error(['Failed to push tag ''' flag ''' to message with UID ' uid]);
    end
end