# example of a gpu

# task running time example
task_examples = task_time %>% 
  filter(eventName == "TotalRender" & hostname == '8b6a0eebc87b4cb2b0539e81075191b900000D') %>%
  select(taskId,timestamp.x,timestamp.y,duration)

gpu_task_part = gpu %>% 
  filter(hostname == '8b6a0eebc87b4cb2b0539e81075191b900000D') %>%
  arrange(timestamp) %>% mutate(taskId="")

# find the task timestamp of gpu running
for(i in 1:length(task_examples$taskId)){
  gpu_task_part = gpu_task_part %>%
    mutate(taskId=case_when(
      timestamp<= task_examples[i,]$timestamp.x & timestamp>=task_examples[i,]$timestamp.y ~ task_examples[i,]$taskId,
      TRUE ~ taskId)
    ) 
}

# get the performance
gpu_task_part = gpu_task_part %>% filter(taskId != "") %>% group_by(taskId) %>%
  mutate(mean_powet = mean(powerDrawWatt),
         mean_temp = mean(gpuTempC),
         mean_gpuPerc = mean(gpuUtilPerc), # find the task duration
         mean_memory = mean(gpuMemUtilPerc)) %>% left_join(task_examples,by = "taskId")


gpu_task_part_average = gpu_task_part %>% 
  select(taskId,mean_powet,mean_temp,mean_gpuPerc,mean_memory,duration) %>% distinct()

  