#ENV["PYTHON"] = "/home/rjjarvis/miniconda3/bin/python"
#using Pkg
#Pkg.build("PyCall")
using PyCall
using JLD2
using DataFrames
#using METIS
using Metis
using Random
using Test
using SparseArrays
import LightGraphs, Graphs
using Test
using JLD
using CSV, DataFrames
using ProgressMeter


py"""
def get_drosop():
    import pickle
    with open("drosophila_connectome.p","rb") as f:
        dros_adj = pickle.load(f)
        print(type(dros_adj))
        #import pdb
        #pdb.set_trace()
        #dros_adj = dros_adj[:,1:2]
        print(type(dros_adj))



        dros_adj.to_csv(path_or_buf="flybrain.csv")
        print("done saving to CSV")
        #npval = dros_adj
        # sep=',', na_rep='', float_format=None, columns=None, header=True, index=True, index_label=None, mode='w', encoding=None, compression='infer', quoting=None, quotechar='"', line_terminator=None, chunksize=None, date_format=None, doublequote=True, escapechar=None, decimal='.', errors='strict', storage_options=None)
        
    return None#dros_adj,npval.to_numpy()
"""

py"""
def get_net_allen():
    import numpy as np
    import h5dict
    from sonata.circuit import File

    # ## Reading SONATA Network files


    netv1 = File(data_files=['v1_nodes.h5', 
                        'v1_v1_edges.h5',
                        'lgn_v1_edges.h5',
                        'bkg_v1_edges.h5',
                        'lgn_nodes.h5',
                        'bkg_nodes.h5',
                        ], 
            data_type_files=['v1_node_types.csv',
                                'v1_v1_edge_types.csv',
                                'bkg_node_types.csv',
                            ])



    v1_edges = netv1.edges

    return [ netv1.edges[key] for key in v1_edges.population_names]
"""

#(dros_full_nets,npval) = 
#py"get_drosop"()

#csv_reader = CSV.File("flybrain.csv")
println("start loading from CSV Julia")

#df = DataFrame(CSV.File("flybrain.csv"))
#println("done loading from CSV Julia")
#mat = Matrix(df[:, 1:3])

#@show(df[:, 1])
#@show(df[:, 2])
#@show(df[:, 3])
#=
=#
#using Counters
#cnt = Counter{Int}()
mat = load("dros_full_nets.jld", "fly_mat")
w0 = Dict{Int,Array{Int,1}}()
@show(w0)
p = Progress(maximum(mat))
#global cnt 
#global cnt = 1
for preCell = 1:maximum(mat)
    for i = 1:mat[preCell,1]
        #if cnt<maximum(mat)

            if !haskey(w0,i)
                w0[i] = []
    
            end
            postCell = mat[i,2]+1
            if !haskey(w0,postCell)
                w0[postCell] = []  
                #@show(w0)
            end
            push!(w0[postCell],preCell)
            #incr!(cnt,1)
            #global cnt+=1
        #end
    end
    next!(p)

end
#temp = [i for i in df[:,5] if i<0]

#mat = convert(Matrix{Int32},mat)
#sp_mat = convert(Matrix{Int32},sparse(mat))
save("dros_full_nets.jld", "fly_mat", mat)
println("start saving to JLD Julia")
#t
sizeconst = Int(trunc(maximum(mat)/100))
#sp_mat = spzeros(Int(maximum(mat)/1000), Int(maximum(mat)/1000))
sp_mat = spzeros(sizeconst, sizeconst)
for i in mat[:, 1]
    for j in mat[:,2]
        if i<sizeconst
            if j<sizeconst
                #println(Int(i+1)+String(" ")+Int(j+1)+String(" ")+1)
                @show(i)
                @show(j)
                #sp_mat[Int(i+1),Int(j+1)] = 1
            end
        end
    end

    #@show(sp_mat)
end
println("done")
@show(sp_mat)
#m#at = Matrix(df[:, 1];df[:, 2];df[:, 3])

#println(typeof(csv_reader))
#temp = [dros_full_nets.bodyId_pre.values,dros_full_nets.bodyId_post.values]
#mat = Matrix(npval)#{Matrix{Int64}}
#@show(typeof(mat))
#for i in mat
#    i = convert(Int32,mat[1,i])
#end
    #df1=convert(Matrix,[temp[1];temp[2]])
##df1=DataFrames.DataFrame(dros_full_nets);
#mat = mat[:,1:2]#.values
@show(typeof(mat))
gw = Metis.graph(mat; weights=true)
@show(gw.xadj)

save("dros_full_nets.jld", "dros_full_nets", mat)
matrix_fly = convert(Matrix, mat[:,1:2])



#fly_mat = Array(collect(zip(dros_full_nets.bodyId_pre,dros_full_nets.bodyId_post))){Tuple{Int8,Int8}}
#fly_mat_ = Array(collect(zip(dros_full_nets.bodyId_pre,dros_full_nets.bodyId_post)))
matsize = Int(round(Int,sizeof(collect(dros_full_nets.bodyId_pre))/9000))
fly_mat = zeros(Int8,2,Int(matsize))#{Int8,Int8}
@show(sizeof(fly_mat))
for (ind,i) in enumerate(collect(dros_full_nets.bodyId_pre[1:matsize]))
    fly_mat[ind,1] = i
    @show(fly_mat.xadj)
end
for (ind,i) in enumerate(collect(dros_full_nets.bodyId_post[1:matsize]))
    fly_mat[ind,2] = i
    @show(fly_mat.xadj)
end
    #fly_mat[:,2] = [i for i in collect(dros_full_nets.bodyId_post[1:matsize])]
@show(fly_mat.xadj)

gw = Metis.graph(fly_mat; weights=true)
@show(gw.xadj)

allen_sub_nets = py"get_net"()
v1_to_v1 = [i for i in allen_sub_nets[1]]{Int32}
@show(v1_to_v1[1])
#=
for key in v1_edges.population_names:
    @show(key)


for key in v1_edges.population_names:
    exec("g"+str(key)+str(" = nx.Graph()"))
    exec("this_name="+str("g")+str(key))
=#      



#@testset "Metis.graph(::SparseMatrixCSC)" begin
#    rng = MersenneTwister(0)
#S = sprand(rng, Int, 10, 10, 0.2); S = S + S'; fill!(S.nzval, 1)
#foreach(i -> S[i, i] = 0, 1:10); dropzeros!(S)
#g = Metis.graph(S)
#=@test g.xadj == gw.xadj
@test g.adjncy == gw.adjncy
@test g.adjwgt == C_NULL
@test gw.adjwgt == ones(Int, length(gw.adjncy))
G  = SparseMatrixCSC(10, 10, g.xadj, g.adjncy, ones(Int, length(g.adjncy)))
GW = SparseMatrixCSC(10, 10, gw.xadj, gw.adjncy, gw.adjwgt)
@test iszero(S - G)
@test iszero(S - GW)
=#