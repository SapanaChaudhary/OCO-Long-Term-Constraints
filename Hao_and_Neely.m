function[iterates, regret, const_violation] = Hao_and_Neely(d, m, x_curr, x_star, L, G, T, g_t_list, A, b, lb, ub, options)
opt_err = zeros(T,1);
regret = zeros(T,1);
const_violation = zeros(T,1);
x_all = zeros(d,T);

gamma = T^(1/4);
beta = sqrt(d);
alpha = (1/2)*(beta^2 + 1)*T^(1/2);
q_curr = zeros(m,1);
b_diff = zeros(m,1);
grad_cons = zeros(d,m);

for t = 1:T
    eta_t = L/(G*sqrt(t));
    theta_t = 6*L*G/sqrt(t);
    mu_t = 1/(theta_t*(t+1));
    
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
    q_temp = grad_cons*b_diff;
    d_temp = grad + q_temp;
    y_new = x_curr - (1/(2*alpha))*d_temp;
    x_curr = do_projection(y_new, lb, ub, options);
    
    % constraint value and gradient of the constraint
    b_curr = A*x_curr;
    b_diff = b_curr - b;
    for i = 1:m
        q_curr(i) = max(-gamma*b_diff(i), q_curr(i) + gamma*b_diff(i));
    end
    
    x_all(:,t) = x_curr; 
    clear grad
end 
iterates = x_all;
end