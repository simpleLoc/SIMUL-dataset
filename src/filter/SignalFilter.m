classdef SignalFilter < handle

	properties (Access = public, Constant)
		TYPE_LOWPASS = 0;
		TYPE_HIGHPASS = 1;
		TYPE_BANDPASS = 2;
		TYPE_BANDSTOP = 3;
	end

	properties(Access = private)
		name = '';
		sampleFreq = [];
	end

	methods(Access = protected)
		function self = SignalFilter(name, sampleFreq)
			self.name = name;
			self.sampleFreq = sampleFreq;
		end
	end

	methods(Access = public, Abstract)
		% Apply the butterworth filter with the configured settings to the given signal.
		% Arguments:
		% - signal: The (optionally multi-dimensional signal) to apply the filter to
		%           rows = dimensions, columns = samples
		%function result = filter(self, signal);
	end

	methods(Access = public)
		function debugAnalyzeFreqResponse(self)
			figure('name', ['Filter Analysis: ', self.name]);
			splCnt = 16384;
			unitSignal = [1, zeros(1, splCnt)];
			filteredUnitSignal = self.filter(unitSignal);
			fftRes = fft(filteredUnitSignal);
			freqSpectrum = abs(fftRes(1:splCnt/2));
			phaseShiftSpectrum = angle(fftRes(1:splCnt/2));

			freqs = self.sampleFreq * (1:splCnt/2) / splCnt;
			subplot(2, 1, 1);
			plot(freqs, freqSpectrum);
			title(['Frequency Response ', self.name]);
			xlabel('Hz');
			ylabel('Response Magnitude');
			subplot(2, 1, 2);
			plot(freqs, phaseShiftSpectrum);
			title(['Phase Shift ', self.name]);
			xlabel('Hz');
			ylabel('Phase Shift');
		end
	end

end
