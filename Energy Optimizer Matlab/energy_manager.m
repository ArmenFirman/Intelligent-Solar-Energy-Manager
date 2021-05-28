function [resultado] = energy_manager(solar_forecast,solar_variance,energy_consumption,buying_price,selling_price,max_load,load_requirement,load_deadline,hour)

%T: time horizon (24 h) k: number of scenarios n: number_apliances
    n=length(max_load);
    T=24;
    k=10;
    
%sigma is the rmse of our solar forecast for a given hour
%mu is the NN forecast
    sigma=solar_variance;
    mu=solar_forecast;
    
%Preallocate vector for increasing perfomance
    Esolar=zeros(T-hour,k);
 
%To generate our scenarios we will add gaussian noise to the NN forecast
    for j=1:(T-hour)
        Esolar(j,:)= sigma(j)*randn(k,1)+mu(j);
    end
%We flatten Esolar from a 2D array to 1D array
    Esolar = Esolar(:).';

%pb: buying_price ps: selling_price EnonDeferrable: energy consumption
%EnonDeferrable: energy consumption from non deferrable loadas
    pb=zeros((T-hour),k);
    ps=zeros((T-hour),k);
    EnonDeferrable=zeros((T-hour),k);

%%%Here create adapt buying_price,selling_price and energy_consumption to
%%%our needs
    for j=1:(T-hour)
        for i=1:k
        pb(j,i)= buying_price(j);
        ps(j,i)= selling_price(j);
        EnonDeferrable(j,i)= energy_consumption(j);
        end
    end
    pb = pb(:).';
    ps = ps(:).';
    EnonDeferrable = EnonDeferrable(:).';
%We transform a py.list objt into an object Matlab equivalent data type
    max_load=cell2mat(cell(max_load));
    load_requirement=cell2mat(cell(load_requirement));
    load_deadline=cell2mat(cell(load_deadline));

%%% To handle the non-linearity of our problem, we will take advantage of
%%% the fact that our function is a piecewise linear convex function
%%% In the documentation, the Obj creation will be discussed
    Obj=zeros(1,n*(T-hour));
    Obj=[Obj,ones(1,(T-hour)*k)];
    Obj=(1/k)*Obj;

%%%Creating equalities constraints
%%%Those constraint will make sure that all the appliances get enough energy
%%%before reaching there deadlines
    B_eq=zeros(1,n);
    for i=1:n
       B_eq(i)=load_requirement(i);
    end
    A_eq=zeros(n,(T-hour)*(n+k));

    for i=1:n
       for t=1:load_deadline(i)
           A_eq(i,i+(t-1)*4)=1;
       end
    end
%%%Creating inequalities contraints
%%%Those constraints are a consequence of the non-linear nature of our
%%%problem
%%%The explanation will be discussed on the documentation

%Firt we create the Z(w,t) matrix, i.e the auxiliar variables matrix
    A_AuxVar=-eye((T-hour)*k);

%We preallocate the indexes
    Indexation_A=zeros((T-hour),1);
    Indexation_A(1,1)=1;
    for index=2:(T-hour)
        Indexation_A(index,1)=Indexation_A(index-1,1)+n;
    end

%%We create the A matrix
    A_Aux_VEnergia=zeros(T-hour,(T-hour)*n);
    A_Aux_CEnergia=zeros(T-hour,(T-hour)*n);
    A_VEnergia=[];
    A_CEnergia=[];
    for scenario1=1:k
    for t=1:(T-hour)
    for i=0:(n-1)
       A_Aux_VEnergia(t,Indexation_A(t,1)+i)=selling_price(t);
       A_Aux_CEnergia(t,Indexation_A(t,1)+i)=buying_price(t);
    end
    end
    A_VEnergia=[A_VEnergia;A_Aux_VEnergia];
    A_CEnergia=[A_CEnergia;A_Aux_CEnergia];
    end

    A_VEnergia=[A_VEnergia,A_AuxVar];
    A_CEnergia=[A_CEnergia,A_AuxVar];
    A=[A_VEnergia;A_CEnergia];
    
%we create the b vector with its constants
    b_excedentes=-ps.*Esolar+ps.*EnonDeferrable;
    b_compra=-pb.*Esolar+pb.*EnonDeferrable;
    B=[b_excedentes,b_compra];

%Lower bound
    lb=zeros(1,(T-hour)*(n+1));
    for t=1:((T-hour)*(n+k))
        if(t<=(T-hour)*n)
            lb(t)=0;
        else
            lb(t)=-inf;
        end
    end
%Upper bound
    ub=inf(1,(T-hour)*(n+k));
    for i=1:n
        for t=1:(T-hour)
           ub(1,i+(t-1)*4)=max_load(i);
       end
    end
%Resolvemos por primera vez
resultado=linprog(Obj,A,-B,A_eq,B_eq,lb,ub);
end