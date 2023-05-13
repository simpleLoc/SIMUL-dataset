init();

recordingsDir = '../data/by-person';
recordingFiles = dir([recordingsDir, '/*/*.csv']);

for rIdx = 1:length(recordingFiles)
	recordingFile = [recordingFiles(rIdx).folder, '/', recordingFiles(rIdx).name];
	stepFile = [recordingFile, '.step'];
	stepNonoverlapFile = [recordingFile, '.stepNonoverlap'];

	printf('Recording: %s...\n', recordingFile);
	printf('\tParsing Steps...\n');
	[leftSteps, rightSteps] = loadSteps(stepFile);
	[leftSteps, rightSteps] = decollideStepregions(leftSteps, rightSteps);
	lrSteps = [leftSteps; rightSteps];
	lrSteps = sortrows(lrSteps, 1);

	dlmwrite(stepNonoverlapFile, lrSteps);
end
