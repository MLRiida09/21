%% ========================================================
%  FILE: ts_activation_functions.m
%  T-S Fuzzy Activation Functions - Nonlinear Quarter-Car
%  Sector nonlinearity for: f(delta) = k_nl * delta^3
%% ========================================================
function [h1, h2, delta, A1, A2] = ts_activation_functions(delta_max)

global mb mw k1 k_nl b k2

%% ---- Default argument ----------------------------------
if nargin < 1
    delta_max = 0.1;
end

%% ---- Scheduling variable -------------------------------
delta = linspace(-delta_max, delta_max, 500);

%% ---- Sector bounds -------------------------------------
f_nl  = k_nl .* delta.^3;
f_max = k_nl * delta_max^2 .* delta;
f_min = zeros(size(delta));

%% ---- Activation functions ------------------------------
epsilon = 1e-10;
h1      = zeros(size(delta));

for i = 1:length(delta)
    denom = f_max(i) - f_min(i);
    if abs(denom) > epsilon
        h1(i) = (f_nl(i) - f_min(i)) / denom;
    else
        h1(i) = 0;
    end
end
h2 = 1 - h1;

%% ---- Console report ------------------------------------
fprintf('\n--- T-S Activation Functions ---\n');
fprintf('  Partition of unity error : %.2e\n', max(abs(h1 + h2 - 1)));
fprintf('  h1 range : [%.4f, %.4f]\n', min(h1), max(h1));
fprintf('  h2 range : [%.4f, %.4f]\n', min(h2), max(h2));

p1 = k_nl * delta_max^2;
p2 = 0;
fprintf('  Rule 1 slope p1 = %g N/m\n', p1);
fprintf('  Rule 2 slope p2 = %g N/m\n', p2);

%% ---- Local state matrices ------------------------------
A1 = build_A(k1 + p1, mb, mw, b, k2);
A2 = build_A(k1 + p2, mb, mw, b, k2);

fprintf('  A1 (Rule 1 - large deflection):\n'); disp(A1);
fprintf('  A2 (Rule 2 - zero deflection):\n');  disp(A2);

%% ---- Plots (each in its own figure) --------------------
plot_h1h2     (delta, h1, h2);
plot_sector   (delta, f_nl, f_max, f_min);

end

%% ========================================================
%  LOCAL: A matrix
%% ========================================================
function A = build_A(k_eff, mb, mw, b, k2)
    A = [0,          1,        0,              0;
        -k_eff/mb,  -b/mb,    k_eff/mb,        b/mb;
         0,          0,        0,              1;
         k_eff/mw,   b/mw,  -(k_eff+k2)/mw, -b/mw];
end

%% ========================================================
%  LOCAL: Figure 1 — h1 alone
%% ========================================================

%% ========================================================
%  LOCAL: Figure 3 — h1 & h2 together (partition of unity)
%% ========================================================
function plot_h1h2(delta, h1, h2)

lw = 1.8; fs = 12; fst = 13;

figure('Name', 'T-S Activation Functions h1 & h2', 'Color', 'w', ...
       'Position', [180 420 620 340]);

plot(delta*100, h1, 'Color', [0.08 0.35 0.72], 'LineWidth', lw); hold on;
plot(delta*100, h2, 'Color', [0.75 0.18 0.10], 'LineWidth', lw, 'LineStyle', '--');
yline(0.5, 'k:', 'LineWidth', 0.8);
xline(0,   'k:', 'LineWidth', 0.8);
xlabel('Suspension deflection \delta = z_s - z_u  (cm)', ...
       'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Membership degree  h_i(\delta)', ...
       'FontSize', fs, 'FontName', 'Times New Roman');
title('T-S Activation Functions  h_1 & h_2  (Partition of Unity)', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend('h_1(\delta) — Rule 1', 'h_2(\delta) — Rule 2', ...
       'Location', 'north', 'FontSize', fs-1, 'FontName', 'Times New Roman');
ylim([-0.05 1.15]); grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits','centimeters','PaperSize',[16 9],'PaperPosition',[0 0 16 9]);
drawnow;
end

%% ========================================================
%  LOCAL: Figure 4 — Sector nonlinearity decomposition
%% ========================================================
function plot_sector(delta, f_nl, f_max, f_min)

lw = 1.8; fs = 12; fst = 13;

figure('Name', 'Sector Nonlinearity Decomposition', 'Color', 'w', ...
       'Position', [220 380 620 340]);

plot(delta*100, f_nl,  'k',   'LineWidth', lw);   hold on;
plot(delta*100, f_max, 'b--', 'LineWidth', 1.4);
plot(delta*100, f_min, 'r--', 'LineWidth', 1.4);
xlabel('Suspension deflection \delta  (cm)', ...
       'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Nonlinear spring force  f(\delta)  (N)', ...
       'FontSize', fs, 'FontName', 'Times New Roman');
title('Sector Nonlinearity — Bounding of  k_{nl}\delta^3', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend('f(\delta) = k_{nl}\delta^3', ...
       'Upper bound  f_{max}', ...
       'Lower bound  f_{min} = 0', ...
       'Location', 'northwest', 'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits','centimeters','PaperSize',[16 9],'PaperPosition',[0 0 16 9]);
drawnow;
end