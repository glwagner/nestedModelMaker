function [padFields, padHGrid] = padInteriorBoundaries(fields, parent, child)

% Add border to three-dimensional parent fields to allow interpolation onto
% the child-grid cells that are adjacent to interior boundaries between
% faces, which require information across face.

% New fields and horizontal grid to be modified and outputted.
padHGrid = parent.hGrid;
padFields = fields;

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
            padFields{face}.T = cat(1, ...
                permute(fields{neighbor}.T(ii, jj, :), permuteKey3), ... 
                padFields{face}.T);

            padFields{face}.S = cat(1, ..
                permute(fields{neighbor}.S(ii, jj, :), permuteKey3), ... 
                padFields{face}.S);

            padHGrid{face}.xC = cat(1, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                padHGrid{face}.xC);

            padHGrid{face}.yC = cat(1, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                padHGrid{face}.yC);

            % Add cells on the left side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                padFields{face}.U = cat(1, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3), ... 
                    padFields{face}.U);

                padHGrid{face}.xU = cat(1, ...
                    permute(parent.hGrid{neighbor}.xV(ii, jj, :), permuteKey2), ...
                    padHGrid{face}.xV);

                padHGrid{face}.yU = cat(1, ...
                    permute(parent.hGrid{neighbor}.yV(ii, jj, :), permuteKey2), ...
                    padHGrid{face}.yV);

                % V
                padFields{face}.V = cat(1, ...
                    -permute( circshift(fields{neighbor}.U(ii, jj, :), 1, 1), permuteKey3), ... 
                    padFields{face}.V);

                padHGrid{face}.xV = cat(1, ...
                    permute( circshift(parent.hGrid{neighbor}.xU(ii, jj, :), 1, 1), permuteKey2), ...
                    padHGrid{face}.xV);

                padHGrid{face}.yV = cat(1, ...
                    permute( circshift(parent.hGrid{neighbor}.yU(ii, jj, :), -1, 1), permuteKey2), ...
                    padHGrid{face}.yV);

            else
                % Without permutation the padding is simple.
                padFields{face}.U = cat(1, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3), ... 
                    padFields{face}.U);

                padFields{face}.V = cat(1, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3), ... 
                    padFields{face}.V);

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};

                    padHGrid{face}.(p) = cat(1, ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2), ...
                        padHGrid{face}.(p));
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

            padFields{face}.T = cat(1, padFields{face}.T, ...
                permute(fields{neighbor}.T(ii, jj, :), permuteKey3));

            padFields{face}.S = cat(1, padFields{face}.S, ...
                permute(fields{neighbor}.S(ii, jj, :), permuteKey3));

            padHGrid{face}.xC = cat(1, padHGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            padHGrid{face}.yC = cat(1, padHGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

            % Add cells on the right side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                padFields{face}.U = cat(1, padFields{face}.U, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3));

                padHGrid{face}.xU = cat(1, padHGrid{face}.xV, ...
                    permute(parent.hGrid{neighbor}.xV(ii, jj, :), permuteKey2));

                padHGrid{face}.yU = cat(1, padHGrid{face}.yV, ...
                    permute(parent.hGrid{neighbor}.yV(ii, jj, :), permuteKey2));

                % V
                padFields{face}.V = cat(1, padFields{face}.V, ...
                    -permute( circshift(fields{neighbor}.U(ii, jj, :), -1, 1), permuteKey3));

                padHGrid{face}.xV = cat(1, padHGrid{face}.xU, ...
                    permute( circshift(parent.hGrid{neighbor}.xU(ii, jj, :), -1, 1), permuteKey2));

                padHGrid{face}.yV = cat(1, padHGrid{face}.yU, ...
                    permute( circshift(parent.hGrid{neighbor}.yU(ii, jj, :), -1, 1), permuteKey2));
            else
                % Without permutation the padding is simple.
                padFields{face}.U = cat(1, padFields{face}.U, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3));

                padFields{face}.V = cat(1, padFields{face}.V, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3));

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};

                    padHGrid{face}.(p) = cat(1, ...
                        padHGrid{face}.(p), ...
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

            padFields{face}.T = cat(2, ...
                    permute(fields{neighbor}.T(ii, jj, :), permuteKey3), ...
                    padFields{face}.T);

            padFields{face}.S = cat(2, ...
                    permute(fields{neighbor}.S(ii, jj, :), permuteKey3), ...
                    padFields{face}.S);

            padHGrid{face}.xC = cat(2, ...
                    permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                    padHGrid{face}.xC);

            padHGrid{face}.yC = cat(2, ...
                    permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                    padHGrid{face}.yC);

            % Add cells on the lower side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                padFields{face}.U = cat(2, ...
                    -permute(fields{neighbor}.V(ii, jj-1, :), permuteKey3), ...
                    padFields{face}.U);

                padHGrid{face}.xU = cat(2, ...
                    permute( circshift(parent.hGrid{neighbor}.xV(ii, jj, :), 1, 2), permuteKey2), ...
                    padHGrid{face}.xU);

                padHGrid{face}.yU = cat(2, ...
                    permute( circshift(parent.hGrid{neighbor}.yV(ii, jj-1, :), 1, 2), permuteKey2), ...
                    padHGrid{face}.yU);

                % V
                padFields{face}.V = cat(2, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3), ...
                    padFields{face}.V);

                padHGrid{face}.xV = cat(2, ...
                    permute(parent.hGrid{neighbor}.xU(ii, jj, :), permuteKey2), ...
                    padHGrid{face}.xV);

                padHGrid{face}.yV = cat(2, ...
                    permute(parent.hGrid{neighbor}.yU(ii, jj, :), permuteKey2), ...
                    padHGrid{face}.yV);

            else
                % Without permutation the padding is simple.
                padFields{face}.U = cat(2, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3), ...
                    padFields{face}.U);

                padFields{face}.V = cat(2, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3), ...
                    padFields{face}.V);

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};

                    padHGrid{face}.(p) = cat(2, ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2), ...
                        padHGrid{face}.(p));
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

            padFields{face}.T = cat(2, padFields{face}.T, ...
                permute(fields{neighbor}.T(ii, jj, :), permuteKey3));

            padFields{face}.S = cat(2, padFields{face}.S, ...
                permute(fields{neighbor}.S(ii, jj, :), permuteKey3));

            padHGrid{face}.xC = cat(2, padHGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            padHGrid{face}.yC = cat(2, padHGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

            % Add cells on the upper side: vectors. 
            % A manual rotation is required for vectors under permutation.
            if permutation
                % U
                padFields{face}.U = cat(2, padFields{face}.U, ...
                    -permute( circshift(fields{neighbor}.V(ii, jj, :), 1, 2), permuteKey3));

                padHGrid{face}.xU = cat(2, padHGrid{face}.xU, ...
                    permute( circshift(parent.hGrid{neighbor}.xV(ii, jj, :), 1, 2), permuteKey2));

                padHGrid{face}.yU = cat(2, padHGrid{face}.yU, ...
                    permute( circshift(parent.hGrid{neighbor}.yV(ii, jj, :), 1, 2), permuteKey2));

                % V
                padFields{face}.V = cat(2, padFields{face}.V, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3));

                padHGrid{face}.xV = cat(2, padHGrid{face}.xV, ...
                    permute(parent.hGrid{neighbor}.xU(ii, jj, :), permuteKey2));

                padHGrid{face}.yV = cat(2, padHGrid{face}.yV, ...
                    permute(parent.hGrid{neighbor}.yU(ii, jj, :), permuteKey2));

            else
                % Without permutation the padding is simple.
                padFields{face}.U = cat(2, padFields{face}.U, ...
                    permute(fields{neighbor}.U(ii, jj, :), permuteKey3));

                padFields{face}.V = cat(2, padFields{face}.V, ...
                    permute(fields{neighbor}.V(ii, jj, :), permuteKey3));

                for prop = {'xU', 'yU', 'xV', 'yV'}
                    p = prop{:};
                
                    padHGrid{face}.(p) = cat(2, padHGrid{face}.(p), ...
                        permute(parent.hGrid{neighbor}.(p)(ii, jj, :), permuteKey2));
                end
            end 
        end


    end
end
