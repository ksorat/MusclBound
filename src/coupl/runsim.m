
%Main simulation routine
function [Grid, Gas] = runsim(Model)

close all;

%Model is a structure that contains domain parameters and initial
%conditions
%Model.Bds = [xs,xe,ys,ye]
%Model.Res = [dx,dy] OR
%Model.Nvec = [Nx,Ny] w/ dx = (xe-xs)/Nx

Model = setupModel(Model); %Sets defaults if not already set

%Construct grid
%xs/xe = x-bounds, is/ie = physical indices, isd/ied = physical+ghost
Grid = BuildGrid(Model);

%Initialize grid variables for gas
Gas = InitGas(Model,Grid);

%Initialize solid (level set method)
if (Model.Obj.present)
    Grid = CalcLvl(Model,Grid);
end

%Enforce BC's on initial setup
[Gas Grid Model] = EnforceBCs(Model,Grid,Gas);

%Calculate initial timestep
Grid.dt = CalcDT(Model,Grid,Gas);

Tfin = Model.Tfin;

%Enter timeloop
while (Grid.t<Tfin)
    
    %Evolve from t->t+dt
    
    %Evolve gas
    [Gas Model] = Integrate2D(Model,Grid,Gas);
    
    %Evolve solid if necessary
    %-----
    if (Model.Obj.anymobile)
        Model = evolveObjects(Model,Grid,Gas);
        Grid = CalcLvl(Model,Grid);
    end
    
    %Print diagnostics if necessary
    if (mod(Grid.Ts,Model.tsDiag) == 0)    
        printDiag(Grid,Gas);
        if (Model.Pic.view)
            makeFig(Model,Grid,Gas);
        end
            
    end
    
    %Enforce BCs
    [Gas Grid Model] = EnforceBCs(Model,Grid,Gas);
    
    %Update time
    Grid.t = Grid.t+Grid.dt;
    Grid.Ts = Grid.Ts+1;
    
    
    %Calc new timestep
    Grid.dt = CalcDT(Model,Grid,Gas);
end
    
%Finish, calculate final diagnostics and clean up
printDiag(Grid,Gas);


function printDiag(Grid,Gas)
%Print diagnostics at given cadence

fprintf('\tTime = %3.3f : Step = %4d, dt = %3.2e\n',Grid.t,Grid.Ts,Grid.dt);

