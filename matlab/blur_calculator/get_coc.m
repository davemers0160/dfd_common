function [err] = get_coc(x)
    global pixel px_size range
    
    f_num = x(1);
    f = x(2);
    d_o = x(3);
    
    dn = (range <= d_o);
    
    d_near = range(dn);
    d_far = range(~dn);
              
    tl = (d_o*f*f)/(f_num*(d_o-f));
    
    coc_far = tl*((1/d_o)-(1./d_far));
    coc_near = tl*((1./d_near) - (1/d_o));
    
    CoC = [coc_near coc_far];  
      
    px = ceil(CoC/px_size);
    %px = ceil(px);
    
    err = sum(abs(pixel - px));
    
end
