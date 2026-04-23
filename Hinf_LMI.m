%% ========================================================
%  FILE: H_inf_LMI.m
%  H-infinity LMI-based T-S Fuzzy Controller Synthesis
%  Quarter-Car Active Suspension System
%% ========================================================

%% =========================
% 1. PARAMETERS 
%% =========================
global mb mw k1 k_nl k k2 fa 

parameters();   % Call your file

%% =========================
% 2. T-S SUBSYSTEM MATRICES
%    pmin/pmax define the scheduling range of k_eff = k1 + k_nl*delta^2
%% =========================
pmin = k1;                          % minimum effective stiffness [N/m]
pmax = k1 + k_nl * (0.1)^2;          % maximum (delta_max = 0.1 m)

A1 = [ 0           1          0               0;
      -pmin/mb    -b/mb       pmin/mb         b/mb;
       0           0          0               1;
       pmin/mw     b/mw      -(pmin+k2)/mw   -b/mw ];

A2 = [ 0           1          0               0;
      -pmax/mb    -b/mb       pmax/mb         b/mb;
       0           0          0               1;
       pmax/mw     b/mw      -(pmax+k2)/mw   -b/mw ];

B  = [0; 1/mb; 0; -1/mw];     % Control input matrix
Bw = [0; 0; 0; k2/mw];        % Disturbance input matrix (road)

n  = size(A1,1);               % State dimension (4)

% Performance output: penalise sprung mass displacement & velocity
% z = C1*x   (1x4)
C1 = [1 0 0 0];   % sprung mass displacement output
ny = size(C1,1);  % number of outputs (1)

%% =========================
% 3. LMI SETUP
%    Variables: Q (symmetric 4x4), F1, F2 (1x4), gamma (scalar)
%    LMI from PDF (3x3 block, <0):
%    [ A_i*Q + B*F_j + (*)'    Bw        0   ]
%    [      Bw'               -gamma^2*I  0   ]
%    [      C1*Q               0         -I   ] < 0
%    for all i,j in {1,2}
%    Plus: Q > 0
%% =========================
setlmis([]);

% Decision variables
Q      = lmivar(1, [n  1]);      % symmetric 4x4
F1     = lmivar(2, [1  n]);      % 1x4 (not symmetric)
F2     = lmivar(2, [1  n]);      % 1x4
gamma2 = lmivar(1, [1  1]);      % scalar gamma^2 (symmetric 1x1)

F = {F1, F2};
A = {A1, A2};

% Identity matrices sized to outputs / disturbance
I_w = eye(1);   % size matches Bw column (1 disturbance)
I_z = eye(ny);  % size matches C1 rows  (1 output)

%% =========================
% 4. LMI CONSTRAINTS
%    co = LMI index, one per (i,j) pair
%% =========================
co = 0;

for i = 1:2
    for j = 1:2
        co = co + 1;

        % ---- Block (1,1): A_i*Q + B*F_j + (*)' ----
        lmiterm([co, 1, 1, Q],  A{i}, 1, 's');   % A_i*Q + Q*A_i'
        lmiterm([co, 1, 1, F{j}], B,  1, 's');   % B*F_j + F_j'*B'

        % ---- Block (2,1): Bw' ----
        lmiterm([co, 2, 1, 0], Bw');              % constant term

        % ---- Block (2,2): -gamma^2 * I ----
        lmiterm([co, 2, 2, gamma2], -I_w, 1);    % -gamma^2 * I_w

        % ---- Block (3,1): C1*Q ----
        lmiterm([co, 3, 1, Q], C1, 1);           % C1*Q

        % ---- Block (3,2): 0 ----
        lmiterm([co, 3, 2, 0], 0);               % zero constant

        % ---- Block (3,3): -I ----
        lmiterm([co, 3, 3, 0], -I_z);            % -I (constant)
    end
end

% Q > 0
lmiterm([-(co+1), 1, 1, Q], 1, 1);

% gamma^2 > 0
lmiterm([-(co+2), 1, 1, gamma2], 1, 1);

%% =========================
% 5. SOLVE: minimise gamma^2
%% =========================
lmisys = getlmis;
ndec   = decnbr(lmisys);
c_obj  = zeros(ndec, 1);

for s = 1:ndec
    c_obj(s) = defcx(lmisys, s, gamma2);
end

options = [1e-5, 200, 1e8, 10, 0];
[opt, xopt] = mincx(lmisys, c_obj, options);

%% =========================
% 6. EXTRACT RESULTS
%% =========================
Q_sol  = dec2mat(lmisys, xopt, Q);
F1_sol = dec2mat(lmisys, xopt, F1);
F2_sol = dec2mat(lmisys, xopt, F2);
g2_sol = dec2mat(lmisys, xopt, gamma2);

K1 = F1_sol / Q_sol;
K2 = F2_sol / Q_sol;

gamma_opt = sqrt(g2_sol);

fprintf('\n=========================================\n');
fprintf('  H-inf LMI Results\n');
fprintf('=========================================\n');
fprintf('  gamma (H-inf bound) = %.6f\n', gamma_opt);
fprintf('\n  K1 = '); disp(K1);
fprintf('  K2 = '); disp(K2);
fprintf('=========================================\n\n');

%% =========================
% 7. MEMBERSHIP FUNCTIONS
%    Scheduling variable: delta = x1 - x3 (suspension deflection)
%    mu1 + mu2 = 1 (convex interpolation between subsystems)
%% =========================
delta_max = sqrt((pmax - pmin) / k_nl);   % = 0.1 m

mu1 = @(delta) max(0, min(1,  (delta_max^2 - delta^2) / delta_max^2 ));
mu2 = @(delta) max(0, min(1,  delta^2                / delta_max^2 ));

%% =========================
% 8. ROAD DISTURBANCE
%    Same bump profile as road_disturbance.m
%% =========================
h_bump = 0.04;    % bump height [m]
L_bump = 1;       % bump length [m]
v_veh  = 10;      % vehicle speed [m/s]
t0_bump = 1;      % bump start [s]

road = @(t) (t >= t0_bump && t <= t0_bump + L_bump/v_veh) * ...
             (h_bump/2) * (1 - cos(2*pi*v_veh/L_bump*(t - t0_bump)));

%% =========================
% 9. SIMULATION
%% =========================
dt    = 0.001;
tspan = 0:dt:10;
N     = length(tspan);
x0    = [0; 0; 0; 0];

% ---- Open-loop T-S (no control) ----
X_ol = zeros(4, N);
X_ol(:,1) = x0;

for k = 1:N-1
    xi    = X_ol(:,k);
    d     = xi(1) - xi(3);
    h1    = mu1(d);  h2 = mu2(d);
    A_ts  = h1*A1 + h2*A2;
    zr    = road(tspan(k));
    dx    = A_ts*xi + Bw*zr;
    X_ol(:,k+1) = xi + dt*dx;
end

% ---- Closed-loop T-S H-inf ----
X_cl = zeros(4, N);
X_cl(:,1) = x0;

for k = 1:N-1
    xi   = X_cl(:,k);
    d    = xi(1) - xi(3);
    h1   = mu1(d);  h2 = mu2(d);
    K_ts = h1*K1 + h2*K2;
    zr   = road(tspan(k));
    dx   = (h1*A1 + h2*A2)*xi + B*(-K_ts*xi) + Bw*zr;
    X_cl(:,k+1) = xi + dt*dx;
end

%% =========================
% 10. SAVE WORKSPACE FOR PLOTTING
%% =========================
save('H_inf_results.mat', 'tspan', 'X_ol', 'X_cl', 'K1', 'K2', 'gamma_opt');
disp('Results saved to H_inf_results.mat');
disp('Run plotHinfComparison.m to see the plots.');