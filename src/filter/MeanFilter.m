classdef MeanFilter < SignalFilter

	properties(Access = private)
		filterWidthSpl = 0;
	end

	methods(Access = public)
		% Design Moving Mean Filter
		% Arguments:
		% sampleFreq: Sampling frequency
		% filterWidthSpl: Width of the filter in samples
		function self = MeanFilter(sampleFreq, filterWidthSpl)
			self.filterWidthSpl = filterWidthSpl;
			self@SignalFilter(sprintf('MovingMean: (width=%d)', filterWidthSpl), sampleFreq);
		end


		function result = filter(self, signal)
			result = movmean(signal, self.filterWidthSpl);
		end
	end

end
