%% ========================================================
%  FILE: plotHinfComparison.m
%  Comparison: T-S Open-Loop  vs  T-S H-inf Closed-Loop
%  Run H_inf_LMI.m first, then call this script.
%% ========================================================

function plotHinfComparison(tspan, X_ol, X_cl)

% Allow calling without arguments (loads from saved workspace)
if nargin == 0
    if ~exist('H_inf_results.mat','file')
        error('Run H_inf_LMI.m first to generate H_inf_results.mat');
    end
    load('H_inf_results.mat', 'tspan', 'X_ol', 'X_cl', 'gamma_opt');
    fprintf('Loaded results. gamma = %.4f\n', gamma_opt);
end

%% ---- Extract states ----------------------------------------
% States: x1=Zs, x2=Zs_dot, x3=Zu, x4=Zu_dot
Zs_ol  = X_ol(1,:);   % Sprung mass displacement - Open Loop
Zu_ol  = X_ol(3,:);   % Unsprung mass displacement - Open Loop
def_ol = Zs_ol - Zu_ol;

Zs_cl  = X_cl(1,:);   % Sprung mass displacement - Closed Loop
Zu_cl  = X_cl(3,:);   % Unsprung mass displacement - Closed Loop
def_cl = Zs_cl - Zu_cl;

%% ---- Style -------------------------------------------------
lw     = 1.8;
fs     = 12;
fst    = 13;
col_ol = [0.08 0.35 0.72];    % blue  - Open loop
col_cl = [0.85 0.15 0.15];    % red   - Closed loop (H-inf)
fig_w  = 700;
fig_h  = 350;

%% ---- Figure 1: Sprung Mass Displacement Zs ----------------
figure('Name','Zs - Sprung Mass','Color','w','Position',[100 500 fig_w fig_h]);

h1a = plot(tspan, Zs_ol, 'Color', col_ol, 'LineWidth', lw);
hold on;
h1b = plot(tspan, Zs_cl, '--', 'Color', col_cl, 'LineWidth', lw);
hold off;

xlabel('Time (s)',          'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Displacement (m)',  'FontSize', fs, 'FontName', 'Times New Roman');
title('Sprung Mass Vertical Displacement Z_s', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend([h1a h1b], {'T-S Open-Loop', 'T-S H\infty Closed-Loop'}, ...
       'Location', 'best', 'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits','centimeters','PaperSize',[18 9],'PaperPosition',[0 0 18 9]);
drawnow;

%% ---- Figure 2: Unsprung Mass Displacement Zu --------------
figure('Name','Zu - Unsprung Mass','Color','w','Position',[140 420 fig_w fig_h]);

h2a = plot(tspan, Zu_ol, 'Color', col_ol, 'LineWidth', lw);
hold on;
h2b = plot(tspan, Zu_cl, '--', 'Color', col_cl, 'LineWidth', lw);
hold off;

xlabel('Time (s)',          'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Displacement (m)',  'FontSize', fs, 'FontName', 'Times New Roman');
title('Unsprung Mass Vertical Displacement Z_u', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend([h2a h2b], {'T-S Open-Loop', 'T-S H\infty Closed-Loop'}, ...
       'Location', 'best', 'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits','centimeters','PaperSize',[18 9],'PaperPosition',[0 0 18 9]);
drawnow;

%% ---- Figure 3: Suspension Deflection (Zs - Zu) ------------
figure('Name','Suspension Deflection','Color','w','Position',[180 340 fig_w fig_h]);

h3a = plot(tspan, def_ol, 'Color', col_ol, 'LineWidth', lw);
hold on;
h3b = plot(tspan, def_cl, '--', 'Color', col_cl, 'LineWidth', lw);
hold off;

xlabel('Time (s)',          'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Displacement (m)',  'FontSize', fs, 'FontName', 'Times New Roman');
title('Suspension Deflection (Z_s - Z_u)', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend([h3a h3b], {'T-S Open-Loop', 'T-S H\infty Closed-Loop'}, ...
       'Location', 'best', 'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits','centimeters','PaperSize',[18 9],'PaperPosition',[0 0 18 9]);
drawnow;

%% ---- Figure 4: Sprung Mass Velocity Zs_dot ----------------
figure('Name','Zs_dot - Sprung Mass Velocity','Color','w','Position',[220 260 fig_w fig_h]);

h4a = plot(tspan, X_ol(2,:), 'Color', col_ol, 'LineWidth', lw);
hold on;
h4b = plot(tspan, X_cl(2,:), '--', 'Color', col_cl, 'LineWidth', lw);
hold off;

xlabel('Time (s)',         'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Velocity (m/s)',   'FontSize', fs, 'FontName', 'Times New Roman');
title('Sprung Mass Velocity \dot{Z}_s', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend([h4a h4b], {'T-S Open-Loop', 'T-S H\infty Closed-Loop'}, ...
       'Location', 'best', 'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits','centimeters','PaperSize',[18 9],'PaperPosition',[0 0 18 9]);
drawnow;

end