# Computing the task time

# add the hostname to task
task.x.y = task.x.y %>% 
  left_join((application.checkpoints %>% dplyr::select(hostname,taskId) %>% distinct(taskId,.keep_all = TRUE)),
            by='taskId')

# find the start and stop time and calculate the running duration
task_time = merge(application.checkpoints %>% 
                    filter(eventType == "STOP") %>%
                    select(timestamp,taskId,eventName,eventType),
                  application.checkpoints %>% 
                    filter(eventType == "START") %>%
                    select(timestamp,eventName,eventType,taskId), 
                  by = c("eventName","taskId"),
                  all = T)  %>% mutate(duration = as.numeric(timestamp.x)-as.numeric(timestamp.y))

# add the task gpu
task_time = task_time %>% left_join(task.x.y %>% select(taskId,hostname), by='taskId')

# mean running time of different event type
mean_task_time = data.frame(eventType = c("TotalRender","Render","Uploading","Tiling","Saving Config"),
                            duration = c(mean(task_time[task_time$eventName == "TotalRender",7]),
                                         mean(task_time[task_time$eventName == "Render",7]),
                                         mean(task_time[task_time$eventName == "Uploading",7]),
                                         mean(task_time[task_time$eventName == "Tiling",7]),
                                         mean(task_time[task_time$eventName == "Saving Config",7])))

task_time %>% filter(eventName=='Render')