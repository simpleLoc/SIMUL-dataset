classdef FigureButtonBar < handle
	properties(Access = protected)
		figureHandle = -1;
		buttons = [];
		buttonWidths = [];

		result = NA;
	end

	properties (Constant)
		BUTTON_PADDING = 10;
	end

	methods
		function obj = FigureButtonBar(figureHandle)
			obj.figureHandle = figureHandle;
		end

		function addButton(obj, title, resultValue, width)
			if !exist('width', 'var')
				width = 100;
			end
			xPos = sum(obj.buttonWidths) + FigureButtonBar.BUTTON_PADDING * (length(obj.buttons) + 1);
			buttonHandle = uicontrol(obj.figureHandle, 'style', 'pushbutton', 'string', title, 'position', [xPos, 10, width, 30], 'callback', @(src, evt) obj.resolve(resultValue));
			obj.buttons = [obj.buttons, buttonHandle];
			obj.buttonWidths = [obj.buttonWidths, width];
		end

		% Example:
		%  getActivity = buttonBar.addCombobox(3, {'Standing', 0; 'Walking', 1; 'Stairs', 3}, 1, 150);
		%  currentlySelectedActivity = getActivity();
		function valueGetter = addCombobox(obj, eventId, items, initialValue, width)
			if !exist('width', 'var')
				width = 100;
			end
			assert(columns(items) == 2, 'Items array has to have 2 colums. The first the displayed text, the second is the value returned when the option is active');
			initialValueIdx = find([items{:,2}] == initialValue);
			xPos = sum(obj.buttonWidths) + FigureButtonBar.BUTTON_PADDING * (length(obj.buttons) + 1);
			comboboxHandle = uicontrol(obj.figureHandle, "style", "popupmenu", "string", items(:, 1), "value", initialValueIdx, "position", [xPos, 10, width, 30], ...
				'callback', @(src, evt) obj.resolve(eventId));
			obj.buttons = [obj.buttons, comboboxHandle];
			obj.buttonWidths = [obj.buttonWidths, width];
			valueGetter = @() items{get(comboboxHandle, 'value'), 2};
		end

		function result = poll(obj, figureClosedValue, nullValue)
			if(ishandle(obj.figureHandle) == false)
				result = figureClosedValue;
			elseif(isna(obj.result))
				result = nullValue;
			else
				result = obj.result;
				obj.result = NA;
			end
		end

		function result = wait(obj, abortValue)
			# Wait until there is either a result or the figure has been closed.
			while isna(obj.result) && ishandle(obj.figureHandle)
				pause(0.1);
			end
			if isna(obj.result)
				result = abortValue;
			else
				result = obj.result;
				obj.result = NA;
			end
		end
	end

	methods(Access = protected)
		function resolve(obj, result)
			obj.result = result;
		end
	end
end
