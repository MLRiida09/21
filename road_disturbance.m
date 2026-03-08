function d = road_disturbance(t)
% ========================================================
%  Road Disturbance Function - Double Bump
%  --------------------------------------------------------
%  d = y1*(1 - cos(4*pi*t)),   0   <= t <= 0.5
%  d = y2*(1 - cos(4*pi*t)),   2   <= t <= 2.5
%  d = 0,                       otherwise
% ========================================================
    y1 = 0.03;    % First  bump height  [m]
    y2 = 0.05;    % Second bump height  [m]

    if t >= 0 && t <= 0.5
        d = y1 * (1 - cos(4*pi*t));
    elseif t >= 2 && t <= 2.5
        d = y2 * (1 - cos(4*pi*t));
    else
        d = 0;
    end
end
