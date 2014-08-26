function [h,rtspks,rtixgrp,rtixorder] = plot_clusters(spkdata,G,ngrps,T,varargin)
% PLOT_CLUSTERS plots spike train clusters
% [H,GS,I,O] = PLOT_CLUSTERS(S,G,NG,T) raster plots the spike data in two-column vector S,
% re-arranged into clusters specified by the cluster structure G (output of
% CLUSTER_SPIKE_DATA_BINS ro CLUSTER_SPIKE_DATA_BINLESS), given the number of clusters NG. Uses the
% two-element time vector T = [start end] to rescale axis...
% 
% Returns: H the handle to the displayed figure window; GS, a cell array of spike-times, one cell per group;
% I, a cell array of group membership indexes, arranged by group; O, a cell
% array of group membership indexes, arranged in trial/raster order
% 
% ... = PLOT_CLUSTERS(...,FLAG,SRT,CMAP) sets plot options in string FLAG, using any combination of letters and numbers:
%       'B' - set plot in black-and-grey alternation, rather than colour
%       '1' - plots the original raster
%       '2' - plots the original raster colour coded by group
%       '3' - plots the raster by groups [n.b. '123' is the default plot]
%       [] - omit;
%  Vector SRT has one entry for each spike-train index in the original data-set and is used to sort the spike-trains 
%  within groups in ascending order. For example, if SRT is a vector of the rates of each train, then the trains are plotted (bottom-to-top) in  
%  ascending rate order. Set to [] to omit.
%  
%  CMAP sets the colormap from which the colors of the groups are taken: this can be either a string (without quotes) 
%  or a matrix (you could provide one colour per group). See COLORMAP for help. 
%
% Mark Humphries 29/04/2011

% defaults
blnColour = 1;

plotraster = [];

if nargin >= 5 & ~isempty(varargin{1})
    if findstr(varargin{1},'B') blnColour = 0; end
    if findstr(varargin{1},'1') plotraster = 1; end
    if findstr(varargin{1},'2') plotraster = [plotraster 2]; end
    if findstr(varargin{1},'3') plotraster = [plotraster 3]; end
end

nIDs = numel(G(:,1));
IDs = G(:,1);
S = 1:nIDs;  blnS = 0;
if nargin >= 6 & ~isempty(varargin{2}) S = varargin{2}; blnS = 1;  end

if isempty(plotraster) plotraster = [1 2 3]; end  % default is all three

if isempty(G) | ngrps==0
    nIDs = 0;
    IDs = [];
    h = [];
    rtspks = []; rtixgrp = []; rtixorder = [];
    return
end


%%% plot
h = figure; clf; 

if nargin >= 7 & ~isempty(varargin{3}) 
    colormap(varargin{3});  
else
    colormap(hsv)
end


if blnColour
    % full colour version % colormaps prism, colorcube better than standard one
    clrs = colormap('jet');  
    [rw cl] = size(clrs); clrstep = floor(rw /ngrps);
    if clrstep ==0
        clrstep =1;
    end
    perm = randperm(rw);
    clrs = clrs(perm,:);
    
    % keyboard
else
    % alternating black and grey version
    clrs = repmat([0 0 0; 0.5 0.5 0.5],ngrps,1); clrstep = 1;
end


nsplots = numel(plotraster);

npassed = 0;
rtspks = cell(ngrps,1); rtixgrp = cell(ngrps,1); rtixorder = cell(ngrps,1);
for loop = 1:ngrps
    try
        inds_of_array = find(G(:,2)==loop);
        inds_of_spks = G(G(:,2)==loop,1);
        if  blnS % index into re-ordering vector
            thisS = S(inds_of_array); 
            [x I] = sort(thisS);
        else
            I = 1:numel(inds_of_array); % otherwise just display in index order....
        end   
        % keyboard
    catch
        keyboard
    end
    
    ctrs = [1:numel(inds_of_array)] + npassed;
    stgrp = []; ixgrp=[]; ixorder = [];
 
    for i = 1:numel(inds_of_array)
        indst = find(spkdata(:,1) == inds_of_spks(i));  % all indexes with this ID stamp
        st = spkdata(indst,2);  % corresponding spike times
        stgrp = [stgrp; st];    % build group
        stix = ctrs(find(I == i));
        ixgrp = [ixgrp; zeros(length(st),1)+stix];    % build y-axis index group - either bu index order, or by order specified in S...
        % ctr = ctr-1;  % plot top-to-bottom
        % ctr = ctr+1; % plot bottom-to-top
        ixorder = [ixorder; ones(length(st),1)*inds_of_spks(i)];
    end
    
    npassed = npassed + numel(inds_of_array);    % the number of indexes that have already been plotted
    rtspks{loop} = stgrp; rtixgrp{loop} = ixgrp; rtixorder{loop} = ixorder;
    
    pctr = 1;
    if any(plotraster == 1)
        %%% plot original raster plot (bottom-to-top)
        subplot(nsplots,1,pctr), plot(stgrp,ixorder,'k.'); hold on; pctr = pctr+1;
    end
    
    if any(plotraster == 2)
        %%% plot colour-coded in event order
        subplot(nsplots,1,pctr), plot(stgrp,ixorder,'.','Color',clrs(mod(clrstep*loop,64)+1,:)); hold on;
         pctr = pctr+1;
    end
    
    if any(plotraster == 3)
        subplot(nsplots,1,pctr), plot(stgrp, ixgrp,'.','Color',clrs(mod(clrstep*loop,64)+1,:)); hold on;
    end
    %fname1 = ['stgrp' num2str(Igrp(loop)) '.txt']; fname2 = ['ixgrp'
    %num2str(Igrp(loop)) '.txt']; 
    %save(fname1,'stgrp','-ascii'); save(fname2,'ixgrp','-ascii')
    
end

pctr = 1;
if any(plotraster==1)
    subplot(nsplots,1,pctr), axis([T(1) T(2) min(IDs)-1 max(IDs)+1]), title('Original raster plot'),xlabel('Time (s)'),ylabel('Train ID')
    pctr = pctr+1;
end
if any(plotraster==2)
    subplot(nsplots,1,pctr), axis([T(1) T(2) min(IDs)-1 max(IDs)+1]), title('Colour coded by cluster membership'),xlabel('Time (s)'),ylabel('Train ID')
    pctr = pctr + 1;
end
if any(plotraster == 3)
    subplot(nsplots,1,pctr), axis([T(1) T(2) -1 nIDs+1]), 
    title('Grouped by detected clusters')
    xlabel('Time (s)'),ylabel('Re-ordered ID')
    
end
% remove top and right lines
% box off


