const MIN_MASS = 0.01;


var SpringConstant = 0 setget Set_Spring_Constant;
var DampingRatio = 0 setget Set_Damping_Ratio;
var ViscousDampingCoefficient = 0 setget _set_noop;
var Mass = MIN_MASS setget Set_Mass;
var Velocity = 0 setget _set_noop;

func _init(Mass, SpringConstant, DampingRatio):
	self.SpringConstant = SpringConstant; 
	self.DampingRatio = DampingRatio;
	self.Mass = Mass;	
	
	_reset_damping_coeff();
	Velocity = 0;

func _set_noop(val):
	pass
	
func _reset_damping_coeff():
	ViscousDampingCoefficient = DampingRatio * 2 * sqrt(Mass * SpringConstant);

func Set_Spring_Constant(val):
	SpringConstant = max(val, 0.0);
	_reset_damping_coeff();
	pass
func Set_Damping_Ratio(val):
	DampingRatio = val;
	_reset_damping_coeff();
	pass
func Set_Mass(val):
	Mass = max(val, MIN_MASS);
	_reset_damping_coeff();
	pass
	
func Reset_Velocity():
	Velocity = 0;
func Set_Velocity(val):
	Velocity = val;

func Get_Force_Applied(Offset):	
	return Get_Force_Applied_With_Velocity(Offset, Velocity);

func Get_Force_Applied_With_Velocity(Offset, Velocity):
	return -SpringConstant * Offset - ViscousDampingCoefficient * Velocity;

func Fixed_Update(delta, Offset):
	var ForceApplied = Get_Force_Applied(Offset);
	Velocity += ForceApplied / Mass * delta;
	pass
	
	