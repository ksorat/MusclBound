
%Sets model defaults if not already set
%Creates various data structures

%Format for solid objects
%Model.Obj : Post-init data for objects in the flow
%_.present   : Are there any objects?
%_.anymobile : Are any objects able to move?
%_.anypropel : Are any objects propelling themselves?
%_.allpoly   : Are all objects of polygon form?  Note, this will be made
%default
%_.numObj    : Number of objects in the flow
%_.objDef{i} : Data for each object
%_._.xv/yv   : Closed polygon vertices for object i
%_._.vx/vy   : Velocities for each vertex
%_._.Vcm_x/y : Velocities of center of mass of object
%_._.ax/ay   : Accelerations of each vertex
%_._.omega   : Angular velocity of total rigid object
%_._.Fx/Fy   : Force on each vertex
%_._.mobile/propel/convel

%Input format for each object
%Model.Init.lvlDef.obsDat{i}
%_._.xv/yv
%_._.mobile  : Boolean for mobility
%_._.propel  : Boolean for propel
%_._.v0      : Initialize constant velocity

function Model = setupModel(Model)

global TINY DEBUG ARMOR Nfig;

TINY = 1.0e-5;
DEBUG = true;
ARMOR = true;
Nfig = -1;

%Integration parameters
Model = setField(Model,'ng',3);
Model = setField(Model,'solver','hll');
Model = setField(Model,'recon','ppm');

%Initial grid defaults
Model = setField(Model,'Bds',[-10 10 -10 10]);
Model = setField(Model,'Nvec', [128 128]);
Model = setField(Model,'Tfin', 100);

%Initial gas parameters
Model.Init = setField(Model.Init,'Gam',5/3);
Model.Init = setField(Model.Init,'rho0',1);
Model.Init = setField(Model.Init,'P0',1);
Model.Init = setField(Model.Init,'DelP',1);

%Extra fluid physics (Model.Visc)
Model = setField(Model,'doVisc',false);
Model = setField(Model,'Visc',[]);

%Non-zero Knudsen number (Model.doKnud)
Model = setField(Model,'doKnud',false);
Model = setField(Model,'Knud',[]);
Model.Knud = setField(Model.Knud,'alpha_u', 1.142); %Slip coefficients
Model.Knud = setField(Model.Knud,'alpha_T', 0.5865); %Slip coefficients
Model.Knud = setField(Model.Knud,'Pr', 1.0); %Prandtl number
Model.Knud = setField(Model.Knud,'lam_mfp',1.0); %Mean free path

%Boundary conditions
if ~isfield(Model,'bcs')
    Model.bcs = [];
end

Model.bcs = setField(Model.bcs,'ibx','periodic');
Model.bcs = setField(Model.bcs,'obx','periodic');
Model.bcs = setField(Model.bcs,'iby','periodic');
Model.bcs = setField(Model.bcs,'oby','periodic');

%Set inward jet information, ie Min->Vin
if isfield(Model.Init,'Min')
    Cs = sqrt( (Model.Init.Gam) * Model.Init.P0/Model.Init.rho0 );
    Model.Init.vin = Model.Init.Min*Cs;
end

%Visualization data
Model = setField(Model,'tsDiag',10);
if ~isfield(Model,'Pic')
    Model.Pic = [];
end
Model.Pic = setField(Model.Pic,'view',true);
Model.Pic = setField(Model.Pic,'val','d');
Model.Pic = setField(Model.Pic,'pg', false);
Model.Pic = setField(Model.Pic,'dovid',false);
%Default video directory, if necessary
if (Model.Pic.dovid)
    Model.Pic = setField(Model.Pic,'vid_dir','Vids/scratch');
end


%Now handle object information
if isfield(Model.Init,'lvlDef')
    Model.Obj.present = true;
    Model.Obj.numObj = length(Model.Init.lvlDef.obsDat);
else
    Model.Obj.present = false;
end

Model.Obj.anymobile = false;
Model.Obj.anypropel = false;
Model.Obj.allpoly = true;

if Model.Obj.present
    Model = Init2Obj(Model); %Convert initialization data to Model.Obj data for simulation
end


function Struct = setField(Struct,field,val)

if ~isfield(Struct,field) %If field isn't already set then set it
    comS = sprintf(' Struct.%s = val; ', field);
    eval(comS);
end

function Model = Init2Obj(Model)

lvlDef = Model.Init.lvlDef;
for n=1:Model.Obj.numObj
    obsDat = lvlDef.obsDat{n}; %Initialization data
    %Set defaults on input data
    obsDat = setField(obsDat,'mobile',false);
    obsDat = setField(obsDat,'propel',false);
    obsDat = setField(obsDat,'convel',false);
    if obsDat.mobile
        Model.Obj.anymobile = true;
    end
    if obsDat.propel
        Model.Obj.anypropel = true;
    end
    switch lower(obsDat.type)
        case{'circle'}
            disp('Circle option is deprecated, use poly instead');
            pause;
        case{'poly'}
            objDef = polyInit2Obj(obsDat);
        otherwise
            disp('Unknown shape type, go away');
            pause;
    end
    Model.Obj.objDef{n} = objDef;
end

function objDef = polyInit2Obj(obsDat)

objDef.mobile = obsDat.mobile;
objDef.propel = obsDat.propel;
objDef.convel = obsDat.convel;
objDef.type = 'poly';

%Close polygon if necessary
if ((obsDat.xv(1) ~= obsDat.xv(end)) || (obsDat.yv(1) ~= obsDat.yv(end))) 
    obsDat.xv = [obsDat.xv ; obsDat.xv(1)];
    obsDat.yv = [obsDat.yv ; obsDat.yv(1)];
end

objDef.xv = obsDat.xv;
objDef.yv = obsDat.yv; 
Nv = length(objDef.xv);

%Create/finalize velocity data
zv = zeros(1,Nv);
objDef.vx = zv;
objDef.vy = zv;
objDef.ax = zv;
objDef.ay = zv;
objDef.Fx = zv;
objDef.Fy = zv;

objDef.Vcm_x = 0;
objDef.Vcm_y = 0;
objDef.omega = 0;

obsDat = setField(obsDat,'M',1);
objDef.M = obsDat.M;

if isfield(obsDat,'v0') %Nonzero initial velocity
    v0x = obsDat.v0(1); v0y = obsDat.v0(2);
    objDef.vx(:) = v0x;
    objDef.vy(:) = v0y;
    objDef.Vcm_x = v0x;
    objDef.Vcm_y = v0y;
end

if (objDef.propel)
    objDef.isOutlet = obsDat.isOutlet;
end

