function precision = get_precision(fileName)

% Determine the precision of data contained in a file.
%
% Inputs:	
%	fileName	: directory/name of the file to be looked at.
%
% Outputs:
%	precision	: precision of the file data (either 'real*4' or 'real*8')

% Initialize the string.
precision='';

% Check to make sure the indicated file exists.
fileList = dir(fileName);
if length(fileList) == 0
	error(sprintf('%s does not exist! \n', fileName));
end

% Open the file.
fileId = fopen(fileName,'r');

% Read the file until the end of line is reached.
while ~feof(fileId);

	% Read current line.
  	line = fgets(fileId);

	% Find the string 'float' on the line
  	ifloat = strfind(line, 'float');

	% Read the characters 5 indices after apperance of 'float' 
	% and convert to an integer (either 32 or 64).
  	if length(ifloat) > 0
    	nn = str2num(line(ifloat+5:ifloat+6));
   	 	if nn==32
   	 	  	precision = 'real*4';
   	 	elseif nn==64
   	 	  	precision='real*8';
   	 	end
	end

end

% Close the file before exiting.
fclose(fileId);
