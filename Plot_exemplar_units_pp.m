%Plotting paired pulse response exemplar rasters with alternating colors
close all
clearvars;
data_dir = 'F:\EPHYS\Curr Bio\Dataset\Figure_1';
load(fullfile(data_dir,'inners_pp.mat'));
load(fullfile(data_dir,'pp_ex.mat'));
n_inner = length(inners);
n_reps = 25;
burst1_time = 250; %one burst is at 250 ms
burst_duration = 20; %20ms bursts (with rise fall time 5 ms each)
burst2_delays = inners; %20 values from 0 to 512 ms
burst2_times = burst2_delays + burst1_time + burst_duration;
%%
num_regions = length(pp_ex);
for r_num = 1:num_regions
    raster_mat_pp = pp_ex(r_num).raster;
    raster = [];
    for inn = 1:1:n_inner
        raster(:,:,inn)= raster_mat_pp((n_inner-inn)*n_reps+(1:n_reps),:);
    end
    if r_num == 3
            c1 = 'b';
            c2 = [0, 0.4470, 0.7410];
    elseif r_num == 2
            c1 = [0, 0.5, 0];
            c2 = [0.4660, 0.6740, 0.1880];
    elseif r_num == 1
            c1 = 'r';
            c2 = [0.8500, 0.3250, 0.0980];
    end   
    figure();
    for i = 1:size(raster,3)
        subplottight(size(raster,3),1,size(raster,3)-i+1);
        L = logical(raster(:,:,i));
        if mod(i,2) == 1 
           MarkerFormat.Color =c1;
        else
            MarkerFormat.Color = c2;
        end
        plotSpikeRaster(L,'PlotType','scatter','MarkerFormat',MarkerFormat);
        hold on
        vline(burst1_time,'k');
        hold on
        vline(round(burst2_times(i)),'k');
        if (i~=2)
        set(gca,'xtick',[])
        set(gca,'xticklabel',[])
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
        end
%         axis off; 
    end
end