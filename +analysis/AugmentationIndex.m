function [AI, Paug, featuretimes] = AugmentationIndex(time, pres, varargin)
% Calculates augmentation index as described in [1]
% i.e. as deltaP / PP, where PP is pulse pressure
% deltaP is the augmentation pressure
% Inputs:
%   time: time vector
%   pres: pressure signal
%   (optional parameter-value inputs):
%   DoPlot: 1 (display a plot), 0 (nothing)
%   FootMethod: 'Minimum' (the foot is found as the minimum point in the first 1/3 of the signal)
%               otherwise a 'Method' in BeatOnsetDetect.m
%   InflectionPointProminenceThreshold: 0 (default), increase (with caution) if it is picking minor fluctuations instead of the real inflection point
%   DerivativeWindowTime: 0.08 seconds (default), change only if results are unreliable (e.g. because of noisy signal)
% Outputs:
%   AI: Augmentation Index
%   Paug: Augmentation Pressure
%   featuretimes: featuretimes.shoulder, featuretimes.inflection, featuretimes.enddiastole, featuretimes.maxP
% The inflection point is determined via the peak second derivative (as used in the SphygmoCor, see [1])
% [1] Nichols WW and O'Rourke MF. McDonald's blood flow in arteries: theoretical, experimental, and clinical principles: CRC Press, 2011.
% [2] Kelly R, Hayward C, Avolio A, and O'Rourke M. Noninvasive determination of age-related changes in the human arterial pulse. Circulation 80: 1652-1659, 1989.
% Author: Jonathan Mynard, jonathan.mynard@mcri.edu.au

p = inputParser;
defaultDoPlot = 0;
defaultFootMethod = 'Minimum';
defaultInflectionPointProminenceThreshold = 0;
defaultDerivativeWindowTime =0.08;

addOptional(p,'DoPlot',defaultDoPlot,@isnumeric);
addOptional(p,'FootMethod',defaultFootMethod,@ischar);
addOptional(p,'InflectionPointProminenceThreshold',defaultInflectionPointProminenceThreshold,@isnumeric);
addOptional(p,'DerivativeWindowTime',defaultDerivativeWindowTime,@isnumeric);

parse(p,varargin{:});

params.DoPlot = p.Results.DoPlot;
params.FootMethod = p.Results.FootMethod;
params.InflectionPointProminenceThreshold = p.Results.InflectionPointProminenceThreshold;
params.DerivativeWindowTime = p.Results.DerivativeWindowTime;

dt = time(2)-time(1);
derwindow = round(params.DerivativeWindowTime/dt); 
if iseven(derwindow)
    derwindow = derwindow + 1;
end
derpolyorder = 4;

%% Calculate the fourth and second derivatives
ddt4 = analysis.derivative(pres, derwindow, derpolyorder, 4);
ddt2 = analysis.derivative(pres, derwindow, derpolyorder, 2);

%% Detect the location of the pressure foot and of maximum pressure
if strcmp(params.FootMethod, 'Minimum')
    [minP, minI] = min(pres(1:round(length(pres)/3)));  % Assume that the foot is defined as the minimum pressure in the first third of the signal
    enddiastoleT = time(minI);
else
    minI = analysis.BeatOnsetDetect(pres, 'Method', params.FootMethod, 'SingleBeat', 1);
    minP = interp1(1:length(pres), pres, minI);
    enddiastoleT = interp1(1:length(time), time, minI);
end
[maxP, maxI] = max(pres);  % Assume that the foot is defined as the minimum pressure in the first third of the signal
featuretimes.enddiastole = enddiastoleT;
featuretimes.maxP = time(maxI);

%% Find shoulder point as the first negative zero crossing in ddt4 after diastolic pressure
shoulderI = find(ddt4(2:end) < 0 & ddt4(1:end-1) >= 0) + 1;
shoulderI(shoulderI < minI) = [];
shoulderI = shoulderI(1);
featuretimes.shoulder = time(shoulderI);

%% Find inflection point as the first peak in ddt2 after diastolic pressure
[~, pksI,~,prom] = findpeaks(ddt2);
pksI(prom < max(prom)*params.InflectionPointProminenceThreshold) = [];
pksI(pksI < minI) = [];  % Exclude peaks occurring before end-diastole
pksI(pres(pksI) < (minP + 0.3*(maxP-minP))) = [];  % Exclude peaks occurring too early in systole (before pressure has risen by 30% of pulse)

% Sometimes no inflection point is discovered. Need to deal with that.
% This is not meant to be a complete solution.
if length(pksI) < 1
    AI = NaN;
    Paug = NaN;
    featuretimes = NaN;
    return
end

inflectI = pksI(1); 
featuretimes.inflection = time(inflectI);

%% Calculate the pressure augmentation
Paug = pres(maxI) - pres(inflectI);
if inflectI > maxI
   Paug = -Paug;    % Negative augmentation index 
end

%% Calculate augmentation index
PP = pres(maxI) - minP;  % Pulse pressure

AI = 100*Paug/PP;    % Augmentation Index = 100% x Augmentation pressure / Pulse pressure

%% Plot for user feedback
if params.DoPlot
    figure; 
    subplot(2,1,1); hold on;
    plot(pres, 'k', 'LineWidth', 1.7);
    plot([minI, minI], [minP, pres(maxI)]);
    plot([maxI, maxI], [minP, pres(maxI)]);
    plot([inflectI, inflectI], [minP, pres(maxI)], 'r');
    plot([shoulderI, shoulderI], [minP, pres(maxI)], 'g');
    title(sprintf('Augmentation Index = %.1f%%', AI)); 

    subplot(2,1,2); hold on;
    plot(ddt2, 'k', 'LineWidth', 1.7);
    plot([inflectI, inflectI], [min(ddt2), max(ddt2)], 'r');
    plot([minI, minI], [min(ddt2), max(ddt2)]);
    plot([maxI, maxI], [min(ddt2), max(ddt2)]);
    plot([shoulderI, shoulderI], [min(ddt2), max(ddt2)], 'g');
    set(gcf, 'color', 'w');
    set(gcf, 'position', [390   375   597   560]);

    uicontrol('Style', 'pushbutton', 'String', 'Continue', 'Callback', 'uiresume(gcbf)');
    uiwait(gcf);
    close(gcf);
end

