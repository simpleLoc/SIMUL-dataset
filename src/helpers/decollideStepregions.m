function [leftFootSteps, rightFootSteps] = decollideStepregions(leftFootSteps, rightFootSteps)
	for(leftIdx = 1:rows(leftFootSteps))
		leftRegion = leftFootSteps(leftIdx, :);

		rightCollidingRegionIdcs = find((rightFootSteps(:, 2) >= leftRegion(1)) & (leftRegion(2) >= rightFootSteps(:, 1)));
		for(rightIdx = rightCollidingRegionIdcs')
			rightRegion = rightFootSteps(rightIdx, :);

			%figure();
			%rectangle('Position', [leftRegion(1), 0, leftRegion(2) - leftRegion(1), 1], 'FaceColor', 'red');
			%rectangle('Position', [rightRegion(1), -1, rightRegion(2) - rightRegion(1), 1], 'FaceColor', 'blue');
			if(leftRegion(1) < rightRegion(1) && rightRegion(2) > leftRegion(2))
				%rectangle('Position', [rightRegion(1), 1, leftRegion(2) - rightRegion(1), 1], 'FaceColor', 'green');
				% de-collide
				cutPoint = mean([leftRegion(2), rightRegion(1)]);
				leftRegion(2) = floor(cutPoint);
				rightRegion(1) = leftRegion(2) + 1;
			elseif(rightRegion(1) < leftRegion(1) && leftRegion(2) > rightRegion(2))
				%rectangle('Position', [leftRegion(1), 1, rightRegion(2) - leftRegion(1), 1], 'FaceColor', 'green');
				% de-collide
				cutPoint = mean([rightRegion(2), leftRegion(1)]);
				rightRegion(2) = floor(cutPoint);
				leftRegion(1) = rightRegion(2) + 1;
			else
				figure('name', 'ERROR: Step Region completely contains other');
				rectangle('Position', [leftRegion(1), 0, leftRegion(2) - leftRegion(1), 1], 'FaceColor', 'red');
				rectangle('Position', [rightRegion(1), -1, rightRegion(2) - rightRegion(1), 1], 'FaceColor', 'blue');
				error('One step region completely contains other step region. This is not supported!');
			end
			% write back
			leftFootSteps(leftIdx, 1) = leftRegion(1);
			leftFootSteps(leftIdx, 2) = leftRegion(2);
			rightFootSteps(rightIdx, 1) = rightRegion(1);
			rightFootSteps(rightIdx, 2) = rightRegion(2);
			%rectangle('Position', [leftRegion(1), 2, leftRegion(2) - leftRegion(1), 1], 'FaceColor', 'red');
			%rectangle('Position', [rightRegion(1), 3, rightRegion(2) - rightRegion(1), 1], 'FaceColor', 'blue');
		end
	end
end
