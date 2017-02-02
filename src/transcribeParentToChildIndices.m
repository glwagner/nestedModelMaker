function cobij = transcribeOpenBoundaryParentToChild(pobij, zoom)

% pobij: parent open boundary info.
% cobij: child open boundary info.

% ------------------------------------------------------------------------- 
% Transcribe descriptive info
cobij.edge = pobij.edge;
cobij.face = pobij.face;

% Because indices specify grid interior by convention, the beginning and 
% ending boundary indices depend on boundary orientation.

if strcmp(cobij.edge, 'south')

	% Recall: ii is tangent and jj is normal to north/south boundary.

	% Set beginning and ending indices.
	ii0 = (pobij.ii(1)-1)*zoom+1;
	iif = pobij.ii(end)*zoom;

	cobij.ii = ii0:iif;

	% For north/south boundary, jj index is single-valued and denotes interior.
	cobij.jj = ((pobij.jj(1)-1)*zoom+1)*ones(1, length(cobij.ii));

elseif strcmp(cobij.edge, 'north')

	% Recall: ii is tangent and jj is normal to north/south boundary.

	% Set beginning and ending indices.
	ii0 = (pobij.ii(1)-1)*zoom+1;
	iif = pobij.ii(end)*zoom;

	cobij.ii = ii0:iif;

	% For north/south boundary, jj index is single-valued and denotes interior.
	cobij.jj = pobij.jj(1)*zoom*ones(1, length(cobij.ii));

elseif strcmp(cobij.edge, 'east')

	% Recall: ii is normal and jj is tangent to east/west boundary.

	% Set beginning and ending indices.
	jj0 = (pobij.jj(1)-1)*zoom+1;
	jjf = pobij.jj(end)*zoom;
	
	cobij.jj = jj0:jjf;

	% For east/west boundary, ii index is single-valued and denotes interior.
	cobij.ii = pobij.ii(1)*zoom*ones(1, length(cobij.jj));

elseif strcmp(cobij.edge, 'west')

	% Recall: ii is normal and jj is tangent to east/west boundary.

	% Set beginning and ending indices.
	jj0 = (pobij.jj(1)-1)*zoom+1;
	jjf = pobij.jj(end)*zoom;
	
	cobij.jj = jj0:jjf;

	% For east/west boundary, ii index is single-valued and denotes interior.
	cobij.ii = ((pobij.ii(1)-1)*zoom+1)*ones(1, length(cobij.jj));

end
