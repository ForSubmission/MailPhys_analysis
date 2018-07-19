function [inSampleLoss, outSampleLoss, X, Y, T, auc, score_svm] = classify(table, variable, predictors)
% classify data for the given variable using the given predictor

% svm
model = fitcsvm(table, variable, 'PredictorNames', predictors, 'Standardize', true, 'KernelFunction', 'rbf', 'KernelScale','auto');
    
% if we use multiple classes, one could try the 'fitcecoc'
% function

% cross validated model, for auc
crossValModel = fitcsvm(table, variable, 'PredictorNames', predictors, 'Standardize', true, 'crossval', 'on', 'Leaveout', 'on', 'KernelFunction', 'rbf', 'KernelScale', 'auto');
ScoreCVSVMModel = fitSVMPosterior(crossValModel);
[~, score_svm] = kfoldPredict(ScoreCVSVMModel);

% we make predictions given that second column in score_svm is assigned 1
[X, Y, T, auc] = perfcurve(table.(variable),score_svm(:,2),1);

outSampleLoss = crossValModel.kfoldLoss;

inSampleLoss = resubLoss(model);

end