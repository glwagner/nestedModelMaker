function child = snapToSuperGrid(child, nGrid)

% Save child prior to snapping.
child.unsnapped.ii = child.ii;
child.unsnapped.jj = child.jj;

% Convention for indices in child.ii and child.jj.
left  = 1;
right = 2;
lower = 1;
upper = 2;

% Snap to grid.
for face = 1:5

    if child.ii(face, 1) ~= 0

        % Snap left.
        oldii = child.ii(face, left);
        child.ii(face, left) = oldii - mod(oldii-1, nGrid);

        % Snap right.
        oldii = child.ii(face, right);
        child.ii(face, right) = oldii + mod(-oldii, nGrid);

        % Snap down.
        oldjj = child.jj(face, lower);
        child.jj(face, lower) = oldjj - mod(oldjj-1, nGrid);

        % Snap up.
        oldjj = child.jj(face, upper);
        child.jj(face, upper) = oldjj + mod(-oldjj, nGrid);

    end
end

% Record the expansion made during grid-snapping.
for face = 1:5
    child.niiPad(face, :) = child.unsnapped.ii(face, :) - child.ii(face, :);
    child.njjPad(face, :) = child.unsnapped.jj(face, :) - child.jj(face, :);
end

% Measure size of the grid.
for face = 1:5
    child.nii(face) = child.ii(face, right) - child.ii(face, left) + 1;
    child.njj(face) = child.jj(face, upper) - child.jj(face, lower) + 1;
end
