function quickOpenBoundaryPlot(obuv, iit)

% Make a plot
hfig = figure(1); clf
hfig.Position = [218 4 1484 955];

ax(1) = subplot(2, 2, 1); axis ij, hold on
pcolor(obuv.T(:, :, iit)'), shading flat

ax(2) = subplot(2, 2, 2); axis ij, hold on
pcolor(obuv.S(:, :, iit)'), shading flat

ax(3) = subplot(2, 2, 3); axis ij, hold on
pcolor(obuv.U(:, :, iit)'), shading flat

ax(4) = subplot(2, 2, 4); axis ij, hold on
pcolor(obuv.V(:, :, iit)'), shading flat

% Colors.
warning off
colormap(ax(1), flipud(cbrewer('seq', 'YlGnBu', 64)))
colormap(ax(2), flipud(cbrewer('seq', 'YlGnBu', 64)))
colormap(ax(3), flipud(cbrewer('div', 'RdBu', 64)))
colormap(ax(4), flipud(cbrewer('div', 'RdBu', 64)))

% These are arbitrary.
ax(1).CLim = [0 25];
ax(2).CLim = [34 37];
ax(3).CLim = [-1 1]*0.08;
ax(4).CLim = [-1 1]*0.08;

% Length of boundary.
nn = length(obuv.T(:, 1, iit));

ax(1).XLim = [1 nn];
ax(2).XLim = [1 nn];
ax(3).XLim = [1 nn];
ax(4).XLim = [1 nn];

hc(1) = colorbar(ax(1), 'eastoutside');
hc(2) = colorbar(ax(2), 'eastoutside');
hc(3) = colorbar(ax(3), 'eastoutside');
hc(4) = colorbar(ax(4), 'eastoutside');

title(ax(1), 'T')
title(ax(2), 'S')
title(ax(3), 'U')
title(ax(4), 'V')

pause(0.2)

