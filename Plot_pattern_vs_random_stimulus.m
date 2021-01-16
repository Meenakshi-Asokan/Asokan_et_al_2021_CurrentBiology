%Plot and visualize various pattern-rand stimuli
close all
clearvars

figure();
n_cyc = 4;
% n_cyc = 8;
% n_cyc = 12;
load(sprintf('F:/EPHYS/Curr Bio/Dataset/Stimulus files/stimulus_regrand_cyc%d',n_cyc));

% set_n = 2;
% load(sprintf('F:/EPHYS/Curr Bio/Dataset/Stimulus files/variant_cyc%d_regrand_set%d',n_cyc, set_n));
% t = t(11:end);%baseline rand has 50 intervals instead of 40(10*n_cyc) in this variant

temp = unique(t);
t_colors = [];
for i = 1:length(t)
t_colors(i) = find(temp == t(i));
end

CT=cbrewer('seq', 'RdPu', n_cyc);
colormap(CT);
% plot(1:length(t),t,'-','color',[0.5 0.5 0.5]);
for i = 1:n_cyc:length(t)
x = i:i+n_cyc-1;
y = t(x);
plot(x,y,'-','color',[0.5 0.5 0.5]);
hold on
end
% CT=colormap(copper(4));
for i = 1:length(t)
plot(i,t(i),'o','markerfacecolor',CT(t_colors(i),:),'markeredgecolor','k','markersize',7);
hold on
end
xlim([1 length(t)]);
ylim([100 300]);
% imagesc(t_colors);%alternate way to visualize
% xlim([1 240]);
xlabel('Burst/Interval number');
% yticks([]);
ylabel('Interval');
colorbar();
box off
set(gca,'fontsize',14);