function checkOpenBoundaries(parent, obij)

% Check that 
%		1. That all fields are specified.
%		2. That indices make sense given the alignement of the field (W v E, ii v jj).
%		3. That open boundaries which span a face are aligned correctly (?).
%		4. That open boundaries are 'legal' and do not coincide exactly with the boundary of a face.

