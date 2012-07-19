function gjet = gaussjet(m)
%DARKJET Variant of the jet color scale

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

n=161;
x=[0:n];
peaks=(n-1)/16*[4 8 12];
sigma=2/16*(n-1);

pmax=max(normpdf(x,0,sigma));

b=normpdf(x,peaks(1),sigma)/pmax;
g=normpdf(x,peaks(2),sigma)/pmax;
r=normpdf(x,peaks(3),sigma)/pmax;

gjet=[r' g' b'];

return
end

% figure(1); clf reset;
% plot(x,b,'b-'); hold on;
% plot(x,g,'g-');
% plot(x,r,'r-');
% plot(x,r+b+g,'k-');
