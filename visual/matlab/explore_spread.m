function explore_spread(varargin)

file='spread_variation.mat';
load(file);


% migrationn c(1) /spreadv
% c(2)=spreadm
% trade spreadm*spreadv c(:,3)
% c(:,4:13) = timing(1:10)
% c(14) r, c(15) p c(16)=v

figure(1); clf reset; hold on;

i0=find(c(:,3)==0);
ipos=find(c(:,3)>0);
c(i0,3)=min(c(ipos,3))/10;

plot3(c(:,1),c(:,3),c(:,14),'ro');
plot3(c(:,1),c(:,3),c(:,16),'bo');
set(gca,'XScale','log','YScale','log','Zlim',[0 2.0]);

ival=find(isfinite(c(:,13)) & c(:,14)>0.5 );
plot3(c(ival,1),c(ival,3),c(ival,16),'bo','MarkerFaceColor','b');
plot3(c(ival,1),c(ival,3),c(ival,14),'ro','MarkerFaceColor','r');




return
end