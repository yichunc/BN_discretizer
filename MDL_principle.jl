include("likelihood_calculation.jl")

function mi_child(data,c1,c2)
        N = length(data[:,1])
        n = length(data[1,:])

        # build carti product
        carti_set = [tuple(unique(data[:,1])...)]

        for i = 2 : n
                carti_set = [carti_set,tuple(unique(data[:,i])...)]
        end

        CP = cartesian_product(carti_set)

        # Distribution wo disc

        p_distri = Array(Any,length(CP[:,1]))

        for i = 1 : length(CP[:,1])
                count = 0
                for j = 1 : N
                        if CP[i,:] == data[j,:]
                                count += 1
                        end
                end
                p_distri[i] = count
        end

        # Distribution within ci cj

        pc_distri = Array(Any,length(CP[:,1]))

        for i = 1 : length(CP[:,1])
                count = 0
                for j = c1 : c2
                        if CP[i,:] == data[j,:]
                                count += 1
                        end
                end
                pc_distri[i] = count
        end
        #println(pc_distri)
        # normalize
        p_distri = p_distri/N
        pc_distri = pc_distri/N
        pc = (c2-c1+1)/N

        # Evaluation MI value
        mi = 0

        for i = 1 : length(CP[:,1])
                if pc_distri[i] != 0
                        add_term = pc_distri[i] * ( log(pc_distri[i]) -
                              log(pc) - log(p_distri[i]))
                        mi += add_term

                end
        end


        return mi
end

function mi_child_table(data)
        N = length(data[:,1])
        n = length(data[1,:])

        # build carti product
        carti_set = [tuple(unique(data[:,1])...)]

        for i = 2 : n
                carti_set = [carti_set,tuple(unique(data[:,i])...)]
        end

        CP = cartesian_product(carti_set)

        # Distribution of parent
        p_distri = Array(Any,length(CP[:,1]))

        for i = 1 : length(CP[:,1])
                count = 0
                for j = 1 : N
                        if CP[i,:] == data[j,:]
                                count += 1
                        end
                end
                p_distri[i] = count
        end

        p_distri = p_distri/N

        # Distribution of all within i and j
        pc_distri = zeros(Float64,N,N,length(CP[:,1]))

        for i = 1 : N
                for j = 1 : length(CP[:,1])
                        if CP[j,:] == data[i,:]
                                pc_distri[i,i,j] = 1
                        end
                end

        end

        for i = 1 : N
                for j = i+1 : N
                        previous = copy(pc_distri[i,j-1,:])
                        for k = 1 : length(CP[:,1])
                                if CP[k,:] == data[j,:]
                                        previous[k] += 1
                                end
                        end
                        pc_distri[i,j,:] = previous

                end
        end

        pc_distri = pc_distri/N

        # Distribution of continuous variable itsel
        pc = Array(Float64,N,N)
        for i = 1 : N
                for j = 1 : N
                        pc[i,j] = (j-i+1)/N
                end
        end

        # MI
        mi = zeros(Float64,N,N)
        for i = 1 : N
        for j = 1 : N
                mi_current = 0
                for k = 1 : length(CP[:,1])
                        if pc_distri[i,j,k] != 0
                                mi_current += pc_distri[i,j,k] * ( log(pc_distri[i,j,k]) -
                                              log(pc[i,j]) - log(p_distri[k]))
                        end
                end
                mi[i,j] = mi_current
        end
        end

        return mi
end


function mi_parent(data,c1,c2)
        # first one is the child
        N = length(data[:,1])
        n_p = length(data[1,:]) - 1

        # p1_distri wo discri
        child_uniq = unique(data[:,1])
        p1_distri = Array(Any,length(child_uniq))

        for i = 1 : length(child_uniq)
                count = 0
                for j = 1 : N
                    if child_uniq[i] == data[j,1]
                            count += 1
                    end
                end
                p1_distri[i] = count
        end

        p1_distri = p1_distri/N

        if length(data[1,:]) == 1
        # If there is no other variable
        p2_distri = Array(Any,length(child_uniq))

        for i = 1 : length(child_uniq)
                count = 0
                for j = c1 : c2
                    if child_uniq[i] == data[j,1]
                            count += 1
                    end
                end
                p2_distri[i] = count
        end
        p2_distri = p2_distri/N

        # mi for no spouse case

        mi = 0
        for i = 1 : length(child_uniq)
                if p2_distri[i] != 0
                        mi += p2_distri[i] * ( log(p2_distri[i]) -
                        log(p1_distri[i]) - log((c2-c1+1)/N)      )
                end
        end
        return mi

        end # if for no spouse case

        # -------------------------------------------------------------

        # build carti product on parent set
        carti_set = [tuple(unique(data[c1:c2,2])...)]

        for i = 3 : length(data[1,:])
                carti_set = [carti_set,tuple(unique(data[c1:c2,i])...)]
        end

        CP = cartesian_product(carti_set)


        # p_distri w discri

        p_distri = Array(Any,length(CP[:,1]))
        for i = 1 : length(CP[:,1])
                count = 0
                for j = c1 : c2
                        if CP[i,:] == data[j,2:end]
                                count += 1
                        end
                end
                p_distri[i] = count
        end

        p_distri = p_distri / N

        # p_c_distri w dis

        carti_pc_set = [carti_set, tuple(child_uniq...)]
        CP_pc = cartesian_product(carti_pc_set)
        p_c_distri = Array(Any,length(CP_pc[:,1]))
        l_c = length(CP[:,1])

        for i = 1 : length(CP_pc[:,1])
                count = 0
                for j = c1 : c2
                        data_reform = [data[j,2:end] data[j,1]]
                        if CP_pc[i,:] == data_reform
                                count += 1
                        end
                end
                p_c_distri[i] = count
        end
        p_c_distri = p_c_distri/N

        # Evaluation

        mi = 0

        for i = 1 : length(CP_pc[:,1])
                # index for child
                index_c = div(i-1,l_c) + 1
                # index for parent set
                index_p = (i)%l_c
                if index_p == 0
                        index_p = l_c
                end

                # addition
                if p_c_distri[i] != 0
                        number = p_c_distri[i]*(
                        log(p_c_distri[i]) - log(p1_distri[index_c]) - log(p_distri[index_p]))
                        mi += number
                end
        end


        return mi
end

function mi_parent_table(data)
        N = length(data[:,1])
        n = length(data[1,:])

        # p1 distri wo discretization
        child_uniq = unique(data[:,1])
        p1_distri = Array(Any,length(child_uniq))
        for i = 1 : length(child_uniq)
                count = 0
                for j = 1 : N
                        if child_uniq[i] == data[j,1]
                                count += 1
                        end
                end
                p1_distri[i] = count
        end
        p1_distri = p1_distri/N

        # if there is no other variable
        if length(data[1,:]) == 1

        p2_distri = zeros(Float64,N,N,length(child_uniq))
        for i = 1 : N
                  for k = 1 : length(child_uniq)
                          count = 0
                          if child_uniq[k] == data[i,1]
                                  count += 1
                          end
                          p2_distri[i,i,k] = count
                  end
        end

       for i = 1 : N
               for j = i+1 : N
                       previous = copy(p2_distri[i,j-1,:])
                       for k = 1 : length(child_uniq)
                               if child_uniq[k] == data[j,1]
                                       previous[k] += 1
                               end
                       end
                       p2_distri[i,j,:] = previous
                end
        end
        p2_distri = p2_distri/N

        mi = zeros(Float64,N,N)
        for i = 1 : N
                for j = i : N
                        for k = 1 : length(child_uniq)
                                if p2_distri[i,j,k] != 0
                                mi[i,j] += p2_distri[i,j,k] * ( log(p2_distri[i,j,k]) -
                                          log(p1_distri[k]) - log((j-i+1)/N)      )
                                end
                        end
                end
        end
        return mi
        end

        # the case that more than one variable for data
        carti_set = [tuple(unique(data[:,2])...)]
        for i = 3 : length(data[1,:])
                carti_set = [carti_set; tuple(unique(data[:,i])...)]
        end

        CP = cartesian_product(carti_set)

        # p_distribution w discri
        p_distri = zeros(Float64,N,N,length(CP[:,1]))
        for i = 1 : N
                for k = 1 : length(CP[:,1])
                        if CP[k,:] == data[i,2:end]
                                p_distri[i,i,k] += 1
                        end
                end
        end

        for i = 1 : N
                for j = i+1 : N
                        previous = copy(p_distri[i,j-1,:])
                        for k = 1 : length(CP[:,1])
                                if CP[k,:] == data[j,2:end]
                                        previous[k] += 1
                                end
                        end
                        p_distri[i,j,:] = previous
                end
        end
        p_distri = p_distri/N

        # pc_distri w discri
        carti_pc_set = [carti_set; tuple(child_uniq...)]
        CP_pc = cartesian_product(carti_pc_set)
        p_c_distri = zeros(Float64,N,N,length(CP_pc[:,1]))
        l_c = length(CP[:,1])

        for i = 1 : N
                for k = 1 : length(CP_pc[:,1])
                        if CP_pc[k,:] == [data[i,2:end] data[i,1]]
                                p_c_distri[i,i,k] += 1
                        end
                end
        end

        for i = 1 : N
                for j = i+1 : N
                        previous = copy(p_c_distri[i,j-1,:])
                        for k = 1 : length(CP_pc[:,1])
                                if CP_pc[k,:] == [data[j,2:end] data[j,1]]
                                        previous[k] += 1
                                end
                        end
                        p_c_distri[i,j,:] = previous
                end
        end
        p_c_distri = p_c_distri/N

        # MI
        mi = zeros(Float64,N,N)
        for i = 1 : N
                for j = i : N
                        for k = 1 : length(CP_pc[:,1])
                                index_c = div(k-1,l_c) + 1
                                index_p = k%(l_c)
                                if index_p == 0
                                        index_p = l_c
                                end

                                if p_c_distri[i,j,k] != 0
                                mi[i,j] += p_c_distri[i,j,k]*(
                        log(p_c_distri[i,j,k]) - log(p1_distri[index_c]) - log(p_distri[i,j,index_p]))

                                end
                        end
                end
        end
        return mi

end


function mi_table(data,parents,child_spouse_set)
        N = length(data[:,1])
        mi_tb = zeros(Float64,N,N)
        for i = 1 : N
        for j = 1 : N
                if i > j
                        mi_tb[i,j] = Inf
                else
                        if (j%50) == 0; println((i,j)); end
                        mi = 0
                        # Add MI by parent set
                        if length(parents) != 0
                        data_parent = Array(Int64,N,length(parents))
                        for k = 1 : length(parents)
                                data_parent[:,k] = data[:,parents[k]]
                        end

                        mi += mi_child(data_parent,i,j)
                        end

                        if length(child_spouse_set) != 0
                        # Add MI by each child_spouse set
                        for k = 1 : length(child_spouse_set)
                                cs_set = child_spouse_set[k]
                                data_cs = Array(Int64,N,length(cs_set))
                                for l = 1 : length(cs_set)
                                        data_cs[:,l] = data[:,cs_set[l]]
                                end
                                mi += mi_parent(data_cs,i,j)
                        end
                        end

                        mi_tb[i,j] = mi
                end
        end
        end

        return mi_tb
end

function mi_table_2(data,parents,child_spouse_set)
        N = length(data[:,1])
        mi_tb = zeros(Float64,N,N)

        # parent part
        if length(parents) != 0
                data_parent = Array(Int64,N,length(parents))
                for k = 1 : length(parents)
                        data_parent[:,k] = data[:,parents[k]]
                end
                mi_tb =  mi_child_table(data_parent)
        end


        # child_spouse case
        if length(child_spouse_set) != 0
        for k = 1 : length(child_spouse_set)
                cs_set = child_spouse_set[k]
                data_cs = Array(Int64,N,length(cs_set))
                for l = 1 : length(cs_set)
                        data_cs[:,l] = data[:,cs_set[l]]
                end
                mi_tb += mi_parent_table(data_cs)
        end
        end

        # non-realistic case
        for i = 1 : N
                for j = 1 : i-1
                      mi_tb[i,j] = Inf
                end
        end

        return mi_tb
end

function H(p)
    if p == 0
        return 0
    else
        return -p*log(p) - (1-p)*log(1-p)
    end
end

function MDL_discretizer(continuous,data_matrix,parent_set,child_spouse_set)
        mi_tb = mi_table_2(data_matrix,parent_set,child_spouse_set)
        N = length(continuous)

        smallest_value = Array(Float64,N,N)
        optimal_disc = Array(Array,N,N)

        for i = 1 : N
                for j = 1 : N
                        if i > j
                                smallest_value[j,i] = Inf
                                optimal_disc[j,i] = [0]
                        end
                end
        end

        parent_cardi = 1
        for i = 1 : length(parent_set)
                parent_cardi = parent_cardi * length(unique(data_matrix[:,parent_set[i]]))
        end

        child_cardi = 0
        for i = 1 : length(child_spouse_set)
                add_term = length(unique(data[:,child_spouse_set[i][1]]))-1
                for j = 2 : length(child_spouse_set[i])
                        add_term = add_term * length(unique(data[:,child_spouse_set[i][j]]))
                end
                child_cardi += add_term
        end

        #return child_cardi
        l_code = 0.5 * log(N)
        Ni = length(unique(continuous))

        # Iteration to find optimal intervals

        for k = 1 : N # k is number of intervals
                for j = k : N # end of the last interval
                        if k == 1
                                smallest_value[j,k] = - mi_tb[1,j] * N
                                optimal_disc[j,k] = [j]
                        else
                                #println(k)
                                current_value = Inf
                                min_index = 0


                                for i = 1 : j-1
                                        second_piece_value = - mi_tb[i+1,j] * N
                                        temp_value = smallest_value[i,k-1] + second_piece_value
                                        #if (k == 2) & (j == N); println(("i=",i,temp_value)); end

                                        if temp_value < current_value
                                                current_value = temp_value
                                                min_index = i
                                        end

                                end

                                smallest_value[j,k] = current_value
                                optimal_disc[j,k] = [optimal_disc[min_index,k-1] [j]]

                        end
                end
        end

        full_length_k_intval = copy(smallest_value[N,:])
        #println(("optimal_disc_2",optimal_disc[N,2]))

        for l = 1:N
                #println((l,"------------------------------"))
                #println(full_length_k_intval[l] )
                full_length_k_intval[l] += l_code*parent_cardi*(l-1) + l_code*child_cardi*l +
                                           log(l) + (Ni-1)*H((l-1)/(Ni-1))
                #println(full_length_k_intval[l] )
        end

        desired_intval_number = indmin(full_length_k_intval)



        bin_edges_index = optimal_disc[N,desired_intval_number]

        bin_edges = [[1] bin_edges_index]


        bin_edge_value = Array(FloatingPoint,length(bin_edges))

        for index = 1 : length(bin_edge_value)
            if index == 1
                    bin_edge_value[index] = continuous[1]
            elseif index == length(bin_edge_value)
                    bin_edge_value[index] = continuous[end]
            else
                    bin_edge_value[index] = 0.5*(continuous[bin_edges[index]]+
                                             continuous[bin_edges[index]+1])
            end


        end
        return (bin_edge_value,mi_tb)
end

###############################################################
####  Allow continuous variable values have repetition ########
###############################################################

function MDL_discretizer_rep(continuous,data_matrix,parent_set,child_spouse_set)
        mi_tb = mi_table_2(data_matrix,parent_set,child_spouse_set)
        N = length(continuous)

        parent_cardi = 1
        for i = 1 : length(parent_set)
                parent_cardi = parent_cardi * length(unique(data_matrix[:,parent_set[i]]))
        end

        child_cardi = 0
        for i = 1 : length(child_spouse_set)
                add_term = length(unique(data[:,child_spouse_set[i][1]]))-1
                for j = 2 : length(child_spouse_set[i])
                        add_term = add_term * length(unique(data[:,child_spouse_set[i][j]]))
                end
                child_cardi += add_term
        end

        #return child_cardi

        l_code = 0.5 * log(N)


        # continuous unqiue index
        conti_norep = unique(continuous)
        conti_head = Array(Int64,length(conti_norep))
        conti_tail = Array(Int64,length(conti_norep))
        Ni = length(conti_norep)


        conti_head[1] = 1
        index_head = 1
        for i = 2 : N
                if continuous[i] != continuous[i-1]
                        index_head += 1
                        conti_head[index_head] = i
                end
        end

        conti_tail[end] = N
        index_tail = length(conti_norep)
        for i = N-1 : -1 : 1
                if continuous[i] != continuous[i+1]
                        index_tail -= 1
                        conti_tail[index_tail] = i
                end
        end


        smallest_value = Array(Float64,Ni,Ni)
        optimal_disc = Array(Array,Ni,Ni)


        for i = 1 : Ni
                for j = 1 : Ni
                        if i > j
                                smallest_value[j,i] = Inf
                                optimal_disc[j,i] = [0]
                        end
                end
        end


        # Iteration to find optimal intervals

        for k = 1 : Ni # k is number of intervals
                for j = k : Ni # end of the last interval
                        if k == 1
                                smallest_value[j,k] = - mi_tb[1,conti_tail[j]] * N
                                optimal_disc[j,k] = [conti_tail[j]]
                        else
                                #println(k)
                                current_value = Inf
                                min_index = 0


                                for i = 1 : j-1
                                        second_piece_value = - mi_tb[conti_head[i+1],conti_tail[j]] * N
                                        temp_value = smallest_value[i,k-1] + second_piece_value

                                        if temp_value < current_value
                                                current_value = temp_value
                                                min_index = i
                                        end

                                end

                                smallest_value[j,k] = current_value
                                optimal_disc[j,k] = [optimal_disc[min_index,k-1] [conti_tail[j]]]

                        end
                end
        end

        full_length_k_intval = copy(smallest_value[Ni,:])



        for l = 1:Ni
                full_length_k_intval[l] += l_code*parent_cardi*(l-1) + l_code*child_cardi*l + (Ni-1)*H((l-1)/(Ni-1)) + log(l)
                                           #log(l) + lfact(Ni-1) - lfact(l-1) - lfact(Ni-l)
                                           #(Ni-1)*H((l-1)/(Ni-1))
        end

        #return full_length_k_intval
        desired_intval_number = indmin(full_length_k_intval)

        bin_edges_index = optimal_disc[Ni,desired_intval_number]

        bin_edges = [[1] bin_edges_index]


        bin_edge_value = Array(FloatingPoint,length(bin_edges))

        for index = 1 : length(bin_edge_value)
            if index == 1
                    bin_edge_value[index] = continuous[1]
            elseif index == length(bin_edge_value)
                    bin_edge_value[index] = continuous[end]
            else
                    bin_edge_value[index] = 0.5*(continuous[bin_edges[index]]+
                                             continuous[bin_edges[index]+1])
            end


        end
        return (bin_edge_value,mi_tb)
end
