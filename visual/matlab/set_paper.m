function set_paper(fignum)

cl_register_function();

if ~exist('fignum','var') fignum=1; end

set(fignum,'PaperUnits','centimeters');
set(fignum,'PaperOrientation','landscape');
%set(fignum,'PaperSize',[21.0 29.6]);
set(fignum,'PaperType','A4');
%set(fignum,'PaperPositionMode','auto');
%set(fignum,'PaperPosition',[1 1 21 29.6]);

%	PaperPosition = [0.25 2.5 8 6]
end	

