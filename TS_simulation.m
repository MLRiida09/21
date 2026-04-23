%% ========================================================
%  Takagi-Sugeno Simulation - Quarter Car Model
%  Comparison: Nonlinear Original vs T-S Fuzzy Model
%% ========================================================

clc; clear all;

global mb mw k1 k_nl b k2 fa
global t x1 x1_dot x2 x2_dot Fa_value mode_str

%% ---- Parameters ------------------------------------
parameters

Fa_value = 20;
mode_str = 'active';

%% ---- T-S Model Parameters --------------------------
pmin = 16000;     
pmax = 16500;     
k_nl = 5000;     

%% ---- T-S Matrices ----------------------------------
A1 = [0          1        0              0;
     -pmin/mb    -b/mb    pmin/mb        b/mb;
      0           0       0              1;
      pmin/mw     b/mw   -(pmin+k2)/mw  -b/mw];

A2 = [0          1        0              0;
     -pmax/mb    -b/mb    pmax/mb        b/mb;
      0           0       0              1;
      pmax/mw     b/mw   -(pmax+k2)/mw  -b/mw];

B  = [0; 1/mb; 0; -1/mw];
w  = [0; 0; 0; k2/mw];

disp('T-S Matrices computed:');

%% ---- Time Vector -----------------------------------
dt   = 0.001;
tspan = 0:dt:10;
N    = length(tspan);

%% ---- Road Disturbance ------------------------------
h  = 0.04;   % bump height [m]
L  = 1;      % bump length [m]
v  = 10;     % vehicle speed [m/s]
t0 = 1;      % start time [s]

zr = zeros(1, N);

for i = 1:N
    t_i = tspan(i);
    if t_i >= t0 && t_i <= t0 + L/v
        zr(i) = (h/2) * (1 - cos(2*pi*v/L * (t_i - t0)));
    end
end

zr_dot = [diff(zr)/dt, 0];


%% ---- Initial Conditions ----------------------------
x0 = [0; 0; 0; 0];

%% ---- Simulation: Original Nonlinear ----------------
fprintf('Simulating Original Nonlinear model...\n');

X_nl = zeros(4, N);
X_nl(:,1) = x0;

for i = 1:N-1
    xi    = X_nl(:,i);
    delta_i = xi(3) - xi(1);

    % Nonlinear spring
    k_eff = k1 + k_nl * delta_i^2;

    A_nl  = [0         1        0             0;
            -k_eff/mb  -b/mb    k_eff/mb      b/mb;
             0          0       0             1;
             k_eff/mw   b/mw   -(k_eff+k2)/mw -b/mw];

    dx = A_nl*xi + w*zr(i);
    X_nl(:,i+1) = xi + dt*dx;
end

%% ---- Simulation: T-S Fuzzy Model -------------------
fprintf('Simulating T-S Fuzzy model...\n');

X_ts = zeros(4, N);
X_ts(:,1) = x0;

delta_min = 0;
delta_max = sqrt((pmax - pmin) / k_nl);

for i = 1:N-1
    xi      = X_ts(:,i);
    delta_i = xi(3) - xi(1);

    d2 = delta_i^2;

    if d2 >= delta_max^2
        mu2 = 1; mu1 = 0;
    elseif d2 <= delta_min^2
        mu2 = 0; mu1 = 1;
    else
        mu2 = (d2 - delta_min^2) / (delta_max^2 - delta_min^2);
        mu1 = 1 - mu2;
    end

    % T-S interpolation
    A_ts = mu1*A1 + mu2*A2;

    dx = A_ts*xi + w*zr(i);
    X_ts(:,i+1) = xi + dt*dx;
end

%% ---- Plot Comparison -------------------------------
plotTSComparison(tspan, X_nl, X_ts, zr);

fprintf('Done!\n');