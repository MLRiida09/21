global mb mw k1 k_nl b k2 fa A B w

%==================== System Matrices ======================================

A = [0        1        0            0;
    -k1/mb   -b/mb    k1/mb       b/mb;
     0        0        0            1;
     k1/mw    b/mw  -(k1+k2)/mw  -b/mw];

B = [0 0 ; 1/mb 0; 0 0; -1/mw k2/mw];

w = [0; 0; 0; k2/mw]; 

disp('-----------------------------------');

% Display matrices
disp('System matrix A:');
disp(A);

disp('Input matrix B:');
disp(B);

disp('Disturbance vector w:');
disp(w);