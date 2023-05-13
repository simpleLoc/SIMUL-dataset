if(isOctave())
	pkg load quaternion;
end

if(exist("rawData", "var"))
	return;
end

if(~exist("fileName", "var"))
	% #########################################################################
	% # Select File
	% #########################################################################
	[cutFile, cutFilePath] = uigetfile('*.csv');
	assert(ischar(cutFile), 'Did not select file in dialog.');
	fileName = [cutFilePath, cutFile];
end

% #########################################################################
% # DATA
% #########################################################################
csvHeaderLineReader = FileReader(fileName);
csvHeaderLine = csvHeaderLineReader.readLine();
csvHeaderLineReader.close();

deviceCnt = 6;
rawData = dlmread(fileName, ',', 1, 0);
colsPerDevice = (columns(rawData) - 2) / deviceCnt;
% raw data
recordingTimestamps = rawData(:, 1);
recordingActivityData = rawData(:, 2);
sampleInterval = mean(diff(recordingTimestamps));
sampleFreq = 1.0 / sampleInterval;
sampleCnt = rows(recordingTimestamps);

[recordingData, recordingDataAligned, recordingDataQuats] = parseRecordingData(rawData, deviceCnt, sampleInterval);


leftFootData = recordingData{1};
leftFootDataAligned = recordingDataAligned{1};
leftFootQuats = recordingDataQuats{1};
leftFootAccel = leftFootData(:, AwindaRecording.DIMS_ACCELEROMETER);
leftFootFreeAccel = leftFootData(:, AwindaRecording.DIMS_FREE_ACCELERATION);
leftFootGyro = leftFootData(:, AwindaRecording.DIMS_GYROSCOPE);
leftFootAccelAligned = leftFootDataAligned(:, AwindaRecording.DIMS_ACCELEROMETER);
leftFootFreeAccelAligned = leftFootDataAligned(:, AwindaRecording.DIMS_FREE_ACCELERATION);
leftFootGyroAligned = leftFootDataAligned(:, AwindaRecording.DIMS_GYROSCOPE);

rightFootData = recordingData{2};
rightFootDataAligned = recordingDataAligned{2};
rightFootAccel = rightFootData(:, AwindaRecording.DIMS_ACCELEROMETER);
rightFootFreeAccel = rightFootData(:, AwindaRecording.DIMS_FREE_ACCELERATION);
rightFootGyro = rightFootData(:, AwindaRecording.DIMS_GYROSCOPE);
rightFootAccelAligned = rightFootDataAligned(:, AwindaRecording.DIMS_ACCELEROMETER);
rightFootFreeAccelAligned = rightFootDataAligned(:, AwindaRecording.DIMS_FREE_ACCELERATION);
rightFootGyroAligned = rightFootDataAligned(:, AwindaRecording.DIMS_GYROSCOPE);

leftPocketData = recordingData{3};
leftPocketDataAligned = recordingDataAligned{3};
leftPocketAccel = leftPocketData(:, AwindaRecording.DIMS_ACCELEROMETER);
leftPocketFreeAccel = leftPocketData(:, AwindaRecording.DIMS_FREE_ACCELERATION);
leftPocketGyro = leftPocketData(:, AwindaRecording.DIMS_GYROSCOPE);
leftPocketAccelAligned = leftPocketDataAligned(:, AwindaRecording.DIMS_ACCELEROMETER);
leftPocketFreeAccelAligned = leftPocketDataAligned(:, AwindaRecording.DIMS_FREE_ACCELERATION);
leftPocketGyroAligned = leftPocketDataAligned(:, AwindaRecording.DIMS_GYROSCOPE);


rightPocketData = recordingData{4};
rightBackPocketData = recordingData{6};
handData = recordingData{5};

function plotActivity(recordingTimestamps, recordingActivityData, axisHandle)
	if(~exist('axisHandle', 'var'))
		axisHandle = gca;
	end

	plotChildren = get(axisHandle, 'children');
	isInitialized = length(plotChildren) == 6;
	if(isInitialized == true)
		axis(axisHandle);
		cla();
	end

	tmp = [1; find(diff(recordingActivityData) != 0); length(recordingTimestamps)];
	tmp = unique(tmp);
	actRegions = []; actRegionValues = [];
	for(i = 1:(length(tmp) - 1))
		regStartIdx = tmp(i); regStartTs = recordingTimestamps(regStartIdx);
		regEndIdx = tmp(i + 1); regEndTs = recordingTimestamps(regEndIdx);
		regActivity = recordingActivityData(regEndIdx);
		actRegions = [actRegions; regStartTs; regEndTs];
		actRegionValues = [actRegionValues; regActivity; regActivity];
	end

	xData = [(actRegionValues == 0), (actRegionValues == 1), (actRegionValues == 2), (actRegionValues == 3), (actRegionValues == 4), (actRegionValues == 5)];
	area(actRegions, double(xData));
end
