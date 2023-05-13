classdef ButterworthFilter < SignalFilter

	properties(Access = private)
		b = [];
		a = [];
	end

	methods(Access = public)
		% Design Butterworth filter
		% Arguments:
		% - filterType: SignalFilter::<TYPE>
		% - filterOrder: Order
		% - sampleFreq: Signal Sampling Frequency in Hz
		% - cutoffFreqs: (in Hz) Scalar (for TYPE_LOWPASS, TYPE_HIGHPASS),
		%                (in Hz) [Scalar, Scalar] (for TYPE_BANDPASS, TYPE_BANDSTOP)
		function self = ButterworthFilter(filterType, filterOrder, sampleFreq, cutoffFreqs)
			pkg load signal;
			ftypeMap = {'low', 'high', 'bandpass', 'stop'};
			ftype = ftypeMap{filterType + 1};
			[self.b, self.a] = butter(filterOrder, cutoffFreqs ./ (sampleFreq / 2), ftype);
			self@SignalFilter(sprintf('Butterworth: (type=%s, cutoffFreqs=%s)', ftype, mat2str(cutoffFreqs)), sampleFreq);
		end


		function result = filter(self, signal)
			result = filtfilt(self.b, self.a, signal);
		end
	end

end
