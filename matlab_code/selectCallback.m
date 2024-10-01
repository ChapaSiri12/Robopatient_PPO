function selectCallback(~,~,h2,RI_select)

%user selection display
selection = evalin('base','z');

if selection == 1
    selDisp = "Agree";
elseif selection == 0
    selDisp = "Disagree";
end

%show select
set(h2,'CData',RI_select);

set(get(gca,'Ylabel'),'String',selDisp);
set(get(gca,'Ylabel'),'Color','w');
set(get(gca,'Ylabel'),'Rotation',-90);
set(get(gca,'Ylabel'),'FontSize',20);
set(get(gca,'Ylabel'),'FontWeight','bold');
end