function [fldOut, fldOut0] = get_obcsNSEW(fldIn0, fldIn, mygrid0, mygrid, ...
											flag_global, flag_case)

% idea: for any obcs, we need: indices [ix,jy]
% input: ix (global)
%        jy (global)
%        face
%        nfx0, nfy0
%        nfx , nfy
%        mygrid0
%        mygrid
%        flag_global: report if mygrid0 and mygrid are global (1) or regional (0) grids
%        flag_case: 1 for special (Gibraltar) or 0 for generic
%
% want:
% fldOut.obcs = [N, S, E, W]
%
%	Nomenclature: 	"C" for center, and "vel" for velocity point.
%					"C1" is the index of the "1st wet point" 
%					"C2" is the index of the "2nd wet point" 
%					"global" means global grid, 
%					"local" refers to the subdomain.
%
%     .iC1      (2, L) : rows for global and local
%	  .iC2      (2, L) : rows for global and local
%     .ivel     (2, L) : rows for global and local (all nan sometimes)
%     .jC1      (2, L) : rows for global and local
%     .jC2      (2, L) : rows for global and local
%     .jvel     (2, L) : rows for global and local
%
%     .dxg      (1, L)
%     .dyg      (1, L)
%
%	 The ratio between parent's and subgrid's linear distance along boundary.
%     .scaleX
%     .scaleY

% Initialize fields.
fldOut  = [];
fldOut0 = [];

for iloop=1:2;
  if(iloop==1);str='';else;str='0';end;
  eval(['fname=fieldnames(fldIn' str ');']);
  for k=1:size(fname,1);
    eval(['fldOut' str '.' char(fname(k)) '=fldIn' str '.' char(fname(k)) ';']);
  end;
end;

%define fullsize global:
nx0=fldIn0.nx;
nfx0_full=[nx0 nx0 nx0 3*nx0 3*nx0];
nfy0_full=[3*nx0 3*nx0 nx0 nx0 nx0];
nfx0=fldIn0.nfx;
nfy0=fldIn0.nfy;

nx =fldIn.nx;
nfx_full=[nx nx nx 3*nx 3*nx];
nfy_full=[3*nx 3*nx nx nx nx];
nfx=fldIn.nfx;
nfy=fldIn.nfy;

fac=nx/nx0;

%ix=fldIn.ix;			%MUST be global
%jy=fldIn.jy;			%MUST be global
face    = fldIn.face;
obcsstr = fldIn.obcsstr;

sshiftx  = fldIn.sshiftx;
sshifty  = fldIn.sshifty;
sshiftx0 = fldIn0.sshiftx;
sshifty0 = fldIn0.sshifty;

% Shift.  What is difference between "local" and "global"?
if ~flag_global
  	sshiftx_l  = -sshiftx;	% to get ix_local, subtract sshiftx_l from global ix_g
  	sshifty_l  = -sshifty; 	% to get jy_local, subtract sshifty_l from global jy_g
  	sshiftx_g  = 0;
  	sshifty_g  = 0;
  	sshiftx0_l = -sshiftx0;	% to get ix_local, subtract sshiftx_l from global ix_g
  	sshifty0_l = -sshifty0;	% to get jy_local, subtract sshifty_l from global jy_g
  	sshiftx0_g = 0;
  	sshifty0_g = 0;
else
  	sshiftx_g  = sshiftx;		% to get ix_global, add sshiftx to ix_local
  	sshifty_g  = sshifty;		% to get jy_global, add sshifty to jy_local
  	sshiftx_l  = 0;
  	sshifty_l  = 0;
  	sshiftx0_g = sshiftx0;	% to get ix_global, add sshiftx to ix_local
  	sshifty0_g = sshifty0;	% to get jy_global, add sshifty to jy_local
  	sshiftx0_l = 0;
  	sshifty0_l = 0;
end

% indices
% fldOut0.obcs=obcsstr;
% ALWAYS these ix are provided ONLY in global
fldOut0.iC1(1,:) = fldIn0.ix;           % global
fldOut0.iC1(2,:) = fldIn0.ix + sshiftx0_l; 	% local
fldOut0.jC1(1,:) = fldIn0.jy;           	% global
fldOut0.jC1(2,:) = fldIn0.jy + sshifty0_l; 	% local

%fldOut.obcs=obcsstr;
fldOut.iC1(1,:) = fldIn.ix;		
fldOut.iC1(2,:) = fldIn.ix + sshiftx_l;
fldOut.jC1(1,:) = fldIn.jy;	
fldOut.jC1(2,:) = fldIn.jy + sshifty_l;

% Display some stuff
disp(['obcsstr = ' obcsstr])
disp(' ')
disp(['sshiftx_l = ' int2str(sshiftx_l)])
disp(['sshifty_l = ' int2str(sshifty_l)])
disp(['sshiftx0_l = ' int2str(sshiftx0_l)])
disp(['sshifty0_l = ' int2str(sshifty0_l)])
disp(' ')
disp('fldOut. ... :')
disp(['iC1(1,[1 end]): ' int2str(fldOut.iC1(1,[1 end])) ])
disp(['iC1(2,[1 end]): ' int2str(fldOut.iC1(2,[1 end])) ])
disp(['jC1(1,[1 end]): ' int2str(fldOut.jC1(1,[1 end])) ])
disp(['jC1(2,[1 end]): ' int2str(fldOut.jC1(2,[1 end])) ])

% Loop over fldOut and fldOut0 (to do what?)
for name = {'fldOut', 'fldOut0'}
  	if strcmp(obcsstr, 'E')
  	  	eval([name{:} '.iC2  = ' name{:} '.iC1-1;']);
  	  	eval([name{:} '.ivel = ' name{:} '.iC1;']);
  	  	eval([name{:} '.jC2  = zeros(size(' name{:} '.jC1));']);
  	  	eval([name{:} '.jvel = zeros(size(' name{:} '.jC1));']);
  	elseif strcmp(obcsstr, 'W')
  	  	eval([name{:} '.iC2  = ' name{:} '.iC1+1;']);
  	  	eval([name{:} '.ivel = ' name{:} '.iC2;']);
  	  	eval([name{:} '.jC2  = zeros(size(' name{:} '.jC1));']);
  	  	eval([name{:} '.jvel = zeros(size(' name{:} '.jC1));']);
  	elseif strcmp(obcsstr, 'N')
  	  	eval([name{:} '.iC2  = zeros(size(' name{:} '.iC1));']);
  	  	eval([name{:} '.ivel = zeros(size(' name{:} '.iC1));']);
  	  	eval([name{:} '.jC2  = ' name{:} '.jC1-1;']);
  	  	eval([name{:} '.jvel = ' name{:} '.jC1;']);
  	elseif strcmp(obcsstr, 'S')
  	  	eval([name{:} '.iC2  = zeros(size(' name{:} '.iC1));']);
  	  	eval([name{:} '.ivel = zeros(size(' name{:} '.iC1));']);
  	  	eval([name{:} '.jC2  = ' name{:} '.jC1+1;']);
  	  	eval([name{:} '.jvel = ' name{:} '.jC2;']);
  	end
end

% keyboard
% d[x,y]g, [x,y]c, [x,y]g
if flag_global, ind = 1;
else, 			ind = 2;
end





% ----------------------------------------------------------------------------- 
% ----------------------------------------------------------------------------- 
% ----------------------------------------------------------------------------- 
% ----------------------------------------------------------------------------- 
% ----------------------------------------------------------------------------- 



if strcmp(obcsstr, 'N') || strcmp(obcsstr, 'S')

	% dx0 is a row vector.
  	dx0 = mygrid0.dxg{face}(fldOut0.iC1(ind, :), fldOut0.jvel(ind, 1))';
  	dx  = mygrid.dxg{face} (fldOut.iC1 (ind, :), fldOut.jvel (ind, 1))';

	% Initialize?
  	dy0	= zeros(1,length(dx0));
  	dy 	= zeros(1,length(dx));

  	fldOut0.xg = mygrid0.xg{face}(fldOut0.iC1(ind,:), fldOut0.jvel(ind,1))';
  	fldOut0.yg = mygrid0.yg{face}(fldOut0.iC1(ind,:), fldOut0.jvel(ind,1))';
  	fldOut.xg  = mygrid.xg{face} (fldOut.iC1(ind,:) , fldOut.jvel(ind,1))';
  	fldOut.yg  = mygrid.yg{face} (fldOut.iC1(ind,:) , fldOut.jvel(ind,1))';

elseif strcmp(obcsstr, 'E') || strcmp(obcsstr,'W')

	% dy0 is a row vector
  	dy0 = mygrid0.dyg{face}(fldOut0.ivel(ind,1), fldOut0.jC1(ind,:));	
  	dy  = mygrid.dyg{face} (fldOut.ivel(ind,1) , fldOut.jC1(ind,:));

  	dx0 = zeros(1,length(dy0));
  	dx  = zeros(1,length(dy));

	% Define the fields in "fldOut" and "fldOut0"
  	fldOut0.xg = mygrid0.xg{face}(fldOut0.ivel(ind,1), fldOut0.jC1(ind,:));
  	fldOut0.yg = mygrid0.yg{face}(fldOut0.ivel(ind,1), fldOut0.jC1(ind,:));
  	fldOut.xg  = mygrid.xg{face} (fldOut.ivel(ind,1) , fldOut.jC1(ind,:));
  	fldOut.yg  = mygrid.yg{face} (fldOut.ivel(ind,1) , fldOut.jC1(ind,:));

end
fldOut0.xc = mygrid0.xc{face}(fldOut0.iC1(ind,1),fldOut0.jC1(ind,:));
fldOut0.yc = mygrid0.yc{face}(fldOut0.iC1(ind,1),fldOut0.jC1(ind,:));
fldOut.xc  = mygrid.xc{face}(fldOut.iC1(ind,1),fldOut.jC1(ind,:));
fldOut.yc  = mygrid.yc{face}(fldOut.iC1(ind,1),fldOut.jC1(ind,:));

%now get scale
if(flag_case==0);	%generic
  	if(strcmp(obcsstr,'N')==1|strcmp(obcsstr,'S')==1);

		% Length of scaling array.
    	Lsc = length(fldIn0.ix);

        ix_1=zeros(1,length(fldIn0.ix)*fac);	%1 x 149*16
        ix=fldIn0.ix;                 			%1 x 149 
        for k=1:length(ix);						%1 to 149
           ii=(k-1)*fac+1 : k*fac;				%k=1, ii : 1:16
           jj=(ix(k)-1)*fac+1:ix(k)*fac;		%k=1, ix(1)=18, jj : 273:288
           ix_1(ii)=jj;
        end;
        [i,j,k]=intersect(fldIn.ix,ix_1);	%we use only k for index
        dx0_1=repmat(dx0./fac,[fac,1]);			% 16 x 149
        dx0_1 = reshape(dx0_1,1,fac*Lsc);
        dx0_1 = dx0_1(k);
        dy0_1 = zeros(size(dx0_1));
        dx1 = dx(j);
        scx=zeros(1,length(fldIn.ix));
        scx(j)=dx1./dx0_1;
    	dy1 = zeros(size(dx1));scy= zeros(size(scx));
        
		% bug?
    	%dx1 = reshape(dx,fac,Lsc);
    	%dx1 = sum(dx1,1);
    	%scx = dx1./dx0;
    	%dy1 = zeros(size(dx1));scy= zeros(size(scx));

	elseif(strcmp(obcsstr,'E')==1|strcmp(obcsstr,'W')==1);

		Lsc = length(fldIn0.jy);

        jy_1=zeros(1,length(fldIn0.jy)*fac);    %1 x 149*16
        jy=fldIn0.jy;                           %1 x 149 
        for k=1:length(jy);                     %1 to 149
           ii=(k-1)*fac+1 : k*fac;              %k=1, ii : 1:16
           jj=(jy(k)-1)*fac+1:jy(k)*fac;        %k=1, jy(1)=18, jj : 273:288
           jy_1(ii)=jj;
        end;
        [i,j,k]=intersect(fldIn.jy,jy_1);   %we use only k for index
        dy0_1=repmat(dy0./fac,[fac,1]);         % 16 x 149
        dy0_1 = reshape(dy0_1,1,fac*Lsc);
        dy0_1 = dy0_1(k);
        dx0_1 = zeros(size(dy0_1));
        dy1 = dy(j);
        scy=zeros(1,length(fldIn.jy));
        scy(j)=dy1./dy0_1;
        dx1 = zeros(size(dy1));scx= zeros(size(scy));

		%dy1 = reshape(dy,fac,Lsc);
		%dy1 = sum(dy1,1);
		%scy = dy1./dy0;
		%dx1 = zeros(size(dy1));scx= zeros(size(scy));

  end;

figure(3);clf;
  %subplot(221);plot(dy0,'ks-');grid;hold on;plot(dy1,'r.-');hold off;title('dy');legend('coarse','fine');
  subplot(221);plot(dy0_1,'ks-');grid;hold on;plot(dy1,'r.-');hold off;title('dy');legend('coarse','fine');
  subplot(222);plot(scy,'ks-');grid;title(num2str(mean(scy)));legend('dy1/dy0');
  %subplot(223);plot(dx0,'ks-');grid;hold on;plot(dx1,'r.-');hold off;title('dx');legend('coarse','fine');
  subplot(223);plot(dx0_1,'ks-');grid;hold on;plot(dx1,'r.-');hold off;title('dx');legend('coarse','fine');
  subplot(224);plot(scx,'ks-');grid;title(num2str(mean(scx)));legend('dx1/dx0');

  %scx=repmat(scx,[fac 1]);scx=reshape(scx,fac*Lsc,1)';	%row
  %scy=repmat(scy,[fac 1]);scy=reshape(scy,fac*Lsc,1)';	%row

else;
  dy1=sum(dy);
  dx1=sum(dx);
  if(strcmp(obcsstr,'N')==1|strcmp(obcsstr,'S')==1);
    scx=(sum(dx0).*ones(size(dx)))./dx1;		%a single number over entire width of ob
    scy=zeros(size(scx));
  elseif(strcmp(obcsstr,'E')==1|strcmp(obcsstr,'W')==1);
    scy=(sum(dy0).*ones(size(dy)))./dy1;		%a single number over entire width of ob
    scx=zeros(size(scy));
  end;
end;

fldOut.scaleX=scx;		%to be applied to uvel at fldOut.ivel
fldOut.scaleY=scy;		%to be applied to vvel at fldOut.jvel
fldOut.dxg   =dx;
fldOut.dyg   =dy;

fldOut0.dxg  =dx0;
fldOut0.dyg  =dy0;

return
