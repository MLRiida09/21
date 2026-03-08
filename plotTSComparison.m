%% ========================================================
%  FUNCTION: plotTSComparison
%  Comparaison: Modèle non-linéaire original vs T-S Fuzzy
%% ========================================================
function plotTSComparison(t, X_nl, X_ts, zr)

% Extract states
x1_nl  = X_nl(1,:);   x1_ts  = X_ts(1,:);
x2_nl  = X_nl(3,:);   x2_ts  = X_ts(3,:);
d_nl   = x1_nl - x2_nl;
d_ts   = x1_ts - x2_ts;

%-- 1: Déplacement vertical de la caisse Zs
figure(1);
plot(t, x1_nl, 'b',  'LineWidth', 1.5); hold on;
plot(t, x1_ts, 'r--','LineWidth', 1.5); hold off;
title('déplacement vertical de la caisse Zs');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('non linéaire','T-S','Location','best');
grid on;

%-- 2: Déplacement vertical de la roue Zu
figure(2);
plot(t, x2_nl, 'b',  'LineWidth', 1.5); hold on;
plot(t, x2_ts, 'r--','LineWidth', 1.5); hold off;
title('déplacement vertical de la roue Zu');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('non linéaire','T-S','Location','best');
grid on;

%-- 3: Débattement de la suspension (Zs - Zu)
figure(3);
plot(t, d_nl, 'b',  'LineWidth', 1.5); hold on;
plot(t, d_ts, 'r--','LineWidth', 1.5); hold off;
title('débattement de la suspension (Zs-Zu)');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('non linéaire','T-S','Location','best');
grid on;

drawnow;
end