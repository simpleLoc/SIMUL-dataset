classdef Madgwick < handle
	properties(Access = protected)
		beta = 0;
		quat = 0;
	end

	methods
		function self = Madgwick(beta)
			if isOctave()
				pkg load quaternion;
			end
			self.beta = double(beta);
			self.quat = [1;0;0;0];
		end

		function q = fastStart(self, deltaT, accel)
			% make backup of configuration
			beta = self.beta;

			% change configuration to forcefully adapt to
			% accelerometer-readings in only one timestep, by change the
			% beta weight to 100% accelerometer.
			self.beta = 10;

			% run adaption
			% For this, we also disable scaling with the sample interval (deltaT).
			q = self.push(deltaT, accel, [0, 0, 0]);

			% restore to actual settings
			self.beta = beta;
		end

		function q = push(self, deltaT, accel, gyro)
			q = self.quat;

			% Rate of change of quaternion from gyroscope
			qDot = 0.5 * [ ...
				-q(2) * gyro(1) - q(3) * gyro(2) - q(4) * gyro(3); ...
				q(1) * gyro(1) + q(3) * gyro(3) - q(4) * gyro(2); ...
				q(1) * gyro(2) - q(2) * gyro(3) + q(4) * gyro(1); ...
				q(1) * gyro(3) + q(2) * gyro(2) - q(3) * gyro(1)];

			% Compute feedback only if accelerometer measurement valid (avoids NaN in accelerometer normalisation)
			if(norm(accel) > 0)
				% Normalise accelerometer measurement
				accel = accel / norm(accel);

				% Auxiliary variables to avoid repeated arithmetic
				v_2q1 = 2.0 * q * accel(1);
				v_2q2 = 2.0 * q * accel(2);
				v_4q = 4.0 * q(1:3);
				v_8q = 8.0 * q(2:3);
				qq = q .* q;

				% Gradient decent algorithm corrective step
				s = [ ...
					v_4q(1) * qq(3) + v_2q1(3) + v_4q(1)  * qq(2) 	- v_2q2(2); ...
					v_4q(2) * qq(4) - v_2q1(4) + 4.0 	  * qq(1) 	* q(2) 	- v_2q2(1) - v_4q(2) + v_8q(1) * qq(2) + v_8q(1) * qq(3) + v_4q(2) * accel(3); ...
					4.0 	* qq(1) * q(3) 	   + v_2q1(1) + v_4q(3) * qq(4) - v_2q2(4) - v_4q(3) + v_8q(2) * qq(2) + v_8q(2) * qq(3) + v_4q(3) * accel(3); ...
					4.0 	* qq(2) * q(4) 	   - v_2q1(2) + 4.0 	* qq(3) * q(4) 	   - v_2q2(3)];
				s = s / norm(s); % normalise step magnitude

				% Apply feedback step
				qDot = qDot - self.beta * s;
			end

			% Integrate rate of change of quaternion to yield quaternion
			q = q + qDot * deltaT;

			% Normalise quaternion
			q = q / norm(q);
			self.quat = q;
		end

		% Return quaternion that transforms (rotates) the world-coordinate system into the device's local coordinate-system.
		function quat = getQuatValues(self)
			quat = self.quat;
		end
		function quat = getQuat(self)
			quat = quaternion(self.quat(1),self.quat(2),self.quat(3),self.quat(4));
		end



		% SERIALIZE / DESERIALIZE
		function s = saveobj(self)
			s.sampleFrequency = self.sampleFrequency;
			s.beta = self.beta;
			s.quat = [self.quat.w, self.quat.x, self.quat.y, self.quat.z];
		end
	end

	methods(Static)
		function self = loadobj(s)
			self = Madgwick(s.sampleFrequency, s.beta);
			self.quat = quaternion(s.quat(1), s.quat(2), s.quat(3), s.quat(4));
		end
	end
end
