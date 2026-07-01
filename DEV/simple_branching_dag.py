from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.empty import EmptyOperator
from datetime import datetime
import random


def choose_branch():
    return random.choice(["task_a", "task_b"])

def task_a():
    print("Running Task A")

def task_b():
    print("Running Task B")

with DAG(
    dag_id="simple_branching_dag",
    start_date=datetime(2026, 1, 19),
    schedule="@daily",
    catchup=False,
) as dag:

    start = EmptyOperator(task_id="start")

    branch = BranchPythonOperator(
        task_id="branch_decision",
        python_callable=choose_branch
    )

    task_a = PythonOperator(
        task_id="task_a",
        python_callable=task_a
    )

    task_b = PythonOperator(
        task_id="task_b",
        python_callable=task_b
    )

    end = EmptyOperator(
        task_id="end",
        trigger_rule="none_failed_min_one_success"
    )

    start >> branch
    branch >> [task_a, task_b]
    [task_a, task_b] >> end
