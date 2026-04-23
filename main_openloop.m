%% ========================================================
%  FILE: main_openloop.m
%  Active Suspension - Nonlinear Quarter-Car Open-Loop
%% ========================================================
clc; clear all; close all;

global mb mw k1 k_nl b k2 fa
global t x1 x1_dot x2 x2_dot Fa_value mode_str

%% ---- 1. Parameters -------------------------------------
parameters

%% ---- 2. State-Space Matrices ---------------------------
[A, B, w] = matrices();

%% ---- 3. T-S Activation Functions -----------------------
delta_max = 0.1;
[h1, h2, delta, A1, A2] = ts_activation_functions(delta_max);

%% ---- 4. Simulink Setup ---------------------------------
modelName = 'ActiveSupensionNonlinear';
load_system(modelName);
set_param(modelName, 'StopTime', '10');

%% ---- 5. Actuator (0 = Passive) -------------------------
Fa_value = 0;
set_param([modelName '/fa'], 'Value', num2str(Fa_value));

if Fa_value == 0, mode_str = 'PASSIVE';
else,             mode_str = 'ACTIVE';
end
fprintf('\nRunning %s suspension simulation...\n', mode_str);

%% ---- 6. Run Simulation ---------------------------------
sim(modelName);

%% ---- 7. Plot State Responses ---------------------------
plotStateResponses();