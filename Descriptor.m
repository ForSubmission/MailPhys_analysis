classdef Descriptor < handle
    % Describes some information for a set of predictions, for example
    % which sets of features were used or whether read messages were
    % considered
    
    properties
        variables  % cell vector of variables to predict
        onlyUnread  % true if only unread messages were considered
        superSetName  % name of super set of features (e.g. aggreate or individual signals
        featureSets  % sets of features, cell matrix with two columns, where first column is feature set name and second column a cell
                     % vector of individual features for the given set
        repetitions  % number of randomisation repetitions
        warnings  % warnings outputted by saveResults (if any)
    end
    
    methods
        function obj = Descriptor(variables, onlyUnread, superSetName, featureSets, repetitions)
            obj.variables = variables;
            obj.onlyUnread = onlyUnread;
            obj.superSetName = superSetName;
            obj.featureSets = featureSets;
            obj.repetitions = repetitions;
            obj.warnings = {};
        end
        
        function outName = outName(self)
            % returns string summarising object, for example
            % Aggregate - only unread
            outName = [self.superSetName '-' self.uString];
        end
        
        function string = uString(self)
            % string for unread vs all messages
            if self.onlyUnread
                string = 'only unread';
            else
                string = 'all messages';
            end
        end
        
    end
end

