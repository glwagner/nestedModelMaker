function childObuv = getChildOpenBoundaryConditions(childObij, parentObij, parentObuv)

% Loop through all the open boundaries.
for iOb = 1:length(childObij)

    % Display a message
    fprintf('Interpolating an obc on the %s edge of face %d...', ...
        childObij{iOb}.edge, childObij{iOb}.face)
    t1 = tic;

    % Use 'interior interpolation' to determine open boundary on child grid.
    childObuv{iOb} = interpOpenBoundary_interior( ...
        parentObuv{iOb}, childObij{iOb}, parentObij{iOb} );

    fprintf(' done. (time = %6.3f s)\n', toc(t1))

end

