%% ========================================================
%  FILE: compare_passive_TS_Hinf.m
%
%  ??????: Passive | T-S open-loop | H-infinity LMI
%  State:  x = [Zs, Zs_dot, Zu, Zu_dot]
%
%  ?????????:
%  - ???? ?????? ?????? ????? ??? ???? ???????? ???????
%  - ????? ???? ???? ?????? ??????
%  - ?????? ?? ??????? ?????? ?????? ??? ?????
%% ========================================================

clc; clear; close all;

%% ========================================================
%  1. PARAMETERS
%% ========================================================
mb  = 300;
mw  = 60;
ks  = 16000;
bs  = 1000;
kt  = 190000;

%% ========================================================
%  2. STATE MATRICES
%% ========================================================
A1 = [  0,         1,         0,           0      ;
       -ks/mb,    -bs/mb,     ks/mb,       bs/mb  ;
        0,         0,         0,           1      ;
        ks/mw,     bs/mw,   -(ks+kt)/mw, -bs/mw  ];

A2 = [  0,            1,            0,               0         ;
       -1.2*ks/mb,   -1.2*bs/mb,    1.2*ks/mb,       1.2*bs/mb ;
        0,            0,            0,               1         ;
        1.2*ks/mw,    1.2*bs/mw,  -(1.2*ks+kt)/mw, -1.2*bs/mw ];

B  = [0;  1/mb;  0;  -1/mw];
Bw = [0;  0;     0;   kt/mw];

n = 4;
m = 1;

%% ========================================================
%  3. PERFORMANCE OUTPUT
%% ========================================================
C1 = [-ks/mb, -bs/mb,  ks/mb,  bs/mb ;   % Zs_ddot
       1,       0,     -1,      0     ];   % Zs - Zu

ny = size(C1,1);
nw = 1;

%% ========================================================
%  4. H-INFINITY LMI DESIGN
%% ========================================================
fprintf('Solving H-inf LMI ...\n');

setlmis([]);

Q  = lmivar(1,[n 1]);
F1 = lmivar(2,[m n]);
F2 = lmivar(2,[m n]);
g2 = lmivar(1,[1 1]);

Inw = eye(nw);
Iny = eye(ny);

co = 0;
for i = 1:2
    if i==1; Ai=A1; else; Ai=A2; end
    for j = 1:2
        if j==1; Fj=F1; else; Fj=F2; end
        co = co+1;

        lmiterm([co 1 1 Q],  Ai, 1,'s');
        lmiterm([co 1 1 Fj], B,  1,'s');
        lmiterm([co 2 1 0],  Bw');
        lmiterm([co 2 2 g2], -Inw, 1);
        lmiterm([co 3 1 Q],  C1, 1);
        lmiterm([co 3 2 0],  zeros(ny,nw));
        lmiterm([co 3 3 0],  -Iny);
    end
end

lmiterm([-(co+1) 1 1 Q],  1, 1);
lmiterm([-(co+2) 1 1 g2], 1, 1);

lmis = getlmis;
q    = decnbr(lmis);
cvec = zeros(q,1);
for s = 1:q
    cvec(s) = defcx(lmis,s,g2);
end

opts = [1e-5, 400, 1e10, 20, 0];
[gopt, xopt] = mincx(lmis, cvec, opts);

if isempty(gopt)
    error('LMI solver did not converge.');
end

Q_sol  = dec2mat(lmis, xopt, Q);
F1_sol = dec2mat(lmis, xopt, F1);
F2_sol = dec2mat(lmis, xopt, F2);
g2_sol = dec2mat(lmis, xopt, g2);

K1 = F1_sol / Q_sol;
K2 = F2_sol / Q_sol;
gamma_opt = sqrt(g2_sol);

fprintf('  gamma_opt = %.4f\n', gamma_opt);
fprintf('  K1 = ['); fprintf(' %.3f', K1); fprintf(' ]\n');
fprintf('  K2 = ['); fprintf(' %.3f', K2); fprintf(' ]\n\n');

%% ========================================================
%  5. VERIFY CLOSED-LOOP STABILITY
%     eigenvalues of (A1 + B*K1) and (A2 + B*K2) must be < 0
%% ========================================================
eig1 = eig(A1 - B*K1);
eig2 = eig(A2 - B*K2);
fprintf('Closed-loop eigenvalues (rule 1): ');
fprintf('%.3f  ', real(eig1));
fprintf('\n');
fprintf('Closed-loop eigenvalues (rule 2): ');
fprintf('%.3f  ', real(eig2));
fprintf('\n\n');

if any(real(eig1) >= 0) || any(real(eig2) >= 0)
    warning('Some closed-loop poles are unstable! Check LMI solution.');
end

%% ========================================================
%  6. MEMBERSHIP FUNCTIONS
%     scheduling: z = Zs - Zu  (suspension deflection)
%     range estimated from passive simulation amplitude
%
%     delta_min = 0  (no deflection)
%     delta_max = 0.02 m  (estimated peak from road bump)
%
%     mu1(z) = 1 when |z| small  (near A1)
%     mu2(z) = 1 when |z| large  (near A2)
%% ========================================================
z_max = 0.02;   % m  — adjust if needed

mu1 = @(x) max(0, min(1,  1 - abs(x(1)-x(3)) / z_max ));
mu2 = @(x) 1 - mu1(x);

%% ========================================================
%  7. ROAD DISTURBANCE
%     Half-sine bump  h=0.08m,  duration=0.15s,  start t=1s
%     (doubled amplitude vs before to get visible response)
%% ========================================================
h_bump = 0.08;    % bump height [m]
t_bump = 1.0;     % start time  [s]
d_bump = 0.15;    % duration    [s]

road = @(t) h_bump .* (t >= t_bump & t <= t_bump+d_bump) ...
            .* (1 - cos(2*pi*(t-t_bump)/d_bump)) / 2;

%% ========================================================
%  8. DYNAMICS
%% ========================================================
f_pass = @(t,x)  A1*x + Bw*road(t);

f_ts   = @(t,x)  (mu1(x)*A1 + mu2(x)*A2)*x + Bw*road(t);

u_hi   = @(x) -(mu1(x)*(K1*x) + mu2(x)*(K2*x));
f_hi   = @(t,x)  (mu1(x)*A1 + mu2(x)*A2)*x ...
                 + B*u_hi(x) + Bw*road(t);

%% ========================================================
%  9. SIMULATION
%% ========================================================
tspan = [0 8];
x0    = [0; 0; 0; 0];   % start at rest, road provides excitation
oopt  = odeset('RelTol',1e-7,'AbsTol',1e-9,'MaxStep',0.002);

fprintf('Simulating ...\n');
[t_p,  X_p ]  = ode45(f_pass, tspan, x0, oopt);
[t_ts, X_ts]  = ode45(f_ts,   tspan, x0, oopt);
[t_hi, X_hi]  = ode45(f_hi,   tspan, x0, oopt);

%% --- quick sanity check: peak amplitude ------------------
fprintf('  Peak |Zs|  Passive=%.5fm  TS=%.5fm  Hinf=%.5fm\n', ...
    max(abs(X_p(:,1))), max(abs(X_ts(:,1))), max(abs(X_hi(:,1))));
fprintf('  Done.\n\n');

%% ========================================================
%  10. RMS
%% ========================================================
rms_fn = @(v) sqrt(mean(v.^2));
tg = linspace(tspan(1),tspan(2),10000);

ip = @(t,X,col) interp1(t, X(:,col), tg,'linear','extrap');

Zs_p  = ip(t_p, X_p, 1);   Zs_ts = ip(t_ts,X_ts,1);  Zs_hi = ip(t_hi,X_hi,1);
Zu_p  = ip(t_p, X_p, 3);   Zu_ts = ip(t_ts,X_ts,3);  Zu_hi = ip(t_hi,X_hi,3);
Df_p  = Zs_p-Zu_p;          Df_ts = Zs_ts-Zu_ts;       Df_hi = Zs_hi-Zu_hi;

fprintf('==============================================\n');
fprintf('  RMS Performance Summary\n');
fprintf('==============================================\n');
fprintf('  %-12s %10s %10s %10s\n','Signal','Passive','T-S','H-inf');
fprintf('  %-12s %10.6f %10.6f %10.6f\n','Zs  (m)', ...
    rms_fn(Zs_p),rms_fn(Zs_ts),rms_fn(Zs_hi));
fprintf('  %-12s %10.6f %10.6f %10.6f\n','Zu  (m)', ...
    rms_fn(Zu_p),rms_fn(Zu_ts),rms_fn(Zu_hi));
fprintf('  %-12s %10.6f %10.6f %10.6f\n','Zs-Zu (m)', ...
    rms_fn(Df_p),rms_fn(Df_ts),rms_fn(Df_hi));
fprintf('==============================================\n');
fprintf('  gamma_opt = %.6f\n\n', gamma_opt);

%% ========================================================
%  11. PLOTS
%% ========================================================
lw     = 2.0;
fs     = 12;
fst    = 13;
col_p  = [0.55 0.55 0.55];
col_ts = [0.11 0.62 0.46];
col_hi = [0.85 0.35 0.19];

leg_str = {'Passive','T-S (open-loop)','H\infty LMI'};

%--- helper: annotation box --------------------------------
ann = @(rp,rts,rhi) annotation('textbox',[0.13 0.12 0.35 0.22], ...
    'String',{ ...
        sprintf('RMS Passive  = %.5f m', rp),  ...
        sprintf('RMS T-S      = %.5f m', rts), ...
        sprintf('RMS H\\infty  = %.5f m', rhi)},...
    'EdgeColor',[0.75 0.75 0.75],'FontSize',9.5, ...
    'FontName','Times New Roman', ...
    'BackgroundColor',[0.97 0.97 0.97],'Interpreter','tex');

%---------------------------------------------------------
%  Figure 1 – Zs
%---------------------------------------------------------
figure('Name','Zs','Color','w','Position',[60 560 800 360]);
hold on; grid on; box on;
plot(t_p,  X_p(:,1),  '--','Color',col_p, 'LineWidth',lw,'DisplayName',leg_str{1});
plot(t_ts, X_ts(:,1), '-', 'Color',col_ts,'LineWidth',lw,'DisplayName',leg_str{2});
plot(t_hi, X_hi(:,1), '-.','Color',col_hi,'LineWidth',lw,'DisplayName',leg_str{3});
xlabel('Time (s)',         'FontSize',fs,'FontName','Times New Roman');
ylabel('Displacement (m)', 'FontSize',fs,'FontName','Times New Roman');
title('Sprung Mass Displacement  Z_s', ...
      'FontSize',fst,'FontName','Times New Roman','FontWeight','bold');
legend('Location','northeast','FontSize',fs-1,'FontName','Times New Roman','Interpreter','tex');
set(gca,'FontSize',fs,'FontName','Times New Roman');
ann(rms_fn(Zs_p), rms_fn(Zs_ts), rms_fn(Zs_hi));

%---------------------------------------------------------
%  Figure 2 – Zu
%---------------------------------------------------------
figure('Name','Zu','Color','w','Position',[80 460 800 360]);
hold on; grid on; box on;
plot(t_p,  X_p(:,3),  '--','Color',col_p, 'LineWidth',lw,'DisplayName',leg_str{1});
plot(t_ts, X_ts(:,3), '-', 'Color',col_ts,'LineWidth',lw,'DisplayName',leg_str{2});
plot(t_hi, X_hi(:,3), '-.','Color',col_hi,'LineWidth',lw,'DisplayName',leg_str{3});
xlabel('Time (s)',         'FontSize',fs,'FontName','Times New Roman');
ylabel('Displacement (m)', 'FontSize',fs,'FontName','Times New Roman');
title('Unsprung Mass Displacement  Z_u', ...
      'FontSize',fst,'FontName','Times New Roman','FontWeight','bold');
legend('Location','northeast','FontSize',fs-1,'FontName','Times New Roman','Interpreter','tex');
set(gca,'FontSize',fs,'FontName','Times New Roman');
ann(rms_fn(Zu_p), rms_fn(Zu_ts), rms_fn(Zu_hi));

%---------------------------------------------------------
%  Figure 3 – Zs - Zu
%---------------------------------------------------------
figure('Name','Deflection','Color','w','Position',[100 360 800 360]);
hold on; grid on; box on;
plot(t_p,  X_p(:,1) -X_p(:,3),  '--','Color',col_p, 'LineWidth',lw,'DisplayName',leg_str{1});
plot(t_ts, X_ts(:,1)-X_ts(:,3), '-', 'Color',col_ts,'LineWidth',lw,'DisplayName',leg_str{2});
plot(t_hi, X_hi(:,1)-X_hi(:,3), '-.','Color',col_hi,'LineWidth',lw,'DisplayName',leg_str{3});
xlabel('Time (s)',       'FontSize',fs,'FontName','Times New Roman');
ylabel('Deflection (m)', 'FontSize',fs,'FontName','Times New Roman');
title('Suspension Deflection  (Z_s - Z_u)', ...
      'FontSize',fst,'FontName','Times New Roman','FontWeight','bold');
legend('Location','northeast','FontSize',fs-1,'FontName','Times New Roman','Interpreter','tex');
set(gca,'FontSize',fs,'FontName','Times New Roman');
ann(rms_fn(Df_p), rms_fn(Df_ts), rms_fn(Df_hi));

%---------------------------------------------------------
%  Figure 4 – Road disturbance
%---------------------------------------------------------
t_r = linspace(tspan(1),tspan(2),5000);
zr  = h_bump*(t_r>=t_bump & t_r<=t_bump+d_bump) ...
      .*(1-cos(2*pi*(t_r-t_bump)/d_bump))/2;

figure('Name','Road','Color','w','Position',[120 260 800 240]);
plot(t_r, zr*100,'k-','LineWidth',lw);
xlabel('Time (s)',   'FontSize',fs,'FontName','Times New Roman');
ylabel('Height (cm)','FontSize',fs,'FontName','Times New Roman');
title('Road Disturbance — Half-Sine Bump', ...
      'FontSize',fst,'FontName','Times New Roman','FontWeight','bold');
grid on; box on;
set(gca,'FontSize',fs,'FontName','Times New Roman');

%---------------------------------------------------------
%  Figure 5 – RMS bar chart
%---------------------------------------------------------
rms_mat = [ rms_fn(Zs_p),  rms_fn(Zu_p),  rms_fn(Df_p)  ;
            rms_fn(Zs_ts), rms_fn(Zu_ts), rms_fn(Df_ts) ;
            rms_fn(Zs_hi), rms_fn(Zu_hi), rms_fn(Df_hi) ];

figure('Name','RMS','Color','w','Position',[140 60 700 400]);
bh = bar(rms_mat', 0.7);
bh(1).FaceColor = col_p;
bh(2).FaceColor = col_ts;
bh(3).FaceColor = col_hi;
set(gca,'XTickLabel',{'Z_s (m)','Z_u (m)','Z_s-Z_u (m)'}, ...
        'FontSize',fs,'FontName','Times New Roman');
ylabel('RMS (m)','FontSize',fs,'FontName','Times New Roman');
title('RMS Performance Comparison', ...
      'FontSize',fst,'FontName','Times New Roman','FontWeight','bold');
legend({'Passive','T-S (open-loop)','H\infty LMI'}, ...
       'Location','best','FontSize',fs-1, ...
       'FontName','Times New Roman','Interpreter','tex');
grid on; box on;