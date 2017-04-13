function lookAtDomain(parent, child, dirz)

% Cosmetic options
pGrid.color = [1 1 1];
pGrid.style = '-';
pGrid.lw    = 0.1;

% Time the function and display a messsage
t1 = tic; disp('Plotting the child subdomain...')

% Load 
bathy{1} = read_llc_fkij(dirz.bathy, child.res, ...
					1, 1, 1:child.res, 1:3*child.res, 'real*8'); 

bathy{5} = read_llc_fkij(dirz.bathy, child.res, ...
					5, 1, 1:child.res, 1:3*child.res, 'real*8'); 

% Rotate 90 deg.
bathy{5} = rot90(bathy{5}, 1);

% Figure positions.
positions = zeros(5, 4);
positions(1,:) = [8 38 237 498];
positions(5,:) = [61 388 632 205];

% FACE 1 ---------------------------------------------------------------------- 
for face = [1 5]

% Subsample for speed.
sub = 4;
subbathy{face}.ii = 1:sub:length(bathy{face}(:,1));
subbathy{face}.jj = 1:sub:length(bathy{face}(1,:));
subbathy{face}.b  = bathy{face}(1:sub:end, 1:sub:end);

% Parent grid on child resolution.
pSkip = 16;
pGrid.i =  1:pSkip*child.zoom:length(bathy{face}(:,1));
pGrid.j =  1:pSkip*child.zoom:length(bathy{face}(1,:));

% Add one more grid point to both.
pGrid.i = [pGrid.i pGrid.i+pSkip*child.zoom];
pGrid.j = [pGrid.j pGrid.j+pSkip*child.zoom];

% Look at bathymetry
hfig(face) = figure(face); clf, hold on
hfig(face).Position = positions(face,:);

% Plot.
imagesc(subbathy{face}.ii, subbathy{face}.jj, subbathy{face}.b')
axis xy, axis tight, ax=gca;

colormap(ax, flipud(bone))
if face == 1 
	ax.YLim = [2e3 child.nyFace(face)];
else
	ax.XLim = [0 child.nxFace(face)-2e3];
end
ax.CLim = [-2e3 5e3];

% Coastal contour for reference.
contour(subbathy{face}.ii, subbathy{face}.jj, subbathy{face}.b', ...
			[1 1]*20, 'Color', [1 1 1]*0.1 )

% Draw parent grid 
for ii = 1:length(pGrid.i)
    plot(pGrid.i([ii ii]), pGrid.j([1 end]), ...
            'LineStyle', pGrid.style, 'Color', pGrid.color, ...
            'LineWidth', pGrid.lw )
end

% x-lines and labels for parent grid.
for ii = 1:length(pGrid.j)
    plot(pGrid.i([1 end]), pGrid.j([ii ii]), ...
            'LineStyle', pGrid.style, 'Color', pGrid.color, ...
            'LineWidth', pGrid.lw )
end

% Make a patch showing the wet points of the grid.
children(face) = patch(	child.xx(face,[1 1 end end]), ...
						child.yy(face,[1 end end 1]), ...
						'b', ...
						'EdgeColor', 'none', 'FaceAlpha', 0.4);


end

% PATCH FACES.
bathy15 = [ rot90(bathy{5}, 3); bathy{1} ];
