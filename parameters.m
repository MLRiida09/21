%% ========================================================
%  FILE 1: GLOBAL PARAMETERS
%  Nonlinear Quarter-Car Active Suspension System
%% ========================================================

global t mb mw k1 k_nl b k2 fa

%% ---- Masses ----------------------------------------
mb  = 300;       % Car body mass (Sprung)    [kg]
mw  = 60;        % Wheel mass (Unsprung)     [kg]

%% ---- Spring ----------------------------------------
k1  = 16000;     % Linear spring stiffness   [N/m]
k_nl = 500;      % Nonlinear cubic coeff     [N/m^3]

%% ---- Damper ----------------------------------------
b   = 1000;       % Damper coefficient        [N.s/m]

%% ---- Tire ------------------------------------------
k2  = 190000;    % Tyre stiffness            [N/m]

%% ---- Actuator --------------------------------------
fa  = 20;        % Active actuator force     [N]

%% ---- Road Disturbance ------------------------------

disp('✔ Parameters loaded successfully');
disp('-----------------------------------');
fprintf('  mb   = %d   kg\n',    mb);
fprintf('  mw   = %d   kg\n',    mw);
fprintf('  k1   = %d   N/m\n',   k1);
fprintf('  k_nl = %d   N/m^3\n', k_nl);
fprintf('  b    = %d   N.s/m\n', b);
fprintf('  k2   = %d   N/m\n',   k2);
fprintf('  fa   = %d   N\n',     fa);
disp('-----------------------------------');
