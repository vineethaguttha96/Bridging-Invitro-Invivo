function dydt = pdgf_model(y, t, k1, k2, k3, k4, k5, k6, k7, Slope, Intercept, Kf_1, K11, K_11, K12, d, b, c, Kmmp, Ktimp, k_deg_collagen)

    % Species (Variables)
    P = y(1);             % Free PDGF
    PB = y(2);            % Free PDGFR
    PB_C = y(3);          % Surface Complex
    p_PB_C = y(4);        % Phosphorylated Complex
    I_p_PB_C = y(5);      % Internalized Complex
    PTP = y(6);           % Phosphatase (static here)
    recycling = y(7);     % Recycled receptor
    PB_C_deg = y(8);      % Degraded receptor
    I_AKT = y(9);         % Inactive AKT
    I_p_AKT = y(10);      % Phosphorylated (active) AKT
    I_Collagenprod = y(11); % Collagen production intermediate
    I_Collagen = y(12);   % Final Collagen protein
    I_p_AKT_deg = y(13);  % Degraded phosphorylated AKT
    I_MMP = y(14);        % MMP production
    I_TIMP = y(15);       % TIMP production

    % Initialize derivative vector
    dydt = zeros(15,1);

    % PDGF signaling dynamics
    dydt(1) = (-k1 * P * PB) + (k2 * PB_C);                  % Free PDGF
    dydt(2) = (-k1 * P * PB) + (k2 * PB_C);                  % Free Receptor
    dydt(3) = (k1 * P * PB) - (k2 * PB_C) - (k3 * PB_C);      % Surface Complex
    dydt(4) = (k3 * PB_C) - (k4 * p_PB_C * PTP) - (k5 * p_PB_C); % Phosphorylated Complex
    dydt(5) = (k5 * p_PB_C) - (k6 * I_p_PB_C) - (k7 * I_p_PB_C); % Internalized Complex
    dydt(6) = 0;                                              % PTP constant
    dydt(7) = (k6 * I_p_PB_C);                                % Recycling
    dydt(8) = (k7 * I_p_PB_C);                                % Degraded receptor

    % AKT phosphorylation dynamics
    dydt(9) = (K_11 * I_p_AKT) - (d * K_11 * b * I_p_PB_C);    % Inactive AKT
    dydt(10) = -(K_11 * I_p_AKT) + (K11 * I_AKT) - (K12 * I_p_AKT); % Phosphorylated AKT

 
  % --- Collagen production and degradation dynamics ---
    collagen_production = (Intercept + Slope * I_p_AKT);  
    collagen_degradation = k_deg_collagen * (I_MMP ./ (I_TIMP + 1)) .* I_Collagen;

    dydt(11) = collagen_production - Kf_1 * I_Collagenprod;  
    dydt(12) = Kf_1 * I_Collagenprod - collagen_degradation;


    % Degraded pAKT
    dydt(13) = K12 * I_p_AKT;    % Degraded pAKT
    
    dydt(14) = Kmmp * I_p_AKT;   % MMP increases with AKT
    dydt(15) = Ktimp * I_p_AKT;  % TIMP increases with AKT
end
