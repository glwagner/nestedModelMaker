function fld=read_slice(fnam,nx,ny,kz,prec)

% copy from read_cs_index
% Function fld=read_index(fnam,nx,ny,kz,prec)
% read in horizontal-slice [nx ny] for matrices of size [nx,ny,nz]
%
% INPUTS
% fnam        input path and file name
% kz          vertical indices to read, e.g., 1:nt (default 1)
% prec        numeric precision (see fread; default 'real*4')
% nx,ny       face sizes (no default)
%
% OUTPUTS
% fld    output array of dimension length(ij_indices)*length(kz)
%
% SEE ALSO
% readbin, read_cs_bin, read_cs_face, read_cs_ifjk

if nargin < 5, prec='real*4'; end
if nargin < 4, kz=1; end
if nargin < 3, error('need to specify [nx,ny]'); end
if nargin < 1, error('please specify input file name'); end

fld=zeros(nx*ny,length(kz));
fid=fopen(fnam,'r','ieee-be');

switch prec
 case {'int8','integer*1'}
  preclength=1;
 case {'int16','integer*2','uint16','integer*2'}
  preclength=2;
 case {'int32','integer*4','uint32','single','real*4','float32'}
  preclength=4;
 case {'int64','integer*8','uint64','double','real*8','float64'}
  preclength=8;
end
temp=dir(fnam);nt=temp.bytes/nx/ny/preclength;

for k=1:length(kz)
    skip = (kz(k)-1)*nx*ny;
    if(fseek(fid,skip*preclength,'bof')<0), error('past end of file'); end
    fld(:,k)=fread(fid,nx*ny,prec);
end

fld=reshape(fld,nx,ny,length(kz));
fid=fclose(fid);

return
