%% ========================================================
%  FILE: main_openloop.m
%  Active Suspension Simulation - Nonlinear Quarter-Car
%% ========================================================

clc; clear all;

global mb mw k1 k_nl b k2 fa
global t x1 x1_dot x2 x2_dot Fa_value mode_str

%% ---- Load Parameters & Matrices --------------------
parameters
matrices

%% ---- Simulink Model Setup --------------------------
modelName = 'ActiveSupensionNonlinear';
set_param(modelName, 'StopTime', '10');

%% ---- Actuator Force Configuration ------------------
% Set to 0 for Passive | nonzero for Active
Fa_value = 0;
set_param([modelName '/fa'], 'Value', num2str(Fa_value));

%% ---- Operation Mode --------------------------------
if Fa_value == 0
    mode_str = 'PASSIVE';
else
    mode_str = 'ACTIVE';
end
fprintf('Running %s suspension simulation...\n', mode_str);

%% ---- Run Simulation --------------------------------
sim(modelName);

%% ---- Plot Results ----------------------------------
plotStateResponses();
