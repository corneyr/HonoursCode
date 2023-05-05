function beatI = AutoBeatDetect(data, params)
%% Automatic beat detection
%  data: the waveform data to detect beats from
%  params.Method = 'Peaks', 'PeakCurvature', 'GradientIntersection'
%  params.InspectPlot = 1 to plot every stage of the algorithm to see what is happening
%  see BeatOnsetDetect for a description of options passed in via params for each method
%  params.SingleBeat = 1 for detecting beat onset of a single heart beat
%  params.IgnoreUpToStartI = 30 ignore detections up to this index (for PeakCurvature only)

% Author: Jonathan Mynard, jonathan.mynard@mcri.edu.au

if ~isfield(params, 'SingleBeat')
    params.SingleBeat = 0;
end
if ~isfield(params, 'IgnoreUpToStartI')
    params.IgnoreUpToStartI = 0;
end
if ~isfield(params, 'CurvatureGeocorrect')
    params.CurvatureGeocorrect = 1;
end

switch params.Method 
    %% Simple detection methods (not requiring initial detection of dP/dtmax)
    case 'Peaks'
        [~, beatI] = findpeaks(data, 'MinPeakProminence', params.PeakThreshold*range(data));
        nbeat = length(beatI);
    otherwise
        %% Methods requiring initial detection of dP/dtmax
        
        % Find dP/dtmax
        dpdt = diff(data);
        if isfield(params, 'SingleBeat') && params.SingleBeat
            [dpdtmax, imax] = max(dpdt);
        else
            [dpdtmax, imax] = findpeaks(dpdt, 'MinPeakProminence', params.DerivativePeakThreshold*range(dpdt));
        end
        if params.InspectPlot
            figure
            hold on
            plot(dpdt)
            plot(imax, dpdtmax, 'ro');
            title('dP/dt(max) Detection');
        end

        beatI = zeros(1000,1);
        nbeat = 0;

        %% Foot detection algorithm
        switch params.Method
            case 'PeakCurvature'
                % Find curvature features
                [curvI, ~] = CurvatureFeatures(data, 1, params.CurvatureThreshold, params.CurvatureGeocorrect);
                if params.InspectPlot
                    figure
                    hold on
                    plot(data)
                    plot(curvI, data(curvI), 'o');
                    title('Curvature Detection');
                end

                % Find the feet of the pressure upstrokes as the curvature feature preceding dP/dtmax
                for ii = 1:length(imax)
                    jj = find(imax(ii)-curvI > 0, 1, 'last');
                    if ~isempty(jj)
                        nbeat = nbeat + 1;
                        beatI(nbeat) = curvI(jj); 
                    end
                end
                if isfield(params, 'IgnoreUpToStartI') && params.IgnoreUpToStartI
                    nbeat = length(find(beatI >= 30));
                    beatI(beatI < 30) = [];  % Remove any points very close to the start which may be misdetected.
                end
            case 'GradientIntersection'
                if params.SingleBeat
                    [pmin, pminI] = findpeaks(-data(1:round(length(data)*0.2)), 'MinPeakProminence', params.MinimumThreshold*range(data));       
                else
                    [pmin, pminI] = findpeaks(-data, 'MinPeakProminence', params.MinimumThreshold*range(data));   
                end
                if isempty(pminI)
                    if params.SingleBeat
                        [pmin, pminI] = min(data(1:round(length(data)*0.2)));
                    else
                        [pmin, pminI] = min(data);
                    end
                else
                    pmin = -pmin;
                end                
                for ii = 1:length(imax)            
                    pp = find(pminI < imax(ii), 1, 'last'); % Find index for the minimum preceding this dp/dtmax
                    if isempty(pp)
                        continue;
                    end
                    rise = data(imax(ii)) - pmin(pp);   % p@dPdtmax - pmin
                    t = rise/dpdtmax(ii);               % The time from the intersection point to dP/dtmax
                    nbeat = nbeat + 1;
                    beatI(nbeat) = imax(ii) - t;
                end
        end
end
beatI = beatI(1:nbeat);
beatI = sort(beatI);