alpha = 10;
k1 = 50;
k2 = 500;
m1 = 150;
m2 = 100;
L = 5;
g = 9.8;
Jc = 100;

x1 = 1;
v1 = 0;
theta1 = pi/2;
omega1 = 0;
t1 = 1;

d = Jc + m2*L^2/4;
% define matrices aMat, bMat, and control bounds uBoundsEllObj:
aMat = [0, 1, 0, 0; 0, -k1/m1, 0, 0; 0, 0, 0, 1; 0, 0, m2*L*g/2/d, -k2*L/d];
bMat = [0; 1/m1; 0; 0];
uBoundsEllObj = alpha * ell_unitball(1);
%define disturbance:
gMat = [0; 0; 0; -m2*L*g*pi/4/d];
vEllObj = ellipsoid(1, 0); %known disturbance

%linear system
lsys = elltool.linsys.LinSysContinuous(aMat, bMat, uBoundsEllObj,...
    gMat, vEllObj);
timeVec = [t1, 0];
% initial directions:
dirsMat = [1 0 1 0; 1 -1 0 0; 0 -1 0 1; 1 1 -1 1; -1 1 1 0; -2 0 1 1].';
x1EllObj = ellipsoid([x1; v1; theta1; omega1], zeros(4)); %known final point

%backward reach set
brsObj = elltool.reach.ReachContinuous(lsys, x1EllObj, dirsMat, timeVec,...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-4,...
    'absTol', 1e-5, 'relTol', 1e-4);

basisMat = [1 0 0 0; 0 0 1 0].'; % orthogonal basis of (x1, x3) subspace
psObj = brsObj.projection(basisMat); % reach set projection

% plot projection of reach set internal approximation:
psObj.plotByIa('b');

%plot backward reach set approximation at time t=0
psCutObj = psObj.cut(0);
psCutObj.plotByIa('r');