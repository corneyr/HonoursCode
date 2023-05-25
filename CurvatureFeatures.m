function [curvI, curvVal] = CurvatureFeatures(data, dt, varargin)
% Finds the curvature-based features of a time signal 'data' sampled at 'dt'
% Returns the time indexes of peak curvature (curvI) and the associated value of (adjusted) curvature (curvVal)
% Usage 1: [curvI, curvVal] = CurvatureFeatures(data, dt)
% Usage 2: [curvI, curvVal] = CurvatureFeatures(data, dt, curvaturethreshold)
%          where curvaturethreshold is a threshold below which any curvature peaks are ignored

% References:
% 1. J. P. Mynard, D. J. Penny, and J. J. Smolich, "A Semi-Automatic Feature Detection Algorithm for 
%      Hemodynamic Signals using Curvature-Based Feature Extraction," 
%      29th Annual International Conference of the IEEE Engineering in Medicine and Biology Society, 2007, pp. 1691-1694.
% 2. J. P. Mynard, D. J. Penny, and J. J. Smolich, "Accurate automatic detection of end-diastole 
%      from left ventricular pressure using peak curvature," IEEE Trans Biomed Eng, 55:2651-2657, 2008.

curvaturethreshold = 0; 
if ~isempty(varargin)
    curvaturethreshold = varargin{1};
end

[curv, dxdt] = Curvature(data, dt);  % Note: Other optional arguments available but not used here

% [cmax, imax, cmin, imin] = extrema(curv, curvaturethreshold, 0);  % Find all the peaks and troughs
[cmax, imax] = findpeaks(curv,'MinPeakProminence',curvaturethreshold);
[cmin, imin] = findpeaks(-curv,'MinPeakProminence',curvaturethreshold);
cpeaks = [cmin, cmax];   % Put peaks and troughs into the one vector
curvI = [imin, imax];
[curvI, sortI] = sort(curvI);
cpeaks = cpeaks(sortI);

t = 0:dt:(length(data)-1)*dt;
features = zeros(length(data),1);

%% Adjust the curvature values based on the importance of the feature (see references)
yrange = max(data)-min(data);
for ii = 2:length(cpeaks)-1   
    % The curvature peak of interest
	secval = data(curvI(ii));
	curvval = cpeaks(ii);
    second = t(curvI(ii));
    
    % The curvature peaks on either side of the one of interest
	fstval = data(curvI(ii-1));
    thrdval = data(curvI(ii+1));
    first = t(curvI(ii-1));
    third = t(curvI(ii+1));
    
    if abs(thrdval - secval) > abs(secval - fstval) 
		deltay = abs(thrdval - secval);
	else
		deltay = abs(secval - fstval);
    end
    
    if (third-second) > (second-first) 
		deltax = (third-second)*dxdt;
	else
		deltax = (second-first)*dxdt;
    end
    
    if abs(deltay) > yrange*0.1 
		deltay = yrange*0.1;
    end
    
	features(curvI(ii)) = curvval * sqrt(deltax*deltax + deltay*deltay);
end

% Adjust the first and last feature points
features(curvI(1)) = cpeaks(1) * (t(curvI(2))-t(curvI(1)));  
features(curvI(end)) = cpeaks(end) * (t(curvI(end))-t(curvI(end-1)));

curvVal = features(curvI);

% hold on;
% plot(Normalise(data));
% % plot(Normalise(curv), 'r');
% plot(Normalise(features), 'k');
% % plot((curv), 'r');
% % plot((features), 'k');

