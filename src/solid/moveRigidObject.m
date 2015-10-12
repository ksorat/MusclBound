function objDef = moveRigidObject(objDef,dt)

M = objDef.M;
Nv = length(objDef.xv);

%Go to reduced quantities, ie non-closed loop

xvr = objDef.xv(1:Nv-1); yvr = objDef.yv(1:Nv-1);
vxr = objDef.vx(1:Nv-1); vyr = objDef.vy(1:Nv-1);
Fxr = objDef.Fx(1:Nv-1);
Fyr = objDef.Fy(1:Nv-1);

%Calculate center of mass, and force on CM

xcm = sum(xvr)/(Nv-1);
ycm = sum(yvr)/(Nv-1);

I = calcMomInertia(xvr,yvr,M);
Fx_cm = sum(Fxr); Fy_cm = sum(Fyr);


%Calculate torque
Tz = 0;
for v=1:Nv-1
    xp = xvr(v)-xcm;
    yp = yvr(v)-ycm;
    T = cross( [xp yp 0], [Fxr(v) Fyr(v) 0] );
    Tz = Tz + T(3);
end %Now have total torque


%Calculate linear/angular accelerations
ax_cm = -Fx_cm/M; ay_cm = -Fy_cm/M;
alpha = -Tz/I;

%Update velocities from forces/torque
objDef.Vcm_x = objDef.Vcm_x + dt*ax_cm;
objDef.Vcm_y = objDef.Vcm_y + dt*ay_cm;

objDef.omega = objDef.omega + dt*alpha;

%Update positions from velocities (linear/angular)
%Note, this is done explicitly with a rotation/translation

for v=1:Nv-1
    %Translate to CM frame
    xp = xvr(v) - xcm;
    yp = yvr(v) - ycm;
    
    %Rotate in CM frame
    theta = dt*objDef.omega;
    xr = cos(theta)*xp - sin(theta)*yp;
    yr = sin(theta)*xp + cos(theta)*yp;
    
    %Calculate rotational velocity, V = r x omega
    Vrot = -1*cross( [xp yp 0], [0 0 objDef.omega] );
    
    %Update vertex velocity for rotation
    vxr(v) = objDef.Vcm_x + Vrot(1);
    vyr(v) = objDef.Vcm_y + Vrot(2);
    
    %Update vertex position
    xvr(v) = xcm + dt*objDef.Vcm_x + xr;
    yvr(v) = ycm + dt*objDef.Vcm_y + yr;
end

%Dump back into holder and close loops
objDef.vx(1:Nv-1) = vxr; objDef.vx(end) = objDef.vx(1);
objDef.vy(1:Nv-1) = vyr; objDef.vy(end) = objDef.vy(1);

objDef.xv(1:Nv-1) = xvr; objDef.xv(end) = objDef.xv(1);
objDef.yv(1:Nv-1) = yvr; objDef.yv(end) = objDef.yv(1);


function I = calcMomInertia(xvr,yvr,M)

x0 = min(xvr); x1 = max(xvr);
y0 = min(yvr); y1 = max(yvr);
xg = linspace(x0,x1); yg = linspace(y0,y1);
[yy xx] = meshgrid(yg,xg);

In = inpolygon(xx,yy,xvr,yvr);
Nv = length(xvr);
xcm = sum(xvr)/Nv;
ycm = sum(yvr)/Nv;

dm = M/sum(In(:));
rad = sqrt( (xx-xcm).^2 + (yy-ycm).^2 );

dI = dm*rad.*rad.* (1*In);
I = sum(dI(:));