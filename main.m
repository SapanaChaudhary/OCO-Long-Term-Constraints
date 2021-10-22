% prediction from expert advice implementation 
function[] = main(T)
%% preliminaries 
d = 2; % dimension of the action space
axis_upper = 1; %uppper bound on observations
L = sqrt(d); %upper bound on action magnitude
G = 2.4 + 1 + 1; %upper bound on gradient of f
m = 3; % # of constraints

%% fmincon options
options = optimoptions('fmincon','Display', 'off'); %,'iter'); %,'Algorithm','active-set');
lb = -axis_upper*ones(d,1); 
ub = axis_upper*ones(d,1); 

%% Generate A and b
sz = [3 2];
A = unifrnd(0,1,sz);

sz2 = [3 1];
b = unifrnd(0,2,sz2);

%% constraint cost (g_t_list)
perm_vec = randperm(T);

for t = 1:T
    c_1 = [2*t^(1/10)*rand - t^(1/10) 2*t^(1/10)*rand - t^(1/10)];
    
    if (t>=1 && t<=1500) || (t>=2000 && t<=3500) || (t>=4000 && t<=5000)
        c_2 = [rand - 1 rand - 1];
    else 
        c_2 = [rand rand];
    end
    c_3 = [(-1)^perm_vec(t) (-1)^perm_vec(t)];
    g_t_list(t,:) = c_1 + c_2 + c_3;
end

%% define starting point
x_curr = zeros(d, 1);

%% Algorithms
% find optimal x
x_star = optimal_x();

[iterates_neely, regret_n, const_violation_n] = Hao_and_Neely(d, m, x_curr, x_star, L, G, T, g_t_list,A, b, lb, ub, options);
[iterates_jenatton, regret_j, const_violation_j] = Jenatton_et_al(d, m, x_curr, x_star, L, G, T, g_t_list, A, b, lb, ub, options);

%% Region of action
figure(1)

x_axis = [-1 -1 1 1 -1]*axis_upper; 
y_axis = [-1 1 1 -1 -1]*axis_upper; 
plot(x_axis,y_axis,'r', 'LineWidth',3)
axis([-1.5 1.5 -1.5 1.5])
hold on;

region_t(1);
region_t(2);
region_t(3);
set(gca,'FontSize',20)
xlabel('x-axis','FontSize',30, 'Interpreter', 'latex');
ylabel('y-axis', 'Interpreter', 'latex','FontSize',30);
hold on;

%% regret plot
figure(2)
plot(regret_n, 'Color', 'b', 'LineWidth',2)
hold on;
plot(regret_j, 'Color', 'r', 'LineWidth',2)
set(gca,'FontSize',20)
xlabel('Time steps (t)','FontSize',30, 'Interpreter', 'latex');
ylabel('$R(t)$', 'Interpreter', 'latex','FontSize',30);
legend('Neely','Jenatton')
grid on

figure(3)
plot(const_violation_n, 'Color', 'b', 'LineWidth',2)
hold on;
plot(const_violation_j, 'Color', 'r', 'LineWidth',2)
set(gca,'FontSize',20)
xlabel('Time steps (t)','FontSize',30, 'Interpreter', 'latex');
ylabel('Constraint Violations', 'Interpreter', 'latex','FontSize',30);
legend('Neely','Jenatton')
grid on

%% """Relevant functions"""
% optimal x for sum of functions
function[x_star] = optimal_x()
    % find x that minimizes sum of functions
    objec = @(x) sum(arrayfun(@(K) g_t_list(K,1)*x(1)+ g_t_list(K,2)*x(2),1:length(g_t_list)));
    nonlcon = [];
    x0 = [1 1]';
    A_optimal =[];
    b_optimal = [];
    Aeq = [];
    beq = [];
    [x_star,abc] = fmincon(objec,x0,A_optimal,b_optimal,Aeq,beq,lb,ub,nonlcon,options);
    clear objec
end

% for plotting constraints
function[h] = region_t(constraint_num)
   X = -(axis_upper+0.5):0.1:(axis_upper+0.5);
   Y = -(axis_upper+0.5):0.1:(axis_upper+0.5);
   [x,y] = meshgrid(X,Y);
   f =  A(constraint_num,1).*x + A(constraint_num,2).*y;
   v = [b(constraint_num,1),b(constraint_num,1)];
   h = contour(x,y,f,v,'LineWidth',3);
   hold on;
end
end