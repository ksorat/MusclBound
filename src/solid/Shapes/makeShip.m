function [xv yv propel] = makeShip(InP, N)
%Assumes InP has parameters for object
%r1 : Half-width of box
%r2 : Sharpness of cone
%L  : Length of box
%Wt : Half-width of tail
%Ht : Height of tail
%pCx/y, pRad : Circle of points producing propulsion

%Creates a simple polygon of a ship
%For now the quantities are fixed

theta = linspace(pi,0,N);
if isempty(InP)
    
    r1 = 1; %Half-Width of box
    r2 = 4; %Sharpness of cone
    
    L = 3; %Length of box
    Wt = 2; %Half-width of tail
    Ht = 3;
    
    %Define circle of points producing propulsion
    pCx = 0;
    pCy = -L-Ht;
    pRad = 0.5;
    
else
    r1 = InP.r1;
    r2 = InP.r2;
    L = InP.L;
    Wt = InP.Wt;
    Ht = InP.Ht;
    pCx = InP.pCx;
    pCy = InP.pCy;
    pRad = InP.pRad;
    
end

%Upper tip
xtip = r1*cos(theta);
ytip = r2*sin(theta);

tau = linspace(0,-L,N);

yR = tau(2:end);
xR = r1*ones(size(yR));

x = [xtip xR];
y = [ytip yR];

xR1 = linspace(r1,Wt,N);
yR1 = linspace(-L,-L-Ht,N);

x = [x xR1(2:end)];
y = [y yR1(2:end)];

xB = linspace(Wt,-Wt,N+1);
yB = (-L-Ht)*ones(size(xB));

x = [x xB(2:end)];
y = [y yB(2:end)];

xL1 = linspace(-Wt,-r1,N);
yL1 = linspace(-L-Ht,-L,N);

x = [x xL1(2:end)];
y = [y yL1(2:end)];

yL = linspace(-L,0,N);
xL = -r1*ones(size(yL));

x = [x xL(2:end)];
y = [y yL(2:end)];

xv = x'; yv = y';


r = sqrt( (xv-pCx).^2 + (yv-pCy).^2 );
propel = (r <= pRad);

% plot(xv,yv,'bx'); axis equal; hold on;
% plot(xv(propel),yv(propel),'ro'); hold off
