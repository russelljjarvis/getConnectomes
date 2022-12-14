using HDF5, FileIO
using Revise
using SparseArrays
##
# Download files link
#https://cloudstor.aarnet.edu.au/plus/s/fFOrhM2ZrIAClZa
##

download("https://cloudstor.aarnet.edu.au/plus/s/fFOrhM2ZrIAClZa")
function get_full_arrays()
    """
    Int64 is used rather than Int32 because 70million is a big number and all values in between must be represented.
    """
    h5f = h5open("v1_source_node_id.h5","r") 
    srcs = Vector{Int64}(read(h5f["source_node_id"]))
    close(h5f)
    h5f = h5open("v1_target_node_id.h5","r") 
    tgts = Vector{Int64}(read(h5f["target_node_id"]))
    close(h5f)
    return (srcs, tgts)    
end

function get_weights_delays(begin_,end_)
    h5f = h5open("v1_node_id_e.h5","r") 
    enodes = Vector{Int64}(read(h5f["node_id_e"]))
    close(h5f)
    h5f = h5open("v1_node_id_i.h5","r") 
    inodes = Vector{Int64}(read(h5f["node_id_i"]))
    close(h5f)
    h5f = h5open("v1_syn_weight.h5","r") 
    syn_weights = Vector{Int64}(read(h5f["syn_weight"])[begin_:end_])   
    close(h5f)
    h5f = h5open("v1_delay.h5","r") 
    delays = Vector{Int64}(read(h5f["delay"])[begin_:end_])   
    close(h5f)
    h5f = h5open("v1_nsyns.h5","r")
    nsyns = Vector{Int64}(read(h5f["nsyns"])[begin_:end_])
    close(h5f)

    return (enodes,inodes,syn_weights,delays,nsyns)
end


function get_subset_array()
    (srcs, tgts) = get_full_arrays()
    total_length = Int64(length(srcs))
    stride_division_constant = Int64(floor(total_length/100.0))
    begin_ = stride_division_constant
    end_ = stride_division_constant*2
    slimited = srcs[begin_:end_]
    tlimited = tgts[begin_:end_]
    (enodes,inodes,syn_weights,delays,nsyns) = get_weights_delays(begin_,end_)

    # Move this transformation to the saved format to speed things up.
    # compensate for Julia's base 1 indexing of arrays.
    slimited = [i+1 for i in slimited]
    tlimited = [i+1 for i in tlimited]
    enodes = [i+1 for i in enodes]
    inodes = [i+1 for i in inodes]

    mat_size = Int64(maximum([maximum(slimited), maximum(tlimited)]))
    exc_matrix = inhib_matrix = spzeros(mat_size ,mat_size)
    for (ind,(i,j)) in enumerate(zip(slimited,tlimited))
        if Int64(i) in enodes
            exc_matrix[Int64(i),Int64(j)] = syn_weights[Int64(ind)]
        elseif Int64(i) in inodes
            inhib_matrix[Int64(i),Int64(j)] = syn_weights[Int64(ind)]
        else
            print("this should condition should never be met")
            println("no synapse polarity")
        end
    end
    return (exc_matrix,inhib_matrix,slimited, tlimited,stride_division_constant,total_length)
end

(exc_matrix,inhib_matrix,slimited, tlimited,stride_division_constant,total_length) = get_subset_array()
