
%Simple driver for some obstruction tests
clear; close all;
Model.recon = 'ppm';
Model.solver = 'hllc';

config = 'blastobs';
%config = 'pflowcyl';

Model.Tfin = 5.0;
Model.Bds = [-1 1 -0.5 0.5];
Model.Nvec = [1024 512]/4;

Init.rho0 = 1.0;
Init.rad = 0.1;
Init.P0 = 0.1;
Init.DelP = 1000.0; %Pressure ratio for in versus out


%Graphical data
Pic.view = true; %Print pic
Pic.val = 'P'; %Which quantity to print
Pic.pg = 'false'; %Print ghosts
%Pic.cax = [0.05 3];
switch lower(config)
    case{'pflowcyl'}
        sim = 'flow';
        Pic.val = 'spd';
        Model.Tfin = 50.0;
        Model.Bds = [-1 1 -0.5 0.5];
        Model.Nvec = [1024 512]/8;
        rad = 0.1;
        
        obsDef.numObs = 1;
        obsDef.obsType = {'circle'};
        obsDef.View = true;
        obsDef.obsParam = zeros(obsDef.numObs,4);
        obsDef.obsParam(1,:) = [-0.25 0 rad 0];
        Init.obsDef = obsDef;
        
        Model.bcs.ibx = 'pinflow'; Model.bcs.obx = 'poutflow';
        Model.bcs.iby = 'wall'; Model.bcs.oby = 'wall';
        
    case{'blastobs'}
        %Blast wave w/ obstructio
        sim = 'blast'; %To call initialization
     
        a = 0.2; rad = Init.rad;
        Init.cent = [-a 0];
        
        %Define obstruction
        obsDef.numObs = 3;
        obsDef.obsType = {'circle','circle','circle'};
        obsDef.View = true;
        obsDef.obsParam = zeros(obsDef.numObs,4);
        obsDef.obsParam(1,:) = [a 0 rad 0];
        obsDef.obsParam(2,:) = [0 a rad 0];
        obsDef.obsParam(3,:) = [0 -a rad 0];
        
        Init.obsDef = obsDef;
        
        Pic.cax = [0 1];
    otherwise
        disp('Unknown simulation');
end

Init.problem = sim;
Model.Init = Init;
Model.Pic = Pic;

[Grid Gas] = runsim(Model);
