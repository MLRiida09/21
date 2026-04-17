%% ========================================================
%  run_FLC_simulation.m
%  Run Quarter Car T-S Fuzzy Simulink model
%  Compatible: MATLAB 2014a
%% ========================================================
clc; clear all;

%% ---- Parameters ------------------------------------
parameters();
pmin=16000; pmax=16500; k_nl=50000;
mb=300; mw=60; b=1000; k2=190000;

A1 = [ 0        1       0              0;
      -pmin/mb -b/mb    pmin/mb        b/mb;
       0        0       0              1;
       pmin/mw  b/mw  -(pmin+k2)/mw  -b/mw];

A2 = [ 0        1       0              0;
      -pmax/mb -b/mb    pmax/mb        b/mb;
       0        0       0              1;
       pmax/mw  b/mw  -(pmax+k2)/mw  -b/mw];

w_vec = [0; 0; 0; k2/mw];

%% ---- Road disturbance ------------------------------
dt    = 0.001;
tspan = (0:dt:5)';
N     = length(tspan);

zr = zeros(N,1);
for i = 1:N
    zr(i) = road_disturbance(tspan(i));
end
zr_input = [tspan, zr];

%% ---- Run Simulink ----------------------------------
mdl = 'QuarterCar_FLC';
if ~bdIsLoaded(mdl), load_system(mdl); end

fprintf('Running simulation...\n');
sim(mdl);
fprintf('Done!\n');

%% ---- Plot ------------------------------------------
figure('Visible','on');
plot(tspan, X_ts(1,:), 'b', 'LineWidth',1.5); hold on;
plot(tspan, X_ts(3,:), 'r--','LineWidth',1.5); hold off;
title('T-S Fuzzy: Zs vs Zu');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('Zs','Zu','Location','best');
grid on;

figure('Visible','on');
plot(tspan, X_ts(1,:)-X_ts(3,:), 'k','LineWidth',1.5);
title('Débattement (Zs - Zu)');
xlabel('temps(s)'); ylabel('déplacement(m)');
grid on;
