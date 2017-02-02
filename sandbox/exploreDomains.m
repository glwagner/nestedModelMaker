% Explore the bathymetry of the five LLC4320 faces.
clear all

% Directory for bathymetry
bathyPath = '/net/nares/raid8/ecco-shared/llc8640/run_template/Smith_Sandwell_v14p1/';
bathyFile = 'SandS14p1_ibcao_4320x56160.bin';
bathyName = [bathyPath bathyFile];

% Face-width in indices
nxFace = 4320;

% Load face 1 ------------------------------------------------------------ 
bathy.f1 = read_llc_fkij(bathyName, nxFace, ...
					1, 1, 1:nxFace, 1:3*nxFace, 'real*8'); 

% Transpose.
bathy.f1 = bathy.f1';

% Subsample
sub = 16;
subbathy.f1.ii = 1:sub:length(bathy.f1(1, :));
subbathy.f1.jj = 1:sub:length(bathy.f1(:, 1));
subbathy.f1.b = bathy.f1(1:sub:end, 1:sub:end);

% Look at bathymetry
hfig(1) = figure(1); clf, hold on
hfig(1).Position = [10 10 334 491];

% Plot.
%imagesc(subbathy.f1.ii, subbathy.f1.jj, subbathy.f1.b)
imagesc(subbathy.f1.b)
axis xy, axis tight, ax(1) = gca;

% 20m depth contour for reference.
%contour(subbathy.f1.ii, subbathy.f1.jj, subbathy.f1.b, ...
contour(1:length(subbathy.f1.b(1, :)), 1:length(subbathy.f1.b(:, 1)), ...
			subbathy.f1.b, ...
			[1 1]*20, 'Color', [1 1 1]*0.6)

%contour(1:4:length(bathy.f1(:,1)), 1:4:length(bathy.f1(1,:)), ...
%			bathy.f1(1:4:end,1:4:end)', ...
%			[1 1]*20, 'Color', [1 1 1]*0.6)

% Small prettying.
xlabel('grid x (east)')
ylabel('grid y (north)')

colormap(ax(1), flipud(bone))
ax(1).CLim = [1e2 5e3];
%ax(1).YLim = [2e3 3*nxFace];

% Load face 5 ------------------------------------------------------------ 
bathy.f5 = read_llc_fkij(bathyName, nxFace, ...
					5, 1, 1:nxFace, 1:3*nxFace, 'real*8'); 

% Rotate and transpose.
bathy.f5 = rot90(bathy.f5', 3);

% Subsample
sub = 16;
subbathy.f5.ii = 1:sub:length(bathy.f5(:, 1));
subbathy.f5.jj = 1:sub:length(bathy.f5(1, :));
subbathy.f5.b = bathy.f5(1:sub:end, 1:sub:end);

% Look at bathymetry
hfig(2) = figure(2); clf, hold on
hfig(2).Position = [10 350 500 150];

% Plot.
imagesc(subbathy.f5.b) %subbathy.f5.ii, subbathy.f5.jj, subbathy.f5.b)
axis xy, axis tight, ax(2) = gca;

% 20m depth contour for reference.
%contour(subbathy.f5.ii, subbathy.f5.jj, subbathy.f5.b, ...
contour(1:length(subbathy.f5.b(1, :)), 1:length(subbathy.f5.b(:, 1)), ...
			subbathy.f5.b, ...
			[1 1]*20, 'Color', [1 1 1]*0.6)

%contour(1:4:length(bathy.f5(1,:)), 1:4:length(bathy.f5(:,1)), ...
%			rot90(bathy.f5(1:4:end,1:4:end)', 3), ...
%			[1 1]*20, 'Color', [1 1 1]*0.6)

% Small prettying.
xlabel('grid x (south)')
ylabel('grid y (east)')

colormap(ax(2), flipud(bone))
ax(2).CLim = [1e2 5e3];
%ax(2).XLim = [1, 3*nxFace-2e3];

%{
% Load face 3 ------------------------------------------------------------ 
bathy.f3 = read_llc_fkij(bathyName, nxFace, ...
					3, 1, 1:nxFace, 1:3*nxFace, 'real*8'); 

% Look at bathymetry
hfig(3) = figure(3); clf, hold on
hfig(3).Position = [10 10 485 420];

% Plot.
imagesc(bathy.f3'), axis xy, axis tight, axis square, ax(3) = gca;

% 20m depth contour for reference.
contour(1:4:length(bathy.f3(:,1)), 1:4:length(bathy.f3(1,:)), ...
			bathy.f3(1:4:end,1:4:end)', ...
			[1 1]*20, 'Color', [1 1 1]*0.6)

% Small prettying.
xlabel('grid x')
ylabel('grid y')

colormap(ax(3), flipud(bone))
ax(3).CLim = [1e2 5e3];
ax(3).XLim = [1 nxFace];
ax(3).YLim = [1 nxFace];
%}
