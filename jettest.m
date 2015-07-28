%Simple driver for some jet tests

clear; close all;
Model.recon = 'ppm';
Model.solver = 'hll';

config = 'flow';




Init.rho0 = 1.0;
Init.P0 = 1;
Init.DelP = 100.0; %Pressure ratio for in versus out

Init.Min = 10; %Inward mach number of jet

Init.cent = 0.0;
Init.rad = 0.3;
Init.disc = 'true'; %Discrete or smooth jet?
%Graphical data
Pic.view = true; %Print pic
Pic.val = 'P'; %Which quantity to print
Pic.pg = 'true'; %Print ghosts

sim = 'flow';
Pic.val = 'd';
Pic.cax = [0.5 10];
Model.Tfin = 50.0;
Model.Bds = [-5 5 -5 5];

Model.Nvec = [1024 1024]/8;
obsDef.numObs = 1;
obsDef.obsType = {'circle'};
obsDef.View = true;
obsDef.obsParam = zeros(obsDef.numObs,4);
obsDef.obsParam(1,:) = [-0.25 0 0.5 0];

% obsDef.obsType = {'trix'};
% obsDef.View = true;
% obsDef.obsParam = zeros(obsDef.numObs,4);
% obsDef.obsParam(1,:) = [0 0 0.5 0.5];

Init.obsDef = obsDef;


Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
%Model.bcs.iby = 'periodic'; Model.bcs.oby = 'periodic';
Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
Cs = sqrt( (5/3) * Init.P0 / Init.rho0);
Init.vin = Init.Min*Cs;

Init.problem = sim;
Model.Init = Init
Model.Pic = Pic;
[Grid Gas] = runsim(Model);
