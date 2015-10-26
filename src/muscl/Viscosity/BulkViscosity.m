%Use configuration information in Model to calculate bulk viscosity
%@ points given by [yy xx] = meshgrid(y,x) and physical values D/P
function Zeta = BulkViscosity(D,P,x,y,Model)

%Put functional forms here
Zeta = 0;