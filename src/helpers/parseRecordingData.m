function [recordingData, recordingDataAligned, recordingDataQuats] = parseRecordingData(rawData, deviceCnt, sampleInterval)
	pkg load parallel;

	sampleCnt = rows(rawData);
	colsPerDevice = (columns(rawData) - 2) / deviceCnt;
	recordingData = cell(1, deviceCnt);
	% alignment
	recordingDataAligned = cell(1, deviceCnt);
	recordingDataQuats = cell(1, deviceCnt);

	offsetIdx = 3;
	for aIdx = 1:deviceCnt
		recordingData{aIdx} = rawData(:, offsetIdx:offsetIdx+colsPerDevice-1);
		offsetIdx = offsetIdx + colsPerDevice;
		recordingDataAligned{aIdx} = zeros(sampleCnt, 3+3+3+3);
		% madgwick
		recordingDataQuats{aIdx} = calculateMadgwickForDevice(sampleInterval, recordingData{aIdx});
	end

	% Use calculated madgwicks to create aligned data
	for dIdx = 1:deviceCnt
		for sIdx = 0:3
			offsetIdx = 1 + sIdx * 3;
			recordingDataAligned{dIdx}(:, offsetIdx:offsetIdx+2) = createAligned(recordingDataQuats{dIdx}, recordingData{dIdx}(:, offsetIdx:offsetIdx+2));
		end
	end
end
