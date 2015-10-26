
%Use configuration information in Model to calculate shear viscosity
%@ points given by [yy xx] = meshgrid(y,x) and physical values D/P
function Eta = ShearViscosity(D,P,x,y,Model)

%Put functional forms here
Eta = 1;