include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = readcsv("data/indian.csv")

data = Array(Any,579,11)

ind = 0
for i = 1 : length(f[:,1])
    if ~(i in [313,254,242,210])
        ind += 1
        data[ind,:] = f[i,:]
        if data[ind,2] == "Male"
            data[ind,2] = 1
        else
            data[ind,2] = 2
        end
    end
end


discrete_index = [2,11]
continuous_index = [1,3,4,5,6,7,8,9,10]

#data_integer = Array(Int64,size(data))
#for i = 1 : 10
#      if i in continuous_index
#               data_integer[:,i] = equal_width_disc(data[:,i],2)
#      else
#               data_integer[:,i] = data[:,i]
#      end
#end

#times = 10
#X = K2(data_integer,10,times)

graph = [4,6,11,3,(6,7),(7,4,5),10,(10,4,5,9),(9,4,5,6,1),(9,10,7,3,8),(5,2)]

Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 5

n_fold = 10
data_group = cross_vali_data(n_fold,data)

log_li_my_w = 0; log_li_my_wo = 0; log_li_MDL = 0
for fold = 1 : n_fold
    println("fold = ", fold,"==============================")
    train_data = 0; test_data = 0
    if fold == 1
        test_data = data_group[fold]
        train_data = data_group[2]
        for j = 3 : n_fold
            train_data = [train_data;data_group[j]]
        end
    else
        test_data = data_group[fold]
        train_data = data_group[1]
        for j = 2 : n_fold
            if j != fold
                train_data = [train_data;data_group[j]]
            end
        end
    end

    #my_w_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    #reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
    reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
    #Li_my_w = likelihood_conti(graph,train_data,continuous_index,reorder_my_w_edge,test_data,1)
    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)
    #log_li_my_w += Li_my_w
    log_li_my_wo += Li_my_wo
    log_li_MDL += Li_MDL
    println(log_li_my_w,log_li_my_wo,log_li_MDL)

end

println(log_li_my_w,log_li_my_wo,log_li_MDL)

#my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

##############
### Result ###
##############

# graph = [4,6,11,3,(6,7),(7,4,5),10,(10,4,5,9),(9,4,5,6,1),(9,10,7,3,8),(5,2)];
# Likelihood = (-20342.09161863941,-23631.94380877098)
# my_discretization = ([4.0,90.0],[0.4,37.7,58.9,75.0],[0.1,15.65,19.7],[63.0,2110.0],[10.0,363.5,1840.0,2000.0],[10.0,469.0,2273.0,3937.5,4929.0],[2.7,9.6],[0.9,2.55,3.45,5.5],[0.3,0.655,0.835,0.985,1.14,2.2,2.65,2.8])
# MDL_discretization = ([4.0,90.0],[0.4,75.0],[0.1,19.7],[63.0,2110.0],[10.0,2000.0],[10.0,4929.0],[2.7,9.6],[0.9,5.5],[0.3,2.8])
