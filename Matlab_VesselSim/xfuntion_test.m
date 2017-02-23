function xfuntion_test
    global r
    r.a = 1;
    r.b = 2;
    
    disp(['r.a = ',num2str(r.a)]);
    
    setra;
    
    disp(['r.a = ',num2str(r.a)]);
    
return;

function setra
    global r
    r.a = 10;
return;