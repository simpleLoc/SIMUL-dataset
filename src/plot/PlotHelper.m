classdef PlotHelper

	properties(Constant = true)
		KEEP = 1337;
	end

	methods(Static)
		function linkAllAxesInCurrentFigure(varargin)
			axesHandles = get(gcf(), 'children');
			axesIdcs = isaxes(axesHandles); % only axes handles
			axesIdcs = axesIdcs & not(strcmp(get(axesHandles, 'tag'), 'legend')); % filter out legends
			linkaxes(axesHandles(axesIdcs), varargin{:});
		end

		function onlyPanXAxis()
			pan('xon');
		end

		function result = figureStillOpen(figureHandle)
			result = ishandle(figureHandle);
		end

		function updatePlotData(plotHandle, xData, yData, zData)
			assert(~isaxes(plotHandle), 'Given handle is not a plot handle!');
			assert(~isfigure(plotHandle), 'Given handle is not a plot handle!');
			if(~isscalar(xData) || (isscalar(xData) && xData ~= PlotHelper.KEEP))
				set(plotHandle, 'xdata', xData);
			end
			if(~isscalar(yData) || (isscalar(yData) && yData ~= PlotHelper.KEEP))
				set(plotHandle, 'ydata', yData);
			end
			if(exist('zData', 'var') && (~isscalar(zData) || (isscalar(zData) && zData ~= PlotHelper.KEEP)))
				set(plotHandle, 'zdata', zData);
			end
		end
	end
end
