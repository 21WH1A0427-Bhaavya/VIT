from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

def greet():
    print("Hello from Airflow 3.x DAG!")

def bye():
    print("Goodbye from Airflow DAG!")

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id='hello_dag',
    default_args=default_args,
    description='A simple hello DAG',
    start_date=datetime(2026, 1, 12, 0, 0),
    schedule="* * * * *",  # every minute
    catchup=False,
) as dag:

    task1 = PythonOperator(
        task_id='say_hello',
        python_callable=greet
    )

    task2 = PythonOperator(
        task_id='say_goodbye',
        python_callable=bye
    )

    task1 >> task2
