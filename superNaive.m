function rate = superNaive(tab, variable)
% given a variable in tab, reports the rate of classification that would
% be optained by assigning the label that appears most often in the table
% to all rows

[uniqueValues,~,uniqueIndex] = unique(tab(:, variable));
frequencies = accumarray(uniqueIndex(:),1)./size(tab, 1);
rate = max(frequencies);

end

