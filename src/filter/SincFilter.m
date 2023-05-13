classdef SincFilter < FIRFilter

	methods(Access = public)
		function self = SincFilter(sampleFreq, filterOrder, filterSize)
			n = (-(filterSize-1)/2:1:(filterSize-1)/2);
			h=(1/filterOrder)*sinc(n/filterOrder);
			self@FIRFilter(sprintf('SincFilter (order=%d, size=%d)', filterOrder, filterSize), sampleFreq, h);
		end
	end

end
