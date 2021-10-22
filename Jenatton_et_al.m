% Implementation of Algorithm in Adaptive algorithms for 
% online convex optimization with long-term constraints
function[iterates, regret, const_violation] = Jenatton_et_al(d, m, x_curr, x_star, L, G, T, g_t_list, A, b, lb, ub, options)
opt_err = zeros(T,1);
regret = zeros(T,1);
const_violation = zeros(T,1);
x_all = zeros(d,T);

lambda_curr = 0; 

for t = 1:T
    eta_t = L/(G*sqrt(t));
    theta_t = 6*L*G/sqrt(t);
    mu_t = 1/(theta_t*(t+1));
    
    % constraint value and gradient of the constraint
    b_curr = A*x_curr;
    [int_cons_t, indx] = max(b_curr);
    cons_t = int_cons_t - b(indx);
    grad_cons_t = A(indx,:)';
    
    %record regret
    g_t = g_t_list(t,:); 
    opt_err(t) = f_x(x_curr,g_t) - f_x(x_star,g_t);
    regret(t) = sum(opt_err);
    
    %record violations
    err = max(A*x_curr - b);
    if err >0
        cons_err(t) = err;
    else 
        cons_err(t) = 0;
    end
    const_violation(t) = sum(cons_err);
    
    %take next step
    grad = g_t';
    y_new = x_curr - eta_t*grad - eta_t*lambda_curr*grad_cons_t;
    x_curr = do_projection(y_new, lb, ub, options);
    lambda_curr = max(0, (1 - mu_t*theta_t)*lambda_curr + mu_t*cons_t);
    
    x_all(:,t) = x_curr; 
    clear grad
end 
iterates = x_all;
end