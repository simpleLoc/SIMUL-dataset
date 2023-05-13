function recordingDataQuats = calculateMadgwickForDevice(sampleInterval, deviceRecordingData)
	sampleCnt = rows(deviceRecordingData);

	madgwickFilter = Madgwick(0.1);
	accelData = deviceRecordingData(:, AwindaRecording.DIMS_ACCELEROMETER);
	gyroData = deviceRecordingData(:, AwindaRecording.DIMS_GYROSCOPE);
	recordingDataQuats = zeros(4, rows(accelData));
	for tIdx = 1:sampleCnt
		if(tIdx < 5)
			recordingDataQuats(:,tIdx) = madgwickFilter.fastStart(sampleInterval, accelData(tIdx, :));
		else
			recordingDataQuats(:,tIdx) = madgwickFilter.push(sampleInterval, accelData(tIdx, :), gyroData(tIdx, :));
		end
	end
end
