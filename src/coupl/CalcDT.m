%Calculates timestep on grid
function dt = CalcDT(Model,Grid,Gas)

global TINY;

%Find min grid size
dxmin = min(Grid.dx,Grid.dy);
dxbar = sqrt(Grid.dx*Grid.dy);

Vabs = sqrt(Gas.Vx.^2 + Gas.Vy.^2);

Cs = Prim2Cs(Gas.D,Gas.Vx,Gas.Vy,Gas.P,Model);

if (Model.Obj.anymobile) %Are any objects moving?
    %If so, consider their velocity in CFL condition
    Vxm = max(abs(Grid.lvlSet.gVx(:)));
    Vym = max(abs(Grid.lvlSet.gVy(:)));
    Vabs = Vabs + max(Vxm,Vym);
end

Vsig = Cs+Vabs; %Signal speeds per cell
dt2d = Grid.C0*dxmin./Vsig; %Fluid CFL
if (Model.doVisc)
    %Incorporate viscosity information into timestep
    Eta = ShearViscosity(Gas.D,Gas.P,Grid.xc,Grid.yc,Model);
    
    %Calculate (cell) Reynolds number
    Re = Vsig*dxbar./Eta; %Double check that units are correct (ie, density)
    Sigma = 0.95;
    %dt_CFL = min(dt2d(:));
    dt2d = Sigma*dt2d./( 1 + 2./Re ); %Modified for viscosity
    %dt_V = min(dt2d(:));
    %fprintf('\tdt_CFL = %e / dt_V = %e\n', dt_CFL, dt_V);
end

dt = min(dt2d(:));

if (dt < TINY)
    disp('Unreasonably small timestep');
    keyboard
end


