clc; clear; close all;

%% =========================
% 1. PARAMETERS
%% =========================
mb = 285;
mw = 60;
bs = 1300;
ks = 25400;
kt = 200000;

%% =========================
% 2. SYSTEM MATRICES (T-S SUBSYSTEMS)
%% =========================

A1 = [ 0 1 0 0;
      -ks/mb -bs/mb ks/mb bs/mb;
       0 0 0 1;
       ks/mw bs/mw -(ks+kt)/mw -bs/mw ];

A2 = [ 0 1 0 0;
      -1.2*ks/mb -1.2*bs/mb 1.2*ks/mb 1.2*bs/mb;
       0 0 0 1;
       1.2*ks/mw 1.2*bs/mw -(1.2*ks+kt)/mw -1.2*bs/mw ];

B = [0; 1/mb; 0; -1/mw];
Bw = [0; 0; 0; kt/mw];

n = size(A1,1);

%% =========================
% 3. LMI SETUP
%% =========================
setlmis([]);

[X, ~, ~]  = lmivar(1,[n 1]);
[Y1, ~, ~] = lmivar(2,[1 n]);
[Y2, ~, ~] = lmivar(2,[1 n]);

gamma = 0.1;

%% =========================
% 4. LMI CONSTRUCTION
%% =========================

% -------- Rule 1 --------
lmiterm([1 1 1 X],A1,1,'s');
lmiterm([1 1 1 Y1],B,1,'s');

lmiterm([1 1 2 X],1,Bw);
lmiterm([1 2 1 X],Bw',1);

lmiterm([1 2 2 0],-gamma^2);

% -------- Rule 2 --------
lmiterm([2 1 1 X],A2,1,'s');
lmiterm([2 1 1 Y2],B,1,'s');

lmiterm([2 1 2 X],1,Bw);
lmiterm([2 2 1 X],Bw',1);

lmiterm([2 2 2 0],-gamma^2);

% -------- X > 0 --------
lmiterm([-3 1 1 X],1,1);

%% =========================
% 5. SOLVE LMI
%% =========================
lmis = getlmis;
[tmin, xfeas] = feasp(lmis);

if tmin < 0
    disp('Feasible solution found ?');

    X_sol  = dec2mat(lmis, xfeas, X);
    Y1_sol = dec2mat(lmis, xfeas, Y1);
    Y2_sol = dec2mat(lmis, xfeas, Y2);

    K1 = Y1_sol / X_sol;
    K2 = Y2_sol / X_sol;
else
    error('No feasible solution ?');
end

%% =========================
% 6. MEMBERSHIP FUNCTIONS
%% =========================

z = @(x) x(1) - x(3);

mu1 = @(z) 1./(1+exp(5*z));
mu2 = @(z) 1 - mu1(z);

%% =========================
% 7. FUZZY CONTROLLER
%% =========================
K = @(x) mu1(z(x))*K1 + mu2(z(x))*K2;

%% =========================
% 8. CLOSED LOOP DYNAMICS
%% =========================
f = @(t,x) ( (A1 + B*(-K(x))) * x );

%% =========================
% 9. SIMULATION
%% =========================
tspan = [0 5];
x0 = [0.05; 0; 0; 0];

[t,x] = ode45(f,tspan,x0);

%% =========================
% 10. PLOTS
%% =========================
figure;
plot(t,x(:,1),'LineWidth',1.5); hold on;
plot(t,x(:,3),'LineWidth',1.5);
legend('Sprung mass','Unsprung mass');
xlabel('Time (s)');
ylabel('Displacement (m)');
title('T-S H? Fuzzy Control Response');
grid on;