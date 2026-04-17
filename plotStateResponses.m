%% ========================================================
%  FUNCTION: plotStateResponses
%  Open-Loop Response - Nonlinear Quarter-Car Model
%% ========================================================
function plotStateResponses()
global t x1 x2

delta = x1 - x2;   % Suspension deflection: Zs - Zu

%% ---- Common Style --------------------------------------
lw    = 1.8;
fs    = 12;
fst   = 13;
col   = [0.08 0.35 0.72];
fig_w = 620;
fig_h = 340;

%% ---- Figure 1: Sprung Mass Displacement Zs -------------
figure('Name', 'Zs - Sprung Mass Displacement', 'Color', 'w', ...
       'Position', [130 400 fig_w fig_h]);

h1 = plot(t, x1, 'Color', col, 'LineWidth', lw);
xlabel('Time (s)',         'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Displacement (m)', 'FontSize', fs, 'FontName', 'Times New Roman');
title('Sprung Mass Vertical Displacement Z_s', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend(h1, {'Nonlinear Model'}, 'Location', 'best', ...
       'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits', 'centimeters', 'PaperSize', [16 9], ...
         'PaperPosition', [0 0 16 9]);
drawnow;

%% ---- Figure 2: Unsprung Mass Displacement Zu -----------
figure('Name', 'Zu - Unsprung Mass Displacement', 'Color', 'w', ...
       'Position', [170 340 fig_w fig_h]);

h2 = plot(t, x2, 'Color', col, 'LineWidth', lw);
xlabel('Time (s)',         'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Displacement (m)', 'FontSize', fs, 'FontName', 'Times New Roman');
title('Unsprung Mass Vertical Displacement Z_u', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend(h2, {'Nonlinear Model'}, 'Location', 'best', ...
       'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits', 'centimeters', 'PaperSize', [16 9], ...
         'PaperPosition', [0 0 16 9]);
drawnow;

%% ---- Figure 3: Suspension Deflection (Zs - Zu) ---------
figure('Name', 'Suspension Deflection Zs-Zu', 'Color', 'w', ...
       'Position', [210 280 fig_w fig_h]);

h3 = plot(t, delta, 'Color', col, 'LineWidth', lw);
xlabel('Time (s)',         'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('Displacement (m)', 'FontSize', fs, 'FontName', 'Times New Roman');
title('Suspension Deflection (Z_s - Z_u)', ...
      'FontSize', fst, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
legend(h3, {'Nonlinear Model'}, 'Location', 'best', ...
       'FontSize', fs-1, 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontSize', fs, 'FontName', 'Times New Roman', 'Box', 'on');
set(gcf, 'PaperUnits', 'centimeters', 'PaperSize', [16 9], ...
         'PaperPosition', [0 0 16 9]);
drawnow;

end