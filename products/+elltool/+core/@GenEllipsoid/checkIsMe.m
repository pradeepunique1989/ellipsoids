function checkIsMe(ellArr,varargin)
%
% CHECKISME - determine whether input object is generalized ellipsoid. And display
%             message and abort function if input object
%             is not generalized ellipsoid
%
% Input:
%   regular:
%       someObjArr: any[] - any type array of objects.
%
% Example:
%   ellObj = elltool.core.GenEllipsoid([1; 2], eye(2));
%   elltool.core.GenEllipsoid.checkIsMe(ellObj)
% 
% 
% % $Author: Rustam Galiev <glvrst@gmail.com> $	$Date: 2012-12-27 $ 
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2012 $
nArgIn = nargin;
if nArgIn == 1
    modgen.common.checkvar(ellArr,@(x)isa(x,'ellipsoid')|| isa(x,'elltool.core.GenEllipsoid'),...
        'errorTag','wrongInput',...
        'errorMessage','input argument must be ellipsoid.');
elseif nArgIn==2
    modgen.common.checkvar(ellArr,@(x) isa(x,'ellipsoid')||isa(x,'elltool.core.GenEllipsoid'),...
        'errorTag','wrongInput','errorMessage',...
        [varargin{1}, ' input argument must be ellipsoid.']);
else
    modgen.common.checkvar(ellArr,@(x) isa(x,'ellipsoid')||isa(x,'elltool.core.GenEllipsoid'),varargin{:});
end