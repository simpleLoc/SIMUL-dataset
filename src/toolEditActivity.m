init();
loadOneRecording();

[leftFootSteps, leftFootMixedSignal, leftFootSignalparts] = KameHeuristics.calc(recordingTimestamps, sampleFreq, recordingData{1}, recordingDataQuats{1});
[rightFootSteps, rightFootMixedSignal, rightFootSignalparts] = KameHeuristics.calc(recordingTimestamps, sampleFreq, recordingData{2}, recordingDataQuats{2});

function drawFoot(axisHandle, footSignalparts, footMixedSignal)
	plotChildren = get(axisHandle, 'children');
	isInitialized = length(plotChildren) == 5;

	if(isInitialized == false)
		plot(1:columns(footSignalparts), footSignalparts');
		hold on;
		plot(1:length(footMixedSignal), footMixedSignal);
		hold off;
	else
		for(idx = 1:4)
			PlotHelper.updatePlotData(plotChildren(idx), 1:columns(footSignalparts), footSignalparts(idx, :)');
		end
		PlotHelper.updatePlotData(plotChildren(5), 1:length(footMixedSignal), footMixedSignal);
	end
end

figHandle = figure('name', 'Activity Editor');
activityAxis = subplot(3, 1, 1);
plotActivity(1:length(recordingActivityData), recordingActivityData);

leftFootAxis = subplot(3, 1, 2);
drawFoot(leftFootAxis, leftFootSignalparts, leftFootMixedSignal);

rightFootAxis = subplot(3, 1, 3);
drawFoot(rightFootAxis, rightFootSignalparts, rightFootMixedSignal);
PlotHelper.linkAllAxesInCurrentFigure('x');
PlotHelper.onlyPanXAxis();

buttonBar = FigureButtonBar(figHandle);
buttonBar.addButton('Save', 0, 75);
buttonBar.addButton('Cancel', 1, 100);
buttonBar.addButton('Set To', 2, 100);
getCurrentActivity = buttonBar.addCombobox(3, {'Standing', 0; 'Walking', 1; 'Stairs Up', 2; 'Stairs Down', 3; 'Elevator Up', 4; 'Elevator Down', 5}, 1, 150);
buttonBar.addButton('Cut Area', 4, 100);

while(true)
	result = buttonBar.wait(1);
	if(result == 0)
		fileWriter = FileWriter(fileName);
		fileWriter.write(csvHeaderLine);
		fileWriter.close();

		rawData(:, 2) = recordingActivityData;
		dlmwrite(fileName, rawData, '-append', 'delimiter', ',');
		break;
	elseif(result == 1)
		break;
	elseif(result == 2)
		display("new activity");

		[pt0, ~, btn] = ginput(1)
		if(btn ~= 1) continue; end
		pause(0.1);
		[pt1, ~, btn] = ginput(1)
		if(btn ~= 1) continue; end

		drawnow;
		fromIdx = floor(min(pt0, pt1)); fromIdx = min(fromIdx, length(recordingActivityData));
		toIdx = floor(max(pt0, pt1)); toIdx = min(toIdx, length(recordingActivityData));
		recordingActivityData(fromIdx:toIdx) = getCurrentActivity();

		axes(activityAxis); cla();
		hold on;
		plotActivity(1:length(recordingActivityData), recordingActivityData);
		hold off;
	elseif(result == 4)
		display("cut area");

		[pt0, ~, btn] = ginput(1)
		if(btn ~= 1) continue; end
		pause(0.1);
		[pt1, ~, btn] = ginput(1)
		if(btn ~= 1) continue; end

		fromIdx = floor(min(pt0, pt1)); fromIdx = min(fromIdx, length(recordingActivityData));
		toIdx = floor(max(pt0, pt1)); toIdx = min(toIdx, length(recordingActivityData));
		accessIdcs = 1:length(recordingActivityData);
		accessIdcs = (accessIdcs < fromIdx) | (accessIdcs > toIdx);
		rawData = rawData(accessIdcs, :);
		for(idx = 1:length(recordingData))
			recordingData{idx} = recordingData{idx}(accessIdcs, :);
		end
		recordingActivityData = recordingActivityData(accessIdcs);
		leftFootSignalparts = leftFootSignalparts(:, accessIdcs);
		leftFootMixedSignal = leftFootMixedSignal(accessIdcs);
		rightFootSignalparts = rightFootSignalparts(:, accessIdcs);
		rightFootMixedSignal = rightFootMixedSignal(accessIdcs);

		plotActivity(1:length(recordingActivityData), recordingActivityData, activityAxis);

		drawFoot(leftFootAxis, leftFootSignalparts, leftFootMixedSignal);
		drawFoot(rightFootAxis, rightFootSignalparts, rightFootMixedSignal);
	end
end
close all;
