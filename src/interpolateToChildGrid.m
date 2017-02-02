function [child, cobij, cobuv] = interpolateToChildGrid(dirz, parent, child, pobij, pObuv)

% -----------------------------------------------------------------------------
child.llc.nx = parent.llc.nx * child.zoom;
child.llc.ny = parent.llc.ny * child.zoom;

% pobij = parent.
% pObuv = chlid.
% cobij = child.
% cObuv = child.

for iOb = 1:parent.nOb

	cobij{iOb} = transcribeParentToChildIndices(pobij{iOb}, child.zoom);

end
