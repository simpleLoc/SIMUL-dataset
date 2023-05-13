classdef FIRFilter < SignalFilter

	properties(Access = private)
		firWindow = 0;
	end

	methods(Access = protected)
		% Design Moving Mean Filter
		% Arguments:
		% sampleFreq: Sampling frequency
		% firWindow: FIR window
		function self = FIRFilter(name, sampleFreq, firWindow)
			assert(isvector(firWindow), 'FIR Window has to be 1-dimensional vector!');
			self.firWindow = firWindow;
			self@SignalFilter(name, sampleFreq);
		end
	end

	methods(Access = public)
		function result = filter(self, signal)
			result = zeros(size(signal));
			for i = 1:rows(signal)
				result(i,:) = conv(signal(i,:), self.firWindow, 'same');
			end
		end
	end

end
