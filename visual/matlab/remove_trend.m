function [v,trend]=remove_trend(t,v,method,tcrit)
%V=REMOVE_TREND(T,V,METHOD,TCRIT)

% Carsten Lemmen <carsten.lemmen@gkss.de
% 2009-04-09

cl_register_function();

if ~exist('method','var') method='polyfit'; end
if ~exist('tcrit','var')  tcrit=2000; end

if nargin<2
    error('At least two input arguments (t,v) are required');
end

if numel(t)~=numel(v)
    error('Input data must be of equal size');
end

switch (method)
    case 'movavg', trend=movavg(t,v,tcrit);
    case 'polyfit'
        n=2;
        c=polyfit(t,v,n);
        nt=length(t);
        trend=repmat(t,1,n+1).^repmat([n:-1:0],nt,1).*repmat(c,nt,1);
        trend=sum(trend,2);
    otherwise, error('Unknown method');
end


v=v-trend;
return
end




