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

# add the hostname to task
task.x.y = task.x.y %>% 
  left_join((application.checkpoints %>% select(hostname,taskId) %>% distinct(taskId,.keep_all = TRUE)),
            by='taskId')

# find the start and stop time
task_time = merge(application.checkpoints %>% 
                        filter(eventType == "STOP") %>%
                        select(timestamp,taskId,eventName,eventType),
                      application.checkpoints %>% 
                        filter(eventType == "START") %>%
                        select(timestamp,eventName,eventType,taskId), 
                  by = c("eventName","taskId"),
                  all = T)
# calculate the running time
task_time = task_time %>% mutate(duration = as.numeric(timestamp.x)-as.numeric(timestamp.y))
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

# tasks of each gpu
gpu_tasks = data.frame(table(task.x.y$hostname)) %>% rename(hostname = Var1, tasks = Freq)

gpu_duration = gpu %>% group_by(hostname) %>% arrange(timestamp,.by_group = TRUE) %>%
  summarise(start_time = first(timestamp), end_time = last(timestamp))
# running time of gpu
gpu_duration = gpu_duration %>% mutate(duration = as.numeric(end_time)-as.numeric(start_time))

# task durations of each gpu 
gpu_performance = merge(gpu_duration, gpu_tasks,
                        by = c("hostname"),
                        all = T)
gpu_performance = gpu_performance %>% left_join( task_time %>% filter(eventName=='TotalRender') %>%
  group_by(hostname) %>%
  mutate(total_duration = sum(duration)) %>% 
  select(hostname,total_duration) %>% distinct()
  ,by='hostname')

gpu_performance = gpu_performance %>% mutate(each_task_duration = total_duration/tasks)

gpu_mean =  gpu %>% filter(gpuUtilPerc !=0 & gpuMemUtilPerc !=0) %>%
  group_by(hostname) %>% mutate(mean_powerDrawWatt = mean(powerDrawWatt),
                                mean_gpuTempC = mean(gpuTempC),
                                mean_gpuUtilPerc = mean(gpuUtilPerc),
                                mean_gpuMemUtilPerc = mean(gpuMemUtilPerc)) %>%
  select(hostname,gpuSerial,gpuUUID,mean_powerDrawWatt,mean_gpuTempC,mean_gpuUtilPerc,mean_gpuMemUtilPerc) %>%
  distinct(hostname,.keep_all = TRUE)

gpu_mean_idle = gpu %>% filter(gpuUtilPerc == 0 & gpuMemUtilPerc == 0) %>%
  group_by(hostname) %>% mutate(mean_powerDrawWatt = mean(powerDrawWatt),
                                mean_gpuTempC = mean(gpuTempC)) %>%
  select(hostname,gpuSerial,gpuUUID,mean_powerDrawWatt,mean_gpuTempC) %>%
  distinct(hostname,.keep_all = TRUE)
  
gpu_performance = gpu_performance %>% left_join(gpu_mean, by='hostname')

## an example of task and gpu information for this task
task_example = task_time %>% filter(taskId == "efad0c1e-213f-430b-9704-88e0cbffa6f8" & eventName == "TotalRender") %>%
  select(hostname,timestamp.x,timestamp.y)

gpu_task_example = gpu %>% 
  filter(hostname == task_example$hostname & 
           timestamp<= task_example$timestamp.x & timestamp>=task_example$timestamp.y) %>%
  arrange(timestamp)



