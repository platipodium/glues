function names=name_regionnumber(varargin)

cl_register_function();

if nargin==1
  regs=varargin{1};
else
  regs=[1:686];
end

n=length(regs);

for i=1:n
  switch regs(i)
    case  93, names{i}='Denmark';
    case 109, names{i}='England';      
    case 117, names{i}='N Poland';
    case 121, names{i}='Ireland';      
    case 123, names{i}='N Germany';
    case 124, names{i}='Pommerania';
    case 143, names{i}='S Poland';
        
    case 147, names{i}='Chekia';
    case 148, names{i}='Belarus';
    case 157, names{i}='Alsace';
    case 159, names{i}='France';
        
    case 164, names{i}='Ucraine';
    case 171, names{i}='Hungary';
    case 174, names{i}='Kazakhstan';
    case 178, names{i}='Alpes';
    case 185, names{i}='Bulgary';
    case 199, names{i}='Croatia';
      
    case 203, names{i}='Tuscany';
    case 212, names{i}='Romania';
      
    case 216, names{i}='Italy';
    case 217, names{i}='N Greece';
      
    case 236, names{i}='Albania';
    case 243, names{i}='N Anatolia';
    case 253, names{i}='S Greece';
        
    case 254, names{i}='W Anatolia';
      
    case 256, names{i}='Turkish Riviera';
    case 253, names{i}='S Greece';
    case 278, names{i}='Atlas mountains';
    case 229, names{i}='Basque country';
      case 251, names{i}='Portugal';
    case 263, names{i}='Andalusia';
    case 272, names{i}='Lebanon';
    case 279, names{i}='N Iraq';
    case 304, names{i}='W Algeria';
    case 316, names{i}='Syria';
    case 358, names{i}='Egypt';
    case 343, names{i}='Libya';
        
    otherwise names{i}=num2str(regs(i));
  end
end
