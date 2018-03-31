function makePlot(result, descriptor, axes)
    % plots a bar chart with output for the given results
    % predictor set

    %% constants

    INSAMPOFFSETX = -0.2;  % offset to plot in-sample accuracy
    AUCOFFSETX = 0.3;  % offset to plot auc
    ACCWIDTH = 0.5;  % accuracy bar width
    INSAMPWIDTH = 0.15;  % in-sample accuracy width
    AUCWIDTH = 0.25;  % auc bar width

    chanceLevel = 0.5;
    MINY = 0.3;

    %% preparation

    variable = result.variable;
    featureSets = descriptor.featureSets;
    predictions = result.predictions;
    sNaiveAcc = result.sNaiveAcc;
    predictorsSetNames = cell(1, size(featureSets, 1));
    inSampleAccs =  zeros(1, size(featureSets, 1)); % in sample accuracies
    outOfSampleAccs = zeros(1, size(featureSets, 1)); % out of sample accuracies
    accsMinusNaive  = zeros(size(featureSets, 1), 2); % one row per each entry, where the first column is the naive accuracy and the second the outOfSampleAccuracy minus naive
    aucs = zeros(size(featureSets, 1), 1);

    for i = 1 : numel(predictions)
        if iscell(featureSets{i, 1})
            predictorsSetNames(i) = featureSets{i, 1};
        else
            predictorsSetNames(i) = featureSets(i, 1);
        end
        inSampleAccs(i) = 1 - predictions{i}.inSampleLoss;
        outOfSampleAccs(i) = 1 - predictions{i}.outSampleLoss;
        aucs(i) = predictions{i}.auc;

        accsMinusNaive(i, 1) = sNaiveAcc;
        diff = outOfSampleAccs(i) - sNaiveAcc;
        % add to stack only if greater than naive
        if diff >= 0
            accsMinusNaive(i, 1) = sNaiveAcc;
            accsMinusNaive(i, 2) = outOfSampleAccs(i) - sNaiveAcc;
        else
            accsMinusNaive(i, 1) = outOfSampleAccs(i);
            accsMinusNaive(i, 2) = 0;
        end

    end

    %% plotting

    xs = [0: numel(predictorsSetNames)];  % use 1 for naive accuracy
    allNames = horzcat('naïve', predictorsSetNames);  % allNames includes naïve

    accsMinusNaive = vertcat([sNaiveAcc 0], accsMinusNaive); % prepend naive accuracy with 0 since we stack nothing

    % out of sample and difference from naive
    bar(xs, accsMinusNaive, ACCWIDTH, 'stacked');  % plot accuracies with increase from naïve stacked on top
    ylim([MINY 1]);
    ylabel('Accuracy');

    hold on;

    % in sample accuracies
    bar((1: numel(predictorsSetNames)) + INSAMPOFFSETX, inSampleAccs, INSAMPWIDTH);

    xl = xlim;
    xtent = [xs(1)-ACCWIDTH/2, xs(numel(xs))+ACCWIDTH/2];  % extent of bar items

    line([xl(1) xtent(2)], [sNaiveAcc sNaiveAcc], 'Color', 'black');  % plot line for naive

    line([xl(1) xtent(2)], [chanceLevel chanceLevel], 'Color', 'black', 'LineStyle', '--');  % plot line for chance
    xlim(xl);

    set(axes, 'XTick', xs);
    set(axes, 'XTickLabel', allNames);
    set(axes, 'XTickLabelRotation', 45);

    yyaxis right;
    xsright = [1: numel(predictorsSetNames)] + AUCOFFSETX;
    bar(xsright, aucs, AUCWIDTH, 'BaseValue', 0, 'ShowBaseLine', 'off');
    ylabel('AUC');

    ylim([0 1]);  % AUC is between 0 and 1

    currentFaceColor = axes.Children(1).FaceColor;
    line([xtent(1) xl(2)], [max(aucs) max(aucs)], 'Color', currentFaceColor);  % plot line for max auc

    title(variable);

end