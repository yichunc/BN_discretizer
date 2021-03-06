include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = open("data/bupa.data")

x = readlines(f)
data = Array(Any,345,7)
for i = 1 : 345
         str = x[i]
         println(str)
         str_element = split(str,",")
         for j = 1 : 7
                 if j == 7
                         last_one = str_element[7]
                         data[i,7] = round(Int64,float(split(last_one,"\n")[1]))
                 #elseif j == 6
                 #        data[i,6] = round(Int64,float(str_element[j]))
                 else
                         data[i,j] = float(str_element[j])
                 end
         end
end

close(f)

discrete_index = [7]
continuous_index = [1,2,3,4,5,6]

#data_integer = Array(Int64,size(data))
#for i = 1 : 7
#      if i in continuous_index
#                data_integer[:,i] = equal_width_disc(data[:,i],2)
#      else
#                 data_integer[:,i] = data[:,i]
#      end
#end
#
#times = 1000
#X = K2(data_integer,1,times)

#cut_time = 5
#u = 6; times = 50;
#A = K2_w_discretization(data,u,continuous_index,times,cut_time,false)



graph = [3,(3,5),1,(3,5,4),(4,7),(3,4,6),(5,6,2)]
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

    my_w_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
    reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
    Li_my_w = likelihood_conti(graph,train_data,continuous_index,reorder_my_w_edge,test_data,1)
    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)
    log_li_my_w += Li_my_w
    log_li_my_wo += Li_my_wo
    log_li_MDL += Li_MDL
    println(log_li_my_w,log_li_my_wo,log_li_MDL)

end

println(log_li_my_w,log_li_my_wo,log_li_MDL)

my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

##############
### Result ###
##############

# graph = [3,(3,5),1,(3,5,4),(4,7),(3,4,6),(5,6,2)];
# Likelihood = (-8188.168714487385,-9166.648376038698)
# my_discretization = ([65.0,84.0,103.0],[23.0,138.0],[4.0,41.5,49.0,95.0,155.0],[5.0,31.5,44.0,82.0],[5.0,50.5,72.0,297.0],[0.0,6.5,20.0])
# MDL_discretization = ([65.0,84.0,103.0],[23.0,138.0],[4.0,155.0],[5.0,82.0],[5.0,297.0],[0.0,20.0])
