clear all; close all; clear classes; clc;

%% Set flags.
inspect_only = false;
cluster = 'wsshin';
nodes = 2;

%% Initialize.
a = 420;  % lattice constant
t = 0.6*a;  % slab thickness
r = 0.29*a;  % hole radius
h = sqrt(3)/2*a;  % distance between rows of holes

ad = 25;  % divider for a
td = 10;  % divider for t
dd = 10;  % divider for d = 2*r

slab = Box([-5.5*a, 5.5*a; -3.5*h, 3.5*h; -t/2, t/2], [a/ad, a/ad, t/td]);
slab_yn = Box([-5.5*a, 5.5*a; -3.5*h, -0.5*h; -t/2, t/2], [a/ad, a/ad, t/td]);
slab_yp = Box([-5.5*a, 5.5*a; 0.5*h, 3.5*h; -t/2, t/2], [a/ad, a/ad, t/td]);

hole = CircularCylinder(Axis.z, t, [0 0 0], r, [2*r/dd, 2*r/dd, t/td]);

%% Solve the system.
gray = [0.5 0.5 0.5];  % [r g  b]
solveropts.method = 'aws';
[E, H, obj_array, err] = maxwell_run(...
	'OSC', 1e-9, 1550, ...
	'DOM', {'vacuum', 'white', 1.0}, [-5.5*a, 5.5*a; -3.5*h, 3.5*h; -3*t, 3*t], [a/ad, a/ad, t/td], BC.p, [2*a 0 t], ...
	'OBJ', ...
		{'Palik/Si', gray}, slab, ...
		{'vacuum', 'white', 1.0}, periodize_shape(hole, {[a 0 0], [a/2 h 0], [0 0 t]}, slab_yn), ...
		{'vacuum', 'white', 1.0}, periodize_shape(hole, {[a 0 0], [a/2 h 0], [0 0 t]}, slab_yp), ...
	'SRC', PointSrc(Axis.y, [0, 0, 0]), ...
	solveropts, inspect_only);

%% Visualize the solution.
if ~inspect_only
	figure;
	clear opts
	opts.cscale = 5e-3;
% 	opts.withobjsrc = true;
	opts.withobjsrc = false;
%  	opts.withgrid = true;
% 	opts.withinterp = false;
	opts.isopaque = true;
	visall(E{Axis.y}, obj_array, opts);

%%
	Sx = poynting(Axis.x, E{Axis.y}, E{Axis.z}, H{Axis.y}, H{Axis.z}, Axis.x, 100);
	figure;
	vis2d(Sx, obj_array);

	p = flux_patch(Sx)
end

if false
	%% Terminate.
	maxwell.terminate(cluster)
end
