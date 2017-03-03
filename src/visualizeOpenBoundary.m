function visualizeOpenBoundary(bathyDir, boundary, fig)

% Pretty options.
colors = flipud(bone);
climz = [-2e3 5e3];

% Hard-coded for now
faceSize = 4320;

% Subsample hi-res bathymetry.
sub = 16;
subSize = faceSize/sub;

% Index vectors.
iiz{1} = 1:subSize;
iiz{2} = 1:subSize;
iiz{3} = 1:subSize;
iiz{4} = 1:3*subSize;
iiz{5} = 1:3*subSize;

jjz{1} = 1:3*subSize;
jjz{2} = 1:3*subSize;
jjz{3} = 1:subSize;
jjz{4} = 1:subSize;
jjz{5} = 1:subSize;

% Load and subsample (not as good as averaging, but what we do now).
disp(' '), disp('Loading bathymetry...'), t1=tic;
hiResBathymetry = read_llc_fkij(bathyDir, faceSize, ...
					1, 1, 1:faceSize, 1:3*faceSize, 'real*8'); 
bathy{1} = hiResBathymetry(1:sub:end, 1:sub:end);

hiResBathymetry = read_llc_fkij(bathyDir, faceSize, ...
					2, 1, 1:faceSize, 1:3*faceSize, 'real*8'); 
bathy{2} = hiResBathymetry(1:sub:end, 1:sub:end);

hiResBathymetry = read_llc_fkij(bathyDir, faceSize, ...
					3, 1, 1:faceSize, 1:3*faceSize, 'real*8'); 
bathy{3} = hiResBathymetry(1:sub:end, 1:sub:end);

hiResBathymetry = read_llc_fkij(bathyDir, faceSize, ...
					4, 1, 1:faceSize, 1:3*faceSize, 'real*8'); 
bathy{4} = hiResBathymetry(1:sub:end, 1:sub:end);

hiResBathymetry = read_llc_fkij(bathyDir, faceSize, ...
					5, 1, 1:faceSize, 1:3*faceSize, 'real*8'); 
bathy{5} = hiResBathymetry(1:sub:end, 1:sub:end);
disp(['   ... time = ' num2str(toc(t1), '%6.3f') ' s']), clear t1

% Adjust 3, 4, and 5.
bathy{3} = bathy{3}(1:subSize, 1:subSize);

bathy{4} = rot90(bathy{4}, 1);
bathy{5} = rot90(bathy{5}, 1);

%bathy{4} = fliplr(rot90(bathy{4}, 1));
%bathy{5} = fliplr(rot90(bathy{5}, 1));

% Plot ------------------------------------------------------------------------ 
hfig = figure(fig); clf
hfig.Position = [-1808 20 1274 952];

% Face 2
ax(1) = subplot(5, 5, [11 16 21]); hold on
ax(2) = subplot(5, 5, [12 17 22]); hold on
ax(3) = subplot(5, 5, 7); hold on
ax(4) = subplot(5, 5, 8:10); hold on
ax(5) = subplot(5, 5, 3:5); hold on

for face = 1:5
	imagesc(bathy{face}', 'Parent', ax(face))
	contour(iiz{face}, jjz{face}, bathy{face}', [1 1]*20, ...
				'Parent', ax(face), 'Color', [1 1 1]*0.1 )
end

% Plot open boundary as a bright cyan line.
plot(boundary.ii, boundary.jj, 'c-', 'LineWidth', 2, ...
		'Parent', ax(boundary.face))

% Prettify -------------------------------------------------------------------- 
ax(1).XLim = [1 subSize];
ax(2).XLim = [1 subSize];
ax(3).XLim = [1 subSize];
ax(4).XLim = [1 3*subSize];
ax(5).XLim = [1 3*subSize];

ax(1).YLim = [1 3*subSize];
ax(2).YLim = [1 3*subSize];
ax(3).YLim = [1 subSize];
ax(4).YLim = [1 subSize];
ax(5).YLim = [1 subSize];

ax(2).YAxisLocation = 'right';
ax(4).YAxisLocation = 'right';
ax(5).YAxisLocation = 'right';

ax(3).XAxisLocation = 'top';
ax(5).XAxisLocation = 'top';

ax(1).YDir = 'Normal';
ax(2).YDir = 'Normal';
ax(3).YDir = 'Normal';

ax(3).XDir = 'Normal';
ax(4).XDir = 'Normal';
ax(5).XDir = 'Normal';

ax(1).CLim = climz;
ax(2).CLim = climz;
ax(3).CLim = climz;
ax(4).CLim = climz;
ax(5).CLim = climz;

colormap(ax(1), colors)
colormap(ax(2), colors)
colormap(ax(3), colors)
colormap(ax(4), colors)
colormap(ax(5), colors)

% Adjust dimension of faces 3-5
xshift = 0.1;
yshift = 0.04;
ax(3).Position(4) = ax(3).Position(4) + yshift;
ax(4).Position(4) = ax(4).Position(4) + yshift;
ax(5).Position(4) = ax(5).Position(4) + yshift;

ax(4).Position(3) = ax(4).Position(3) - xshift;
ax(5).Position(3) = ax(5).Position(3) - xshift;

% Offset
yoff = 0.02;
ax(5).Position(2) = ax(5).Position(2) + yoff;

% Shifts of every face
rightShift = 0.02;
downShift = 0.04;
ax(1).Position(3) = ax(1).Position(3) + rightShift;
ax(2).Position(3) = ax(2).Position(3) + rightShift;
ax(3).Position(3) = ax(3).Position(3) + rightShift;
ax(4).Position(1) = ax(4).Position(1) + rightShift;
ax(5).Position(1) = ax(5).Position(1) + rightShift;

ax(1).Position(2) = ax(1).Position(2) - downShift;
ax(2).Position(2) = ax(2).Position(2) - downShift;
ax(3).Position(2) = ax(3).Position(2) - downShift;
ax(4).Position(2) = ax(4).Position(2) - downShift;
ax(5).Position(2) = ax(5).Position(2) - downShift;

% Compare bathymetry along parent and child open boundaries.
figure(2), clf, hold on
plot(1/2 + [0:parentObij{iOb}.nn-1], parentObij{iOb}.depth1, 'k-')
plot(1/child.zoom + [0:1/child.zoom:parentObij{iOb}.nn-1/child.zoom], childObij{iOb}.depth1, 'r-')
xlabel('kkp'), ylabel('depth'), legend('parent grid', 'child grid')
title(sprintf('Open boundary on the %s edge of face %d', childObij{iOb}.edge, childObij{iOb}.face))

pause(0.1)

