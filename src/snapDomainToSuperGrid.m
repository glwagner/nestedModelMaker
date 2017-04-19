function child = snapDomainToSuperGrid(child, nGrid)

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
    child.niiPad(face, :) = abs(child.unsnapped.ii(face, :) - child.ii(face, :));
    child.njjPad(face, :) = abs(child.unsnapped.jj(face, :) - child.jj(face, :));
end

% Measure the face-wise size of the grid.
for face = 1:5
    if child.ii(face, 1) == 0 
        child.nii(face) = 0;
        child.njj(face) = 0;
    else
        child.nii(face) = child.ii(face, right) - child.ii(face, left) + 1;
        child.njj(face) = child.jj(face, upper) - child.jj(face, lower) + 1;
    end
end

% Measure the east-west dimension of the grid.
% WARNING: this breaks if the grid resides completely on face 3.
nEast = 0;
nNorth = 0;
for face = 1:5
    switch face
        case {1, 2}
            nEast = nEast + child.nii(face);
            if child.njj(face) ~= 0
                nNorth = child.njj(face);
            end
        case {4, 5}
            nEast = nEast + child.njj(face)
            if child.nii(face) ~= 0
                nNorth = child.nii(face);
            end
    end
end

child.nEast = nEast;
child.nNorth = nNorth;
