function quickOpenBoundaryMovie(obuv, obij, nt, fig)

% Make a plot
hfig = figure(fig); clf
set(gcf, 'DefaultTextInterpreter', 'latex')
%hfig.Position = [218 4 1484 955];

% Initialize subplots.
ax(1) = subplot(4, 1, 1); hold on, shading flat
ax(2) = subplot(4, 1, 2); hold on, shading flat
ax(3) = subplot(4, 1, 3); hold on, shading flat
ax(4) = subplot(4, 1, 4); hold on, shading flat

% Colors.
warning off
colormap(ax(1), parula)
colormap(ax(2), parula)
colormap(ax(3), polarmap(jet))
colormap(ax(4), polarmap(jet))

% These are arbitrary.
ax(1).CLim = [0 25];
ax(2).CLim = [34 37];
ax(3).CLim = [-1 1]*0.08;
ax(4).CLim = [-1 1]*0.08;

hc(1) = colorbar(ax(1), 'eastoutside');
hc(2) = colorbar(ax(2), 'eastoutside');
hc(3) = colorbar(ax(3), 'eastoutside');
hc(4) = colorbar(ax(4), 'eastoutside');

hc(1).TickLabelInterpreter = 'latex';
hc(2).TickLabelInterpreter = 'latex';
hc(3).TickLabelInterpreter = 'latex';
hc(4).TickLabelInterpreter = 'latex';

% Titles and labels
title(ax(2), 'salinity')

if obij.face == 1 || obij.face == 2
	title(ax(3), 'Eastward velocity (m/s)')
	title(ax(4), 'Northward velocity (m/s)')
elseif obij.face == 4 || obij.face == 5
	title(ax(3), 'Southward velocity (m/s)')
	title(ax(4), 'Eastward velocity (m/s)')
elseif obij.face == 3
	title(ax(3), 'x-velocity on cube sphere (m/s)')
	title(ax(4), 'y-velocity on cube sphere (m/s)')
end

% Decision-tree for labeling the x-axis.
if obij.face == 1 || obij.face == 2
	if strcmp(obij.edge, 'south') || strcmp(obij.edge, 'north')
		xlabel(ax(4), 'longitude')
	else
		xlabel(ax(4), 'latitude')
	end
elseif obij.face == 4 || obij.face == 5
	if strcmp(obij.edge, 'west') || strcmp(obij.edge, 'east')
		xlabel(ax(4), 'longitude')
	else
		xlabel(ax(4), 'latitude')
	end
else
	xlabel(ax(4), 'x')
end

ax(1).XTickLabel = [];
ax(2).XTickLabel = [];
ax(3).XTickLabel = [];

ax(1).YLim = [-6500 0];
ax(2).YLim = [-6500 0];
ax(3).YLim = [-6500 0];
ax(4).YLim = [-6500 0];

ylabel(ax(1), '$z$ (m)')
ylabel(ax(2), '$z$ (m)')
ylabel(ax(3), '$z$ (m)')
ylabel(ax(4), '$z$ (m)')

% Loop through all time points.
for iit = 1:nt

	% Adjust date.
	year  = obuv.time(iit, 1);
	month = obuv.time(iit, 2);
	day   = obuv.time(iit, 3); 

	% Make title...
	title(ax(1), ['Temperature in deg C for averging period ending ', ...
                     datestr([year month day 0 0 0])])

	% Pcolorz in (l, z), where 'l' is a horizontal coordinate
	% along the boundary.

	if obij.face == 1 || obij.face == 2
		if strcmp(obij.edge, 'south') || strcmp(obij.edge, 'north')
			pcolor(ax(1), obij.xC2, obij.zC, obuv.T2(:, :, iit)')
			pcolor(ax(2), obij.xC2, obij.zC, obuv.S2(:, :, iit)')
			pcolor(ax(3), obij.xC2, obij.zC, obuv.U (:, :, iit)')
			pcolor(ax(4), obij.xC2, obij.zC, obuv.V (:, :, iit)')
		elseif strcmp(obij.edge, 'west') || strcmp(obij.edge, 'east')
			pcolor(ax(1), obij.yC2, obij.zC, obuv.T2(:, :, iit)')
			pcolor(ax(2), obij.yC2, obij.zC, obuv.S2(:, :, iit)')
			pcolor(ax(3), obij.yC2, obij.zC, obuv.U (:, :, iit)')
			pcolor(ax(4), obij.yC2, obij.zC, obuv.V (:, :, iit)')
		end
	elseif obij.face == 4 || obij.face == 5
		if strcmp(obij.edge, 'south') || strcmp(obij.edge, 'north')
			pcolor(ax(1), obij.yC2, obij.zC, obuv.T2(:, :, iit)')
			pcolor(ax(2), obij.yC2, obij.zC, obuv.S2(:, :, iit)')
			pcolor(ax(3), obij.yC2, obij.zC, obuv.U (:, :, iit)')
			pcolor(ax(4), obij.yC2, obij.zC, obuv.V (:, :, iit)')
		elseif strcmp(obij.edge, 'west') || strcmp(obij.edge, 'east')
			pcolor(ax(1), obij.xC2, obij.zC, obuv.T2(:, :, iit)')
			pcolor(ax(2), obij.xC2, obij.zC, obuv.S2(:, :, iit)')
			pcolor(ax(3), obij.xC2, obij.zC, obuv.U (:, :, iit)')
			pcolor(ax(4), obij.xC2, obij.zC, obuv.V (:, :, iit)')
		end
	else % face 3
			nn = length(obuv.T2(:, 1, 1));
			pcolor(ax(1), 1:nn, obij.zC, obuv.T2(:, :, iit)')
			pcolor(ax(2), 1:nn, obij.zC, obuv.S2(:, :, iit)')
			pcolor(ax(3), 1:nn, obij.zC, obuv.U (:, :, iit)')
			pcolor(ax(4), 1:nn, obij.zC, obuv.V (:, :, iit)')
	end

	% Set pcolor shading to flat.
	axes(ax(1)), shading flat, axis tight
	axes(ax(2)), shading flat, axis tight
	axes(ax(3)), shading flat, axis tight
	axes(ax(4)), shading flat, axis tight

    ax(1).TickLabelInterpreter = 'latex';
    ax(2).TickLabelInterpreter = 'latex';
    ax(3).TickLabelInterpreter = 'latex';
    ax(4).TickLabelInterpreter = 'latex';

	pause(0.1)

end
