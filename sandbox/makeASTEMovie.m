% Make a movie of ASTE fields.

% Initialize directories and parent model parameters.
[dirz, parent] = specifyDirzAndModel();

% z-level and number of months for movie
zLevel = 1;
nMonths = 12;

% Hard-coded for now
faceSize = 4320;
sub = 16;

% Load and subsample (not as good as averaging, but what we do now).
disp(' '), disp('Loading bathymetry...'), t1=tic;
hiResBathymetry = -abs(read_llc_fkij(dirz.bathy, faceSize, ...
					1, 1, 1:faceSize, 1:3*faceSize, 'real*8')); 
bathy1 = hiResBathymetry(1:sub:end, 1:sub:end);

hiResBathymetry = -abs(read_llc_fkij(dirz.bathy, faceSize, ...
					5, 1, 1:faceSize, 1:3*faceSize, 'real*8')); 
bathy5 = hiResBathymetry(1:sub:end, 1:sub:end);
disp(['   ... bathymetry loaded. (time = ' num2str(toc(t1), '%6.3f') ' s)'])
clear t1

% Concatenate into 'Atlantic ASTE movie' format.
asteBathy = [ bathy5(:, 361:end)', bathy1(:, 361:end)' ];

% Get the horizontal grid in 'Atlantic ASTE movie' format
hgrid = getHorizontalGrid(dirz.globalGrids.parent, parent);

% Visualize the bathymetry
hfig = figure(1); clf
set(gcf, 'DefaultTextInterpreter', 'latex')

ax(1) = subplot(1, 2, 1); hold on
contour(hgrid.xx, hgrid.yy, asteBathy, [-20 -20], 'k-')

ax(2) = subplot(1, 2, 2); hold on
contour(hgrid.xx, hgrid.yy, asteBathy, [-20 -20], 'k-')

colormap(ax(1), flipud(cbrewer('seq', 'YlGnBu', 64)))
colormap(ax(2), flipud(cbrewer('div', 'RdBu', 64)))

hc(1) = colorbar(ax(1), 'northoutside');
hc(2) = colorbar(ax(2), 'northoutside');

xlabel(ax(1), 'Longitude')
ylabel(ax(1), 'Latitude')

xlabel(ax(2), 'Longitude')
ylabel(ax(2), 'Latitude')

ax(1).YLim = [-32, 10];
ax(2).YLim = ax(1).YLim;

ax(1).XLim = [-60, 20];
ax(2).XLim = ax(1).XLim;

ax(1).CLim = [0.01 0.4];
ax(2).CLim = [-1 1]*4;

ax(1).TickLabelInterpreter = 'latex';
ax(2).TickLabelInterpreter = 'latex';
hc(1).TickLabelInterpreter = 'latex';
hc(2).TickLabelInterpreter = 'latex';

ax(2).YAxisLocation = 'right';

drawnow, pause(0.1)

xshift = 0.05;
ax(1).Position(1) = ax(1).Position(1) - xshift;
ax(2).Position(1) = ax(2).Position(1) - xshift;

xstretch = 0.05;
ax(1).Position(3) = ax(1).Position(3) + xstretch;
ax(2).Position(3) = ax(2).Position(3) + xstretch;

yshrink = 0.0;
ax(1).Position(4) = ax(1).Position(4) - yshrink; 
ax(2).Position(4) = ax(2).Position(4) - yshrink; 

drawnow, pause(0.1)
input('Press enter to make movie.')

% Make the movie
for month = 1:nMonths

    % Load 2D solution at level 'zLevel'
    soln = getASTEFields(dirz, parent, month, zLevel);

    % Speed
    sp = sqrt(soln.U.^2 + soln.V.^2);

    % Deviation of temperature from zonal average.
    Tp = bsxfun(@minus, soln.T, mean(soln.T, 2, 'omitnan'));

    axes(ax(1))
    pcolor(hgrid.xx, hgrid.yy, sp), shading flat

    axes(ax(2))
    pcolor(hgrid.xx, hgrid.yy, Tp), shading flat
        
    drawnow, pause(0.1)

end
