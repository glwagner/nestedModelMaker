function [icoast]=locate_coast(hf,num_grid)
% ----- a quick way to locate coast: ------------------------------------
% function [icoast]=locate_coast(hf,num_grid)
%
% Input: hf [nx ny nz]
%        num_grid: number of grid points next to coast
%
% Output: icoast: index [1:num_grid=coast,0=otherwise]
%         icoast [nx ny nz]
% ATN 07-Oct-2013
%------------------------------------------------------------------------

%dirGrid='/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/output/obcsERAdlwsub5pdrag1a/GRID/';
%hf=readbin([dirGrid 'hFacC.data'],[nx ny]);hf=get_aste_tracer(hf,nfx,nfy);

%check size, put in ASTE format if needed:
sz=size(hf);if(length(sz)==2);sz=[sz 1];end;
nx=sz(1);ny=sz(2);nz=sz(3);

iland=find(hf==0);hf(find(hf>0))=1;

msk=1-hf;%msk(find(msk<1))=0;
icoast=nan(size(msk));

%say want first 6 grid points next to coast ~50km in llc270 horizontal res
%num_grid=6;	
for k=1:sz(3);
  mska=msk(:,:,k);
  temp=zeros(size(mska));
  for j=1:num_grid;
    mskb=smooth2a(mska,1);ii=find((mskb-mska)>0);temp(ii)=j;mskb(ii)=1;
    mska=mskb;mska(find(mska>0))=1;
  end;
  msk(:,:,k)=mska;
  icoast(:,:,k)=temp;
end;
msk(iland)=0;
icoast(iland)=0;

return
