function [leftSteps, rightSteps] = loadSteps(stepFile)
	rawSteps = dlmread(stepFile);
	steps = sortrows(rawSteps, 1);
	leftSteps = steps(steps(:,3) == 0, 1:2);
	rightSteps = steps(steps(:,3) == 1, 1:2);
end
