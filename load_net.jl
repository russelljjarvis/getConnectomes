using Pkg
using CSV
using HDF5
v1_nodes = h5open("v1_nodes.h5", "r")
edges = h5open("v1_v1_edges.h5", "r")
src_target_iterator = edges["edges"]["v1_to_v1"]["indicies"]["source_to_target"]["node_id_to_range"]
edges["edges"]["v1_to_v1"]["indicies"]["source_to_target"]["range_to_edge_id"][1,:]
@show(sizeof(src_target_iterator[1,:]))
conn_list=[]
for (x,i) in enumerate(collect(src_target_iterator))
    append!(conn_list,(x,Int32(i)))

end
@show(conn_list)
