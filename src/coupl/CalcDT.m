%Calculates timestep on grid
function dt = CalcDT(Model,Grid,Gas)

global TINY;

%Find min grid size
dxmin = min(Grid.dx,Grid.dy);

Vabs = sqrt(Gas.Vx.^2 + Gas.Vy.^2);

Cs = Prim2Cs(Gas.D,Gas.Vx,Gas.Vy,Gas.P,Model);

if (Model.Obj.anymobile) %Are any objects moving?
    %If so, consider their velocity in CFL condition
    Vxm = max(abs(Grid.lvlSet.gVx(:)));
    Vym = max(abs(Grid.lvlSet.gVy(:)));
    Vabs = Vabs + max(Vxm,Vym);
end

dt2d = dxmin./(Cs + Vabs);

dt = Grid.C0*min(dt2d(:));

if (dt < TINY)
    disp('Unreasonably small timestep');
    keyboard
end


