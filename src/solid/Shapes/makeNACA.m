function [xv yv] = naca(inP, N)
%Returns a polygon-ization of a naca airfoil w/ N points
%Uses data from inP
%inP.x0, inP.y0
%inP.T 
%inP.c

x0 = inP.x0; y0 = inP.y0;
T = inP.T; c = inP.c;

if isfield(inP,'alpha')
    alpha = -1*inP.alpha; %Rotation in degrees
else
    alpha = 0;
end

if isfield(inP,'m')
    m = inP.m;
else
    m = 0;
end

if isfield(inP,'p')
    p = inP.p;
else
    p = c;
end

Lam = linspace(0,c,N);

a0= 0.2969;
a1=-0.1260;
a2=-0.3516;
a3= 0.2843;
a4=-0.1036;

Lscl = Lam/c;
Yt = 5*T*c*( a0*sqrt(Lscl) + a1*Lscl + a2*Lscl.^2 + a3*Lscl.^3 + a4*Lscl.^4);

Ind = (Lscl >= 0) & (Lscl <= p);
Ind1 = ~Ind;

Yc = zeros(size(Yt));

Yc(Ind) = m*(Lam(Ind)/(p*p)).*( 2*p - Lscl(Ind));
Yc(Ind1) = m*(c-Lam(Ind1)).*(1 + Lscl(Ind1) - 2*p)/ ( (1-p)^2 );

atheta = zeros(size(Yt));
atheta(Ind) = 2*m*(p - Lscl(Ind))/(p*p);
atheta(Ind1) = 2*m*(p-Lscl(Ind1))/( (1-p)^2 );

theta = atan(atheta);
xU = Lam-Yt.*sin(theta);
yU = Yc + Yt.*cos(theta);

xL = Lam+Yt.*sin(theta);
yL = Yc - Yt.*cos(theta);

xLr = flip(xL); yLr = flip(yL);
xLr = xLr(2:end-1); yLr = yLr(2:end-1);

xv = [ xU xLr ];
yv = [ yU yLr ];

