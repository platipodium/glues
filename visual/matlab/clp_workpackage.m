function clp_workpackage(varargin)

arguments = {...
  {'wp',3},...
  {'divprefix','Q'},...
  {'ndiv',8},...
  {'figoffset',0},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end


tasks{1}={'Coasts',2};
tasks{2}={'Emissions',[1:4]};
tasks{3}={'Copuling interface',4:8};
tasks{4}={'Complexity',2:6}
tasks{5}={'HRU',4:7};

milestones{1}={'Coasts',2};
milestones{2}={'HRU',4};
milestones{3}={'HRU',6};
milestones{4}={'Emissions',1};
milestones{5}={'Emissions',4};
milestones{6}={'Coupling interface',4};
milestones{7}={'Coupling interface',5};
milestones{8}={'Coupling interface',8};
milestones{9}={'Complexity',2};
milestones{10}={'Complexity',6};

figure(1+figoffset); clf reset; hold on;

x0=2;y0=2;xw=2;yw=1;

p(1)=patch([x0 x0+xw x0+xw x0],[y0 y0 y0+yw y0+yw],'b');


return;
end