%% ========================================================
%  FUNCTION: checkSystemProperties.m
%  Checks: Controllability, Observability, Eigenvalues,
%          and Stability for T-S subsystems (A1, A2)
%  Quarter-Car Active Suspension System
%% ========================================================
%% ---- Parameters ----------------------------------------

function checkSystemProperties()

%% ---- Parameters ----------------------------------------
global mb mw k1 k_nl b k2 

delta_max = 0.1;
pmin = k1;
pmax = k1 + k_nl * delta_max^2;

%% ---- System Matrices -----------------------------------
A1 = [ 0          1        0               0;
      -pmin/mb   -b/mb     pmin/mb         b/mb;
       0          0        0               1;
       pmin/mw    b/mw    -(pmin+k2)/mw   -b/mw ];

A2 = [ 0          1        0               0;
      -pmax/mb   -b/mb     pmax/mb         b/mb;
       0          0        0               1;
       pmax/mw    b/mw    -(pmax+k2)/mw   -b/mw ];

B  = [0;  1/mb; 0; -1/mw];    % Control input
C  = [1   0    0    0   ;      % Output: Zs
      0   0    1    0   ];     % Output: Zu

n = size(A1, 1);   % number of states = 4

%% ========================================================
fprintf('\n');
fprintf('=========================================================\n');
fprintf('       SYSTEM PROPERTIES - Quarter-Car T-S Model        \n');
fprintf('=========================================================\n');

%% ---- Loop over both subsystems -------------------------
A_list   = {A1, A2};
names    = {'Subsystem 1  (pmin = k1)', 'Subsystem 2  (pmax = k1 + k_nl*dmax^2)'};

for s = 1:2
    A = A_list{s};

    fprintf('\n---------------------------------------------------------\n');
    fprintf('  %s\n', names{s});
    fprintf('---------------------------------------------------------\n');

    %% ---- 1. Eigenvalues --------------------------------
    ev = eig(A);
    fprintf('\n  [1] Eigenvalues of A%d:\n', s);
    for i = 1:n
        re = real(ev(i));
        im = imag(ev(i));
        if im >= 0
            fprintf('       lambda_%d = %+.4f  %+.4fi\n', i, re, im);
        else
            fprintf('       lambda_%d = %+.4f  %.4fi\n',  i, re, im);
        end
    end

    %% ---- 2. Stability ----------------------------------
    fprintf('\n  [2] Stability of A%d:\n', s);
    if all(real(ev) < 0)
        fprintf('       >> STABLE  (all real parts < 0)\n');
    else
        unstable_idx = find(real(ev) >= 0);
        fprintf('       >> UNSTABLE  (%d eigenvalue(s) with real part >= 0)\n', ...
                length(unstable_idx));
        for i = 1:length(unstable_idx)
            fprintf('          eigenvalue %d = %+.4f %+.4fi\n', ...
                    unstable_idx(i), real(ev(unstable_idx(i))), imag(ev(unstable_idx(i))));
        end
    end

    %% ---- 3. Controllability ----------------------------
    Co = ctrb(A, B);
    rank_Co = rank(Co);
    fprintf('\n  [3] Controllability of (A%d, B):\n', s);
    fprintf('       Controllability matrix rank = %d  (required: %d)\n', rank_Co, n);
    if rank_Co == n
        fprintf('       >> CONTROLLABLE\n');
    else
        fprintf('       >> NOT CONTROLLABLE  (rank deficient by %d)\n', n - rank_Co);
    end

    %% ---- 4. Observability ------------------------------
    Ob = obsv(A, C);
    rank_Ob = rank(Ob);
    fprintf('\n  [4] Observability of (A%d, C):\n', s);
    fprintf('       Observability matrix rank  = %d  (required: %d)\n', rank_Ob, n);
    if rank_Ob == n
        fprintf('       >> OBSERVABLE\n');
    else
        fprintf('       >> NOT OBSERVABLE  (rank deficient by %d)\n', n - rank_Ob);
    end

end

%% ---- Summary Table -------------------------------------
fprintf('\n=========================================================\n');
fprintf('  SUMMARY\n');
fprintf('=========================================================\n');
fprintf('  %-30s  %-12s  %-12s\n', 'Property', 'Subsystem 1', 'Subsystem 2');
fprintf('  %s\n', repmat('-',1,58));

props  = {'Stable','Controllable','Observable'};
checks = zeros(2,3);

for s = 1:2
    A  = A_list{s};
    ev = eig(A);
    checks(s,1) = all(real(ev) < 0);
    checks(s,2) = (rank(ctrb(A,B)) == n);
    checks(s,3) = (rank(obsv(A,C)) == n);
end

for p = 1:3
    r1 = result_str(checks(1,p));
    r2 = result_str(checks(2,p));
    fprintf('  %-30s  %-12s  %-12s\n', props{p}, r1, r2);
end

fprintf('=========================================================\n\n');

end

%% ---- Helper: result string -----------------------------
function s = result_str(val)
    if val
        s = 'YES';
    else
        s = 'NO';
    end
end