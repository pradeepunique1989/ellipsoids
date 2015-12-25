function volArr=volume(ellArr)
%
% VOLUME - returns the volume of the GenEllipsoid.
%
%	volArr = VOLUME(ellArr)  Computes the volume of GenEllipsoids in
%       GenEllipsoidal array ellArr.
%
%	The volume of GenEllipsoid represented as E+L, where L is a subspace 
%   of R^n and E is some (may be degenerate) ellipsoid, is:
%       Inf, if L is not empty 
%       volume(E), is L is empty
%	is given by V = S sqrt(det(Q)) where S is the volume of unit ball.
%
% Input:
%   regular:
%       ellArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array
%           of GenEllipsoids.
%
% Output:
%	volArr: double [nDims1,nDims2,...,nDimsN] - array of
%   	volume values, same size as ellArr.
%
% Example:
%   ellObj=elltool.core.GenEllipsoid([1;1]);
%   ellObj.volume()
%   
%   ans =
%
%       3.1416
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
% 
volArr = arrayfun(@(x) fSingleVolume(x), ellArr);
end
%
function volVal=fSingleVolume(ellObj)
qInfMat=ellObj.getQInfMat();
if any(qInfMat(:)>0)
    volVal=Inf;
else
    if ellObj.isEmpty()
        simpleEllObj=ellipsoid();
    else
        simpleEllObj=ellipsoid(ellObj.centerVec,ellObj.getShapeMat());
    end
    volVal=ellSingleVolume(simpleEllObj);
end
end