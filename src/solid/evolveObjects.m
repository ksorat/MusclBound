
%Some objects are mobile, so move them
function Model = evolveObjects(Model,Grid,Gas)

%Useful grabs
Obj = Model.Obj;
numObj = Model.Obj.numObj;
dt = Grid.dt;

for n=1:numObj
    objDef = Obj.objDef{n};
    
    %Is this non-mobile, convel, or fully mobile?
    if (~objDef.mobile)
        continue;
    end
    if (objDef.convel)
        objDef.xv = objDef.xv + dt*objDef.vx;
        objDef.yv = objDef.yv + dt*objDef.vy;
        continue;
    end
        
    if (objDef.mobile && ~objDef.convel)
       objDef = moveRigidObject(objDef,dt); 
    end
    Obj.objDef{n} = objDef;
end

Model.Obj = Obj;


