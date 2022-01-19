# remove the duplicated data
application.checkpoints = unique(application.checkpoints)
gpu = unique(gpu)
task.x.y = unique(task.x.y)

application.checkpoints$timestamp = as.POSIXct(application.checkpoints$timestamp, format="%Y-%m-%dT%H:%M:%OS")
gpu$timestamp = as.POSIXct(gpu$timestamp, format="%Y-%m-%dT%H:%M:%OS")

# application.checkpoints %>%
#   filter(eventName == "TotalRender") %>%
#   select(timestamp,eventName,eventName,eventType,taskId,jobId) %>%
#   group_by(eventType)

# find the start and stop time
task_time = merge(application.checkpoints %>% 
                        filter(eventType == "STOP") %>%
                        select(timestamp,taskId,eventName,eventType),
                      application.checkpoints %>% 
                        filter(eventType == "START") %>%
                        select(timestamp,eventName,eventType,taskId), 
                  by = c("eventName","taskId"),
                  all = T)
# calculate the runing time
task_time = task_time %>% mutate(duration = as.numeric(timestamp.x)-as.numeric(timestamp.y))

# mean running time of different event type
mean_task_time = data.frame(eventType = c("TotalRender","Render","Uploading","Tiling","Saving Config"),
                            duration = c(mean(task_time[task_time$eventName == "TotalRender",7]),
                                         mean(task_time[task_time$eventName == "Render",7]),
                                         mean(task_time[task_time$eventName == "Uploading",7]),
                                         mean(task_time[task_time$eventName == "Tiling",7]),
                                         mean(task_time[task_time$eventName == "Saving Config",7])))

# add the hostname to task
task.x.y = task.x.y %>% 
  left_join((application.checkpoints %>% select(hostname,taskId) %>% distinct(taskId,.keep_all = TRUE)),
                       by='taskId')

task.x.y %>% filter(level==12)


