% function osc = Oscillogram(cuffpressure, sampletime)
% Extracts the oscillogram from a cuff pressure
% Inputs:
%   cuffPressure - the cuff pressure signal
%   sampletime - sample interval of the cuffPressure
%   varargin - optional parameters as follows:
%       'BaselineSmoothTime' - the time period over which to smooth to obtain oscillogram via subtraction
%       'OscillogramSmoothTime' - time constant for smoothing the oscillogram
%       'Plot - 1 to plot the results, otherwise 0
% Author: Jonathan Mynard (jonathan.mynard@mcri.edu.au)
function osc = Oscillogram(cuffPressure, sampletime, varargin)

%% Default parameter values
defaultBaselineSmoothTime = 3;      % seconds
defaultOscillogramSmoothTime = 0.1;
defaultPlot = 0;

%% Parse input parameters
p = inputParser;
addOptional(p,'BaselineSmoothTime',defaultBaselineSmoothTime,@isnumeric);
addOptional(p,'OscillogramSmoothTime',defaultOscillogramSmoothTime,@isnumeric);
addOptional(p,'Plot',defaultPlot,@isnumeric);

parse(p,varargin{:});

%% Smooth cuff pressure
nsmooth = p.Results.BaselineSmoothTime/sampletime;
nsmooth = 2*floor(nsmooth/2)+1;  % Rounding to an odd number
smoothedPres = sgolayfilt(cuffPressure,3,nsmooth);

%% Calculate oscillogram
oscRaw = cuffPressure - smoothedPres;

% smooth
nsmooth = p.Results.OscillogramSmoothTime/sampletime;
nsmooth = 2*floor(nsmooth/2)+1;  % Rounding to an odd number
osc = sgolayfilt(oscRaw,3,nsmooth);

%% Plot results
if p.Results.Plot
    figure;
    set(gcf, 'position', [232          38        1482         912]);
    
    subplot(2,1,1);
    hold on;
    time = 0:sampletime:(length(cuffPressure)-1)*sampletime;
    plot(time, cuffPressure, 'k');
    plot(time, smoothedPres, 'r', 'linewidth', 1.5);
    
    subplot(2,1,2);
    hold on;
    plot(time, oscRaw, 'k');
    plot(time, osc, 'r', 'linewidth', 1.5);
end
