%% ========================================================================
%  01_generacion_senal_referencia.m
%  Marco de Instrumentación Virtual MATLAB-Python
%  
%  Descripción: Genera el vector de corriente poliharmónica pura y emula
%               la adquisición a través del sensor de efecto Hall y ADC de
%               12 bits. Exporta los resultados a formato CSV para Python.
%  Autores: D. H. Cárdenas-Villacrés, C. Chávez-Cordova, O. Astudillo-Astudillo
%  Universidad Politécnica Salesiana - Sede Guayaquil
% ========================================================================

clear; clc; close all;

%% 1. Configuración de Parámetros Globales
Vcc = 3.3;             % Voltaje de alimentación [V]
S = 0.045;             % Sensibilidad estática del sensor Hall [V/A]
B = 12;                % Resolución del convertidor ADC [bits]
N_levels = 2^B - 1;    % 4095 niveles discretos
q = Vcc / N_levels;    % Paso de cuantización: 0.8058 mV

sigma_noise = 0.012;   % Desviación estándar del ruido analógico [V]
fs = 10000;            % Frecuencia de muestreo [Hz]
f1 = 60;               % Frecuencia fundamental de red [Hz]
T_window = 0.1667;     % Ventana de observación: 10 ciclos completos
t = 0:(1/fs):(T_window - 1/fs); % Vector de tiempo (N = 1668 muestras)

%% 2. Generación de la Señal Poliharmónica Pura
% Modelo analítico: Fundamental (10A, 60Hz), 3ro (3A, 180Hz), 5to (1.5A, 300Hz)
I1 = 10.0; I3 = 3.0; I5 = 1.5;
i_theoretical = I1*sin(2*pi*f1*t) + I3*sin(2*pi*3*f1*t) + I5*sin(2*pi*5*f1*t);

%% 3. Transducción de Hardware y Ruido AWGN (Canal Analógico)
rng(42); % Fijar semilla pseudoaleatoria para reproducibilidad
V_sensor_pure = (Vcc / 2) + S * i_theoretical;
noise_vector = normrnd(0, sigma_noise, size(V_sensor_pure));
V_sensor_noisy = V_sensor_pure + noise_vector;

%% 4. Cuantización Espacial ADC de 12 bits
V_clipped = min(max(V_sensor_noisy, 0), Vcc); % Recorte por saturación
ADC_code = round((V_clipped / Vcc) * N_levels);

%% 5. Exportación de Datos a CSV para Interoperabilidad con Python
dataset = table(t', i_theoretical', V_sensor_noisy', ADC_code', ...
    'VariableNames', {'timestamp_s', 'i_pure_A', 'V_sensor_noisy_V', 'ADC_code_12bit'});

output_filename = 'dataset_simulacion_senales.csv';
writetable(dataset, output_filename);

fprintf('=======================================================\n');
fprintf('  ETAPA MATLAB COMPLETADA EXITOSAMENTE\n');
fprintf('=======================================================\n');
fprintf('Paso de cuantización q         : %.4f mV\n', q * 1000);
fprintf('Total de muestras exportadas   : %d\n', length(t));
fprintf('Archivo generado               : %s\n', output_filename);
fprintf('=======================================================\n');