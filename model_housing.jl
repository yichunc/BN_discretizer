include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")
include("MDL_principle.jl")

f = open("data/housing.data")

x = readlines(f)
data = Array(Any,506,14)
for i = 1 : 506
         str = x[i]
         println(str)
         str_element = split(str)
         #println(str_element)
         for j = 1 : 14
                 if j == 14
                         last_one = str_element[14]
                         data[i,14] = float(split(last_one,"\n")[1])
                 elseif (j in [4,9] )
                         data[i,j] = round(Int64,float(str_element[j]))
                 else
                         data[i,j] = float(str_element[j])
                 end
         end
end

close(f)

graph = [1,(1,14),4,(14,4,3),(3,10),(3,2),(10,2,3,8),(3,8,5),(8,7),(10,3,2,9),(14,1,13),(14,6),(10,12),(9,3,2,11)];
discrete_index = [4,9]
continuous_index = [1,2,3,5,6,7,8,10,11,12,13,14]
<<<<<<< HEAD
cut_time = 10
# my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,cut_time)[2]
# println("my_w_done =========================== ")
# my_disc_edge_wo = BN_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,cut_time,false)[2]
# println("my_wo_done =========================== ")
# MDL_disc =  MDL_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,cut_time)[2]
# println("MDL_done =========================== ")
order = [11,12,6,13,7,5,8,2,10,3,14,1]
my_w = Any[[12.6,12.8,13.3,14.0,14.55,14.75,15.25,15.75,15.95,16.05,16.25,16.5,16.700000000000003,16.85,16.95,17.15,17.35,17.5,17.700000000000003,17.85,17.95,18.1,18.25,18.35,18.45,18.55,18.65,18.75,18.85,19.05,19.15,19.4,19.65,19.9,20.15,20.549999999999997,20.95,21.05,21.15,21.6,22.0],[0.32,357.485,390.525,396.9],[3.561,3.7119999999999997,4.0005,4.253,5.548,6.5425,6.918,7.436999999999999,8.551,8.78],[1.73,4.65,14.895,35.875,37.474999999999994,37.97],[2.9,51.4,66.8,87.5,100.0],[0.385,0.462,0.4665,0.4705,0.491,0.496,0.5125,0.519,0.522,0.528,0.535,0.541,0.5774999999999999,0.601,0.607,0.6114999999999999,0.639,0.651,0.8205,0.871],[1.1296,2.58835,4.750249999999999,11.4184,12.1265],[0.0,6.25,15.0,20.5,26.5,29.0,100.0],[187.0,190.5,222.5,260.0,264.5,276.5,306.0,312.0,377.0,394.5,402.5,407.0,431.0,434.5,453.0,567.5,688.5,711.0],[0.46,3.875,3.9850000000000003,6.145,6.305,6.66,7.625,8.350000000000001,9.795,14.48,16.57,18.84,20.735,23.77,26.695,27.74],[5.0,15.85,28.15,38.3,50.0],[0.00632,0.09215000000000001,6.88166,27.2982,33.15885,39.9405,43.63765,48.44095,59.5283,70.72745,81.25515,88.9762]]
my_wo = Any[[12.6,12.8,13.3,14.0,14.75,19.4,19.9,20.549999999999997,21.6,22.0],[0.32,357.485,390.525,396.9],[3.561,3.7119999999999997,4.0005,5.548,6.0440000000000005,6.5425,7.07,7.436999999999999,8.7525,8.78],[1.73,4.65,9.77,14.895,37.97],[2.9,52.4,63.8,79.45,100.0],[0.385,0.44395,0.446,0.4705,0.491,0.496,0.5125,0.5165,0.522,0.528,0.535,0.541,0.5485,0.5774999999999999,0.601,0.607,0.639,0.651,0.8205,0.871],[1.1296,3.5712,12.1265],[0.0,6.25,15.0,20.5,37.5,42.5,100.0],[187.0,190.5,222.5,260.0,264.5,276.5,302.0,304.5,306.0,309.0,312.0,377.0,387.5,394.5,402.5,407.0,431.0,434.5,453.0,567.5,688.5,711.0],[0.46,3.875,3.9850000000000003,6.145,6.305,7.225,7.625,8.005,9.125,10.3,14.48,16.57,18.84,20.735,27.74],[5.0,15.649999999999999,21.85,28.15,38.3,50.0],[0.00632,0.092825,0.698855,6.88166,48.44095,59.5283,70.72745,81.25515,88.9762]]
mdl = Any[AbstractFloat[12.6,15.25,17.15,17.5,19.15,20.15,20.95,22.0],AbstractFloat[0.32,396.9],AbstractFloat[3.561,8.78],AbstractFloat[1.73,37.97],AbstractFloat[2.9,100.0],AbstractFloat[0.385,0.871],AbstractFloat[1.1296,12.1265],AbstractFloat[0.0,100.0],AbstractFloat[187.0,711.0],AbstractFloat[0.46,27.74],AbstractFloat[5.0,50.0],AbstractFloat[0.00632,88.9762]]
My_w = Array(Any,12);My_wo = Array(Any,12);MDL = Array(Any,12)
ii = 0
for i = 1 : 14
      if i in continuous_index
      ii += 1
      ind = findfirst(order,i)
      My_w[ii] = my_w[ind]; My_wo[ii] = my_wo[ind]; MDL[ii] = mdl[ind]
      end
end

Y1 = sample_from_discetization(graph,data,continuous_index,My_w,500)
Y2 = sample_from_discetization(graph,data,continuous_index,My_wo,500)
Y3 = sample_from_discetization(graph,data,continuous_index,MDL,500)
=======
order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 8
my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,discrete_index,order,cut_time)[2]
println("my_w_done =========================== ")
my_disc_edge_wo = BN_discretizer_iteration_converge(data,graph,discrete_index,order,cut_time,false)[2]
println("my_wo_done =========================== ")
MDL_disc =  MDL_discretizer_iteration_converge(data,graph,discrete_index,order,cut_time)[2]
println("MDL_done =========================== ")
>>>>>>> origin/master

