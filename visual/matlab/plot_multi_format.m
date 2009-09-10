function plot_multi_format(plot,basename,varargins)
cl_register_function();

    try
    set(plot,'PaperPositionMode','auto');
    %print('-depsc2','-r300',[basename '.eps']); % -r600
    catch end;
    try
    set(plot,'PaperPositionMode','auto');
    %print('-dpdf',[basename '.pdf']); % -r600
    catch end;
    try
    set(plot,'PaperPositionMode','auto');
    print('-dsvg',[basename '.svg']); % -r600
    catch end;
    try
    set(plot,'PaperPositionMode','auto');
    %print('-dpsc2','-r150',[basename '.ps']); % -r600
    catch end;
    try 
    print('-dpng',[basename '.png']);
    catch end;
    
    try
    %  print([basename '.fig']);
    catch end;

    try
        ;
    %zip([basename '.zip'],{[basename '.png'],[basename '.fig'],[basename '.eps']});
    catch end;
return;
%EOF
