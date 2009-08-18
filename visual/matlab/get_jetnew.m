% File plotm_region_numbers
% Author Carsten Lemmen <carsten.lemmen@gkss.de>
%
% based on show_map.m by Kai Wirtz
%--------------------------------------------------

function jetnew=get_jetnew(n)

cl_register_function();

    map19=zeros([19 3]);
    map19(1:6,1)=1;
    map19([2 7:11],2)=1;
    map19([3 8 12:15],3)=1;
    map19([9 11 14 15 17 18 19],1)=0.5;
    map19([5 6 13 15 16 18 19],2)=0.5;
    map19([4 6 10 11 16 17 19],3)=0.5;
    jetnew=repmat(map19,[n/19+1 1]);
    jetnew=jetnew(1:n,:);
    jetnew(n,:) = [1 1 1];
    jetnew(1,:) = [0 0 0];
return; 

