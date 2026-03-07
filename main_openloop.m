clc; clear all;
%==========================================================================
%                    ACTIVE SUSPENSION SIMULATION
%                    Nonlinear Quarter-Car Model
%==========================================================================

%--------------------------------------------------------------------------
%                        GLOBAL VARIABLES
%--------------------------------------------------------------------------
global mb mw k1 k_nl b k2 fa
global t x1 x1_dot x2 x2_dot Fa_value mode_str

%--------------------------------------------------------------------------
%                     SYSTEM INITIALIZATION
%--------------------------------------------------------------------------
% Load physical parameters (masses, stiffness, damping)
parameters

% Build system matrices (state-space representation)
matrices

%--------------------------------------------------------------------------
%                      SIMULINK MODEL SETUP
%--------------------------------------------------------------------------
% Define Simulink model name
modelName = 'ActiveSupensionNonlinear';

% Set simulation duration to 5 seconds
set_param(modelName, 'StopTime', '5');

%--------------------------------------------------------------------------
%                      ACTUATOR FORCE CONFIGURATION
%--------------------------------------------------------------------------
% Set actuator force value (0 = Passive | nonzero = Active)
Fa_value = 20;

% Update actuator force block inside Simulink model
set_param([modelName '/fa'], 'Value', num2str(Fa_value));

%--------------------------------------------------------------------------
%                        OPERATION MODE SELECTION
%--------------------------------------------------------------------------
if Fa_value == 0
    mode_str = 'PASSIVE';   % No control force applied
else
    mode_str = 'ACTIVE';    % Control force active
end

% Display selected mode in command window
fprintf('Running %s suspension simulation...\n', mode_str);

%--------------------------------------------------------------------------
%                         RUN SIMULATION
%--------------------------------------------------------------------------
sim(modelName);

%--------------------------------------------------------------------------
%                        PLOT RESULTS
%--------------------------------------------------------------------------
plotSuspensionResults();
