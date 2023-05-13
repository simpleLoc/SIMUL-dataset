classdef FileReader < handle

	properties(Access = private)
		fid = -1;
	end

	methods(Access = public)
		function self = FileReader(filePath)
			self.fid = fopen(filePath, 'r');
			assert(self.fid >= 0, 'Failed to open file!');
		end

		function line = readLine(self)
			line = fgets(self.fid);
		end

		function close(self)
			fclose(self.fid);
		end
	end

end
