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

Grid.dt = 0;
Grid.t = 0;
Grid.Ts = 0;
Grid.C0 = 0.45;


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