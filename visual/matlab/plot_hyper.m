function plot_hyper
cl_register_function();

figure (1);
clf reset;

function hyper=hyper(x,n)
    hyper=n*x./(x.^n + (n-1));
  return
end

    function hyper3=hyper3(k,p,n)
        
        hyper3=n*k^(n-1).*p./(k^n*(n-1)+p.^n);
        return
    end

x=[0:1500];
kappa=800;

cmap=colormap(prism);

hold on;
set(gca,'Ylim',[0 1.5]);

for n=2:0.5:5
%for k=2:60
%  y=hyper(x,n);
  y=hyper3(kappa,x,n);
  [ymax,imax]=max(y);   
  plot(x,y,'color',cmap(n*2,:));
  text(x(imax),ymax,[num2str(n)]);
%end
end
return

end

