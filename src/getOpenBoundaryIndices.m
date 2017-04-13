function [ii, jj] = getOpenBoundaryIndices(obij, outputCoordinates, varargin)

% Get parent-grid coordinates to extract boundary conditions.

% Due to MITgcm convention, the correct index from which to 
% extract data for a boundary condition depends on the 
% orientation of the boundary.

% The boundary points contained in obij{iOb}.ii and .jj specify 
% the *interior* of the domain, and thus specify the "second wet
% point" in MITgcm terminology.  In consequence, finding the "first
% wet point" means adding or subtracting 1 depending on the 
% boundary direction.

% ----------------------------------------------------------------------------- 
% There is one optional input, "outputCoordinates". If 
% outputCoordinates='parent', the function returns indices with respect to the 
% parent grid.  Because the input "obij.ii" and "obij.jj" are required to be 
% with respect to the global llc coordinate system, this means there is 
% *a change of coordinates* between input and output.  If coordinateSystem='llc', 
% the function will *not* change coordinates.  If no outputCoordinates system 
% is specified, the default is to keep the coordinate system the same.

if nargin < 3
	% Default: do not change coordinates.
	changingCoordinates = 0;
elseif length(varargin) > 1
	error('An inavlid number of input arguments have been given!')
elseif strcmp(outputCoordinates, 'local')
	changingCoordinates = 1;
	% Struct offset gives coordinate transformation from llc to parent in x,y.
	offset = varargin{1};
elseif strcmp(outputCoordinates, 'llc')
	changingCoordinates = 0;
else
	error(['We have never heard of the coordinate system ' ...
			outputCoordinates '.  The two options are ''parent'' and ''llc''.'])
end

% ----------------------------------------------------------------------------- 
% Indices for arrays T, U, V along open boundaries.
% Indices for T are provided for first and second wet points.
% Indices for S are identical to T.
switch obij.edge
    case 'south'
        % On southern boundaries:
        %	- V is normal velocity
        %	- Velocity across boundary is defined at the second wet point.
        %	- First wet point is outside the interior to the south (-(grid y) dir).

        % First wet point.
        jj.T1 = obij.jj(1) - 1;

        % Second wet point.
        jj.T2 = obij.jj(1);
        jj.U  = obij.jj(1);
        jj.V  = obij.jj(1);

        % ii's along southern or northern boundares are identical.
        ii.T2 = obij.ii;
        ii.T1 = obij.ii;
        ii.U  = obij.ii;
        ii.V  = obij.ii;

        % Indices for xG have one extra point on the end.
        ii.xG  = [ii.V, 1+ii.V(end)];
        ii.yG  = [ii.V, 1+ii.V(end)];

        % For dxG on north/south boundaries, ii is same as ii for normal velocity.
        ii.dxG = ii.V;

        % For xG, yG, and dxG, jj is same as jj for normal velocity.
        jj.xG  = jj.V;
        jj.yG  = jj.V;
        jj.dxG = jj.V;

        % For north/south boundaries, dyG indices are for second wet point.
        ii.dyG = [ii.T2, 1+ii.T2(end)];
        jj.dyG = jj.T2;

    case 'north'
        % On northern boundaries:
        %	- V is normal velocity
        %	- Velocity across boundary is defined at the first wet point.
        %	- First wet point is outside the interior to the north (+(grid y) dir).

        % First wet point.
        jj.T1 = obij.jj(1)+1;
        jj.V  = obij.jj(1)+1;

        % Second wet point
        jj.T2 = obij.jj(1);
        jj.U  = obij.jj(1);

        % ii's along southern or northern boundares are identical.
        ii.T1 = obij.ii;
        ii.T2 = obij.ii;
        ii.U  = obij.ii;
        ii.V  = obij.ii;

        % Indices for grid information along boundary.
        ii.xG  = [ii.V, 1+ii.V(end)];
        ii.yG  = [ii.V, 1+ii.V(end)];

        % For dxG on north/south boundaries, ii is same as ii for normal velocity.
        ii.dxG = ii.V;

        % For xG, yG, and dxG, ii is same as ii for the normal velocity.
        jj.xG  = jj.V;
        jj.yG  = jj.V;
        jj.dxG = jj.V;

        % For southern/northern boundaries, dyG indices are for second wet point.
        ii.dyG = [ii.T2, 1+ii.T2(end)];
        jj.dyG = jj.T2;

    case 'west'
        % On western boundaries:
        %	- U is normal velocity
        %	- Velocity across boundary is defined at the second wet point.
        %	- First wet point is outside the interior to the west (-(grid x) dir).

        % First wet point.
        ii.T1 = obij.ii(1)-1;

        % Second wet point.
        ii.T2 = obij.ii(1);
        ii.U  = obij.ii(1);
        ii.V  = obij.ii(1);

        % jj's along western or eastern boundaries are identical.
        jj.U  = obij.jj;
        jj.V  = obij.jj;
        jj.T1 = obij.jj;
        jj.T2 = obij.jj;

        % Indices for grid information along boundary.
        jj.xG  = [jj.U, 1+jj.U(end)];
        jj.yG  = [jj.U, 1+jj.U(end)];

        % For dyG on east/west boundaries, jj is same as jj for normal velocity.
        jj.dyG = jj.U;

        % For xG, yG, and dxG, ii is same as ii for the normal velocity.
        ii.xG  = ii.U;
        ii.yG  = ii.U;
        ii.dyG = ii.U;

        % For east/west boundaries, dxG indices are for second wet point.
        ii.dxG = ii.T2;
        jj.dxG = [jj.T2, 1+jj.T2(end)];


    case 'east'
        % On eastern boundaries:
        %	- U is normal velocity
        %	- Velocity across boundary is defined at the first wet point.
        %	- First wet point is outside the interior to the east (+(grid x) dir).

        % First wet point.
        ii.T1 = obij.ii(1)+1;
        ii.U  = obij.ii(1)+1;

        % Second wet point
        ii.T2 = obij.ii(1);
        ii.V  = obij.ii(1);

        % jj's along western or eastern boundaries are identical.
        jj.U  = obij.jj;
        jj.V  = obij.jj;
        jj.T1 = obij.jj;
        jj.T2 = obij.jj;

        % Indices for grid information along boundary.
        jj.xG  = [jj.U, 1+jj.U(end)];
        jj.yG  = [jj.U, 1+jj.U(end)];

        % For dyG on east/west boundaries, jj is same as jj for normal velocity.
        jj.dyG = jj.U; 

        % For xG, yG, and dxG, ii is same as ii for the normal velocity.
        ii.xG  = ii.U;
        ii.yG  = ii.U;
        ii.dyG = ii.U;

        % For east/west boundaries, dxG indices are for second wet point.
        ii.dxG = ii.T2;
        jj.dxG = [jj.T2, 1+jj.T2(end)];

end

% ----------------------------------------------------------------------------- 
if changingCoordinates
	% Add face-wise ii and jj offsets to convert from 
	% global to parent-grid coordinates.
	iiOff = offset.ii(obij.face);
	jjOff = offset.jj(obij.face);

	ii.T1 = ii.T1 - iiOff;
	ii.T2 = ii.T2 - iiOff;
	ii.U  = ii.U  - iiOff;
	ii.V  = ii.V  - iiOff;

	jj.T1 = jj.T1 - jjOff;
	jj.T2 = jj.T2 - jjOff;
	jj.U  = jj.U  - jjOff;
	jj.V  = jj.V  - jjOff;
end
