%% ============================================================
%  Plot: Control Force u vs u_saturation
%  Quarter-Car T-S H-inf PDC Controller
%  Run AFTER quarter_car_sat_v4.m (variables must be in workspace)
%% ============================================================

% ---- If workspace is empty, re-run the simulation ----
if ~exist('u_ctrl','var') || ~exist('u_sat_v','var')
    error('Run quarter_car_sat_v4.m first to generate u_ctrl and u_sat_v');
end

%% ============================================================
%  FIGURE 1 — u vs u_sat (Main Plot)
%% ============================================================
figure('Name','Control Force: u vs u\_sat',...
       'NumberTitle','off',...
       'Position',[100 100 900 500],...
       'Color','white');

ax = axes;
hold on; grid on; box on;

% --- Shaded saturation zones ---
patch([t(1) t(end) t(end) t(1)], [u_max  u_max  u_max+200  u_max+200], ...
      [1 0.85 0.85], 'EdgeColor','none','FaceAlpha',0.4);
patch([t(1) t(end) t(end) t(1)], [u_min  u_min  u_min-200  u_min-200], ...
      [1 0.85 0.85], 'EdgeColor','none','FaceAlpha',0.4);

% --- Saturation limit lines ---
yline(u_max, 'r:', 'LineWidth', 1.5, 'Label', '+u_{max} = +1500 N', ...
      'LabelHorizontalAlignment','left','FontSize',10);
yline(u_min, 'r:', 'LineWidth', 1.5, 'Label', '-u_{max} = -1500 N', ...
      'LabelHorizontalAlignment','left','FontSize',10);
yline(0, 'k-', 'LineWidth', 0.5, 'Alpha', 0.3);

% --- u before saturation ---
p1 = plot(t, u_ctrl, 'b--', 'LineWidth', 1.8, 'DisplayName', 'u(t)  — before saturation');

% --- u after saturation ---
p2 = plot(t, u_sat_v, 'r',  'LineWidth', 2.0, 'DisplayName', 'u_{sat}(t) — applied force');

% --- Axes labels & title ---
xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Force (N)', 'FontSize', 12, 'FontWeight', 'bold');
title('Actuator Force: u(t) vs u_{sat}(t)', 'FontSize', 13, 'FontWeight', 'bold');
legend([p1 p2], 'Location', 'best', 'FontSize', 11);

% --- Axis limits ---
y_range = max(abs(u_ctrl)) * 1.3;
ylim([-max(y_range, u_max*1.2)  max(y_range, u_max*1.2)]);
xlim([t(1) t(end)]);

ax.FontSize = 11;
ax.GridAlpha = 0.3;

%% ============================================================
%  FIGURE 2 — Difference (u - u_sat) = Dead-Zone signal psi(u)
%% ============================================================
figure('Name','Dead-Zone Signal psi(u)',...
       'NumberTitle','off',...
       'Position',[100 650 900 300],...
       'Color','white');

psi_u = u_ctrl - u_sat_v;   % dead-zone function psi(u) = u - sat(u)

hold on; grid on; box on;
area(t, psi_u, 'FaceColor', [0.9 0.6 0.1], 'FaceAlpha', 0.5, ...
     'EdgeColor', [0.8 0.4 0], 'LineWidth', 1.2);
yline(0, 'k-', 'LineWidth', 0.8);

xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('\psi(u) = u - u_{sat}  (N)', 'FontSize', 12);
title('Dead-Zone Function \psi(u) = u(t) - u_{sat}(t)', 'FontSize', 13, 'FontWeight', 'bold');
grid on;

n_sat = sum(abs(u_ctrl) > u_max);
text(0.98, 0.9, sprintf('Saturation events: %d', n_sat), ...
     'Units','normalized','HorizontalAlignment','right',...
     'FontSize',11,'Color','r','FontWeight','bold');

%% ============================================================
%  FIGURE 3 — Combined: 3 subplots (publication style)
%% ============================================================
figure('Name','Complete Saturation Analysis',...
       'NumberTitle','off',...
       'Position',[1020 100 700 750],...
       'Color','white');

% --- Subplot 1: u and u_sat ---
subplot(3,1,1)
hold on; grid on; box on;
plot(t, u_ctrl,  'b--', 'LineWidth', 1.8, 'DisplayName', 'u(t)');
plot(t, u_sat_v, 'r',   'LineWidth', 2.0, 'DisplayName', 'u_{sat}(t)');
yline( u_max, 'k:', 'LineWidth', 1.5);
yline( u_min, 'k:', 'LineWidth', 1.5);
ylabel('Force (N)', 'FontSize', 11);
title('(a)  Control Force u(t) and Saturated Force u_{sat}(t)', 'FontSize', 11);
legend('Location','northeast','FontSize',10);
ylim([-u_max*1.3  u_max*1.3]);
xlim([t(1) t(end)]);

% --- Subplot 2: Dead-zone psi(u) ---
subplot(3,1,2)
hold on; grid on; box on;
area(t, psi_u, 'FaceColor',[0.9 0.6 0.1],'FaceAlpha',0.5,...
     'EdgeColor',[0.7 0.3 0],'LineWidth',1.2);
yline(0,'k-','LineWidth',0.8);
ylabel('\psi(u)  (N)', 'FontSize', 11);
title('(b)  Dead-Zone Signal \psi(u) = u(t) - u_{sat}(t)', 'FontSize', 11);
xlim([t(1) t(end)]);

% --- Subplot 3: Road disturbance ---
subplot(3,1,3)
hold on; grid on; box on;
plot(t, zr*100, 'k', 'LineWidth', 1.8);
xlabel('Time (s)', 'FontSize', 11);
ylabel('Height (cm)', 'FontSize', 11);
title('(c)  Road Disturbance z_r(t) — Speed Bump 5 cm', 'FontSize', 11);
xlim([t(1) t(end)]);

sgtitle('Actuator Saturation Analysis — Quarter-Car H\infty PDC',...
        'FontSize',13,'FontWeight','bold');

%% ============================================================
%  PRINT SUMMARY
%% ============================================================
fprintf('\n========== Saturation Summary ==========\n');
fprintf('u_max (limit)         = %.0f N\n', u_max);
fprintf('Max |u(t)| computed   = %.2f N  (%.1f%% of limit)\n', ...
        max(abs(u_ctrl)), max(abs(u_ctrl))/u_max*100);
fprintf('Max |u_sat(t)|        = %.2f N\n', max(abs(u_sat_v)));
fprintf('Max |psi(u)|          = %.2f N\n', max(abs(psi_u)));
fprintf('Saturation events     = %d\n', n_sat);
fprintf('=========================================\n\n');