% Make a movie of ASTE fields.
clear all

% Initialize directories and parent model parameters.
[dirz, parent] = specifyDirzAndModel();

% z-level and number of months for movie
zLevel = 1;
nMonths = 36;

% Brazil Basin:
%YLim = [  30, 120 ];
%XLim = [ 230, 440 ];

% North Atlantic:
YLim = [ 200, 320 ];
XLim = [ 100, 380 ];

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

% Concatenate into 'Atlantic ASTE movie' format.
asteBathy = [ bathy5(:, 361:end)', bathy1(:, 361:end)' ];

% Get the horizontal grid in 'Atlantic ASTE movie' format
hgrid = getHorizontalGrid(dirz.globalGrids.parent, parent);

% Visualize the bathymetry
hfig = figure(1); clf
set(gcf, 'DefaultTextInterpreter', 'latex')

ax(1) = subplot(1, 2, 1); hold on
ax(2) = subplot(1, 2, 2); hold on

imagesc(asteBathy, 'Parent', ax(1))
imagesc(asteBathy, 'Parent', ax(2))

ax(1).YDir = 'normal';
ax(2).YDir = 'normal';

colormap(ax(1), flipud(cbrewer('seq', 'YlGnBu', 64)))
colormap(ax(2), flipud(cbrewer('div', 'RdBu', 64)))

hc(1) = colorbar(ax(1), 'northoutside');
hc(2) = colorbar(ax(2), 'northoutside');

xlabel(ax(1), '$i$')
ylabel(ax(1), '$j$')

xlabel(ax(2), '$i$')
ylabel(ax(2), '$j$')

try
    ax(1).YLim = YLim;
    ax(2).YLim = YLim;

    ax(1).XLim = XLim;
    ax(2).XLim = XLim;
end

ax(1).CLim = [-6, 0]*1e3;
ax(2).CLim = ax(1).CLim;

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

yText = 1.33;
text(0, yText, 'Speed (m/s)', 'Parent', ax(1), ...
    'Units', 'Normalized')
text(0, yText, '$T - \int T \mathrm{d} x$ (${}^\circ C$)', 'Parent', ax(2), ...
    'Units', 'Normalized')

drawnow, pause(0.1)
input('Press enter to plot temperature and speed.')

% Make the movie
vid = VideoWriter('NorthAtlanticASTE.avi');
vid.FrameRate = 4;
open(vid)

for month = 1:nMonths

    % Load 2D solution at level 'zLevel'
    soln = getASTEFields(dirz, parent, month, zLevel);

    % Speed
    sp = sqrt(soln.U.^2 + soln.V.^2);

    % Deviation of temperature from zonal average.
    Tp = bsxfun(@minus, soln.T, mean(soln.T, 2, 'omitnan'));

    % Plot and adjust
    imagesc(sp, 'Parent', ax(1)) %, 'AlphaData', ~isnan(sp));
    imagesc(Tp, 'Parent', ax(2)) % 'AlphaData', ~isnan(Tp));

    % Paint NaNs white with partially transparent mask of white data. 
    [n, m] = size(sp);
    imagesc('CData', ones(n, m, 3), 'Parent', ax(1), 'AlphaData', isnan(sp))
    imagesc('CData', ones(n, m, 3), 'Parent', ax(1), 'AlphaData', isnan(sp))

    if ~exist('htxt')
        htxt = text(1, yText, sprintf('Monthly average ending %s', soln.date), ...
            'Parent', ax(1), 'Units', 'Normalized', ...
            'HorizontalAlignment', 'right');
    else
        htxt.String = sprintf('Monthly average ending %s', soln.date);
    end

    ax(1).CLim = [0.01 0.6];
    ax(2).CLim = [-1 1]*4;

    drawnow, pause(0.1)

    frame = getframe(hfig);
    writeVideo(vid, frame);

end

close(vid)
