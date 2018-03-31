function publishResults(partNum, repetitions)
% Publishes the classification results for the given participant number,
% using the results files saved on disk

sfo = ['P' Params.sfo_p];
partString = sprintf(sfo, partNum);
outputFolder = ['pub_' partString '_' num2str(repetitions)];
publish(['reportResults(' num2str(partNum) ', ' num2str(repetitions) ')'],'format','html','showCode',false, 'outputDir', outputFolder);

end

