function obij = specifyOpenBoundaries(parent)

% A user-defined function that specifies open boundary parameters.

% Open boundary cell arrays (of structures):
%		obij	: indices and stuff.

% Boundary fields are:
%		obij .face	: face on which the boundary lives.
%		obij .edge	: boundary location; edge='south' means 'southern boundary'
% 		obij .ii	: ii-points of boundary in global coordinates.
% 		obij .jj	: jj-points of boundary in global coordinates.
%
%		length(obij) must equal the number of open boundaries.

%** Perhaps automate this in the future using data from "parent" structure.

% Display a simple message for this quick and fast function.
disp('Specifying open boundaries.')

obij{1}.edge = 'south';
obij{1}.face = 1;
obij{1}.ii   = 1:170;
obij{1}.jj   = 395*ones(1, length(obij{1}.ii));

obij{2}.edge = 'north';
obij{2}.face = 1;
obij{2}.ii   = 1:170;
obij{2}.jj   = 448*ones(1, length(obij{2}.ii));

% The boundaries are symmetric around face 1/5 contact point.
obij{3}.edge = 'east';		% "grid E" is south on face 5.
obij{3}.face = 5;
obij{3}.jj   = 220:270;
obij{3}.ii   = (810-obij{1}.jj(1)+1)*ones(1, length(obij{3}.jj));;

% The boundaries are symmetric around face 1/5 contact point?
obij{4}.edge = 'west';		% "grid W" is north on face 5.
obij{4}.face = 5;
obij{4}.jj   = 220:270;
obij{4}.ii   = (810-obij{2}.jj(1)+1)*ones(1, length(obij{4}.jj));

