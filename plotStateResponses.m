%% ========================================================
%  FUNCTION: plotStateResponses
%  Figure 2.7 - Réponse de système de suspension en 
%  boucle ouverte, cas modèle quart de véhicule.
%% ========================================================

function plotStateResponses()

global t x1 x2 mode_str

%% ---- Débattement -----------------------------------
delta = x1 - x2;   % Zs - Zu

%% ---- Figure ----------------------------------------
figure('Name', 'Reponse Boucle Ouverte - Quart de Vehicule', ...
       'Color', 'w', 'Position', [100 50 700 850]);

%-- 1: Déplacement vertical de la caisse Zs
subplot(3,1,1);
plot(t, x1, 'b', 'LineWidth', 1.5);
title('déplacement vertical de la caisse Zs');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('non linéaire', 'Location', 'best');
grid on;

%-- 2: Déplacement vertical de la roue Zu
subplot(3,1,2);
plot(t, x2, 'b', 'LineWidth', 1.5);
title('déplacement vertical de la roue Zu');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('non linéaire', 'Location', 'best');
grid on;

%-- 3: Débattement de la suspension (Zs - Zu)
subplot(3,1,3);
plot(t, delta, 'b', 'LineWidth', 1.5);
title('débattement de la suspension (Z-Zu)');
xlabel('temps(s)'); ylabel('déplacement(m)');
legend('non linéaire', 'Location', 'best');
grid on;

drawnow;
end