from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    wait_time = between(1, 2)  # 用户在任务间等待 1 到 2 秒的随机时间

    @task
    def visit_register(self):
        self.client.get("https://uat.techscrumjr11.com/register", name="Visit Register Page")

    @task
    def visit_api_docs(self):
        self.client.get("https://uat-api.techscrumjr11.com/api-docs", name="Visit API Docs Page")

    @task
    def visit_api_root(self):
        self.client.get("https://uat-api.techscrumjr11.com/", name="Visit API Root")

    @task
    def visit_health_check(self):
        self.client.get("https://qa-api.techscrumjr11.com/api/v2/healthcheck", name="Visit Health Check")

# click  静态地址。  workload，  fargate。 request too many , 
#  

# from locust import HttpUser, task, between

# class QuickstartUser(HttpUser):
#     wait_time = between(5, 9)  # will make the simulated users wait between 5 and 9 seconds

#     @task
#     def view_registration_page_frontend(self):
#         self.client.get("https://uat.techscrumjr11.com/register")
 # data block就是一个 load .   
#     @task
#     def trigger_400_error(self):
#         header = {'content-type': 'application/json'}
#         data = {
#             "username": "",
#             "email": "mailformed-email",
#             "password": "",
#         }
#         # 注意：如果你想使用 header 和 data，你需要在 post 请求中包含它们
#         self.client.post("https://uat.techscrumjr11.com/register", headers=header, json=data)

#     @task
#     def trigger_500_error(self):
#         self.client.get("https://uat-api.techscrumjr11.com/api-docs/")

#     def on_start(self):
#         pass
