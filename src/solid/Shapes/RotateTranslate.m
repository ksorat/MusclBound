
function Obj = RotateTranslate(Obj,InP)
%InP contains
%alpha, rotation angle in degrees
%delx,dely translation amount
Nv = length(Obj.xv);
xcm = sum(Obj.xv)/Nv;
ycm = sum(Obj.yv)/Nv;

xp = Obj.xv-xcm;
yp = Obj.yv-ycm;

alpha = InP.alpha;
xpr = cosd(alpha)*xp - sind(alpha)*yp;
ypr = sind(alpha)*xp + cosd(alpha)*yp;

Obj.xv = xpr+xcm+InP.delx;
Obj.yv = ypr+ycm+InP.dely;