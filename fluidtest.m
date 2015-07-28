
%Simple driver for testing while building

%Note, unless specified otherwise defaults are
%gamma - 5/3
%bc's - periodic in all 4 directions

Model.recon = 'ppm';

sim = 'blast';

%Graphical data
Pic.view = true; %Print pic
Pic.val = 'D'; %Which quantity to print
Pic.pg = 'false'; %Print ghosts
%Pic.cax = [0.5 2.5];


switch lower(sim)
    case{'khi'}
        %Kelvin helmholtz instability
        Model.Tfin= 5.0;
        Model.Bds = [-1 1 -1 1];
        Model.Nvec = [1024 1024]/8;
        
        Init.rho0 = 1.0; Init.DelD = 2.0;
        Init.P0 = 2.5;
        Init.Vx0 = 0.5;
        Init.amp = 0.1; %Perturbation amplitude
        
    case{'blast'}
        %Blast wave
        Model.Tfin = 5.0;
        Model.Bds = [-1 1 -0.5 0.5];
        Model.Nvec = [1024 512]/4;
        Pic.cax = [0.1 3];
        Init.rho0 = 1.0;
        Init.rad = 0.1;
        Init.P0 = 0.1;
        Init.DelP = 1000; %Pressure ratio for in versus out

        
    case{'rti'}
        %Rayleigh taylor instability
        Model.Tfin = 10.0;
        Model.Bds = [-0.25 0.25 -0.75 0.75];
        Model.Nvec = [300 900]/4;
        
        Pic.cax = [1 2];
        
        Model.bcs.ibx = 'periodic'; Model.bcs.obx = 'periodic';
        Model.bcs.iby = 'reflect'; Model.bcs.oby = 'reflect';
        Init.Gam = 1.4;
        Model.force.g = 0.1; Model.force.type = 'simpgrav';
        Init.amp = 0.1; %Perturbation amplitude
        
    case{'imp'}
        %Implosion test
        Model.Tfin = 10;
        Model.Bds = [0 1 0 1];
        Model.Nvec = [512 512];
        Pic.cax = [0.125 1.0];
        Init.Gam = 1.4;
        
        Model.bcs.ibx = 'reflect'; Model.bcs.obx = 'reflect';
        Model.bcs.iby = 'reflect'; Model.bcs.oby = 'reflect';

    otherwise
        disp('Unknown simulation')
end



Init.problem = sim;
Model.Init = Init;
Model.Pic = Pic;

%Model.recon = 'ppm';
[Grid Gas] = runsim(Model);
