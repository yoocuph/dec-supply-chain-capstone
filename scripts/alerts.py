

def on_failure_callback(context):
    """
    Centralized failure alert function.
    """
    task_id = context['task_instance'].task_id
    execution_date = context['execution_date']
    error_msg = context.get('exception')
    
    print(f"🚨 ALERT: Task {task_id} failed!")
    print(f"Execution Date: {execution_date}")
    if error_msg:
        print(f"Error Detail: {error_msg}")
    
