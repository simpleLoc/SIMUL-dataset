function p = rotatepoint(quat, q)
	assert(columns(q) == 3, 'q must be vector in R3.');
	quat = unit(quat);
	pointCnt = rows(q);
	if pointCnt == 1
		result = quat * quaternion(0, q(1), q(2), q(3)) .* conj(quat);
		p = [result.x;result.y;result.z]';
	else
		result = quat(:) .* quaternion(zeros(pointCnt, 1), q(:,1), q(:,2), q(:,3)) .* conj(quat)(:);
		p = [result.x,result.y,result.z];
	end
end

%TEST-CASES:
% q = quaternion([1,2], [1,6],[2,10],[0,0]);
% rotatepoint(q, [1,2,3]) == [3.0000, 1.0000, -2.0000; 2.1429, 1.3143, -2.7714]

% q = quaternion([1,2], [1,6],[2,10],[0,0]);
% rotatepoint(q, [1,2,3; 4,5,6]) == [3.0000, 1.0000, -2.0000; 4.2857, 4.8286, -5.9429]
