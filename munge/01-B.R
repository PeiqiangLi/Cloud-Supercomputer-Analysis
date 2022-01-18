# # Example preprocessing script.
# clusterA = X10000000_102085486928524_1722343428282384384_n
# clusterA = clusterA[order(clusterA$timestamp),]
# clusterA = cbind(order = dense_rank(clusterA$timestamp),
#                  date_time = as.POSIXct(clusterA$timestamp, origin="1970-01-01", tz="UTC"),
#                  clusterA)
# clusterA = cbind(hour=format(as.POSIXct(clusterA$date_time), format ="%d %H"),clusterA)
# # clusterA = clusterA %>% mutate(order = dense_rank(clusterA$timestamp))
# clusterC = X10000000_203476113398092_2646434590096359424_n
# clusterC = clusterC[order(clusterC$timestamp),]
# clusterC = cbind(order = dense_rank(clusterC$timestamp),
#                  date_time = as.POSIXct(clusterC$timestamp, origin="1970-01-01", tz="UTC"),
#                  clusterC)
# 
# # package length each point of time
# packet_lengthA = clusterA %>% 
#   group_by(order) %>% 
#   summarise(
#     order = order,
#     date_time = date_time,
#     packet_length = sum(`packet length (1)`)
#   ) %>% distinct()

#########


