% Load bathymetry file for face 1
clear all

dirRoot='/data5/glwagner/Numerics/regionalGridz/'
dirOut =[dirRoot 'run_template/'];
if(exist(dirOut)==0);mkdir(dirOut);fprintf('making directory %s\n',dirOut);end;

% nx is the size of the daughter grid
nx=4320;
% nx0 is the size of the parent grid
nx0=270;
fac=nx/nx0;

% Padding from left (western) boundary
pad = fac/2 - 2;

% Initial guesses for grid outline, eyeballed to 
%         1) contain the BBTRE experimental domain, and
%         2) has a dimension with many factors of 2, 3 and 5.  
ix = 300:2699;	        % 2400
jy = 6300:7199;         % 900

% Length of ix, jy
lx = length(ix); ly = length(jy);

% Make two 2x2 matrices of parent-grid indices: ix1_0 and jy1_0.
% The first column gives indices on the global llc270 grid, 
% while the second column gives indices on the aste llc270 grid.

% Find indices in global llc270 face1.
ix1_0(1,1) = floor(ix(1)   / fac);
ix1_0(2,1) = ceil (ix(end) / fac);
jy1_0(1,1) = floor(jy(1)   / fac);
jy1_0(2,1) = ceil (jy(end) / fac);

% Find indices in aste llc270 face1.
asteShift = 3*nx0-450;
ix1_0(:,2) = ix1_0(:,1);
jy1_0(1,2) = jy1_0(1,1) - asteShift;  
jy1_0(2,2) = jy1_0(2,1) - asteShift;

%       ix0        jy0
%    18   169   393   450
%    18   169    33    90

% Recalculate ix(1), at western boundary. (Eastern boundary is land.)
ixW = ix1_0(1,1)*fac + pad;
% Recalculate jy, at northern and southern boundaries
jyN = jy1_0(2,1)*fac - pad;
jyS = jy1_0(1,1)*fac + pad + 1;

% Remake ix and keep size constant.
ix1 = ixW:(ixW+lx-1);
% Remake jy. 
jy1 = jyS:jyN;

% New lengths.
lx = length(ix1); ly = length(jy1);

% To load and plot bathymetry and subdomain boundary.
loadAndPlotBathymetry = 0;
if loadAndPlotBathymetry

    % Directory for bathymetry
    dirBathy = '/net/nares/raid8/ecco-shared/llc8640/run_template/Smith_Sandwell_v14p1/';
    namBathy = 'SandS14p1_ibcao_4320x56160.bin';
    
    % Load 
    b = read_llc_fkij([dirBathy namBathy],  ...
                          nx, 1, 1, 1:nx, 1:3*nx, 'real*8'); 
    
    % Look at bathymetry
    figure(1), clf, hold on
    imagesc(b'), axis xy, axis tight
    
    % Draw a box around subdomain.
    plot(ix1, jy1(1)  *ones(1,lx), 'r-')
    plot(ix1, jy1(end)*ones(1,lx), 'r-')
    plot(ix1(1)  *ones(1,ly), jy1, 'r-')
    plot(ix1(end)*ones(1,ly), jy1, 'r-')
    
    set(gcf,'paperunits','inches','paperposition',[0 0 5 10]);
    fpr=[dirOut 'subdomain.png']; 
    print(fpr,'-dpng'); fprintf('%s\n',fpr);

end

% clear most of the variables.
clear asteShift dirBathy dirOut dirRoot fac fpr get_face5 ix ixW jy jyN jyS
clear namBathy nx nx0 pad

% code to get indices for face 5 if using both face1 and face5:
get_face5 = 0;
if get_face5
    ix5=3*nx-[iy1(end):-1:iy1(1)]+1;        %global [   1  450]
    iy5=sort(nx-ix1)+1;             %global [   1 1080]
    
    ix5_0=sort(3*nx0-(iy1_0)+1);            %global [   1  114]
    iy5_0=ceil(iy5(1)/fac):iy5(end)/fac;        %global [   1  270]
end
