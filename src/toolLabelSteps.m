init();
loadOneRecording();

stepFileName = [fileName, '.step'];

[leftFootSteps, leftFootMixedSignal, leftFootSignalparts] = KameHeuristics.calc(recordingTimestamps, sampleFreq, recordingData{1}, recordingDataQuats{1});
[rightFootSteps, rightFootMixedSignal, rightFootSignalparts] = KameHeuristics.calc(recordingTimestamps, sampleFreq, recordingData{2}, recordingDataQuats{2});

% restore steps
if(exist(stepFileName, 'file'))
	stepData = dlmread(stepFileName);
	leftFootIdcs = (stepData(:,3) == 0);
	rightFootIdcs = (stepData(:,3) == 1);
	leftFootSteps = stepData(leftFootIdcs, 1:2);
	rightFootSteps = stepData(rightFootIdcs, 1:2);
end

function result = stepRegionsToAccessIdcs(stepRegions)
	stepRegions = round(stepRegions);
	result = [];
	for stepIdx = 1:rows(stepRegions)
		result = [result, stepRegions(stepIdx, 1):stepRegions(stepIdx, 2)];
	end
end

function unmappedHandle = drawFoot(axisHandle, footSignalparts, footMixedSignal, flip)
	axes(axisHandle); cla();
	factor = 1.0;
	if(flip == true)
		factor = -1.0;
	end
	plot(footSignalparts' * factor);
	hold on;
	plot(footMixedSignal * factor);
	unmappedHandle = plot(zeros(1, length(footMixedSignal)), 'LineWidth', 3, 'Color', [0.5 0 0.8]);
	hold off;
end
function updateUnmappedFootRegions(unmappedHandle, footMixedSignal, stepRegions, flip)
	factor = 1.0;
	if(flip == true)
		factor = -1.0;
	end

	unmappedSignalIdcs = (footMixedSignal > 0);
	unmappedSignalIdcs(stepRegionsToAccessIdcs(stepRegions)) = 0;
	unmappedSignal = zeros(1, length(footMixedSignal));
	unmappedSignal(unmappedSignalIdcs) = footMixedSignal(unmappedSignalIdcs);

	PlotHelper.updatePlotData(unmappedHandle, PlotHelper.KEEP, unmappedSignal * factor);
end
function drawStepRegions(axisHandle, stepRegions)
	plotChildren = get(axisHandle, 'children');
	isInitialized = length(plotChildren) == 2;

	if(~isInitialized)
		axes(axisHandle); cla();
	end

	hold on; FOOT_COLORS = {'blue', 'red'}; FOOT_Y = {1, -1};
	for footIdx = 1:2
		footRegions = stepRegions{footIdx};
		footY = FOOT_Y{footIdx};

		footAreaX = repelem(footRegions(:), 2);
		footAreaY = repmat([0, footY, footY, 0], 1, rows(footRegions));

		if(isInitialized)
			PlotHelper.updatePlotData(plotChildren(footIdx), footAreaX, footAreaY);
		else
			area(footAreaX, footAreaY, 'FaceColor', FOOT_COLORS{footIdx});
		end
	end
	hold off;
end

labelerFigHandle = figure('name', 'Step Labling');
leftFootAxis = subplot_tight(3, 1, 1, [0.03, 0.03]);
leftUnmappedHandle = drawFoot(leftFootAxis, leftFootSignalparts, leftFootMixedSignal, false);
updateUnmappedFootRegions(leftUnmappedHandle, leftFootMixedSignal, leftFootSteps, false);

stepAxis = subplot_tight(3, 1, 2, [0.03, 0.03]);
drawStepRegions(stepAxis, {leftFootSteps, rightFootSteps});
drawStepRegions(stepAxis, {leftFootSteps, rightFootSteps});

rightFootAxis = subplot_tight(3, 1, 3, [0.08, 0.03]);
rightUnmappedHandle = drawFoot(rightFootAxis, rightFootSignalparts, rightFootMixedSignal, true);
updateUnmappedFootRegions(rightUnmappedHandle, rightFootMixedSignal, rightFootSteps, true);
PlotHelper.linkAllAxesInCurrentFigure('x');
PlotHelper.onlyPanXAxis();

buttonBar = FigureButtonBar(gcf());
buttonBar.addButton('Add Steps', 0, 75);
buttonBar.addButton('Delete Steps', 1, 100);
buttonBar.addButton('Merge Steps', 2, 100);
buttonBar.addButton('Undo', 3, 75);
buttonBar.addButton('Redo', 4, 75);
buttonBar.addButton('Preview Decollided', 5, 125);

function stepRegions = addStep(stepRegions, startIdx, endIdx)
	collidingRegionIdcs = (stepRegions(:, 2) >= startIdx) & (endIdx >= stepRegions(:, 1));
	stepRegions = [stepRegions(~collidingRegionIdcs, :); startIdx, endIdx];
	% sort after new step region was inserted
	stepRegions = sortrows(stepRegions, 1);
end
function stepRegions = removeStep(stepRegions, ptIdx)
	collidingRegionIdcs = (stepRegions(:, 1) <= ptIdx) & (stepRegions(:, 2) >= ptIdx);
	stepRegions = stepRegions(~collidingRegionIdcs, :);
end
function stepRegions = mergeSteps(stepRegions, ptIdx)
	if(rows(stepRegions) < 2)
		return;
	end
	stepRegionMeans = mean(stepRegions, 2);
	stepRegionDistances = abs(stepRegionMeans - ptIdx);
	[~, nearestStepRegionIdcs] = sort(stepRegionDistances);
	nearestStepRegions = stepRegions(nearestStepRegionIdcs(1:2), :);
	stepRegions = [stepRegions(nearestStepRegionIdcs(3:end), :); min(nearestStepRegions(:, 1)), max(nearestStepRegions(:, 2))];
end

function save(stepFileName, leftFootSteps, rightFootSteps)
	dlmwrite(stepFileName, [uint64(leftFootSteps), repmat(0, rows(leftFootSteps), 1); uint64(rightFootSteps), repmat(1, rows(rightFootSteps), 1)]);
end

undoHistory = UndoRedoStack({leftFootSteps, rightFootSteps});

while(true)
	btnId = buttonBar.wait(-1);
	if(btnId == 0)
		display('Mode: Add Steps');
		while(PlotHelper.figureStillOpen(labelerFigHandle))
			[regX0, ~, btn] = ginput(1);
			if(isempty(regX0) || btn ~= 1) break; end % anything but left-click exits mode
			pause(0.1);
			newStepAxis = gca();
			if(newStepAxis == stepAxis) display('ERROR! Steps can only be added by clicking in either of the two foot axes!'); continue; end
			if(newStepAxis == leftFootAxis) display('Adding left step...'); else display('Adding right step...'); end
			[regX1, ~, btn] = ginput(1);
			if(isempty(regX1) || btn ~= 1) break; end % anything but left-click exits mode
			pause(0.1);
			startX = min(regX0, regX1); endX = max(regX0, regX1);
			if(endX - startX < 5) display('ERROR: Step Area too short - Ignoring!'); continue; end
			if(newStepAxis == leftFootAxis)
				leftFootSteps = addStep(leftFootSteps, startX, endX);
				updateUnmappedFootRegions(leftUnmappedHandle, leftFootMixedSignal, leftFootSteps, false);
			else
				rightFootSteps = addStep(rightFootSteps, startX, endX);
				updateUnmappedFootRegions(rightUnmappedHandle, rightFootMixedSignal, rightFootSteps, true);
			end
			undoHistory.push({leftFootSteps, rightFootSteps});
			drawStepRegions(stepAxis, {leftFootSteps, rightFootSteps});
			save(stepFileName, leftFootSteps, rightFootSteps);
			fprintf('New Step Region: [%f, %f]\n', startX, endX);
		end
	elseif(btnId == 1)
		display('Mode: Delete');
		while(PlotHelper.figureStillOpen(labelerFigHandle))
			[ptX, ptY, btn] = ginput(1);
			if(isempty(ptX) || btn ~= 1) break; end % anything but left-click exits mode
			pause(0.1);
			if(gca() == leftFootAxis || (gca() == stepAxis && ptY > 0))
				leftFootSteps = removeStep(leftFootSteps, ptX);
				updateUnmappedFootRegions(leftUnmappedHandle, leftFootMixedSignal, leftFootSteps, false);
				fprintf('Removed [left] step regions intersecting: %f\n', ptX);
			else
				rightFootSteps = removeStep(rightFootSteps, ptX);
				updateUnmappedFootRegions(rightUnmappedHandle, rightFootMixedSignal, rightFootSteps, true);
				fprintf('Removed [right] step regions intersecting: %f\n', ptX);
			end
			undoHistory.push({leftFootSteps, rightFootSteps});
			drawStepRegions(stepAxis, {leftFootSteps, rightFootSteps});
			save(stepFileName, leftFootSteps, rightFootSteps);
		end
	elseif(btnId == 2)
		display('Mode: Merge');
		while(PlotHelper.figureStillOpen(labelerFigHandle))
			[ptX, ptY, btn] = ginput(1);
			if(isempty(ptX) || btn ~= 1) break; end % anything but left-click exits mode
			pause(0.1);
			if(gca() == leftFootAxis || (gca() == stepAxis && ptY > 0))
				leftFootSteps = mergeSteps(leftFootSteps, ptX);
				updateUnmappedFootRegions(leftUnmappedHandle, leftFootMixedSignal, leftFootSteps, false);
				fprintf('Merged [left] step regions near: %f\n', ptX);
			else
				rightFootSteps = mergeSteps(rightFootSteps, ptX);
				updateUnmappedFootRegions(rightUnmappedHandle, rightFootMixedSignal, rightFootSteps, true);
				fprintf('Merged [right] step regions near: %f\n', ptX);
			end
			undoHistory.push({leftFootSteps, rightFootSteps});
			drawStepRegions(stepAxis, {leftFootSteps, rightFootSteps});
			save(stepFileName, leftFootSteps, rightFootSteps);
		end
	elseif(btnId == 3 || btnId == 4)
		if(btnId == 3)
			display('Undo');
			undoHistory.undo();
		else
			display('Redo');
			undoHistory.redo();
		end
		prevState = undoHistory.getCurrent();
		leftFootSteps = prevState{1};
		rightFootSteps = prevState{2};
		drawStepRegions(stepAxis, {leftFootSteps, rightFootSteps});
		save(stepFileName, leftFootSteps, rightFootSteps);
	elseif(btnId == 5)
		try
			[tmpLeftSteps, tmpRightSteps] = decollideStepregions(leftFootSteps, rightFootSteps);
			drawStepRegions(stepAxis, {tmpLeftSteps, tmpRightSteps});
		catch err
			display(err);
		end
	elseif(btnId == -1)
		display('Exiting');
		break;
	end
	display('Mode: None');
end
save(stepFileName, leftFootSteps, rightFootSteps);
