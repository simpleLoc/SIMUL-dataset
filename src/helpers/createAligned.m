function result = createAligned(q, sensorData)
	result = rotatepoint(quaternion(q(1,:), q(2,:), q(3,:), q(4,:)), sensorData);
end
