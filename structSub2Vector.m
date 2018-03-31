function vector = structSub2Vector(struct, field)
% "Flattens" the given field in the given struct array, so we obtain a
% vector containing all concatenated items for every repeated instance of the struct
% INPUTS
% struct : a struct array. If empty, returns [0]
% field : a field in the given array, itself containing a vector

%% check if empty first

outNum = numel(struct);

if outNum == 0
    vector = [0];
    return
end

%% append all items in struct array's field

assert(isfield(struct, field), 'STRUCT2SUBVECTOR:NOTAFIELD', ['The given field (' field ') is not a valid field for the given struct']);

vector = [];

k = 1;
for i = 1:outNum
    assert(isvector(struct(i).(field)), 'STRUCT2SUBVECTOR:FIELDNOTVECTOR', ['The given field (' field ') is not a vector for this struct']);
    
    inNum = numel(struct(i).(field));
    for j = 1:inNum
        vector(k) = struct(i).(field)(j); %#ok<AGROW>
        k = k + 1;
    end
end

end