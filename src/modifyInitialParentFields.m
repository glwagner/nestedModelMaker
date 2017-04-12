function [SALT, THETA, UVEL, VVEL, parent] = modifyInitialParentFields( ...
            SALT, THETA, UVEL, VVEL, parent, child);

    %{
    % Modify fields - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Cut parent grids to size (not implemented yet).
    for face = 1:5
        if child.nii(face) == 0
            % Clear up space in memory.
            SALT{face}  = [];
            THETA{face} = [];
            UVEL{face}  = []; 
            VVEL{face}  = [];
        else
            % Need to convert from 'global' coordinates given by child.parent.ii 
            % To local coordinates on the ASTE grid, on which SALT{face} lives.
            % We also buffer the frame to be chopped out of the parent grid by 
            % a hard-coded number of cells to be safe.
            buffer = 10;
            iiLeft = max(1, ...
                child.parent.ii(face, 1) - parent.ii(face, 1) + 1 - buffer);
            iiRight = min(parent.nii(face), ...
                child.parent.ii(face, 2) - parent.ii(face, 1) + 1 + buffer);

            jjBottom = max(1, ...
                child.parent.jj(face, 1) - parent.jj(face, 1) + 1 - buffer);
            jjTop = min(parent.njj(face), ...
                child.parent.jj(face, 2) - parent.jj(face, 1) + 1 + buffer);

            ii = iiLeft:iiRight;
            jj = jjBottom:jjTop;

            % Cut both parent fields and parent grid.
            SALT{face}  = SALT{face} (ii, jj, :);
            THETA{face} = THETA{face}(ii, jj, :);
            UVEL{face}  = UVEL{face} (ii, jj, :);
            VVEL{face}  = VVEL{face} (ii, jj, :);

            parent.hGrid{face}.xC = parent.hGrid{face}.xC(ii, jj);
            parent.hGrid{face}.yC = parent.hGrid{face}.yC(ii, jj);

            % Remove parent grid variables that haven't been cut to avoid errors.
            rmfield(parent.hGrid{face}, 'xG' );
            rmfield(parent.hGrid{face}, 'yG' );
            rmfield(parent.hGrid{face}, 'dxG');
            rmfield(parent.hGrid{face}, 'dyG');
        end
    end
    %}


    % Add border to three-dimensional parent fields to allow interpolation onto
    %   1. The deepest bottom cell mid-point on the child grid, which is deeper
    %       than the deepest parent cell mid-point; 
    %   2. The child-grid cells that are adjacent to interior boundaries between
    %       faces, which require information across face.


    % Copy bottom cell on the parent grid
    parent.zGrid.zF(parent.nz+2) = parent.zGrid.zF(end)-parent.zGrid.dzF(end);
    parent.zGrid.dzF(parent.nz+1) = parent.zGrid.zF(end);
    parent.zGrid.zC(parent.nz+1) = 1/2*(parent.zGrid.zF(end-1)+parent.zGrid.zF(end));
    parent.zGrid.dzC(parent.nz) = parent.zGrid.zC(end-1)-parent.zGrid.zC(end);
    parent.nz = length(parent.zGrid.zC);

    for face = 1:5
        if child.nii(face) ~= 0
            SALT{face}  = cat(3, SALT{face},  NaN(size(SALT{face}(:, :, 1))));
            THETA{face} = cat(3, THETA{face}, NaN(size(SALT{face}(:, :, 1))));
            UVEL{face}  = cat(3, UVEL{face},  NaN(size(SALT{face}(:, :, 1))));
            VVEL{face}  = cat(3, VVEL{face},  NaN(size(SALT{face}(:, :, 1))));
        end
    end


    % Copy top cell on the parent grid into land.
    parent.zGrid.zF = [ -parent.zGrid.zF(1); 
                        reshape(parent.zGrid.zF, parent.nz+1, 1) ];

    parent.zGrid.dzF = [ parent.zGrid.zF(1)-parent.zGrid.zF(2);
                         reshape(parent.zGrid.dzF, parent.nz, 1) ];

    parent.zGrid.zC = [ 1/2*(parent.zGrid.zF(1)+parent.zGrid.zF(2));
                        reshape(parent.zGrid.zC, parent.nz, 1) ];

    parent.zGrid.dzC = [ parent.zGrid.zC(1)-parent.zGrid.zC(2);
                         reshape(parent.zGrid.dzC, parent.nz-1, 1) ];
    parent.nz = length(parent.zGrid.zC)

    for face = 1:5
        if child.nii(face) ~= 0
            SALT{face}  = cat(3, SALT{face}(:, :, 1),  SALT{face}  ); 
            THETA{face} = cat(3, THETA{face}(:, :, 1), THETA{face} ); 
            UVEL{face}  = cat(3, UVEL{face}(:, :, 1),  UVEL{face}  ); 
            VVEL{face}  = cat(3, VVEL{face}(:, :, 1),  VVEL{face}  ); 
        end
    end

    % Along each interior boundary, add the neighboring strip of field and grid points
    % from the adjacent face.

    % Key
    left  = 1;
    right = 2;
    lower = 1;
    upper = 2;

    % Remember: ii (1st index) is left-right; jj (2nd index) is up-down.
    % "Left" or "lower" means first index, "right" or "upper" means final index.
    for face = 1:5
        if child.nii(face) ~= 0

            % Left: ii=1.
            if strcmp(child.bcs.ii{face}{left}, 'interior')
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
                SALT{face} = cat(1, ...
                    permute(SALT{neighbor}(ii, jj, :), permuteKey3), ...
                    SALT{face});

                THETA{face} = cat(1, ...
                    permute(THETA{neighbor}(ii, jj, :), permuteKey3), ...
                    THETA{face});

                UVEL{face} = cat(1, ...
                    permute(UVEL{neighbor}(ii, jj, :), permuteKey3), ...
                    UVEL{face});

                VVEL{face} = cat(1, ...
                    permute(VVEL{neighbor}(ii, jj, :), permuteKey3), ...
                    VVEL{face});

                parent.hGrid{face}.xC = cat(1, ...
                    permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                    parent.hGrid{face}.xC);

                parent.hGrid{face}.yC = cat(1, ...
                    permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                    parent.hGrid{face}.yC);

            end

            % Right: ii=end.
            if strcmp(child.bcs.ii{face}{right}, 'interior')
                % Add cells.
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
                SALT{face} = cat(1, ...
                    SALT{face}, ...
                    permute(SALT{neighbor}(ii, jj, :), permuteKey3));

                THETA{face} = cat(1, ...
                    THETA{face}, ...
                    permute(THETA{neighbor}(ii, jj, :), permuteKey3));

                UVEL{face} = cat(1, ...
                    UVEL{face}, ...
                    permute(UVEL{neighbor}(ii, jj, :), permuteKey3));

                VVEL{face} = cat(1, ...
                    VVEL{face}, ...
                    permute(VVEL{neighbor}(ii, jj, :), permuteKey3));

                parent.hGrid{face}.xC = cat(1, ...
                    parent.hGrid{face}.xC, ...
                    permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

                parent.hGrid{face}.yC = cat(1, ...
                    parent.hGrid{face}.yC, ...
                    permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

            end

            if strcmp(child.bcs.jj{face}{lower}, 'interior')
                % Add cells.
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
                SALT{face} = cat(2, ...
                    permute(SALT{neighbor}(ii, jj, :), permuteKey3), ...
                    SALT{face});

                THETA{face} = cat(2, ...
                    permute(THETA{neighbor}(ii, jj, :), permuteKey3), ...
                    THETA{face});

                UVEL{face} = cat(2, ...
                    permute(UVEL{neighbor}(ii, jj, :), permuteKey3), ...
                    UVEL{face});

                VVEL{face} = cat(2, ...
                    permute(VVEL{neighbor}(ii, jj, :), permuteKey3), ...
                    VVEL{face});

                parent.hGrid{face}.xC = cat(2, ...
                    permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                    parent.hGrid{face}.xC);

                parent.hGrid{face}.yC = cat(2, ...
                    permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                    parent.hGrid{face}.yC);

            end

            if strcmp(child.bcs.jj{face}{upper}, 'interior')
                % Add cells.
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
                SALT{face} = cat(2, ...
                    SALT{face}, ...
                    permute(SALT{neighbor}(ii, jj, :), permuteKey3));

                THETA{face} = cat(2, ...
                    THETA{face}, ...
                    permute(THETA{neighbor}(ii, jj, :), permuteKey3));

                UVEL{face} = cat(2, ...
                    UVEL{face}, ...
                    permute(UVEL{neighbor}(ii, jj, :), permuteKey3));

                VVEL{face} = cat(2, ...
                    VVEL{face}, ...
                    permute(VVEL{neighbor}(ii, jj, :), permuteKey3));

                parent.hGrid{face}.xC = cat(2, ...
                    parent.hGrid{face}.xC, ...
                    permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

                parent.hGrid{face}.yC = cat(2, ...
                    parent.hGrid{face}.yC, ...
                    permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

            end
        end
    end


end
