%% ========================================================
%  FILE: matrices.m
%  Build state-space matrices for Quarter-Car model
%% ========================================================

global mb mw k1 k2 b A B w

%% ---- State Matrix A --------------------------------
A = [0        1        0            0;
    -k1/mb   -b/mb    k1/mb       b/mb;
     0        0        0            1;
     k1/mw    b/mw  -(k1+k2)/mw  -b/mw];

%% ---- Input Matrix B --------------------------------
B = [0      0;
     1/mb   0;
     0      0;
    -1/mw   k2/mw];

%% ---- Disturbance Vector w --------------------------
w = [0; 0; 0; k2/mw];

%% ---- Display ---------------------------------------
disp('-----------------------------------');
disp('System matrix A:');     disp(A);
disp('Input matrix B:');      disp(B);
disp('Disturbance vector w:'); disp(w);