%% function [avbeat, meanSD, meanR, indiv_beats, varargout] = AverageBeat(mbdata, beatI, beatincludeI, doplot, [dt], [offsetI], [dodetrend])
% Creates an average beat from multi-beat data (mbdata)
% beatI contains indexes of mbdata corresponding to beat onset
% beatincludeI indicates which beats to include (1) and which to exclude (0). 
%  All beats are included if beatincludeI = 1
% doplot: 1, standard plot with individual beats in green, average beat in bold black
%         2, average beat in black with pointwise +/- two standard deviations
%         3, interactively select/deselect beats to include
% dt: optionally input a time step for the plotting a time-axis
% offsetI: optionally include number of samples to offset beat markers by
% dodetrend: enforce rotational continuity (i.e. so that [avbeat; avbeat] isn't discontinuous at the boundary between beats)
% Usage: 
%   [avbeat, meanSD, meanR] = AverageBeat(mbdata, beatI, beatincludeI, 0)  % Calculate average beat without plotting
%   [avbeat, meanSD, meanR, ploth] = AverageBeat(mbdata, beatI, beatincludeI, 1)  % Calculate average beat with plotting and return plot handle
%   [avbeat, meanSD, meanR] = AverageBeat(mbdata, beatI, beatincludeI, 1, dt, offsetI)  % Specify sample time and offset index
% Outputs:
%   avbeat: the average beat waveform
%   meanSD: average point-wise standard deviation
%   meanR:  average correlation coefficient between the average beat and individual beats
%   indiv_beats: individual beats
%   ploth:  the figure handle, available if plot = 1 or plot = 2 (if plot = 3, the figure window is automatically closed)
%
% Author: Jonathan Mynard (jonathan.mynard@mcri.edu.au)

function [avbeat, meanSD, meanR, indiv_beats, varargout] = AverageBeat(mbdata, beatI, beatincludeI, doplot, varargin)

beatI = round(beatI);

if length(beatI) > 3
    approxbeatlen = length(mbdata)/(length(beatI)-3);
else
    approxbeatlen = 3000;
end
beat = zeros(round(approxbeatlen),1);

if length(varargin) >= 1
    dt = varargin{1};
end
if length(varargin) >= 2
    offsetI = varargin{2};
else
    offsetI = 0;
end
if length(varargin) >= 3
    dodetrend = varargin{3};
else
    dodetrend = 0;
end

if nargin > 4
    time = 0:dt:((length(mbdata)-1)*dt);
else
    time = 1:length(mbdata);
end

if beatincludeI == 1
    beatincludeI = ones(length(beatI),1);
else
    if length(beatincludeI) ~= length(beatI)-1
       error('Error setting beatincludeI. This should be 1 to include all beats, or have a length equal to length(beatI)-1.'); 
    end
end

if doplot
    ploth = figure;
    varargout{1} = ploth;
    hold on;
end
if isempty(beatincludeI)
    error('No beats detected. Can''t proceed');
end

[avbeat, sd, meanSD, meanR, beat, beatlen] = AvBeatCalc(mbdata, dodetrend, beatI, beatincludeI, offsetI);

if doplot == 1 || doplot == 3  
    ii = 0;
    for bb = 1:length(beatI)-1   
        if beatincludeI(bb)
            ii = ii + 1;
            beatlen = length(beatI(bb):beatI(bb+1));
            beat(1:beatlen, ii) = mbdata((beatI(bb)-offsetI):(beatI(bb+1)-offsetI));

            ph(ii) = plot(time(1:beatlen), beat(1:beatlen, ii), 'g');         
        
            if doplot == 3             
                ph(ii).ButtonDownFcn = {@toggle, bb};                
            end
        end
    end
end

%% Plotting of the standard deviations (if doplot == 2)
if doplot == 2
    if nargin > 4
        x = 0:dt:((length(avbeat)-1)*dt);
        curve1 = (avbeat+2*sd)';
        curve2 = (avbeat-2*sd)';        
        x2 = [x, fliplr(x)];
        inBetween = [curve1, fliplr(curve2)];
        fh = fill(x2, inBetween, 'g');
        fh.FaceColor = [0, 0.8, 0];
        fh.FaceAlpha = 0.6;
        fh.EdgeColor = [0.5,0.5,0.5];
    else
        plot(avbeat+2*sd, 'm', 'linewidth', 1);
        plot(avbeat-2*sd, 'm', 'linewidth', 1);
    end
end

%% Plotting of the average beat
if doplot
    avbeath = plot(time(1:length(avbeat)), avbeat, 'k', 'linewidth', 2);
end

%% Allow interactive inclusion/exclusion of beats
if doplot == 3

    handles = guidata(ploth);
    handles.beatI = beatI;
    handles.offsetI = offsetI;
    handles.beatincludeI = beatincludeI;
    handles.mbdata = mbdata;
    handles.dodetrend = dodetrend;
    handles.avbeath = avbeath;
    handles.time = time;
    guidata(ploth, handles);

    set(ploth, 'position', [509   557   731   420]);
    set(gca, 'position', [0.2476    0.1100    0.6574    0.8150]);    
    uicontrol('style', 'pushbutton', 'string', 'Done/Good', 'fontsize', 14, 'position', [27,167,118,36], 'callback', @done);
    uicontrol('style', 'pushbutton', 'string', 'Skip/Poor', 'fontsize', 14, 'position', [27,123,118,36], 'callback', @skip);
    uiwait(ploth);
    
    if ploth.UserData == "skip"
        avbeat = [];
        sd = [];
        meanSD = [];
        meanR = [];        
    else
        handles = guidata(ploth);
        beatincludeI = handles.beatincludeI;

        [avbeat, sd, meanSD, meanR, beat] = AvBeatCalc(mbdata, dodetrend, beatI, beatincludeI, offsetI);

        cla;
        ii = 0;
        for bb = 1:length(beatI)-1   
            if beatincludeI(bb)
                ii = ii + 1;
                beatlen = length(beatI(bb):beatI(bb+1));
                beat(1:beatlen, ii) = mbdata((beatI(bb)-offsetI):(beatI(bb+1)-offsetI));
    
                ph(ii) = plot(time(1:beatlen), beat(1:beatlen, ii), 'g');         
            end
        end
        avbeath = plot(time(1:length(avbeat)), avbeat, 'k', 'linewidth', 2);

        close(ploth);
    end
end

indiv_beats = beat;


function [avbeat, sd, meanSD, meanR, beat, beatlen] = AvBeatCalc(mbdata, dodetrend, beatI, beatincludeI, offsetI)

ii = 0;
minlen = 1e10;

%% Get the individual beats that are included
for bb = 1:length(beatI)-1
    if beatincludeI(bb)
        ii = ii + 1;
        beatlen = length(beatI(bb):beatI(bb+1));
        beat(1:beatlen, ii) = mbdata((beatI(bb)-offsetI):(beatI(bb+1)-offsetI));
        if beatlen < minlen
            minlen = beatlen;
        end        
    end
end

%% Calculate the average beat
avbeat = mean(beat(1:minlen,:), 2);
avbeat = avbeat(:);

%% Detrend the average beat
if dodetrend
    enddiff = avbeat(end) - avbeat(end-1);  % We're going to assume a linear slope
    nextval = avbeat(end) + enddiff;        % The expected value of the next sample after the end of the avbeat
    slope = (nextval-avbeat(1))/length(avbeat);  % Slope of the line connecting sample 1 to sample length(avbeat)+1 (which should be zero after detrending)
    correction = (0:(length(avbeat)-1))*slope;
    correction = correction(:);
    avbeat = avbeat - correction;
end

%% Calculate standard deviation
sd = std(beat(1:length(avbeat),:),0,2);
meanSD = mean(sd);

%% Calculate correlations
avbeatL = length(avbeat);

R = zeros(sum(beatincludeI),1);
for bb = 1:sum(beatincludeI)-1
    C = corrcoef(avbeat,beat(1:avbeatL,bb));
    R(bb) = C(1,2);
end
meanR = mean(R);

function done(hObject, ~)
hObject.Parent.UserData = 'done';
uiresume(hObject.Parent);

function skip(hObject, ~)
hObject.Parent.UserData = 'skip';
uiresume(hObject.Parent);

function toggle(hObject, ~, beatI)
handles = guidata(hObject.Parent);

if handles.beatincludeI(beatI) == 1
    handles.beatincludeI(beatI) = 0;
    hObject.Color = [0.7,0.7,0.7];
else
    handles.beatincludeI(beatI) = 1;
    hObject.Color = 'g';
end

avbeat = AvBeatCalc(handles.mbdata, handles.dodetrend, handles.beatI, handles.beatincludeI, handles.offsetI);
handles.avbeath.YData = avbeat;
handles.avbeath.XData = handles.time(1:length(avbeat));
guidata(hObject.Parent, handles);