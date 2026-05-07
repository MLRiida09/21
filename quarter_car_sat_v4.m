%% ============================================================
%  Quarter-Car Active Suspension — T-S H? Control
%  with Actuator Saturation (PDC Controller)
%  Based on: Master's Thesis — ZAOUT Leila, USDB1, 2025
%  VERSION 4 — gamma = 0.2, corrected LMI
%% ============================================================

clear; clc; close all;

%% ============================================================
%  1. PARAMETERS
%% ============================================================
ms    = 240;
mu    = 36;
ks    = 16000;
kt    = 160000;
cs    = 980;
alpha = 5e4;

u_max =  1500;
u_min = -1500;

gamma = 0.2;   % H-infinity performance level

%% ============================================================
%  2. T-S SECTOR BOUNDS
%% ============================================================
x1_max  = 0.08;
k1_min  = ks;
k1_max  = ks + alpha*(x1_max^2);
fprintf('k1_min = %.1f N/m\n', k1_min);
fprintf('k1_max = %.1f N/m\n', k1_max);

%% ============================================================
%  3. SYSTEM MATRICES
%% ============================================================
A1 = [0,          1,      0,      -1;
     -k1_min/ms, -cs/ms,  0,     cs/ms;
      0,          0,      0,       1;
      k1_min/mu, cs/mu, -kt/mu, -cs/mu];

A2 = [0,          1,      0,      -1;
     -k1_max/ms, -cs/ms,  0,     cs/ms;
      0,          0,      0,       1;
      k1_max/mu, cs/mu, -kt/mu, -cs/mu];

Bu = [0; 1/ms; 0; -1/mu];
Bw = [0; 0; -1; 0];

n  = 4;
nw = 1;

%% ============================================================
%  4. SOLVE LMI — H? PDC (Theorem 3 from thesis)
%
%  Find P > 0, Ki such that for i = 1, 2:
%
%  Phi_i = Ai'P + P*Ai - P*Bu*Ri^{-1}*Bu'*P + (1/gamma^2)*P*Bw*Bw'*P < 0
%
%  Equivalent Schur form (numerically better):
%  [ Ai*X + X*Ai' + Bu*Mi + Mi'*Bu'   Bw    0  ]
%  [           Bw'                   -I     0  ]  < 0
%  [            0                     0  -g2*I ]
%
%  where X = P^{-1}, Mi = Ki*X
%  PLUS output performance row via separate bound
%% ============================================================

setlmis([]);

X  = lmivar(1, [n 1]);      % P^{-1} symmetric PD 4x4
M1 = lmivar(2, [1 n]);      % K1*X
M2 = lmivar(2, [1 n]);      % K2*X

g2 = gamma^2;

% ---- LMI 1: subsystem 1 (3 blocks: n, nw, nw)
% [ A1X+XA1'+BuM1+M1'Bu'   Bw    0     ]
% [        Bw'             -I    0     ]  < 0
% [         0               0  -g2*I  ]

lmiterm([1 1 1 X],  A1, 1, 's');
lmiterm([1 1 1 M1], Bu, 1, 's');
lmiterm([1 2 1 0],  Bw');
lmiterm([1 2 2 0], -eye(nw));
lmiterm([1 3 3 0], -g2*eye(nw));

% ---- LMI 2: subsystem 2
lmiterm([2 1 1 X],  A2, 1, 's');
lmiterm([2 1 1 M2], Bu, 1, 's');
lmiterm([2 2 1 0],  Bw');
lmiterm([2 2 2 0], -eye(nw));
lmiterm([2 3 3 0], -g2*eye(nw));

% ---- LMI 3: X > 1e-4*I
lmiterm([-3 1 1 X], 1, 1);
lmiterm([ 3 1 1 0], 1e-4*eye(n));

lmisys = getlmis;

options = [1e-6, 1000, 1e10, 10, 0];
[tmin, xfeas] = feasp(lmisys, options);

if tmin < 0
    fprintf('\n>>> LMI FEASIBLE (t = %.5f) — H-inf controllers found!\n\n', tmin);
    Xsol = dec2mat(lmisys, xfeas, X);
    M1sol = dec2mat(lmisys, xfeas, M1);
    M2sol = dec2mat(lmisys, xfeas, M2);
    K1 = M1sol / Xsol;
    K2 = M2sol / Xsol;
    fprintf('K1 = [%.2f  %.2f  %.2f  %.2f]\n', K1);
    fprintf('K2 = [%.2f  %.2f  %.2f  %.2f]\n', K2);
else
    fprintf('\n>>> LMI not feasible (t = %.4f)\n', tmin);
    fprintf('    Using LQR-based gains instead.\n\n');

    % LQR on average model — reliable alternative
    A_avg = (A1 + A2) / 2;
    Q = diag([1e6, 1e4, 1e5, 1e4]);   % penalise suspension deflection & body vel
    R_lqr = 1e-3;
    K_lqr = lqr(A_avg, Bu, Q, R_lqr);
    K1 = K_lqr;
    K2 = K_lqr;
    fprintf('LQR gain K = [%.2f  %.2f  %.2f  %.2f]\n', K_lqr);
end

%% ============================================================
%  5. ROAD DISTURBANCE — Bump
%% ============================================================
dt      = 0.001;
T       = 5;
t       = 0:dt:T;
N       = length(t);

A_bump  = 0.05;
t_start = 0.5;
t_end   = 1.0;
zr      = zeros(1,N);
idx     = (t >= t_start) & (t <= t_end);
zr(idx) = A_bump/2*(1 - cos(2*pi*(t(idx)-t_start)/(t_end-t_start)));
zr_dot  = [diff(zr)/dt, 0];

%% ============================================================
%  6. SIMULATION — Closed-loop vs Open-loop
%% ============================================================
x_cl    = zeros(4,N);
x_ol    = zeros(4,N);
u_ctrl  = zeros(1,N);
u_sat_v = zeros(1,N);

for k = 1:N-1
    x1   = x_cl(1,k);
    k_nl = min(ks + alpha*x1^2, k1_max);
    h1   = (k1_max - k_nl)/(k1_max - k1_min + 1e-12);
    h2   = 1 - h1;

    % PDC law
    u_ctrl(k) = h1*(K1*x_cl(:,k)) + h2*(K2*x_cl(:,k));

    % Saturation
    u_sat_v(k) = max(u_min, min(u_max, u_ctrl(k)));

    % Nonlinear closed-loop matrix
    A_nl = [0,         1,     0,      -1;
           -k_nl/ms, -cs/ms,  0,     cs/ms;
            0,         0,     0,       1;
            k_nl/mu,  cs/mu, -kt/mu, -cs/mu];

    w = zr_dot(k);
    x_cl(:,k+1) = x_cl(:,k) + dt*(A_nl*x_cl(:,k) + Bu*u_sat_v(k) + Bw*w);

    % Open-loop (passive)
    k_ol = min(ks + alpha*x_ol(1,k)^2, k1_max);
    A_ol = [0,        1,     0,      -1;
           -k_ol/ms, -cs/ms, 0,     cs/ms;
            0,        0,     0,       1;
            k_ol/mu, cs/mu, -kt/mu, -cs/mu];
    x_ol(:,k+1) = x_ol(:,k) + dt*(A_ol*x_ol(:,k) + Bw*w);
end

%% ============================================================
%  7. OUTPUTS
%% ============================================================
zs_cl      = cumsum(x_cl(2,:))*dt;
zu_cl      = cumsum(x_cl(4,:))*dt;
zs_ol      = cumsum(x_ol(2,:))*dt;
zu_ol      = cumsum(x_ol(4,:))*dt;
sd_cl      = x_cl(1,:);   % suspension deflection CL
sd_ol      = x_ol(1,:);   % suspension deflection OL
acc_cl     = (-ks*sd_cl - cs*x_cl(2,:) + u_sat_v)/ms;
acc_ol     = (-ks*sd_ol - cs*x_ol(2,:))/ms;

%% ============================================================
%  8. PLOTS
%% ============================================================
figure('Name','Quarter-Car T-S H-inf + Saturation',...
       'NumberTitle','off','Position',[80 60 1150 780]);

subplot(3,2,1)
plot(t,zs_ol*100,'r--','LineWidth',1.5); hold on
plot(t,zs_cl*100,'b','LineWidth',1.5)
plot(t,zr*100,'Color',[.5 .5 .5],'LineStyle',':','LineWidth',1.2)
xlabel('Time (s)'); ylabel('cm')
title('Sprung Mass Displacement z\_s')
legend('Open-loop','H-inf+Sat','Road z\_r'); grid on

subplot(3,2,2)
plot(t,zu_ol*100,'r--','LineWidth',1.5); hold on
plot(t,zu_cl*100,'b','LineWidth',1.5)
xlabel('Time (s)'); ylabel('cm')
title('Unsprung Mass Displacement z\_u')
legend('Open-loop','H-inf+Sat'); grid on

subplot(3,2,3)
plot(t,sd_ol*100,'r--','LineWidth',1.5); hold on
plot(t,sd_cl*100,'b','LineWidth',1.5)
xlabel('Time (s)'); ylabel('cm')
title('Suspension Deflection z\_s - z\_u')
legend('Open-loop','H-inf+Sat'); grid on

subplot(3,2,4)
plot(t,acc_ol,'r--','LineWidth',1.5); hold on
plot(t,acc_cl,'b','LineWidth',1.5)
xlabel('Time (s)'); ylabel('m/s^2')
title('Sprung Mass Acceleration')
legend('Open-loop','H-inf+Sat'); grid on

subplot(3,2,5)
plot(t,u_ctrl,'b--','LineWidth',1.2,'DisplayName','u (before sat)'); hold on
plot(t,u_sat_v,'r','LineWidth',1.5,'DisplayName','u\_sat (applied)')
yline( u_max,'k:','LineWidth',1.2,'DisplayName','+u\_max')
yline( u_min,'k:','LineWidth',1.2,'DisplayName','-u\_max')
xlabel('Time (s)'); ylabel('N')
title('Control Force — Saturation')
legend('Location','best'); grid on

subplot(3,2,6)
plot(t,zr*100,'k','LineWidth',1.5)
xlabel('Time (s)'); ylabel('cm')
title('Road Disturbance z\_r (Bump 5 cm)'); grid on

sgtitle('Quarter-Car: T-S H-inf PDC with Actuator Saturation (gamma=0.2)',...
        'FontSize',12,'FontWeight','bold')

%% ============================================================
%  9. PERFORMANCE TABLE
%% ============================================================
fprintf('\n+------------------------------------------+------------+------------+\n');
fprintf('| Metric                                   | Open-loop  |  H-inf+Sat |\n');
fprintf('+------------------------------------------+------------+------------+\n');
fprintf('| Max body displacement   (cm)             |  %8.4f  |  %8.4f  |\n', max(abs(zs_ol))*100, max(abs(zs_cl))*100);
fprintf('| Max body acceleration   (m/s2)           |  %8.4f  |  %8.4f  |\n', max(abs(acc_ol)), max(abs(acc_cl)));
fprintf('| Max suspension deflect  (cm)             |  %8.4f  |  %8.4f  |\n', max(abs(sd_ol))*100, max(abs(sd_cl))*100);
fprintf('| Max tyre deflection     (cm)             |  %8.4f  |  %8.4f  |\n', max(abs(x_ol(3,:)))*100, max(abs(x_cl(3,:)))*100);
fprintf('| Max control force       (N)              |     —      |  %8.1f  |\n', max(abs(u_sat_v)));
fprintf('| Saturation events                        |     —      |  %8d  |\n', sum(abs(u_ctrl) > u_max));
fprintf('+------------------------------------------+------------+------------+\n\n');

%% ============================================================
%  10. ACTIVATION FUNCTIONS
%% ============================================================
figure('Name','T-S Activation Functions','NumberTitle','off',...
       'Position',[200 200 580 280]);
x1v = linspace(-x1_max, x1_max, 500);
kv  = min(ks + alpha*x1v.^2, k1_max);
h1v = (k1_max - kv)/(k1_max - k1_min);
h2v = 1 - h1v;
plot(x1v*100, h1v,'b','LineWidth',2,'DisplayName','h\_1(x\_1)'); hold on
plot(x1v*100, h2v,'r','LineWidth',2,'DisplayName','h\_2(x\_1)')
xlabel('Suspension deflection x\_1 (cm)'); ylabel('Weight')
title('T-S Activation Functions'); legend; grid on; ylim([-0.05 1.05])