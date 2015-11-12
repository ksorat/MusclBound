%Various tests of diffusive term in Navier Stokes

clear; close all;
config = 'vortexsheet';
config = 'pflow';
Model.doVisc = true; %Why else are you here?
Init = [];
switch lower(config)
    case{'vortexsheet'}
        Init.Nu = 0.005;
        Init.T0 = 1;
        Init.problem = 'vortexsheet';
        Model.Bds = [-2 2 -2 2];
        Model.Nvec = [1024 1024]/4;
        
        Model.bcs.ibx = 'periodic'; Model.bcs.obx = 'periodic';
        Model.bcs.iby = 'reflect'; Model.bcs.oby = 'reflect';
        Model.Pic.val = 'Vx';
        Model.Pic.cax = [-1 1];
        Model.Tfin = 20;
    case{'couette'}
        Init.U = 1;
        Init.Nu = 5;
        Init.problem = 'flow';
        Model.Bds = [-2 2 -2 2];
        
        Model.Nvec = [1024 1024]/8;
        Model.bcs.ibx = 'periodic'; Model.bcs.obx = 'periodic';
        Model.bcs.iby = 'couette'; Model.bcs.oby = 'couette';
        Model.Pic.val = 'Vx';
        %Model.Pic.cax = [-1 1];
        Model.Tfin = 1;
    case{'pflow'} %Poiseille flow
        Init.Nu = 0.05;
        DelP = 0.05;
        Init.problem = 'flow';
        Model.Bds = [-2 2 -1 1];
        Model.Nvec = [1024 1024]/8;
        
        %Model.bcs.ibx = 'dirichlet'; Model.bcs.obx = 'dirichlet';
        Model.bcs.ibx = 'dirichlet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'noslip'; Model.bcs.oby = 'noslip';
        Model.Pic.val = 'vx';
        Model.Tfin = 10;
        
        %Init.ibx.dbc = [1 0 0 (1+DelP/2)]; %Inlet boundaries
        Init.ibx.dbc = [1 0.25 0 1]; %Inlet boundaries
        Init.obx.dbc = [1 0 0 (1-DelP/2)]; %Outlet
        
end


Model.Init = Init; 
[Grid Gas] = runsim(Model);

switch lower(config)
    case{'vortexsheet'}
        y = Grid.yc;
        Vxsim = Gas.Vx( round(Grid.Nx/2), : );
        DelT = Init.T0+Grid.t;
        scl = 2*sqrt( Init.Nu * DelT );
        scl0 = 2*sqrt( Init.Nu * Init.T0 );
        Vxan = erf( y/scl );
        Vxan0 = erf( y/scl0 );  
        hold off; close all;
        plot(y,Vxsim,'ro',y,Vxan,'r',y,Vxan0,'b');
        legend('Simulated','Analytic','Initial Condition');
        xlabel('Height'); ylabel('Vx(y)');
        title('Diffusion of Vortex Sheet');
        
        
end
