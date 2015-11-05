%Calculates viscous flux @ each interface

function [Fx Fy] = ViscousFlux(Model,Grid,Gas)

Nx = Grid.Nx;
Ny = Grid.Ny;
Nxi = Nx+1;
Nyi = Ny+1;

xc = Grid.xc; xi = Grid.xi;
yc = Grid.yc; yi = Grid.yi;

%Need to calculate certain values at certaion points
%Need
%Pi_xx @x-interfaces
%Pi_yy @y-interfaces
%Pi_xy @x & y-interfaces
%Vx/Vy @x & y-interfaces

%Where, Pi = \eta [ \grad(v) + \grad(v)^{T} - (2/3)*div(v)*I ]
%             + \zeta*div(v)*I

%Start by creating directed states
%Has to be done again/can't reuse from Integrate2D

%Use PLM so as not to introduce unnecessary wiggles
%In addition to directed states get monotonized slopes in x/y
[nW eW sW wW DxW DyW] = ReconStates(Grid,Gas,'plm'); 

%Construct interface states for primitive variables by averaging directed
%D_xi/yi
%P_xi/yi
%Vx_xi/yi
%Vy_Xi/yi

[W_xi W_yi] = Dirstates2Interface(Grid,nW,eW,sW,wW); %Never eat shredded wheat

[D_xi Vx_xi Vy_xi P_xi] = PeelOut(W_xi);
[D_yi Vx_yi Vy_yi P_yi] = PeelOut(W_yi);


%Use these interface-located prim variables to calculate
%Eta_xi = Shear viscosity @ x-interfaces
%Eta_yi = Shear viscosity @ y-interfaces

%Zeta_xi = Bulk viscosity @ x-interfaces
%Zeta_yi = Bulk viscosity @ y-interfaces

Eta_xi = ShearViscosity(D_xi,P_xi,xi,yc,Model);
Eta_yi = ShearViscosity(D_yi,P_yi,xc,yi,Model);
Zeta_xi = BulkViscosity(D_xi,P_xi,xi,yc,Model);
Zeta_yi = BulkViscosity(D_yi,P_yi,xc,yi,Model);

%Now calculate velocity derivatives using monotonized differences
%DxVx_xi, DxVx_yi
%DyVy_xi, DyVy_yi
%DxVy_xi, DxVy_yi
%DyVx_xi, DyVx_yi

[DxVx DxVy DyVx DyVy] = PeelJacobian(DxW,DyW);

[DxVx_xi DxVx_yi] = Centered2Interface(Grid,DxVx);
[DxVy_xi DxVy_yi] = Centered2Interface(Grid,DxVy);
[DyVx_xi DyVx_yi] = Centered2Interface(Grid,DyVx);
[DyVy_xi DyVy_yi] = Centered2Interface(Grid,DyVy);

%Now get divergence at interfaces
%Div_xi, Div_yi

Div_xi = DxVx_xi + DyVy_xi;
Div_yi = DxVx_yi + DyVy_yi;


%Now (finally, amirite?) construct Pi tensor
%For diagonal terms no ambiguity about centering
Pi_xx = Eta_xi.*( (4/3)*DxVx_xi - (2/3)*DyVy_xi ) + Zeta_xi.*Div_xi;
Pi_yy = Eta_yi.*( (4/3)*DyVy_yi - (2/3)*DxVx_yi ) + Zeta_yi.*Div_yi;

%Calculate cross term for x/y interfaces
Pi_xy_xi = Eta_xi.*( DxVy_xi + DyVx_xi );
Pi_xy_yi = Eta_yi.*( DxVy_yi + DyVx_yi );


%Assuming 2D, need extra component for 3D
Fx = zeros(4,Nxi,Ny);
Fy = zeros(4,Nx,Nyi);

%Calculate flux (flip sign at end)
%No flux in density
%Mx
Fx(2,:,:) = Pi_xx;
Fy(2,:,:) = Pi_xy_yi;

%My
Fx(3,:,:) = Pi_xy_xi;
Fy(3,:,:) = Pi_yy;

%E
Fx(4,:,:) = Vx_xi.*Pi_xx + Vy_xi.*Pi_xy_xi;
Fy(4,:,:) = Vx_yi.*Pi_xy_yi + Vy_yi.*Pi_yy;

%Flip sign because math
Fx = -Fx;
Fy = -Fy;

%Converts directed states to interface values in x/y
function [W_xi W_yi] = Dirstates2Interface(Grid,nW,eW,sW,wW)
Nx = Grid.Nx; Ny = Grid.Ny;
Nxi = Nx+1; Nyi = Ny+1;
Nv = 4;
%|W_xi| = Nv x Nxi x Ny
%|W_yi| = Nv x Nx  x Nyi

W_xi = zeros(Nv,Nxi,Ny);
W_xi(:,1,:)    = wW(:,1,:);
W_xi(:,Nxi,:)  = eW(:,Nx,:);
W_xi(:,2:Nx,:) = 0.5*( eW(:,1:Nx-1,:) + wW(:,2:Nx,:) );

W_yi = zeros(Nv,Nx,Nyi);
W_yi(:,:,1)    = sW(:,:,1);
W_yi(:,:,Nyi)  = nW(:,:,Ny);
W_yi(:,:,2:Ny) = 0.5*( nW(:,:,1:Ny-1) + sW(:,:,2:Ny) );

%Converts cell-centered values to interface values
%Note, right now we're averaged slope-limited derivatives to get interface
%values.  Could instead calculate Hessian, but likely not necessary.
%Maybe something to play with later?



function [W_xi W_yi] = Centered2Interface(Grid,W)
Nx = Grid.Nx; Ny = Grid.Ny;
Nxi = Nx+1; Nyi = Ny+1;

W_xi = zeros(Nxi,Ny);
W_yi = zeros(Nx,Nyi);

W_xi(1,:) = W(1,:);
W_xi(Nxi,:) = W(Nx,:);
W_xi(2:Nx,:) = 0.5*( W(1:Nx-1,:) + W(2:Nx,:) );

W_yi(:,1) = W(:,1);
W_yi(:,Nyi) = W(:,Ny);
W_yi(:,2:Ny) = 0.5*( W(:,1:Ny-1) + W(:,2:Ny) );
    
function [DxVx DxVy DyVx DyVy] = PeelJacobian(DxW,DyW)
DxVx = squeeze( DxW(2,:,:) );
DxVy = squeeze( DxW(3,:,:) );
DyVx = squeeze( DyW(2,:,:) );
DyVy = squeeze( DyW(3,:,:) );

function [D Vx Vy P] = PeelOut(W)
D  = squeeze(W(1,:,:));
Vx = squeeze(W(2,:,:));
Vy = squeeze(W(3,:,:));
P  = squeeze(W(4,:,:));

