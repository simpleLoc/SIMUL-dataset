classdef KameHeuristics
	properties(Constant)
		MAGDWICK_INIT_TIME = 5; # [s]
		THRESHOLD_GYRO = 60/180*pi; # [rad/s]
		THRESHOLD_GYRO_DERIVED = 10/180*pi; # [rad/s/s]
		THRESHOLD_ANGLES = 30/180*pi; # [rad]
		THRESHOLD_MIN_DURATION = 0.3; # [sec]
	end

	methods(Access = public, Static)
		function [mixedSignal, signalParts, signalPartLabels] = calcKameSignal(recordingTimestamps, sampleFreq, sensorData, sensorDataQuats)
			THRESHOLD_ACCEL = 0.03 * sampleFreq; # [m/s]

			createAligned = @(q, sensorData) rotatepoint(quaternion(q(1,:), q(2,:), q(3,:), q(4,:)), sensorData);
			createInvAligned = @(q, sensorData) rotatepoint(conj(quaternion(q(1,:), q(2,:), q(3,:), q(4,:))), sensorData);

			accelFilter = ButterworthFilter(SignalFilter.TYPE_LOWPASS, 3, sampleFreq, 4);
			gyroFilter = ButterworthFilter(SignalFilter.TYPE_LOWPASS, 3, sampleFreq, 3);

			# accel
			accelData = sensorData(:, AwindaRecording.DIMS_FREE_ACCELERATION); #TODO: aligned data?
			accelDataFlt = accelFilter.filter(accelData);
			#
			accelZResMagn_YZ = vecnorm(accelDataFlt(:, 2:3), 2, 2);
			accelZResMagn_YZ(accelZResMagn_YZ < THRESHOLD_ACCEL) = 0; # nomml movmean?
			#
			accelDerived_YZ = vecnorm([0, 0; diff(accelDataFlt(:, 2:3))], 2, 2);
			accelDerived_YZ(accelZResMagn_YZ < THRESHOLD_ACCEL) = 0;

			# gyro
			gyroData = sensorData(:, AwindaRecording.DIMS_GYROSCOPE);
			gyroDataFlt = gyroFilter.filter(gyroData);
			#
			gyroZRes_X = abs(gyroDataFlt(:, 1)); # for gyro, only select x axis
			gyroZRes_X(gyroZRes_X < KameHeuristics.THRESHOLD_GYRO) = 0;
			#
			gyroZResDerived_X = [0; abs(diff(gyroDataFlt(:, 1)))];
			gyroZResDerived_X(gyroZResDerived_X < KameHeuristics.THRESHOLD_GYRO_DERIVED) = 0;

			# sensor angle
			sensorStatic = gyroZRes_X + gyroZResDerived_X + accelZResMagn_YZ;
			upVectorsInSensorCOS = createInvAligned(sensorDataQuats, [0, 0, 1]);						# translate up into sensor coos
			refUpVectorInSensorCOS = upVectorsInSensorCOS(ceil(KameHeuristics.MAGDWICK_INIT_TIME * sampleFreq), :);	# get calibrated up vector in sensor coos
			refUpVectorInGlobalCOS = createAligned(sensorDataQuats, refUpVectorInSensorCOS);			# translate calibrated up back in global coos (should be [0 0 1] again)
			sensorAngles = zeros(rows(upVectorsInSensorCOS), 1);
			for i = 1:rows(sensorAngles)
				#translatedUp = createAligned(sensorDataQuats(:, i), refUpVectorInSensorCOS);	# translate calibrated up back in global coos (should be [0 0 1] again
				sensorAngles(i) = acos(dot(refUpVectorInGlobalCOS(i,:), [0, 0, 1], 2));
				if sensorStatic(i) == 0 && sensorAngles(i) < KameHeuristics.THRESHOLD_ANGLES
					sensorAngles(i) = 0;
					refUpVectorInSensorCOS = upVectorsInSensorCOS(i, :);
				end
			end
			#sensorAngles(sensorAngles < KameHeuristics.THRESHOLD_ANGLES) = 0;

#			plot(recordingTimestamps, 0.5 * accelZResMagn_YZ);
#			hold on;
#				plot(recordingTimestamps, 3 * accelDerived_YZ);
#				plot(recordingTimestamps, gyroZRes_X);
#				plot(recordingTimestamps, 7 * gyroZResDerived_X);
#				plot(recordingTimestamps, 7 * sensorAngles);
#				plot(recordingTimestamps, 1.01 * (gyroZRes_X + 7 * gyroZResDerived_X + 0.5 * accelZResMagn_YZ), 'linewidth', 2);
#			hold off;
#			legend('accel zero-res magn', 'accel derived', 'gyro zero-res abs', 'gyro zero-res derived', 'sensorAngles', 'KAME');

			mixedSignal = [gyroZRes_X + gyroZResDerived_X + accelZResMagn_YZ + sensorAngles];
			signalParts = [gyroZRes_X, gyroZResDerived_X, accelZResMagn_YZ, sensorAngles]';
			signalPartLabels = {'gyro', 'gyro derived', 'accel', 'sensorAngle'};
		end

		function [stepRegions, mixedSignal, signalParts, signalPartLabels] = calc(recordingTimestamps, sampleFreq, sensorData, sensorDataQuats)
			[mixedSignal, signalParts, signalPartLabels] = KameHeuristics.calcKameSignal(recordingTimestamps, sampleFreq, sensorData, sensorDataQuats);
			kameSignal = [mixedSignal; 0]; # append 0 to have same size stepStartIdcs and stepEndIdcs
			kameSignal(1:ceil(KameHeuristics.MAGDWICK_INIT_TIME * sampleFreq)) = 0; # ignore magdwick init time in mixed signal

			stepStartIdcs = find(diff(kameSignal > 0) == 1);
			stepEndIdcs = find(diff(kameSignal > 0) == -1);
			stepRegions = [stepStartIdcs(:), stepEndIdcs(:)];
			stepDurations = (stepRegions(:, 2) - stepRegions(:, 1)) / sampleFreq;
			durationFilterIdcs = (stepDurations >= KameHeuristics.THRESHOLD_MIN_DURATION);
			stepRegions = stepRegions(durationFilterIdcs, :);
		end
	end
end
