function [meanVal, stdVal, gazeCount] = read_gaze(gazeStruct)
% Extracts some metrics from a given json gaze structure regarding gaze.

vec = structSub2Vector(gazeStruct, 'duration');

meanVal = mean(vec);
stdVal = std(vec);
gazeCount = numel(vec);

end

