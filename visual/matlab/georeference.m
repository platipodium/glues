function georeference

cl_register_function();

  imagefile='/h/lemmen/projects/glues/tex/mihh2007/grafik/Zohary1999_Hopf_color.png';
  
  figure(1);clf;
  im=imread(imagefile,'png');

  imagesc(im);

  figure(2); clf;
  m_proj('mercator','lat',[30,67],'lon',[-15,65]);
  m_coast;
  m_grid;
  
  get(gca,'Ylim');
  get(gca,'XLim');
  


return
