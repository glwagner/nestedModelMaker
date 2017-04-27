function bathy_new=remove_extra_ocean_hFacC(bathy_old,hfC_old,hfC_new,hFacMin,hFacMinDr,drf,rf)
%------
%function bathy_new=remove_extra_ocean_hFacC(bathy_old,hfC_old,hfC_new,hFacMin,hFacMinDr,drf,rf)
%
% Function to remove "extra" ocean, which is due to how hFacCMin and hFacCminDr are defined
%   Goal: find index of where hFacC_new > hFacC_old where 
%         hFacC_old are from 50-klev and hFacC_new are from 106-klev
%         and remove this extra bathy;
% input:
%  bathy_old: [nx 1 ]
%  hfC_old  : [nx nz]
%  hfC_new  : [nx nz]
%  drf      : [ 1 nz]
%   rf      : [ 1 nz+1] (positive, abs(DRF.data))
%  hFacMin  : 0.2 (typical value)
%  hFacMinDr: 5.  (typical value)
%
% output:
%  bathy_new: [nx 1]
%
% ATN 16.Nov.2016

ttiny=1e-8;
%Take a threshold, so that if there's no new "cell" made, then even if ocean is deeper it should still be more
%than this threshold before we zero the cell out.  Otherwise can introduce large jump if using rf(iz(1))
hFacThreshold=hFacMin;
%hFacThreshold=0;

%check size:
if(size(drf,1)>size(drf,2));drf=drf';end;
if(size( rf,1)>size( rf,2)); rf= rf';end;
sz=size(bathy_old);nx=max(sz);
sz=size(drf);      nz=max(sz);
rf=abs(rf);if(length(rf)==nz & rf(1)>ttiny);rf=[0 rf];end;

%define indices
[zz,xx]=meshgrid(1:nz,1:nx);

bathy_new=bathy_old;

%search for "new" ocean:
for iloop=1:2;

  clear jj ii

  if(iloop==1);jj=find(hfC_old(:)<0 & hfC_new(:)>ttiny); str_loop = 'new ocean';	%first, search for case of entirely new ocean
  else;jj=find((hfC_new(:)-hfC_old(:))>hFacThreshold);str_loop = 'larger hfC'; end;

  fprintf('iloop: %i ');fprintf('%s ',str_loop);

  if(length(jj)>0);

    ii=xx(jj);

    fprintf(': length(ii): %i ',length(ii));
    icase1=0;icase2=0;icase3=0;icase4=0;
    for i=1:length(ii);
      %if(temp(ii(i))<=ttiny);                %case when diff is less than 1e-4m, just subtract 2e-4m
      %  %bathy_new(ii(i))=bathy_old(ii(i))-1e-4;
      %  icase3=icase3+1;
      %else;
        clear iz
        iz=closest(bathy_old(ii(i)),rf,2);
% rf(iz)                                  [2726.369999999999   2854.000000000000]
% [tempb(ii(i)) tempd(ii(ii))]            [2740.523681640625   2751.895999999999]
% rf(iz(1))+.2*drf(iz(1)) = tempd(ii(i))  %                    2751.895999999999
%So, the idea here is simply to make tempd < hFacMin/2*drf , and thus it 
% will get zeroed out and we have less ocean instead of more
        iz=sort(iz);                %make sure to always pick point ABOVE (less than)
        if(rf(iz(1))<=bathy_old(ii(i)));
          if(drf(iz(1))>hFacMinDr);
            bathy_new(ii(i))=rf(iz(1))+1e-4;%fac*(hFacMin/2)*drf(iz(1));
            icase1=icase1+1;
            if(bathy_new(ii(i))>bathy_old(ii(i)));
              fprintf('case1: bathy_new > bathy_old\n');
              %keyboard;
            end;
          else;
          %not yet a scheme to fix this, so just make a bit higher that prev depth
            bathy_new(ii(i))=rf(iz(1))+1e-4;
            icase2=icase2+1;
            if(bathy_new(ii(i))>bathy_old(ii(i)));
              fprintf('case2: bathy_new > bathy_old\n');
              %keyboard;
            end;
          end;
        else;
          icase4=icase4+1;
          fprintf('case4: %i %i',[i ii(i)]);
        end;
      %end;
    end;%length(ii)
    fprintf('[case1,case2,case3]: %i %i %i\n',[icase1 icase2 icase3]);
  end;
end;

return
