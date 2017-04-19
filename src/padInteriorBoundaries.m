function [fields, hGrid] = padInteriorBoundaries(fields, parent, child)

% Add border to three-dimensional parent fields to allow interpolation onto
% the child-grid cells that are adjacent to interior boundaries between
% faces, which require information across face.

% New horizontal grid to be modified and outputted.
hGrid = parent.hGrid;

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
                    error('Actions involving face 3 are not supported.')
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

            % Add cells on left side: tracers
            fields{face}.T = cat(1, permute(fields{neighbor}.T(ii, jj, :), permuteKey3), ... 
                fields{face}.T);

            fields{face}.S = cat(1, permute(fields{neighbor}.S(ii, jj, :), permuteKey3), ... 
                fields{face}.S);

            hGrid{face}.xC = cat(1, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                hGrid{face}.xC);

            hGrid{face}.yC = cat(1, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                hGrid{face}.yC);

            % Add cells on the left side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                fields{face}.U = cat(1, permute(fields{neighbor}.V(ii, jj, :), permuteKey3), ... 
                    fields{face}.U);

                hGrid{face}.xU = cat(1, ...
                    permute(parent.hGrid{neighbor}.xV(ii, jj, :), permuteKey2), ...
                    hGrid{face}.xV);

                hGrid{face}.yU = cat(1, ...
                    permute(parent.hGrid{neighbor}.yV(ii, jj, :), permuteKey2), ...
                    hGrid{face}.yV);

                % V
                fields{face}.V = cat(1, -permute( circshift(fields{neighbor}.U(ii, jj, :), 1, 1), permuteKey3), ... 
                    fields{face}.V);

                hGrid{face}.xV = cat(1, ...
                    permute( circshift(parent.hGrid{neighbor}.xU(ii, jj, :), 1, 1), permuteKey2), ...
                    hGrid{face}.xV);

                hGrid{face}.yV = cat(1, ...
                    permute( circshift(parent.hGrid{neighbor}.yU(ii, jj, :), -1, 1), permuteKey2), ...
                    hGrid{face}.yV);

            else
                % Without permutation the padding is simple.
                fields{face}.U = cat(1, permute(fields{neighbor}.U(ii, jj, :), permuteKey3), ... 
                    fields{face}.U);

                fields{face}.V = cat(1, permute(fields{neighbor}.V(ii, jj, :), permuteKey3), ... 
                    fields{face}.V);

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};
                    hGrid{face}.(p) = cat(1, ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2), ...
                        hGrid{face}.(p));
                end
            end
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

            fields{face}.T = cat(1, fields{face}.T, ...
                permute(fields{neighbor}.T(ii, jj, :), permuteKey3));

            fields{face}.S = cat(1, fields{face}.S, ...
                permute(fields{neighbor}.S(ii, jj, :), permuteKey3));

            hGrid{face}.xC = cat(1, ...
                hGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            hGrid{face}.yC = cat(1, ...
                hGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

            % Add cells on the right side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                fields{face}.U = cat(1, fields{face}.U, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3));

                parent.hGrid{face}.xU = cat(1, ...
                    parent.hGrid{face}.xV, ...
                    permute(parent.hGrid{neighbor}.xV(ii, jj, :), permuteKey2));

                parent.hGrid{face}.yU = cat(1, ...
                    parent.hGrid{face}.yV, ...
                    permute(parent.hGrid{neighbor}.yV(ii, jj, :), permuteKey2));

                % V
                fields{face}.V = cat(1, fields{face}.V, ...
                    -permute( circshift(fields{neighbor}.U(ii, jj, :), -1, 1), permuteKey3));

                parent.hGrid{face}.xV = cat(1, ...
                    parent.hGrid{face}.xU, ...
                    permute( circshift(parent.hGrid{neighbor}.xU(ii, jj, :), -1, 1), permuteKey2));

                parent.hGrid{face}.yV = cat(1, ...
                    parent.hGrid{face}.yU, ...
                    permute( circshift(parent.hGrid{neighbor}.yU(ii, jj, :), -1, 1), permuteKey2));
            else
                % Without permutation the padding is simple.
                fields{face}.U = cat(1, fields{face}.U, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3));

                fields{face}.V = cat(1, fields{face}.V, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3));

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};

                    parent.hGrid{face}.(p) = cat(1, ...
                        parent.hGrid{face}.(p), ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2));
                end
            end
        end

        % Lower boundary
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

            fields{face}.T = cat(2, ...
                    permute(fields{neighbor}.T(ii, jj, :), permuteKey3), ...
                    fields{face}.T);

            fields{face}.S = cat(2, ...
                    permute(fields{neighbor}.S(ii, jj, :), permuteKey3), ...
                    fields{face}.S);

            hGrid{face}.xC = cat(2, ...
                    permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                    hGrid{face}.xC);

            hGrid{face}.yC = cat(2, ...
                    permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                    hGrid{face}.yC);

            % Add cells on the lower side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                fields{face}.U = cat(2, ...
                    -permute(fields{neighbor}.V(ii, jj-1, :), permuteKey3), ...
                    fields{face}.U);

                hGrid{face}.xU = cat(2, ...
                    permute( circshift(parent.hGrid{neighbor}.xV(ii, jj, :), 1, 2), permuteKey2), ...
                    hGrid{face}.xU);

                hGrid{face}.yU = cat(2, ...
                    permute( circshift(parent.hGrid{neighbor}.yV(ii, jj-1, :), 1, 2), permuteKey2), ...
                    hGrid{face}.yU);

                % V
                fields{face}.V = cat(2, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3), ...
                    fields{face}.V);

                hGrid{face}.xV = cat(2, ...
                    permute(parent.hGrid{neighbor}.xU(ii, jj, :), permuteKey2), ...
                    hGrid{face}.xV);

                hGrid{face}.yV = cat(2, ...
                    permute(parent.hGrid{neighbor}.yU(ii, jj, :), permuteKey2), ...
                    hGrid{face}.yV);

            else
                % Without permutation the padding is simple.
                fields{face}.U = cat(2, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3), ...
                    fields{face}.U);

                fields{face}.V = cat(2, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3), ...
                    fields{face}.V);

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};

                    hGrid{face}.(p) = cat(2, ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2), ...
                        hGrid{face}.(p));
                end
            end
        end


        % Upper boundary
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

            fields{face}.T = cat(2, fields{face}.T, ...
                permute(fields{neighbor}.T(ii, jj, :), permuteKey3));

            fields{face}.S = cat(2, fields{face}.S, ...
                permute(fields{neighbor}.S(ii, jj, :), permuteKey3));

            hGrid{face}.xC = cat(2, hGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            hGrid{face}.yC = cat(2, hGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

            % Add cells on the upper side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                fields{face}.U = cat(2, fields{face}.U, ...
                    -permute( circshift(fields{neighbor}.V(ii, jj, :), 1, 2), permuteKey3));

                hGrid{face}.xU = cat(2, hGrid{face}.xU, ...
                    permute( circshift(parent.hGrid{neighbor}.xV(ii, jj, :), 1, 2), permuteKey2));

                hGrid{face}.yU = cat(2, hGrid{face}.yU, ...
                    permute( circshift(parent.hGrid{neighbor}.yV(ii, jj, :), 1, 2), permuteKey2));

                % V
                fields{face}.V = cat(2, fields{face}.V, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3));

                hGrid{face}.xV = cat(2, hGrid{face}.xV, ...
                    permute(parent.hGrid{neighbor}.xU(ii, jj, :), permuteKey2));

                hGrid{face}.yV = cat(2, hGrid{face}.yV, ...
                    permute(parent.hGrid{neighbor}.yU(ii, jj, :), permuteKey2));

            else
                % Without permutation the padding is simple.
                fields{face}.U = cat(2, fields{face}.U, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3));

                fields{face}.V = cat(2, fields{face}.V, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3));

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};
                
                    hGrid{face}.(p) = cat(2, ...
                        hGrid{face}.(p), ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2));
                end
            end 
        end




    end
end
