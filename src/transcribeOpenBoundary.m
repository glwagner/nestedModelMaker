function childObij = transcribeOpenBoundary(zoom, parentObij)

% ----------------------------------------------------------------------------- 
% "transcribeOpenBoundary.m"
%
%   This function transcribes an open boundary structure from a parent grid
%   to a child grid.  The resolution of the child grid is higher by a factor
%   "zoom".
%   
%   Inputs:
%       zoom       : The multiplicative increase in resolution from parent to 
%                    child grid.  The resolution of the child grid is 
%                    child.res = zoom*parent.res.
%
%       parentObij : Cell array of structures of ob info with fields:
%            .face : Face on which the open boundary lives.
%            .edge : Compass direction of the boundary.  .edge='south' 
%                    corresponds to a southern boundary. 
%            .ii   : i-indices of the open boundary in global coordinates. 
%            .jj   : j-indices of the open boundary in global coordinates. 
%            .nn   : Number of points along the open boundary.
%      
%   Outputs:
%       childObij  : Cell array of structures with child-grid open boundary info
%                    with the same fields listed above for the elements of 
%                    parentObij.
%  
% ----------------------------------------------------------------------------- 

% Loop over open boundaries.
for iOb = 1:length(parentObij)

    % Rename structure for convenience
    pobij = parentObij{iOb};

    % Transcribe descriptive info
    cobij.face = pobij.face;
    cobij.edge = pobij.edge;

    % Number of boundary cells on child grid
    cobij.nn = zoom*pobij.nn;

    % Transcribe ii and jj. Because indices specify grid interior by convention, 
    % the beginning and ending boundary indices depend on boundary orientation.
    switch cobij.edge
        case 'south'
            % Recall: ii is tangent and jj is normal to north/south boundary.

            % Set beginning and ending indices.
            ii0 = (pobij.ii(1)-1)*zoom+1;
            iif = pobij.ii(end)*zoom;

            cobij.ii = ii0:iif;

            % For north/south boundary, jj index is single-valued and denotes interior.
            cobij.jj = ((pobij.jj(1)-1)*zoom+1)*ones(1, length(cobij.ii));

        case 'north'
            % Recall: ii is tangent and jj is normal to north/south boundary.

            % Set beginning and ending indices.
            ii0 = (pobij.ii(1)-1)*zoom+1;
            iif = pobij.ii(end)*zoom;

            cobij.ii = ii0:iif;

            % For north/south boundary, jj index is single-valued and denotes interior.
            cobij.jj = pobij.jj(1)*zoom*ones(1, length(cobij.ii));

        case 'east'
            % Recall: ii is normal and jj is tangent to east/west boundary.

            % Set beginning and ending indices.
            jj0 = (pobij.jj(1)-1)*zoom+1;
            jjf = pobij.jj(end)*zoom;
            
            cobij.jj = jj0:jjf;

            % For east/west boundary, ii index is single-valued and denotes interior.
            cobij.ii = pobij.ii(1)*zoom*ones(1, length(cobij.jj));

        case 'west'
            % Recall: ii is normal and jj is tangent to east/west boundary.

            % Set beginning and ending indices.
            jj0 = (pobij.jj(1)-1)*zoom+1;
            jjf = pobij.jj(end)*zoom;
            
            cobij.jj = jj0:jjf;

            % For east/west boundary, ii index is single-valued and denotes interior.
            cobij.ii = ((pobij.ii(1)-1)*zoom+1)*ones(1, length(cobij.jj));
    end

    % Store transcribed open boundary structure.
    childObij{iOb} = cobij;

end
