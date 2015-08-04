
%Main simulation routine
function [Grid, Gas] = runsim(Model)

close all;

%Model is a structure that contains domain parameters and initial
%conditions
%Model.Bds = [xs,xe,ys,ye]
%Model.Res = [dx,dy] OR
%Model.Nvec = [Nx,Ny] w/ dx = (xe-xs)/Nx

Model = FixMod(Model); %Sets defaults if not already set

%Construct grid
%xs/xe = x-bounds, is/ie = physical indices, isd/ied = physical+ghost
Grid = BuildGrid(Model);

%Initialize grid variables
Gas = InitGas(Model,Grid);

%Initialize solid (legoland method)
if (Model.solid.present)
    Grid = InitSolid(Model,Grid);
end

%Initialize solid (level set method)
if (Model.lvlset.present)
    Grid = InitLvl(Model,Grid);
end

%Enforce BC's on initial setup
[Gas Grid] = EnforceBCs(Model,Grid,Gas);

%Calculate initial timestep
Grid.dt = CalcDT(Model,Grid,Gas);

Tfin = Model.Tfin;

%Enter timeloop
while (Grid.t<Tfin)
    %Evolve from t->t+dt

    Gas = Integrate2D(Model,Grid,Gas);
    
    %Print diagnostics if necessary
    if (mod(Grid.Ts,Grid.tsDiag) == 0)    
        printDiag(Grid,Gas);
        if (Model.Pic.view)
            makeFig(Model,Grid,Gas);
        end
            
    end
    
    %Update time
    Grid.t = Grid.t+Grid.dt;
    Grid.Ts = Grid.Ts+1;
    
    %Enforce BCs
    [Gas Grid] = EnforceBCs(Model,Grid,Gas);
    
    %Calc new timestep
    Grid.dt = CalcDT(Model,Grid,Gas);
end
    
%Finish, calculate final diagnostics and clean up
printDiag(Grid,Gas);


function printDiag(Grid,Gas)
%Print diagnostics at given cadence

fprintf('\tTime = %3.3f : Step = %4d, dt = %3.2e\n',Grid.t,Grid.Ts,Grid.dt);


function Grid = BuildGrid(Model)

Bds = Model.Bds;
Grid.xs = Bds(1); Grid.xe = Bds(2); Grid.ys = Bds(3); Grid.ye = Bds(4);

if isfield(Model,'Res')
    dx = Model.Res(1); dy = Model.Res(2);
    Model.Nvec = [ ceil( (Grid.xe-Grid.xs)/dx ) ceil( (Grid.ye-Grid.ys)/dy ) ];
end
Nx = Model.Nvec(1);
Ny = Model.Nvec(2);
dx = (Grid.xe-Grid.xs)/Nx;
dy = (Grid.ye-Grid.ys)/Ny;

Grid.Nxp = Nx; Grid.Nyp = Ny;
Grid.dx = dx; Grid.dy = dy;
Grid.ng = Model.ng;

%Construct dimensions
%xc = cell-centered
%xi = interface values
% is/ie: physical cells
% isd/ied: all cells


[Grid.xi Grid.xc Grid.is Grid.ie Grid.isd Grid.ied] = conDimNg(Grid.xs,Grid.xe,Grid.Nxp,Grid.ng);
Grid.Nx = length(Grid.xc);

[Grid.yi Grid.yc Grid.js Grid.je Grid.jsd Grid.jed] = conDimNg(Grid.ys,Grid.ye,Grid.Nyp,Grid.ng);
Grid.Ny = length(Grid.yc);

Grid.t = 0;
Grid.Ts = 0;
Grid.C0 = 0.4;

Grid.tsDiag = 10;

function [xi xc is ie isd ied] = conDimNg(xs,xe,Nxp,ng)

Nx = Nxp + 2*ng;

xip = linspace(xs,xe,Nxp+1);
xcp = 0.5*(xip(1:end-1)+xip(2:end));
dx = xcp(2)-xcp(1);

isd = 1;
ied = Nx;
is = ng+1;
ie = ied-ng;

xc = zeros(1,Nx);
xi = zeros(1,Nx+1);

xc(is:ie) = xcp;

for n=1:ng
    xc(ie+n) = xc(ie+n-1) + dx;
    xc(is-n) = xc(is-n+1) - dx;
end
xi(1:end-1) = xc-dx/2;
xi(end) = xc(end)+dx/2;

function Model = FixMod(Model)

if ~isfield(Model,'ng')
    Model.ng = 3;
end

if ~isfield(Model,'solver')
    Model.solver = 'hllc';
end

if ~isfield(Model,'recon')
    Model.recon = 'ppm';
end

if ~isfield(Model.Init,'Gam')
    Model.Init.Gam = 5/3;
end

if ~isfield(Model,'Pic')
    Model.Pic.view = false;
    Model.Pic.dovid = false;
else
    if ~isfield(Model.Pic,'dovid')
        Model.Pic.dovid = false;
    end
end

%Handle video directory default
if (Model.Pic.dovid) & ~isfield(Model.Pic,'vid_dir')
        Model.Pic.vid_dir = 'Vids/scratch';
end

if isfield(Model.Init,'obsDef')
    Model.solid.present = true;    
else
    Model.solid.present = false;
end

if isfield(Model.Init,'lvlDef')
    Model.lvlset.present = true;
    if ~isfield(Model.Init.lvlDef,'mobile')
        Model.lvlset.mobile = false;
    else
        Model.lvlset.mobile = Model.Init.lvlDef.mobile;
    end
    if (Model.lvlset.mobile) %Initial center
        Model.Init.lvlDef.x0 = Model.Init.lvlDef.obsParam(1);
        Model.Init.lvlDef.y0 = Model.Init.lvlDef.obsParam(2);
    end
else
    Model.lvlset.mobile = false;
    Model.lvlset.present = false;
end


if ~isfield(Model,'ib')
    Model.ib.present = false;
else
    Model.ib.present = true;
end

%Set unset BCs
%All periodic if nothing set
if ~isfield(Model,'bcs')
    Model.bcs.ibx = 'periodic';
    Model.bcs.obx = 'periodic';
    Model.bcs.iby = 'periodic';
    Model.bcs.oby = 'periodic';
end

global SMALL_NUM;
global DEBUG;
global Pmin;
global Dmin;
global Nfig;

SMALL_NUM = 1.0e-4;
DEBUG = true;
Pmin = 1.0e-4;
Dmin = 1.0e-4;
Nfig = 0;



    
