function [beatI, regionlimits] = BeatOnsetDetect(data, varargin)
% Performs beat detection
% data: a vector containing haemodynamic data
% 'Method' can be
%  1. 'PeakCurvature' (default) based on peak curvature preceding dP/dtmax similar to that described
%        in Mynard JP, Penny DJ & Smolich JJ. (2008). IEEE Trans Biomed Eng 55, 2651-2657.
%        Associated options: DerivativePeakThreshold, CurvatureThreshold, IgnoreUpToStartI
%  2. 'GradientIntersection' detects the onset based on the intersection of two lines.
%        The first line is horizontal at the level of the local minimum preceding dP/dtmax
%        The second line has a slope equal to that at dP/dtmax and passes through dP/dtmax
%        Associated options: DerivativePeakThreshold, MinimumThreshold
%  3. 'Peaks' simply detects the peaks (e.g. for ECG R-wave detection)
%        Associated options: 'PeakThreshold'
% 'RegionLimits' should be a 2-element vector specifies the analysis region. For example, [1000, 2000] would not
%    detect any beats with indexes less than 1000 or greater than 2000
% 'Interactive' can be 1 in order to be able to edit dP/dtmax threshold and delete beats; or 0 (no editing, default)
% 'InteractiveIfAutoFails', value of 1 means if no beat onsets are detected automatically, switch to interactive mode; 0 means auto only
% 'DerivativePeakThreshold' determines the threshold for the first pass detection of beats
% 'CurvatureThreshold' alters the curvture threshold when 'Method' is 'PeakCurvature'
% 'MinimumThreshold' alters the threshold for finding local minima when 'Method' is 'GradientIntersection'
% 'PeakThreshold' alters the threshold for finding peaks when 'Method' is 'Peaks'
% 'BeatMarkColor' optionally sets the color of the beat markers
% 'InspectPlot' allows inspection of how the algorithm is working
% 'IgnoreUpToStartI' does not detect beats in the first IgnoreUpToStartI points (PeakCurvature method only)
% returns beatI containing the indexes of data where beat onset is detected
% Examples:
%   beatI = BeatOnsetDetect(data)
%   beatI = BeatOnsetDetect(data, 'DerivativePeakThreshold', 0.2, 'CurvatureThreshold', 0.01)
%   beatI = BeatOnsetDetect(data, 'Method', 'GradientIntersection', 'DerivativePeakThreshold', 0.2, 'MinimumThreshold', 0.4)

p = inputParser;
defaultCurvatureThreshold = 0.002;
defaultddtThreshold = 0.4;
defaultMethod = 'PeakCurvature';
defaultMinThreshold = 0.05;
defaultInteractive = 0;
defaultRegionLimits = [1, length(data)];
defaultPeakThreshold = 0.7;
defaultBeatMarkColor = 'k';
defaultInspectPlot = 0;
defaultSingleBeat = 0;
defaultIgnoreUpToStartI = 30;
defaultInteractiveIfAutoFails = 0;

fontsize = 13;

addOptional(p,'DerivativePeakThreshold',defaultddtThreshold,@isnumeric);
addOptional(p,'CurvatureThreshold',defaultCurvatureThreshold,@isnumeric);
addOptional(p,'Method',defaultMethod,@ischar);
addOptional(p,'MinimumThreshold',defaultMinThreshold,@isnumeric);
addOptional(p,'Interactive',defaultInteractive,@isnumeric);
addOptional(p,'RegionLimits',defaultRegionLimits,@isnumeric);
addOptional(p,'PeakThreshold',defaultPeakThreshold,@isnumeric);
addOptional(p,'BeatMarkColor',defaultBeatMarkColor);
addOptional(p,'InspectPlot',defaultInspectPlot);
addOptional(p,'SingleBeat',defaultSingleBeat);
addOptional(p,'IgnoreUpToStartI',defaultIgnoreUpToStartI);
addOptional(p,'InteractiveIfAutoFails',defaultInteractiveIfAutoFails);

parse(p,varargin{:});

params.DerivativePeakThreshold = p.Results.DerivativePeakThreshold;
params.CurvatureThreshold = p.Results.CurvatureThreshold;
params.Method = p.Results.Method;
params.MinimumThreshold = p.Results.MinimumThreshold;
params.RegionLimits = p.Results.RegionLimits;
params.PeakThreshold = p.Results.PeakThreshold;
params.BeatMarkColor = p.Results.BeatMarkColor;
params.InspectPlot = p.Results.InspectPlot;
params.SingleBeat = p.Results.SingleBeat;
params.IgnoreUpToStartI = p.Results.IgnoreUpToStartI;
params.InteractiveIfAutoFails = p.Results.InteractiveIfAutoFails;
params.Interactive = p.Results.Interactive;

beatI = analysis.AutoBeatDetect(data, params);

if params.InteractiveIfAutoFails && isempty(beatI)
    params.Interactive = 1;
end

regionlimits = [];
if params.Interactive
    f = figure;
    f.Tag = 'BeatFig';
    a = axes(f);
    a.Tag = 'BeatAx';
    set(f, 'position', [95         170        1658         314]);

    %% Determine which threshold is adustable
    switch params.Method
        case 'PeakCurvature'
            params.adjustableThreshold = 'DerivativePeakThreshold';
        case 'GradientIntersection'
            params.adjustableThreshold = 'DerivativePeakThreshold';
        case 'Peaks'
            params.adjustableThreshold = 'PeakThreshold';
    end

    %% Plot the data and beat markers
    hold on;
    plot(a, data);
    xlim([0, length(data)]);

    uicontrol('Position', [51    26    86    33], ...
              'Style', 'PushButton', ...
              'String', 'Done', ...
              'Callback', {@done, f}, ...
              'FontSize', fontsize);
    uicontrol('Position', [44   112    47    26], ...
              'Style', 'Edit', ...
              'String', params.(params.adjustableThreshold), ...
              'Callback', {@changeThreshold, f, data, params}, ...
              'FontSize', fontsize, ...
              'Tag', 'ThreshEdit');
    uicontrol('Position', [54,181,73,37], ...
              'Style', 'PushButton', ...
              'String', 'Detect', ...
              'Callback', {@detectBeats, f, data, params}, ...
              'FontSize', fontsize);
    uicontrol('Position', [103   123    41    33], ...
              'Style', 'PushButton', ...
              'String', '+', ...
              'Callback', {@increaseThreshold, f, data, params}, ...
              'FontSize', fontsize+3);
    uicontrol('Position', [103    92    41    33], ...
              'Style', 'PushButton', ...
              'String', '-', ...
              'Callback', {@decreaseThreshold, f, data, params}, ...
              'FontSize', fontsize+3);

    handles = guihandles(f);
    guidata(f, handles);
    handles.params = params;
    handles.beataccept = ones(length(beatI),1);
    handles.data = data;

    yinrange = handles.data(round(params.RegionLimits(1)):round(params.RegionLimits(2)));
    ymin = min(yinrange) - 0.1*range(yinrange);
    ymax = max(yinrange) + 0.1*range(yinrange);
    ylim([ymin, ymax]);

    yl = ylim(a);
    handles.markeryrange = yl;
    handles.cursh(1) = plot(params.RegionLimits(1)*[1,1], [yl(1), yl(2)], 'r', 'linewidth', 2, 'ButtonDownFcn', {@startMoveCursor, f, 1});
    handles.cursh(2) = plot(params.RegionLimits(2)*[1,1], [yl(1), yl(2)], 'r', 'linewidth', 2, 'ButtonDownFcn', {@startMoveCursor, f, 2});
    ylim(yl);

    handles = plotBeatMarkers(a, beatI, handles);

    guidata(f, handles);

    uiwait(f);

    handles = guidata(f);
    if ~isfield(handles, 'bh')  % No beats were detected
        beatI = [];
    else
        beatI = zeros(length(handles.bh),1);
        nbeats = 0;
        for bb = 1:length(handles.bh)
            if isvalid(handles.bh(bb))
                col = handles.bh(bb).Color;
                if sum(col) == 0   % Black, hence included as a valid beat
                    nbeats = nbeats+1;
                    beatI(nbeats) = handles.bh(bb).XData(1);
                end
            end
        end
        beatI = beatI(1:nbeats);
    end

    regionlimits(1) = handles.cursh(1).XData(1);
    regionlimits(2) = handles.cursh(2).XData(1);

    close(f);

end

function startMoveCursor(~, ~, f, cursnum)
set(f, 'WindowButtonMotionFcn', {@MoveCursor, f, cursnum});
set(f, 'WindowButtonUpFcn', {@StopMoveCursor, f});

function StopMoveCursor(~, ~, f)
set(f, 'WindowButtonMotionFcn', '');
set(f, 'WindowButtonUpFcn', '');


function MoveCursor(~,~, f, cursnum)
pt = get(gca, 'CurrentPoint');
x = pt(1,1);

handles = guidata(f);
handles.cursh(cursnum).XData = [x,x];

lowerlim = handles.cursh(1).XData(1);
upperlim = handles.cursh(2).XData(1);

if upperlim > length(handles.data)
    upperlim = length(handles.data);
    handles.cursh(2).XData = upperlim*[1,1];
end
if lowerlim < 1
    lowerlim = 1;
    handles.cursh(1).XData = [1,1];
end

yinrange = handles.data(round(lowerlim):round(upperlim));
ymin = min(yinrange) - 0.1*range(yinrange);
ymax = max(yinrange) + 0.1*range(yinrange);
ylim([ymin, ymax]);

if isfield(handles, 'bh')
    for bb = 1:length(handles.bh)
        if handles.bh(bb).XData(1) < lowerlim || handles.bh(bb).XData(1) > upperlim
            handles.bh(bb).Color = [0.6, 0.6, 0.6];
        else
            if handles.beataccept(bb) == 1
                handles.bh(bb).Color = handles.params.BeatMarkColor;
            end
        end
    end
end

function increaseThreshold(~,~,f, data, params)
handles = guidata(f);
thresh = str2double(handles.ThreshEdit.String);
thresh = thresh + 0.05;
handles.ThreshEdit.String = sprintf('%g', thresh);
changeThreshold([],[],f, data, params);

function decreaseThreshold(~,~,f, data, params)
handles = guihandles(f);
thresh = str2double(handles.ThreshEdit.String);
thresh = thresh - 0.05;
handles.ThreshEdit.String = sprintf('%g', thresh);
changeThreshold([],[],f, data, params);

function handles = plotBeatMarkers(a, beatI, handles)
lowerlim = handles.cursh(1).XData(1);
upperlim = handles.cursh(2).XData(1);
for bb = 1:length(beatI)
    handles.bh(bb) = plot(a, [beatI(bb), beatI(bb)], handles.markeryrange, handles.params.BeatMarkColor);
    if handles.bh(bb).XData(1) < lowerlim || handles.bh(bb).XData(1) > upperlim
        handles.bh(bb).Color = [0.6, 0.6, 0.6];
    end
    handles.bh(bb).ButtonDownFcn = {@ToggleBeatAccept, a.Parent, bb};
end

function changeThreshold(~,~,f, data, params)

handles = guidata(f);

params.(params.adjustableThreshold) = str2double(handles.ThreshEdit.String);

lowerlim = round(handles.cursh(1).XData(1));
upperlim = round(handles.cursh(2).XData(1));

beatI = analysis.AutoBeatDetect(data(lowerlim:upperlim), params);
if ~isempty(beatI)
    beatI = beatI + lowerlim + 1;
end

if isfield(handles, 'bh')
    for bb = 1:length(handles.bh)
       delete(handles.bh(bb));
    end
end

handles.beataccept = ones(length(beatI),1);
handles = plotBeatMarkers(handles.BeatAx, beatI, handles);
guidata(f, handles);

function done(~, ~, f)
uiresume(f);

function ToggleBeatAccept(hObject, ~, f, bb)
handles = guidata(f);
handles.beataccept(bb) = -handles.beataccept(bb);  % Toggle

if handles.beataccept(bb) == 1
    hObject.Color = handles.params.BeatMarkColor;
else
    hObject.Color = [0.6, 0.6, 0.6];
end

guidata(f, handles);

function detectBeats(~,~,f, data, params)

changeThreshold([],[],f, data, params);
