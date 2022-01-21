# computing gpu performance

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

task.x.y_duration = task.x.y %>% 
  left_join(task_time %>% filter(eventName == "TotalRender") %>% 
              select(taskId,duration),by="taskId")

# task_examples = task_time %>% 
#   filter(eventName == "TotalRender" & hostname == '4a79b6d2616049edbf06c6aa58ab426a000002') %>%
#   select(taskId,timestamp.x,timestamp.y,duration)

# gpu_task_part = gpu %>% 
#   filter(hostname == '4a79b6d2616049edbf06c6aa58ab426a000002') %>%
#   arrange(timestamp) %>% mutate(taskId="")
# 
# # find the task timestamp of gpu running
# for(i in 1:length(task_examples$taskId)){
#   gpu_task_part = gpu_task_part %>%
#   mutate(taskId=case_when(
#     timestamp<= task_examples[i,]$timestamp.x & timestamp>=task_examples[i,]$timestamp.y ~ task_examples[i,]$taskId,
#     TRUE ~ taskId)
#     )
# }
