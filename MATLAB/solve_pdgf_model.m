
% initial conditions
y0 = [0.02, 0.001, 0, 0, 0, 0.01, 0, 0, 1, 0, 0, 0, 0, 0, 0];


tspan = [0 100];

% Define parameters
k1 = 1;     % association rate
k2 = 0.01;  % dissociation rate
k3 = 0.002;   % phosphorylation of complex
k4 = 0.00002;   % dephosphorylation of complex
k5 = 0.09;   % recycling rate
k6 = 0.010; %lysosomal degradation rate
k7 = 0.0005;
b = 1;
d = 1;
c = 1;
% MMP/TIMP production parameters
Kmmp = 20;   % strength of MMP production
Ktimp = 5;  % strength of TIMP production


% AKT parameters
K11 = 0.5;    % Phosphorylation of AKT by p_PB_C
K_11 = 0.005;  % Dephosphorylation of AKT
K12 = 0.0005;  % Degradation of pAKT

% Collagen production parameters
Slope = 0.5;        % Sensitivity of collagen production to pAKT
Intercept = 0.01;   % Baseline collagen production
Kf_1 = 0.01;        % Rate of collagen intermediate conversion
k_deg_collagen = 0.01; % Collagen degradation by MMP


%Define the ODE function
odefun = @(t, y) pdgf_model(y, t, k1, k2, k3, k4, k5, k6, k7, Slope, Intercept, Kf_1, K11, K_11, K12, d, b, c, Kmmp, Ktimp, k_deg_collagen);
[t, y] = ode45(odefun, tspan, y0);

% Calculate collagen degradation rate over time
degradation_rate = k_deg_collagen * (y(:,14) ./ (y(:,15) + 1)) .* y(:,12);


% Collagen over time
figure;
plot(t, y(:,12), 'b-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Collagen (M)');
title('Collagen Concentration');
grid on;
print('collagen over time','-dpng');
%%
% MMP over time
figure;
plot(t, y(:,14), 'r-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('MMP (M)');
title('MMP Concentration');
grid on;
print('MMP','-dpng');

%TIMP over time
figure;
plot(t, y(:,15), 'g-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('TIMP (M)');
title('TIMP Concentration');
grid on;
print('TIMP','-dpng');

% Collagen degradation rate over time
figure;
plot(t, degradation_rate, 'k-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Degradation Rate (M/min)');
title('Collagen Degradation Rate');
grid on;
print('collagen degradation over time','-dpng');


% Plot Free PDGF (P)
figure;
plot(t, y(:,1), 'b-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Free PDGF (P)');
legend('Free PDGF');
grid on;
print('PDGF','-dpng');

% Plot Free PDGFR² (PB)
figure;
plot(t, y(:,2), 'g--', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Free PDGFR² (PB)');
legend('Free PDGFR²');
grid on;
print('PDGFR','-dpng');


% Plot Surface Complex (PB_C)
figure;
plot(t, y(:,3), 'k-.', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Surface Complex (PB_C)');
legend('Surface Complex');
grid on;
print('PDGFRB complex','-dpng');


figure;
plot(t, y(:,4), 'm-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Phosphorylated Surface Complex (p\_PB\_C)');
legend('Phosphorylated Surface Complex');
grid on;
print('p-PDGFRB complex','-dpng');

% Plot Internalized Complex (I_p_PB_C)
figure;
plot(t, y(:,5), 'r:', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Internalized Complex (I\_p\_PB\_C)');
legend('Internalized Complex');
grid on;
print('PDGFRB - internalization','-dpng');

% Plot Degradation (recycling/degradation species)
figure;
plot(t, y(:,7), 'm:', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Recycling');
legend('Recycling');
grid on;
print('PDGF-recycling','-dpng');

% Plot phosphorylated AKT
figure;
plot(t, y(:,10), 'm-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Phosphorylated AKT (I_p_AKT)');
legend('pAKT');
grid on;
print('p-AKT','-dpng');

%%
%Alzheimer's disease condition
% initial conditions
y0 = [0.002, 0.00001, 0, 0, 0, 0.01, 0, 0, 1, 0, 0, 0, 0, 0, 0];

tspan = [0 100];

% Define Alzheimer's parameters
k1 = 0.5;      % PDGF association rate reduced
k2 = 0.01;     % dissociation rate (same)
k3 = 0.001;    % phosphorylation of complex reduced
k4 = 0.00002;  % dephosphorylation (same)
k5 = 0.09;     % recycling rate (same)
k6 = 0.010;    % lysosomal degradation rate (same)
k7 = 0.0005;   % degradation rate (same)
b = 1;
d = 1;
c = 1;

% MMP/TIMP production parameters for AD
Kmmp = 40;    % MMP production increased
Ktimp = 0.1;    % TIMP production decreased

% AKT parameters for AD
K11 = 0.01;    % AKT phosphorylation reduced
K_11 = 0.005; % dephosphorylation of AKT (same)
K12 = 0.0005; % degradation of pAKT (same)

% Collagen production parameters
Slope = 0.5;         % Sensitivity to pAKT (same)
Intercept = 0.01;    % Baseline collagen production (same)
Kf_1 = 0.01;         % Collagen intermediate conversion (same)
k_deg_collagen = 0.2; % Collagen degradation increased in AD

% Define the ODE function
odefun = @(t, y) pdgf_model(y, t, k1, k2, k3, k4, k5, k6, k7, Slope, Intercept, Kf_1, K11, K_11, K12, d, b, c, Kmmp, Ktimp, k_deg_collagen);

[t, y] = ode45(odefun, tspan, y0);

% Calculate collagen degradation rate over time
degradation_rate = k_deg_collagen * (y(:,14) ./ (y(:,15) + 1)) .* y(:,12);


% Collagen over time
figure;
plot(t, y(:,12), 'b-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Collagen (M)');
title('Collagen Concentration (AD)');
grid on;
print('collagen over time-AD','-dpng');

% Collagen degradation rate over time
figure;
plot(t, degradation_rate, 'k-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Degradation Rate (M/min)');
title('Collagen Degradation Rate (AD)');
grid on;
print('collagen degradation over time-AD','-dpng');

% Free PDGFR² (PB)
figure;
plot(t, y(:,2), 'g--', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Free PDGFR² (PB) (AD)');
legend('Free PDGFR²');
grid on;
print('free PDGFR-AD','-dpng');

% MMP over time
figure;
plot(t, y(:,14), 'r-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('MMP (M)');
title('MMP Concentration (AD)');
grid on;
print('MMP-AD','-dpng');

% TIMP over time
figure;
plot(t, y(:,15), 'g-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('TIMP (M)');
title('TIMP Concentration (AD)');
grid on;
print('TIMP-AD','-dpng');


% Phosphorylated AKT (pAKT)
figure;
plot(t, y(:,10), 'm-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Phosphorylated AKT (I\\_p\\_AKT) (AD)');
legend('pAKT');
grid on;
print('p-AKT-AD','-dpng');

% Free PDGF (P)
figure;
plot(t, y(:,1), 'b-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Free PDGF (P) (AD)');
legend('Free PDGF');
grid on;
print('PDGF-AD','-dpng');

% Surface Complex (PB_C)
figure;
plot(t, y(:,3), 'k-.', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Surface Complex (PB_C) (AD)');
legend('Surface Complex');
grid on;
print('PDGFB complex-AD','-dpng');

% Phosphorylated Surface Complex (p_PB_C)
figure;
plot(t, y(:,4), 'm-', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Phosphorylated Surface Complex (p\\_PB\\_C) (AD)');
legend('Phosphorylated Surface Complex');
grid on;
print('p-PDGFB-complex-AD','-dpng');

% Internalized Complex (I_p_PB_C)
figure;
plot(t, y(:,5), 'r:', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Internalized Complex (I\\_p\\_PB\\_C) (AD)');
legend('Internalized Complex');
grid on;
print('PDGFB-Internalization-AD','-dpng');

% Recycling (Receptor recycling)
figure;
plot(t, y(:,7), 'm:', 'LineWidth', 2);
xlabel('Time (min)');
ylabel('Concentration (M)');
title('Recycling (AD)');
legend('Recycling');
grid on;
print('PDGF-recycling-AD','-dpng');



