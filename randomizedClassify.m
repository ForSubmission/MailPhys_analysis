function [inSampleLosses, outSampleLosses, Xs, Ys, Ts, aucs] = randomizedClassify(table, variable, predictors, repetitions)
% runs classify for the given number of repetitions, with the given
% parameters, and output 1 value for each result for each repetition

inSampleLosses = zeros(repetitions, 1);
outSampleLosses = zeros(repetitions, 1);
aucs = zeros(repetitions, 1);
Xs = cell(repetitions, 1);
Ys = cell(repetitions, 1);
Ts = cell(repetitions, 1);

for i = 1 : repetitions
    shuffledVariable = table.(variable);
    shuffledVariable = shuffledVariable(randperm(size(shuffledVariable, 1)));
    table.(variable) = shuffledVariable;
    [inSampleLosses(i), outSampleLosses(i), Xs{i}, Ys{i}, Ts{i}, aucs(i)] = classify(table, variable, predictors);
end

end

