%%% function [curv] = Curvature(data, dt, {geocorrect}, {spanthres}, {window}, {polyorder})
% Generates the curvature signal of the input vector 'data' whose time interval is 'dt'
% Optional arguments:
%    geocorrect (default = 1) a correction is used to account for the small time interval 'dt' (0 = don't correct)
%    spanthresh (default = 0.001), a threshold below which delta(data) is ignored when calculating the x-axis transformation
%    window (default = 5), the number of data points used in the Savitzky-Golay filter
%    polyorder (default = 4), the polynomial order used in the Savitzky-Golay filter
% Dependencies: derivative

% References:
% 1. J. P. Mynard, D. J. Penny, and J. J. Smolich, "A Semi-Automatic Feature Detection Algorithm for 
%      Hemodynamic Signals using Curvature-Based Feature Extraction," 
%      29th Annual International Conference of the IEEE Engineering in Medicine and Biology Society, 2007, pp. 1691-1694.
% 2. J. P. Mynard, D. J. Penny, and J. J. Smolich, "Accurate automatic detection of end-diastole 
%      from left ventricular pressure using peak curvature," IEEE Trans Biomed Eng, 55:2651-2657, 2008.

function [curv, dxdt] = Curvature(data, dt, varargin)

%% Data integrity checks
if ~isvector(data) || ~isreal(data)
    error('Input data must be a vector array of real numbers');
end

if ~isreal(dt)
    error('Input dt must be a real numeric value');
end

geocorrect = 1; 
if ~isempty(varargin) 
    if varargin{1} == 0 || varargin{1} == 1
        geocorrect = varargin{1};
    else
        warning('Curvature:geocorrectValue', 'The first optional argument (geocorrect) must be 0 or 1. Using default value of 1.');
    end
end

spanthresh = 0.001;
if length(varargin) > 1
    if isscalar(varargin{2}) && isreal(varargin{2})
        spanthresh = varargin{2};   
    else
        warning('Curvature:spanthresh', 'The second optional argument (spanthresh) must be a real scalar number. Using default value of 0.001.');
    end
end

window = 5;
if length(varargin) > 2
    if isscalar(varargin{3}) && isinteger(varargin{2})
        window = varargin{3};   
    else
        warning('Curvature:window', 'The third optional argument (window) must be a scalar integer. Using default value of 5.');
    end
end

polyorder = 4;
if length(varargin) > 3
    if isscalar(varargin{4}) && isinteger(varargin{4}) 
        window = varargin{4};   
    else
        warning('Curvature:polyorder', 'The third optional argument (polyorder) must be a scalar integer. Using default value of 4.');
    end
end    

%% Perform axis transformation
num = length(data);

if geocorrect == 1 
%Calculate an equivalent geometrical value for a time sample based on the median difference in y-values between samples
    deltay = abs(diff(data(2:end)));
    deltay(num) = 0;  
	maxspan = max(deltay);
	numsig = 0;
    sigdeltay = zeros(num,1);
    for j = 1:num-1
        if deltay(j) > maxspan*spanthresh 
            numsig = numsig + 1;
			sigdeltay(numsig) = deltay(j);			
        end
    end
	dx = median(sigdeltay(1:numsig));
else
	dx = dt;
end

%% Calculate curvature signal
dxdt = dx/dt;
dtdx2 = (1/dxdt)^2;
data = data(:)';
dy = savgol(data, window, polyorder, 1)/dt;
d2y = savgol(dy, window, polyorder, 1)/dt;
curv = d2y*dtdx2 ./ (1 + dy.^2*dtdx2).^1.5;     %  (d2y/dx2) / (1 + (dy/dx)^2)^(3/2)
