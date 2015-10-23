function [D Vx Vy P] = Con2Prim(D,Mx,My,E,Model)

Gam = Model.Init.Gam;

global TINY;

D = max(D,TINY);

Vx = Mx./D;
Vy = My./D;
K = 0.5*D.*( Vx.^2 + Vy.^2);
e = E - K;
P = max( (Gam-1)*e,TINY );
