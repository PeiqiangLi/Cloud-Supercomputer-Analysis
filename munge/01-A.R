select = dplyr::select
# Clean the data

# remove the duplicated data
application.checkpoints = unique(application.checkpoints)
gpu = unique(gpu)
task.x.y = unique(task.x.y)

# format the datatime
application.checkpoints$timestamp = as.POSIXct(application.checkpoints$timestamp, format="%Y-%m-%dT%H:%M:%OS")
gpu$timestamp = as.POSIXct(gpu$timestamp, format="%Y-%m-%dT%H:%M:%OS")

# application.checkpoints %>%
#   filter(eventName == "TotalRender") %>%
#   select(timestamp,eventName,eventName,eventType,taskId,jobId) %>%
#   group_by(eventType)



