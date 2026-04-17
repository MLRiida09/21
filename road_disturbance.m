function d = road_bump(t)

    % Parameters
    h  = 0.04;   % bump height [m]
    L  = 1;      % bump length [m]
    v  = 10;     % vehicle speed [m/s]
    t0 = 1;     % start time [s]

    d = 0;

    if t >= t0 && t <= t0 + L/v
        d = (h/2) * (1 - cos(2*pi*v/L * (t - t0)));
    end
end