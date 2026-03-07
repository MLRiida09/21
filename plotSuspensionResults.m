function plotSuspensionResults()
global t x1 x1_dot x2 x2_dot Fa_value mode_str mb mw k1 k_nl b k2

% ??????
delta   = x2 - x1;
Fs      = k1*delta + k_nl.*delta.^3;
Fd      = b*(x2_dot - x1_dot);
x1_ddot = (Fs + Fd + Fa_value)/mb;
x2_ddot = (-Fs - Fd - Fa_value)/mw;
T       = t(end) - t(1);

% ????? ?????
zr = zeros(size(t));
for i = 1:length(t)
    zr(i) = road_disturbance(t(i));
end

% ??????? ??????
tire_defl  = x2 - zr;
susp_defl  = x1 - x2;

peak_acc       = max(abs(x1_ddot));
rms_acc        = sqrt(trapz(t, x1_ddot.^2) / T);
peak_tire      = max(abs(tire_defl)) * 1000;
rms_tire       = sqrt(trapz(t, tire_defl.^2) / T) * 1000;
peak_susp      = max(abs(susp_defl)) * 1000;
rms_susp       = sqrt(trapz(t, susp_defl.^2) / T) * 1000;
peak_fs        = max(abs(Fs));
rms_fs         = sqrt(trapz(t, Fs.^2) / T);
peak_tire_force= max(abs(k2 .* tire_defl));
dyn_ratio      = peak_tire_force / (mb * 9.81);

% ????? ???????
fprintf('\n=== Ride Comfort ===\n');
fprintf('  Peak acceleration : %.4f m/s^2\n', peak_acc);
fprintf('  RMS  acceleration : %.4f m/s^2\n', rms_acc);
fprintf('\n=== Road Holding ===\n');
fprintf('  Peak tire deflection  : %.4f mm\n', peak_tire);
fprintf('  RMS  tire deflection  : %.4f mm\n', rms_tire);
fprintf('  Peak tire force       : %.4f N\n',  peak_tire_force);
fprintf('  Dynamic load ratio    : %.4f\n',    dyn_ratio);
fprintf('\n=== Suspension Deflection ===\n');
fprintf('  Max suspension travel : %.4f mm\n', peak_susp);
fprintf('  RMS suspension defl   : %.4f mm\n', rms_susp);

%==========================================================
% FIGURE 1 - ?????? ???????
%==========================================================
figure('Name',['Open Loop - ' mode_str],'Color','w','Position',[100 50 1200 800]);
subplot(3,3,2); plot(t,x1*1000,'b','LineWidth',2);        title('Body Displacement (x1)');  xlabel('Time(s)'); ylabel('mm');    grid on;
subplot(3,3,3); plot(t,x2*1000,'r','LineWidth',2);        title('Wheel Displacement (x2)'); xlabel('Time(s)'); ylabel('mm');    grid on;
subplot(3,3,4); plot(t,x1_dot,'b','LineWidth',2);         title('Body Velocity');            xlabel('Time(s)'); ylabel('m/s');   grid on;
subplot(3,3,5); plot(t,x2_dot,'r','LineWidth',2);         title('Wheel Velocity');           xlabel('Time(s)'); ylabel('m/s');   grid on;
subplot(3,3,6); plot(t,delta*1000,'m','LineWidth',2);     title('Suspension Deflection');    xlabel('Time(s)'); ylabel('mm');    grid on;
subplot(3,3,7); plot(t,Fs,'g','LineWidth',2);             title('Spring Force');             xlabel('Time(s)'); ylabel('N');     grid on;
subplot(3,3,8); plot(t,x1_ddot,'b','LineWidth',2);        title('Body Acceleration');        xlabel('Time(s)'); ylabel('m/s^2'); grid on;
subplot(3,3,9); plot(t,x2_ddot,'r','LineWidth',2);        title('Wheel Acceleration');       xlabel('Time(s)'); ylabel('m/s^2'); grid on;
axes('Position',[0 0 1 1],'Visible','off');
text(0.5,0.99,['Nonlinear Quarter-Car | ' mode_str ' (Fa=' num2str(Fa_value) 'N)'],...
    'HorizontalAlignment','center','VerticalAlignment','top','FontSize',13,'FontWeight','bold');

%==========================================================
% FIGURE 2 - ?? ????? ?? ?????
%==========================================================
figure('Name','Performance vs Road','Color','w','Position',[150 80 1100 850]);

subplot(4,1,1);
plot(t, zr*1000,'k','LineWidth',1); hold on;
plot(t, x1_ddot,'b','LineWidth',2);
line([t(1) t(end)],[peak_acc peak_acc],'Color','r','LineStyle','--','LineWidth',1.5);
line([t(1) t(end)],[rms_acc  rms_acc], 'Color','m','LineStyle','-.','LineWidth',1.5);
title('Body Acceleration vs Road'); xlabel('Time(s)'); ylabel('m/s^2'); grid on;
legend('zr(mm)','x1 ddot',['Peak=' num2str(peak_acc,'%.3f')],['RMS=' num2str(rms_acc,'%.3f')],'Location','best');

subplot(4,1,2);
plot(t, zr*1000,'k','LineWidth',1); hold on;
plot(t, tire_defl*1000,'r','LineWidth',2);
line([t(1) t(end)],[peak_tire peak_tire],'Color','r','LineStyle','--','LineWidth',1.5);
line([t(1) t(end)],[rms_tire  rms_tire], 'Color','m','LineStyle','-.','LineWidth',1.5);
title('Tire Deflection vs Road'); xlabel('Time(s)'); ylabel('mm'); grid on;
legend('zr(mm)','Tire Defl',['Peak=' num2str(peak_tire,'%.3f')],['RMS=' num2str(rms_tire,'%.3f')],'Location','best');

subplot(4,1,3);
plot(t, zr*1000,'k','LineWidth',1); hold on;
plot(t, susp_defl*1000,'m','LineWidth',2);
line([t(1) t(end)],[peak_susp peak_susp],'Color','r','LineStyle','--','LineWidth',1.5);
line([t(1) t(end)],[rms_susp  rms_susp], 'Color','m','LineStyle','-.','LineWidth',1.5);
title('Suspension Deflection vs Road'); xlabel('Time(s)'); ylabel('mm'); grid on;
legend('zr(mm)','Susp Defl',['Peak=' num2str(peak_susp,'%.3f')],['RMS=' num2str(rms_susp,'%.3f')],'Location','best');

subplot(4,1,4);
plot(t, zr*1000,'k','LineWidth',1); hold on;
plot(t, Fs,'g','LineWidth',2);
line([t(1) t(end)],[peak_fs peak_fs],'Color','r','LineStyle','--','LineWidth',1.5);
line([t(1) t(end)],[rms_fs  rms_fs], 'Color','m','LineStyle','-.','LineWidth',1.5);
title('Spring Force vs Road'); xlabel('Time(s)'); ylabel('N'); grid on;
legend('zr(mm)','Fs',['Peak=' num2str(peak_fs,'%.1f')],['RMS=' num2str(rms_fs,'%.1f')],'Location','best');

axes('Position',[0 0 1 1],'Visible','off');
text(0.5,0.99,['Performance vs Road Disturbance | ' mode_str],...
    'HorizontalAlignment','center','VerticalAlignment','top','FontSize',13,'FontWeight','bold');

drawnow;
end