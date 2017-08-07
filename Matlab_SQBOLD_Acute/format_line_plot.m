a=findobj(gcf);
allaxes=findall(a,'Type','axes');
alllines=findall(a,'Type','line');
alltext=findall(a,'Type','text');
set(allaxes,'FontName','Helvetica','FontWeight','normal','LineWidth',1,'FontSize',8);
set(alllines,'Linewidth',1)
set(alltext,'FontName','Helvetica','FontSize',8);
box on
width = 6; height = 6;
set(gcf,'PaperUnits','centimeters','PaperPosition',[1 1 width height])
