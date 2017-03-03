function cobuv = interpolateOpenBoundaryCondition(cobij, pobij, pobuv)

% Display a message
fprintf('Interpolating an obc on the %s edge of face %d...', cobij.edge, cobij.face)
t1 = tic;

% Number of time-steps.
nt = length(pobuv.T1(1, 1, :));

% Initialize U, V, T, S (which are all the same size)
cobuv.T1 = zeros(cobij.nn, cobij.nz, nt);
cobuv.T2 = zeros(cobij.nn, cobij.nz, nt);
cobuv.S1 = zeros(cobij.nn, cobij.nz, nt);
cobuv.S2 = zeros(cobij.nn, cobij.nz, nt);
cobuv.U  = zeros(cobij.nn, cobij.nz, nt);
cobuv.V  = zeros(cobij.nn, cobij.nz, nt);

cobuv.time = pobuv.time;

% Extract the grid centers and edges in the coordinate that varies over the boundary.
switch cobij.face
    case {1, 2}
        switch cobij.edge
            case {'south', 'north'}
                pG = pobij.xG;
                pC = pobij.xC1;
                cC = cobij.xC1;
            case {'east', 'west'}
                pG = pobij.yG;
                pC = pobij.yC1;
                cC = cobij.yC1;
        end
    case {4, 5}
        switch cobij.edge
            case {'south', 'north'}
                pG = pobij.yG;
                pC = pobij.yC1;
                cC = cobij.yC1;
            case {'east', 'west'}
                pG = pobij.xG;
                pC = pobij.xC1;
                cC = cobij.xC1;
        end
    case 3
        error('Open boundary interpolation on face 3 is not yet supported.')
end

% Set NaN's to zero.
pobuv.T1(isnan(pobuv.T1)) = 0;
pobuv.T2(isnan(pobuv.T2)) = 0;
pobuv.S1(isnan(pobuv.S1)) = 0;
pobuv.S2(isnan(pobuv.S2)) = 0;
pobuv.U (isnan(pobuv.U )) = 0;
pobuv.V (isnan(pobuv.V )) = 0;

% Plot of bathymetry along the boundary.
zoom = cobij.nn / pobij.nn;

% Loop over the horizontal index of the open boundary.
for kk = 1:cobij.nn

    %disp(sprintf('depth: %.10f', cobij.depth1(kk)))

    % Continue only if the 'first wet point' is ocean (with depth < 0).
    if cobij.depth1(kk) < 0

        for mm = 1:cobij.nz
            
            %disp(sprintf('zF: %.3f', cobij.zF(mm)))

            % Only assign values if the top of the cell is above 
            % the bottom of the ocean.
            if cobij.zF(mm) > cobij.depth1(kk)

                % --------------------------------------------------------- 
                % "Interior interpolation."  Determine containing cell.
                % --------------------------------------------------------- 

                % This snippet returns the index of zC and either xC or yC
                % on the parent grid that corresponds to the parent cell in which 
                % the child cell is entirely contained. 

                % To determine this index, the 'grid' (for x,y) or 'face' (for z) 
                % index is found for which either 
                % parent.zF > child.zC (zF lies above zC) or parent.xG < child.xC
                % (xG is 'left' of xC).  The indexing convention is then such that
                % the child center-point lies between the two parent face or grid 
                % points; and that the parent center point corresponding to that 
                % cell is equivalent to the right grid index.

                % Note: find(x<a) returns a vector with the indices of x that 
                % meet the criterion x<a.  max(find(x<a)) finds the 
                % maximum or 'rightmost' index that satisfies x<a. This logic 
                % underlies both the following lines.

                % Find index of containing z-cell.
                mmp = max(find( pobij.zF > cobij.zC(mm) ));
                % Find index of containing tangent-cell.
                kkp = max(find( pG < cC(kk) ));

                % Check that behavior is as expected.
                if cC(kk) < pG(kkp) && cC(kk) < pG(kkp+1)
                    error('Interpolation: child cell is outside (left) of selected parent cell.')
                elseif cC(kk) > pG(kkp) && cC(kk) > pG(kkp+1)
                    error('Interpolation: child cell is outside (right) of selected parent cell.')
                end

                %disp(sprintf(['left parent face: %.3f, child center: %.3f, ', ...
                %                'parent center: %.3f, right parent face: %.3f'],  ...
                %                pG(kkp), cC(kk), pC(kkp), pG(kkp+1) ))

                % Assign values.  If hFac=0, no value exists on parent grid; use 
                % value overhead instead.
                
                % Assign values.  There are two hooks for two possible errors:
                %
                %   1. The selected parent cell is dry (new ocean is being created 
                %      on the child grid).  In this case, assign child grid with 
                %      values from the deepest adjacent cell. kkAdj is the index 
                %      of the adjacent boundary column to be used. 
                %
                %   2. The selected parent cell lies underneath the bottom (and thus
                %      there is no data to attach to the child grid).  In this case, 
                %      uniformly extend data from the deepest wet cell on the parent 
                %      grid.

                % Scenario #1: selected parent column is dry.
                if pobij.depth1(kkp) == 0

                    warning(['New ocean is being created on the boundary. ', ...
                            'The resulting boundary condition will be unrealistic.'])

                    if kkp == 1
                        kkLeft = 1;
                    else
                        % Search for nearest adjacent wet column to the left.
                        leftWetPtFound = 0;
                        kkLeft = kkp-1;
                        while ~leftWetPtFound && kkLeft > 1
                            if pobij.depth1(kkLeft) < 0
                                leftWetPtFound = 1;
                            else
                                kkLeft = kkLeft - 1;
                            end
                        end
                    end

                    if kkp == pobij.nn
                        kkRight = pobij.nn;
                    else
                        % Search for nearest adjacent wet column to the right.
                        rightWetPtFound = 0;
                        kkRight = kkp+1;
                        while ~rightWetPtFound && kkRight < pobij.nn
                            if pobij.depth1(kkRight) < 0
                                rightWetPtFound = 1;
                            else
                                kkRight = kkRight + 1;
                            end
                        end
                    end

                    % Check various cases for right- and left-adjacent wet columns to 
                    % decide which one to use:

                    % First, make sure there are wet points in the whole boundary.
                    if pobij.depth1(kkLeft) == 0 && pobij.depth1(kkRight) == 0
                        error('No wet parent points have been found!')
    
                    % Next check if one of the two have hit a dry end point.
                    elseif kkLeft == 1 && pobij.depth1(kkLeft) == 0
                        kkAdj = kkRight;
                    elseif kkRight == pobij.nn && pobij.depth1(kkRight) == 0
                        kkAdj = kkLeft;

                    % Next check if both are equal distance apart. If so, choose deepest.
                    elseif abs(kkp-kkRight) == abs(kkp-kkLeft)
                        if pobij.depth1(kkLeft) < pobij.depth1(kkRight)
                            kkAdj = kkLeft;
                        else
                            kkAdj = kkRight;
                        end
                    
                    % Finally if no other hooks are caught, choose the closest wet cell.
                    elseif abs(kkp-kkLeft) < abs(kkp-kkRight)
                        kkAdj = kkLeft;
                    else
                        kkAdj = kkRight;
                    end

                    % Set index of target parent cell to index of selected adjacent column.
                    kkp = kkAdj;
                        
                    %{
                    % With the new index in hand, modify the parent boundary conditions.
                    pobij.hFac.depth1(kkp) = pobij.hFac.depth1(kkAdj);
                    pobuv.T1(kkp, :) = pobuv.T1(kkAdj, :);
                    pobuv.T2(kkp, :) = pobuv.T2(kkAdj, :);
                    pobuv.S1(kkp, :) = pobuv.S1(kkAdj, :);
                    pobuv.S2(kkp, :) = pobuv.S2(kkAdj, :);
                    pobuv.U (kkp, :) = pobuv.U (kkAdj, :);
                    pobuv.V (kkp, :) = pobuv.V (kkAdj, :);
                    %}

                end
                        
                % Scenario #2: selected parent cell lies beneath the bottom 
                % of the parent-grid ocean. One hook each for first wet pt,
                % second wet pt, U, and V.
                if pobij.hFac.T1(kkp, mmp) == 0
                    % Find deepest wet cell in column.
                    mmw = max(find( pobij.hFac.T1(kkp, :) > 0 ));

                    cobuv.T1(kk, mm, :) = pobuv.T1(kkp, mmw, :);
                    cobuv.S1(kk, mm, :) = pobuv.S1(kkp, mmw, :);
                else
                    cobuv.T1(kk, mm, :) = pobuv.T1(kkp, mmp, :);
                    cobuv.S1(kk, mm, :) = pobuv.S1(kkp, mmp, :);
                end

                if pobij.hFac.T2(kkp, mmp) == 0
                    % Find deepest wet cell in column.
                    mmw = max(find( pobij.hFac.T2(kkp, :) > 0 ));

                    if isempty(mmw)
                        % Use first wet point value if second is land.
                        mmw = max(find( pobij.hFac.T1(kkp, :) > 0 ));
                        cobuv.T2(kk, mm, :) = pobuv.T1(kkp, mmw, :);
                        cobuv.S2(kk, mm, :) = pobuv.S1(kkp, mmw, :);
                    else
                        cobuv.T2(kk, mm, :) = pobuv.T2(kkp, mmw, :);
                        cobuv.S2(kk, mm, :) = pobuv.S2(kkp, mmw, :);
                    end
                else
                    cobuv.T2(kk, mm, :) = pobuv.T2(kkp, mmp, :);
                    cobuv.S2(kk, mm, :) = pobuv.S2(kkp, mmp, :);
                end

                if pobij.hFac.U(kkp, mmp) == 0
                    % Find deepest wet cell in column.
                    mmw = max(find( pobij.hFac.U(kkp, :) > 0 ));

                    % Only assign if an hFac > 0 was found.
                    if ~isempty(mmw)
                        cobuv.U(kk, mm, :) = pobuv.U(kkp, mmw, :);
                    end
                else
                    cobuv.U(kk, mm, :) = pobuv.U(kkp, mmp, :);
                end

                if pobij.hFac.V(kkp, mmp) == 0
                    % Find deepest wet cell in column.
                    mmw = max(find( pobij.hFac.V(kkp, :) > 0 ));

                    % Only assign if an hFac > 0 was found.
                    if ~isempty(mmw)
                        cobuv.V(kk, mm, :) = pobuv.V(kkp, mmw, :);
                    end
                else
                    cobuv.V(kk, mm, :) = pobuv.V(kkp, mmp, :);
                end

            end
        end
    end
end

fprintf(' done. (time = %6.3f s)\n', toc(t1))
