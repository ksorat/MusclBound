%Update gas variables to include viscous effects
%Viscous flux formulation

function Gas = ApplyViscosity(Model,Grid,Gas)

%Steps:
%Calculate viscous flux @ interfaces
%Consevative update of Con-vars w/ viscous flux

%Fx/Fy include fluxes for all conserved variables
[Fx Fy] = ViscousFlux(Model,Grid,Gas);

%Do conservative update
%Note this flux update should be made modular/unified with one in
%Integrate2D

Gas = doFluxUpdate(Model,Grid,Gas,Fx,Fy);


function Gas = doFluxUpdate(Model,Grid,Gas,Fx,Fy)
%Go to conservative variables

[Di Mxi Myi Ei] = Prim2Con(Gas.D,Gas.Vx,Gas.Vy,Gas.P,Model);

if (Model.Obj.present)
    %Zero out fluxes at fluid/ghost interfaces
    %Ie, there's hydro flux but not viscous flux there
    [Fx Fy] = ZeroGhostFlux(Grid,Fx,Fy);
end
%Note, |Fx| = [Nv,Nx+1,Ny]
%|Fy| = [Nv,Nx,Ny+1]

Mxo = Evolve(Grid,Mxi,Fx,Fy,2);
Myo = Evolve(Grid,Myi,Fx,Fy,3);
Eo  = Evolve(Grid,Ei ,Fx,Fy,4);

%Convert back to primitive and return, U_o -> W_o
[Do Vxo Vyo Po] = Con2Prim(Di,Mxo,Myo,Eo,Model);

Gas.D = Do;
Gas.Vx = Vxo;
Gas.Vy = Vyo;
Gas.P = Po;

%Zero out flux at interfaces connecting fluid/ghost
function [Fx Fy] = ZeroGhostFlux(Grid,Fx,Fy)
Nx = Grid.Nx;
Ny = Grid.Ny;

lvl = Grid.lvlSet;
Ng = length(lvl.ghost1d);

for n=1:Ng
    i = lvl.gi(n);
    j = lvl.gj(n);
    %Cell i,j is a ghost cell, zero out four interfaces
    Fx(i,j) = 0.0;
    Fx(i+1,j) = 0.0;
    Fy(i,j) = 0.0;
    Fy(i,j+1) = 0.0;
end

function Uo = Evolve(Grid,Ui,Fx,Fy,Nvar)
Nx = Grid.Nx;
Ny = Grid.Ny;
dt = Grid.dt;
%Advance in time, U_i -> U_o
dtox = dt/Grid.dx;
dtoy = dt/Grid.dy;

%Grab variable we care about
Fxv = squeeze(Fx(Nvar,:,:));
Fyv = squeeze(Fy(Nvar,:,:));

Uo = Ui(:,:) + dtox*( Fxv(1:Nx,:) - Fxv(2:Nx+1,:) ) + ...
    + dtoy*( Fyv(:,1:Ny) - Fyv(:,2:Ny+1) );

    

         
         