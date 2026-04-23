function plotTSComparison(tspan, X_nl, X_ts, zr)

%% ---- States ----------------------------------------
x1_nl = X_nl(1,:);   % Sprung mass
x2_nl = X_nl(3,:);   % Unsprung mass

x1_ts = X_ts(1,:);
x2_ts = X_ts(3,:);

delta_nl = x1_nl - x2_nl;
delta_ts = x1_ts - x2_ts;

error = abs(x1_nl - x1_ts);

lw = 1.8;

%% ---- Zs --------------------------------------------
figure;
plot(tspan, x1_nl, 'b', 'LineWidth', lw); hold on;
plot(tspan, x1_ts, 'r--', 'LineWidth', lw);
title('Sprung Mass Displacement Z_s');
xlabel('Time (s)');
ylabel('Displacement (m)');
legend('Nonlinear','T-S Fuzzy');
grid on;

%% ---- Zu --------------------------------------------
figure;
plot(tspan, x2_nl, 'b', 'LineWidth', lw); hold on;
plot(tspan, x2_ts, 'r--', 'LineWidth', lw);
title('Unsprung Mass Displacement Z_u');
xlabel('Time (s)');
ylabel('Displacement (m)');
legend('Nonlinear','T-S Fuzzy');
grid on;

%% ---- Deflection ------------------------------------
figure;
plot(tspan, delta_nl, 'b', 'LineWidth', lw); hold on;
plot(tspan, delta_ts, 'r--', 'LineWidth', lw);
title('Suspension Deflection (Z_s - Z_u)');
xlabel('Time (s)');
ylabel('Displacement (m)');
legend('Nonlinear','T-S Fuzzy');
grid on;



%% ---- Road ------------------------------------------
%% ---- Road ------------------------------------------
if nargin == 4
    figure;
    plot(tspan, zr, 'k', 'LineWidth', lw);
    title('Road Disturbance Profile');
    xlabel('Time (s)');
    ylabel('Road Profile (m)');
    xlim([0 2]);          % zoom in on the bump region (t0=1, ends at t0+L/v=1.1)
    ylim([-0.005 0.05]);  % tight around bump height (h=0.04m)
    grid on;
end

end