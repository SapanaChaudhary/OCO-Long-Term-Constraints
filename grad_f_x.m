% true function grad
function[deriv] = grad_f_x(g_t) 
    deriv = zeros(d,1);
    for ii = 1:d
        deriv(ii,1) = g_t(ii);
    end
end