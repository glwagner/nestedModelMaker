function varargout = addOverlappingBorders(field, hGrid)

    % Along each interior boundary, add the neighboring strip of field and grid points
    % from the adjacent face.

    % Remember: ii (1st index) is left-right; jj (2nd index) is up-down.
    % "Left" or "lower" means first index, "right" or "upper" means final index.
    for face = 1:5

        switch face
            case 1
                % Note: left edge of face 1 is upper edge of face 5
                neighbor = 5;
                permutation = 1;
            case 2
                % Note: left edge of face 2 is right edge of face 1.
                neighbor = 1;
                permutation = 0;
            case 3
                error('Face 3 is not yet supported.')
                % Note: left edge of face 3 is upper edge of face 1.
                neighbor = 1;
                permutation = 1;
            case 4
                error('Actions involving face 3 are not supported.')
                % Note: left edge of face 4 is right edge of face 3.
                neighbor = 3;
                permutation = 0;
            case 5
                error('Actions involving face 3 are not supported.')
                % Note: left edge of face 5 is upper edge of face 3.
                neighbor = 3;
                permutation = 1;
        end

        if permutation
           permuteKey2 = [2 1];
           permuteKey3 = [2 1 3];
           % Target indices on neighboring face
           ii = 1:parent.nii(neighbor);
           jj = parent.njj(neighbor);
        else
            permuteKey2 = [1 2];
            permuteKey3 = [1 2 3];
            % Target indices on neighboring face
            ii = parent.nii(neighbor);
            jj = 1:parent.njj(neighbor);
        end

        % Add cells on left side.
        field{face} = cat(1, ...
            permute(field{neighbor}(ii, jj, :), permuteKey3), ...
            field{face});

        % Modify horizontal grid if included
        if nargin == 2

            hGrid{face}.xC = cat(1, ...
                permute(hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                hGrid{face}.xC);

            hGrid{face}.yC = cat(1, ...
                permute(hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                hGrid{face}.yC);
        end

        switch face
            case 1
                % Note: right edge of face 1 is left edge of face 2.
                neighbor = 2;
                permutation = 0;
            case 2
                % Note: right edge of face 2 is lower edge of face 4.
                neighbor = 4;
                permutation = 1;
            case 3
                error('Face 3 is not yet supported.')
                % Note: right edge of face 3 is left edge of face 4.
                neighbor = 4;
                permutation = 0;
            case 4
                error('The right edge of face 4 is Antarctica.')
            case 5
                error('The right edge of face 5 is Antarctica.')
        end

        if permutation
           permuteKey2 = [2 1];
           permuteKey3 = [2 1 3];
           % Target indices on neighboring face
           ii = 1:parent.nii(neighbor);
           jj = 1;
        else
            permuteKey2 = [1 2];
            permuteKey3 = [1 2 3];
            % Target indices on neighboring face
            ii = 1;
            jj = 1:parent.njj(neighbor);
        end

        % Add cells on right side.
        field{face} = cat(1, ...
            field{face}, ...
            permute(field{neighbor}(ii, jj, :), permuteKey3));

        % Modify horizontal grid if included
        if nargin == 2
            parent.hGrid{face}.xC = cat(1, ...
                parent.hGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            parent.hGrid{face}.yC = cat(1, ...
                parent.hGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));
        end

        switch face
            case 1
                error('Lower edge of face 1 is Antarctica')
            case 2
                error('Lower edge of face 2 is Antarctica')
            case 3
                error('Lower edge of face 3 is Russia')
            case 4
                % Note: lower edge of face 4 is right edge of face 2.
                neighbor = 2;
                permutation = 1;
            case 5
                % Note: lower edge of face 5 is upper edge of face 4.
                neighbor = 4;
                permutation = 0;
        end

        if permutation
           permuteKey2 = [2 1];
           permuteKey3 = [2 1 3];
           % Target indices on neighboring face
           ii = parent.nii(neighbor);
           jj = 1:parent.njj(neighbor);
        else
            permuteKey2 = [1 2];
            permuteKey3 = [1 2 3];
            % Target indices on neighboring face
            ii = 1:parent.nii(neighbor);
            jj = parent.njj(neighbor);
        end

        % Add cells on the lower side.
        field{face} = cat(2, ...
            permute(field{neighbor}(ii, jj, :), permuteKey3), ...
            field{face});

        if nargin == 2
            parenthGrid{face}.xC = cat(2, ...
                permute(parenthGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                parenthGrid{face}.xC);

            parenthGrid{face}.yC = cat(2, ...
                permute(parenthGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                parenthGrid{face}.yC);
        end

        switch face
            case 1
                error('Actions involving face 3 are not supported.')
                % Note: upper edge of face 1 is left edge of face 3.
                neighbor = 3;
                permutation = 1;
            case 2
                error('Upper edge of face 2 is Russia')
            case 3
                error('Actions involving face 3 are not supported.')
                % Note: upper edge of face 3 is left edge of face 5
                neighbor = 5;
                permutation = 1;
            case 4
                % Note: upper edge of face 4 is lower edge of face 5.
                neighbor = 5;
                permutation = 0;
            case 5
                % Upper edge of face 5 is left edge of face 1.
                neighbor = 1;
                permutation = 1;
        end

        if permutation
           permuteKey2 = [2 1];
           permuteKey3 = [2 1 3];
           % Target indices on neighboring face
           ii = 1;
           jj = 1:parent.njj(neighbor);
        else
            permuteKey2 = [1 2];
            permuteKey3 = [1 2 3];
            % Target indices on neighboring face
            ii = 1:parent.nii(neighbor);
            jj = 1;
        end

        % Add cells on right side.
        field{face} = cat(2, ...
            field{face}, ...
            permute(field{neighbor}(ii, jj, :), permuteKey3));

        if nargin == 2
            hGrid{face}.xC = cat(2, ...
                hGrid{face}.xC, ...
                permute(hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            hGrid{face}.yC = cat(2, ...
                hGrid{face}.yC, ...
                permute(hGrid{neighbor}.yC(ii, jj, :), permuteKey2));
        end

    end

end
