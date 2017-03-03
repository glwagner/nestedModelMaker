function child = initializeChildGrid(child)

% Construct domain for child grid.
child.ii = zeros(5, 2);
child.jj = zeros(5, 2);

% Convention for indices in child.ii and child.jj.
left  = 1;
right = 2;
lower = 1;
upper = 2;

% Map grid specification in child.parent to child resolution  - - - - - - - - -

for face = 1:5

    if child.parent.ii(face, 1) ~= 0

        % Left (grid west) boundary.
        switch child.bcs.ii{face}{left}
            case 'interior'
                child.ii(face, left) = child.parent.ii(face, left);
            case 'land'
                child.ii(face, left) = child.parent.ii(face, left)*child.zoom;
            case 'open'
                % Add first wet point and framing land point
                child.ii(face, left) = (child.parent.ii(face, left)-1)*child.zoom - 1;
        end

        % Right (grid east) boundary.
        switch child.bcs.ii{face}{right}
            case 'interior'
                child.ii(face, right) = child.parent.ii(face, right)*child.zoom;
            case 'land'
                child.ii(face, right) = (child.parent.ii(face, right)-1)*child.zoom + 1;
            case 'open'
                % Add first wet point and framing land point
                child.ii(face, right) = child.parent.ii(face, right)*child.zoom + 2;
        end

        % Lower (grid south) boundary.
        switch child.bcs.jj{face}{lower}
            case 'interior'
                child.jj(face, lower) = child.parent.jj(face, lower);
            case 'land'
                child.jj(face, lower) = child.parent.jj(face, lower)*child.zoom;
            case 'open'
                % Add first wet point and framing land point
                child.jj(face, lower) = (child.parent.jj(face, lower)-1)*child.zoom - 1;
        end

        % Upper (grid north) boundary.
        switch child.bcs.jj{face}{upper}
            case 'interior'
                child.jj(face, upper) = child.parent.jj(face, upper)*child.zoom;
            case 'land'
                child.jj(face, upper) = (child.parent.jj(face, upper)-1)*child.zoom + 1;
            case 'open'
                % Add first wet point and framing land point
                child.jj(face, upper) = child.parent.jj(face, upper)*child.zoom + 2;
        end

    end

end
