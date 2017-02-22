function cobuv = interpolateOpenBoundaryCondition(cobij, pobij, pobuv)

% Display a message
disp(sprintf('Interpolating an obc on the %s edge of face %d...', cobij.edge, cobij.face))
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
                cC = cobij.xC1;
            case {'east', 'west'}
                pG = pobij.yG;
                cC = cobij.yC1;
        end
    case {4, 5}
        switch cobij.edge
            case {'south', 'north'}
                pG = pobij.yG;
                cC = cobij.yC1;
            case {'east', 'west'}
                pG = pobij.xG;
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
        
% Loop over the horizontal index of the open boundary.
for kk = 1:cobij.nn
    % If first wet point is dry, leave fields set to zero.
    if cobij.depth1(kk) ~= 0
        for mm = 1:cobij.nz
            % Only assign values if cell is above the bottom of the ocean.
            if cobij.zF(mm) < cobij.depth1

                % --------------------------------------------------------- 
                % "Interior interpolation."  Determine containing cell.
                % This scheme assumes that the z-index starts
                % at the surface and increase downwards, while the x-index
                % increases towards increasing values of x.
                % --------------------------------------------------------- 
                [~, mmp] = min( pobij.zF.*(pobij.zF > cobij.zC(mm)) );
                [~, kkp] = max( (pG+180).*(pG < cC(kk)) );

                % Assign.
                cobuv.T1(kk, mm, :) = pobuv.T1(kkp, mmp, :);
                cobuv.T2(kk, mm, :) = pobuv.T2(kkp, mmp, :);
                cobuv.S1(kk, mm, :) = pobuv.S1(kkp, mmp, :);
                cobuv.S2(kk, mm, :) = pobuv.S2(kkp, mmp, :);
                cobuv.U (kk, mm, :) = pobuv.U (kkp, mmp, :);
                cobuv.V (kk, mm, :) = pobuv.V (kkp, mmp, :);
            end
        end
    end
end

disp(sprintf('  ... interpolation is finished. (time = %6.3f s)', toc(t1))) 
