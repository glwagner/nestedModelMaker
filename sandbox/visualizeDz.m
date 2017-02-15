% 'visualizeDz.m'.  This script loads and visualizes four z-grids, 
% one of which is the ASTE z-grid.
%
% glw Jan 22 2016
% -----------------------------------------------------------------------------  
clear all

% Specify the three grids to be compared with the ASTE grid.
namez{1} = '107b';
namez{2} = '101b';
namez{3} = 'flex';

% Specify the color to be associated with the three grids.
colorz{1} = 'b';
colorz{2} = 'r';
colorz{3} = [1 1 1]*0.6;
asteColor = 'k';

% Font size
fontSize = 14;

% Prefix before each grid name
prefix = [ pwd '/zgrid_' ];

% -----------------------------------------------------------------------------  
% Load three grids.
load([ prefix namez{1} '.mat'])
grid1 = zgrid; 
grid1Color = colorz{1};

load([ prefix namez{2} '.mat'])
grid2 = zgrid;
grid2Color = colorz{2};

load([ prefix namez{3} '.mat'])
grid3 = zgrid;
grid3Color = colorz{3};

% Load ASTE z-grid to compare with
load([pwd '/asteDz.mat'])

% Compute a few grid diagnostics.
grid1.averageDz = mean(grid1.delz);
grid2.averageDz = mean(grid2.delz);
grid3.averageDz = mean(grid3.delz);
aste.averageDz  = mean(aste.delz );

grid1.maxdzdelz = max(abs(grid1.dzdelz));
grid2.maxdzdelz = max(abs(grid2.dzdelz));
grid3.maxdzdelz = max(abs(grid3.dzdelz));
aste.maxdzdelz  = max(abs(aste.dzdelz ));

% Display some information about the grids.
disp(' ')
disp('Average delz (m):')
disp([grid1.name '    ' grid2.name '    ' grid3.name '    aste'])
disp([  num2str(grid1.averageDz,'%4.1f') '    ' ...
		num2str(grid2.averageDz,'%4.1f') '    ' ...
		num2str(grid3.averageDz,'%4.1f') '    ' ...
		num2str(aste.averageDz, '%4.1f') ]);
disp(' ')

disp('Max dz(delz):')
disp([grid1.name '    ' grid2.name '    ' grid3.name '    aste'])
disp([  num2str(grid1.maxdzdelz,'%04.2f') '    ' ...
		num2str(grid2.maxdzdelz,'%04.2f') '    ' ...
		num2str(grid3.maxdzdelz,'%04.2f') '    ' ...
		num2str( aste.maxdzdelz,'%04.2f') ]);
disp(' ')

% -----------------------------------------------------------------------------  
% Make a figure.
hfig = figure(1); clf, set(gcf, 'DefaultTextInterpreter', 'latex')
hfig.Position = [1 5 1280 669];

% Plot a visualization of the grid using offset horizontal lines.
ax(1) = subplot(1, 6, 1); axis ij, hold on

offset = 0.01;
for ii = 1:length(aste.zf)
	plot( [1.0 1.1], aste.zf([ii ii]), ...
		'LineStyle', '-', 'Color', asteColor), axis ij, grid minor
end
for ii = 1:length(grid1.zf)
	plot( [1.1 1.2]+1*offset, grid1.zf([ii ii]), ...
		'LineStyle', '-', 'Color', grid1Color), axis ij, grid minor
end
for ii = 1:length(grid2.zf)
	plot( [1.2 1.3]+2*offset, grid2.zf([ii ii]), ...
		'LineStyle', '-', 'Color', grid2Color), axis ij, grid minor
end
for ii = 1:length(grid3.zf)
	plot( [1.3 1.4]+3*offset, grid3.zf([ii ii]), ...
		'LineStyle', '-', 'Color', grid3Color), axis ij, grid minor
end

% Plot dz(delz) versus depth.
ax(2) = subplot(1, 6, 2); axis ij, grid minor, hold on

plot(grid1.dzdelz, grid1.zf(2:end-1), ...
		'o-', 'Color', grid1Color), axis ij, grid minor
plot(grid2.dzdelz, grid2.zf(2:end-1), ...
		'o-', 'Color', grid2Color), axis ij, grid minor
plot(grid3.dzdelz, grid3.zf(2:end-1), ...
		'o-', 'Color', grid3Color), axis ij, grid minor
plot(aste.dzdelz, aste.zf(2:end-1), ...
		'o-', 'Color', asteColor), axis ij, grid minor


% Plot delz versus depth.
ax(3) = subplot(1, 6, 3); axis ij, grid minor, hold on

plot(grid1.delz, (grid1.zf(2:end)+grid1.zf(1:end-1))/2, ...
		'o-', 'Color', grid1Color), axis ij, grid minor
plot(grid2.delz, (grid2.zf(2:end)+grid2.zf(1:end-1))/2, ...
		'o-', 'Color', grid2Color), axis ij, grid minor
plot(grid3.delz, (grid3.zf(2:end)+grid3.zf(1:end-1))/2, ...
		'o-', 'Color', grid3Color), axis ij, grid minor
plot(aste.delz, (aste.zf(2:end)+aste.zf(1:end-1))/2, ...
		'o-', 'Color', asteColor), axis ij, grid minor

% Plot a visualization of the grid using offset horizontal lines.
ax(4) = subplot(1, 6, 4); axis ij, hold on

offset = 0.01;
for ii = 1:length(aste.zf)
	plot( [1.0 1.1], aste.zf([ii ii]), ...
		'LineStyle', '-', 'Color', asteColor), axis ij, grid minor
end
for ii = 1:length(grid1.zf)
	plot( [1.1 1.2]+1*offset, grid1.zf([ii ii]), ...
		'LineStyle', '-', 'Color', grid1Color), axis ij, grid minor
end
for ii = 1:length(grid2.zf)
	plot( [1.2 1.3]+2*offset, grid2.zf([ii ii]), ...
		'LineStyle', '-', 'Color', grid2Color), axis ij, grid minor
end
for ii = 1:length(grid3.zf)
	plot( [1.3 1.4]+3*offset, grid3.zf([ii ii]), ...
		'LineStyle', '-', 'Color', grid3Color), axis ij, grid minor
end

% Plot dz(delz) versus depth.
ax(5) = subplot(1, 6, 5); axis ij, grid minor, hold on

plot(grid1.dzdelz, grid1.zf(2:end-1), ...
		'o-', 'Color', grid1Color), axis ij, grid minor
plot(grid2.dzdelz, grid2.zf(2:end-1), ...
		'o-', 'Color', grid2Color), axis ij, grid minor
plot(grid3.dzdelz, grid3.zf(2:end-1), ...
		'o-', 'Color', grid3Color), axis ij, grid minor
plot(aste.dzdelz, aste.zf(2:end-1), ...
		'o-', 'Color', asteColor), axis ij, grid minor


% Plot delz versus depth.
ax(6) = subplot(1, 6, 6); axis ij, grid minor, hold on

plot(grid1.delz, (grid1.zf(2:end)+grid1.zf(1:end-1))/2, ...
		'o-', 'Color', grid1Color), axis ij, grid minor
plot(grid2.delz, (grid2.zf(2:end)+grid2.zf(1:end-1))/2, ...
		'o-', 'Color', grid2Color), axis ij, grid minor
plot(grid3.delz, (grid3.zf(2:end)+grid3.zf(1:end-1))/2, ...
		'o-', 'Color', grid3Color), axis ij, grid minor
plot(aste.delz, (aste.zf(2:end)+aste.zf(1:end-1))/2, ...
		'o-', 'Color', asteColor), axis ij, grid minor

%%% Pretty things up ----------------------------------------------------------
% Labels
xlabel(ax(1), 'Grid visualization')
xlabel(ax(2), '$\partial_z (\Delta z)$')
xlabel(ax(3), '$\Delta z$ (m)')

ylabel(ax(1), 'Depth (m)')

% Link axes
linkaxes(ax(1:3), 'y')
linkaxes(ax(4:6), 'y')

% Use a logarithmic scale for subplots 4-6
ax(4).YScale = 'log';
ax(5).YScale = 'log';
ax(6).YScale = 'log';
ax(6).XScale = 'log';

% Axis limits
ax(1).YLim = [0 6200];
ax(4).YLim = [0 6200];

ax(1).XLim = [0.95 1.45];
ax(2).XLim = [0 0.3];
ax(5).XLim = [0 0.3];
ax(4).XLim = ax(1).XLim;
ax(6).XLim = [1e0 1e3];

ax(2).YTickLabel = [];
ax(3).YTickLabel = [];

xlabel(ax(4), 'Grid visualization')
xlabel(ax(5), '$\partial_z (\Delta z)$')
xlabel(ax(6), '$\Delta z$ (m)')

ylabel(ax(4), 'Depth (m, log scale)')

% Set many tick labels to nothing.
ax(1).XTickLabel = [];
ax(4).XTickLabel = [];
ax(5).YTickLabel = [];
ax(6).YTickLabel = [];

% Create separation between linear- and log-scale plots.
xshift = 0.03;
for ii = 1:3
	% Move first three to the left, second three to the right.
	ax(ii).Position(1) 	 = ax(ii).Position(1) - xshift;
	ax(ii+3).Position(1) = ax(ii+3).Position(1) + xshift;
end

% Set fontsize and use a latex interpreter for all plots
for ii = 1:6
	ax(ii).TickLabelInterpreter = 'latex';
	ax(ii).FontSize = fontSize;
end

% Text labels to identify the grids.  Format assumes the grid names have
% four characters each, roughly.
xtxt  = [0.19 0.41 0.63 0.86];
ytxt1 = 1.02;
ytxt2 = 1.055;

htxt(1) = text(xtxt(1), ytxt1, 'ASTE', ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(1));

htxt(2) = text(xtxt(2), ytxt2, grid1.name, ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(1));

htxt(3) = text(xtxt(3), ytxt1, grid2.name, ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(1));

htxt(4) = text(xtxt(4), ytxt2, grid3.name, ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(1));

htxt(5) = text(xtxt(1), ytxt1, 'ASTE', ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(4));

htxt(6) = text(xtxt(2), ytxt2, grid1.name, ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(4));

htxt(7) = text(xtxt(3), ytxt1, grid2.name, ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(4));

htxt(8) = text(xtxt(4), ytxt2, grid3.name, ...
				'Units', 'Normalized', 'FontSize', fontSize, ...
				'HorizontalAlignment', 'center', 'Parent', ax(4));
