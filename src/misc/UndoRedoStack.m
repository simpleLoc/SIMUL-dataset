classdef UndoRedoStack < handle

	properties(Access = private)
		stack = {};
		currentIdx = 1;
	end

	methods(Access = public)
		function self = UndoRedoStack(initialState)
			self.stack = {initialState};
		end

		function push(self, newState)
			self.stack = self.stack(1:self.currentIdx);
			self.stack{end+1} = newState;
			self.currentIdx = length(self.stack);
		end

		function undo(self)
			if(self.currentIdx > 1)
				self.currentIdx = self.currentIdx - 1;
			end
		end

		function redo(self)
			if(self.currentIdx < length(self.stack))
				self.currentIdx = self.currentIdx + 1;
			end
		end

		function currentState = getCurrent(self)
			currentState = self.stack{self.currentIdx};
		end
	end

end
