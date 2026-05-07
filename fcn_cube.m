function y = fcn_cube(u)
% ========================================================
%  EXTERNAL FUNCTION: Cubic Nonlinear Term
%  --------------------------------------------------------
%  Input  : u  --> delta = x2 - x1  (relative deflection)
%  Output : y  --> u^3
% ========================================================

    y = u.^3;

end