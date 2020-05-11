function h = IFR_plot(IFRTable, cumIFR, xValues)
% modified by Alberto Averna Feb 2015 for InVivo exp
h = figure;
subplot(2,1,1) % Activity on active channels
if size(IFRTable,1) > size(IFRTable,2)
    IFRTable = IFRTable';
end
image(IFRTable)
% h=colorbar(gca,[0.04583 0.5833 0.04762 0.3429]);
p=colorbar('eastoutside');  
%set(p,'Box','on','LineWidth',1,'Location','manual','XAxisLocation','top','XLim',[-0.5 1.5])
% 
% colormap hot
colormap jet
axis off
subplot(2,1,2) % Average firing rate of the network
plot(xValues, cumIFR, '-', 'MarkerFaceColor', 'b');
xlim([0 xValues(end)])
xlabel('Time [sec]')
ylabel('Array-wide Firing Rate [spikes/sec]')