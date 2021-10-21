% projection operator
function[x_new] = do_projection(y_t, lb, ub, options)
    objec = @(x) (sqrt(sum((x-y_t).^2)))^2;
    nonlcon = [];
    x0 = [1 1]';
    AAA = [];
    bbb = [];
    Aeq = [];
    beq = [];
    [x_new,abc] = fmincon(objec,x0,AAA,bbb,Aeq,beq,lb,ub,nonlcon,options);
    clear objec
end